-- Resolve executables from Cargo's JSON build artifacts, not manifest text or
-- guessed target/debug paths. Cargo handles workspaces and custom target directories.
local M = {}

function M.program(root, tests)
  local dap = require("dap")

  -- nvim-dap accepts a coroutine for asynchronous configuration values. Resume its
  -- waiting run coroutine only after the build and optional target selection finish.
  return coroutine.create(function(dap_run_co)
    local function finish(value)
      local ok, err = coroutine.resume(dap_run_co, value)
      if not ok then
        vim.notify("Debug configuration failed: " .. tostring(err), vim.log.levels.ERROR)
      end
    end

    local function fail(message)
      vim.notify(message, vim.log.levels.ERROR)
      finish(dap.ABORT)
    end

    if vim.fn.executable("cargo") == 0 then
      fail("Cargo is not on PATH. Install Rust/Cargo before using Cargo debug profiles.")
      return
    end

    -- Argument lists preserve paths containing spaces without invoking a shell.
    local command = { "cargo", tests and "test" or "build" }
    command[#command + 1] = tests and "--no-run" or "--bins"
    vim.list_extend(command, { "--message-format=json", "--manifest-path", root .. "/Cargo.toml" })
    vim.notify("Building Cargo " .. (tests and "tests" or "binaries") .. "...", vim.log.levels.INFO)

    local ok, process = pcall(vim.system, command, { cwd = root, text = true }, vim.schedule_wrap(function(result)
      local artifacts, seen, diagnostics = {}, {}, {}
      for line in (result.stdout or ""):gmatch("[^\r\n]+") do
        -- Cargo/build scripts can also emit ordinary text; only decode JSON objects.
        if line:sub(1, 1) == "{" then
          local decoded, message = pcall(vim.json.decode, line)
          if not decoded then
            fail("Invalid JSON in Cargo build output:\n" .. line)
            return
          end
          if message.reason == "compiler-message" and message.message.level == "error" then
            diagnostics[#diagnostics + 1] = message.message.rendered or message.message.message
          elseif message.reason == "compiler-artifact"
            and type(message.executable) == "string"
            and message.profile.test == tests
            and (tests or vim.list_contains(message.target.kind, "bin"))
            and not seen[message.executable]
          then
            seen[message.executable] = true
            artifacts[#artifacts + 1] = {
              path = message.executable,
              label = message.target.name .. " [" .. table.concat(message.target.kind, ", ") .. "] - " .. message.executable,
            }
          end
        end
      end

      -- Do not debug stale binaries or fall back to a success-looking manual prompt.
      if result.code ~= 0 or result.signal ~= 0 then
        fail("Cargo build failed:\n" .. table.concat(diagnostics, "\n") .. "\n" .. (result.stderr or ""))
      elseif #artifacts == 0 then
        fail("Cargo produced no runnable " .. (tests and "test executables" or "binaries") .. ".")
      elseif #artifacts == 1 then
        finish(artifacts[1].path)
      else
        table.sort(artifacts, function(a, b)
          return a.label < b.label
        end)
        vim.ui.select(artifacts, {
          prompt = tests and "Select Cargo test executable:" or "Select Cargo binary:",
          format_item = function(item)
            return item.label
          end,
        }, function(choice)
          -- Cancelling the picker intentionally aborts the debug launch.
          finish(choice and choice.path or dap.ABORT)
        end)
      end
    end))

    -- Spawning can fail before the asynchronous callback (for example if cwd vanished).
    if not ok then
      fail("Could not start Cargo: " .. tostring(process))
    end
  end)
end

return M
