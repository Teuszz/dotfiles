# Neovim-Cheatsheet

Passend zur Neovim-Konfiguration dieses Repositories (Neovim 0.12+).

[English version](CHEATSHEET.en.md)

**Notation:** `Space ff` bedeutet Leertaste, dann `f`, dann `f` drücken.
`Ctrl+w h` bedeutet zuerst `Ctrl+w`, dann `h`; `Alt+t` wird gleichzeitig
gedrückt. Befehle mit `:` mit `Enter` bestätigen.
Sofern nicht anders angegeben, gelten Tasten im **Normalmodus**.

## 1. Grundlegende Neovim-Bedienung

### Modi und Dateien

| Taste / Befehl | Wirkung |
| --- | --- |
| `Esc` | Zurück in den Normalmodus |
| `i` / `a` | Vor / hinter dem Cursor schreiben |
| `I` / `A` | Am ersten Nicht-Leerzeichen / am Zeilenende schreiben |
| `o` / `O` | Neue Zeile unterhalb / oberhalb öffnen und schreiben |
| `v` / `V` / `Ctrl+v` | Zeichen / ganze Zeilen / rechteckigen Block auswählen |
| `:` | Befehlszeile öffnen |
| `:e pfad/datei` | Datei öffnen |
| `:w` / `:wa` | Aktuelle / alle geänderten Dateien speichern |
| `:q` / `:wq` | Fenster schließen / speichern und Fenster schließen |
| `:qa` / `:wqa` | Neovim beenden / alles speichern und beenden |
| `:q!` / `:qa!` | Fenster / Neovim ohne Speichern schließen; Änderungen gehen verloren |

### Bewegung

| Taste | Wirkung |
| --- | --- |
| `h` / `j` / `k` / `l` | Links / unten / oben / rechts |
| `w` / `b` / `e` | Nächster Wortanfang / vorheriger Wortanfang / Wortende |
| `0` / `^` / `$` | Zeilenanfang / erstes Nicht-Leerzeichen / Zeilenende |
| `gg` / `G` / `42G` | Dateianfang / Dateiende / Zeile 42 |
| `5j` / `5k` | Fünf Zeilen nach unten / oben; Zahlen lassen sich mit Bewegungen kombinieren |
| `Ctrl+d` / `Ctrl+u` | Halbe Bildschirmseite nach unten / oben |
| `zz` | Cursorzeile im Fenster zentrieren |
| `fX` / `tX` | Zum nächsten Zeichen `X` / bis unmittelbar davor springen |
| `;` / `,` | Letzte `f`-/`t`-Suche wiederholen / in Gegenrichtung wiederholen |
| `%` | Zur passenden Klammer springen |
| `Ctrl+o` / `Ctrl+i` | In der Sprunghistorie zurück / vor |

### Bearbeiten, kopieren und einrücken

| Taste | Wirkung |
| --- | --- |
| `u` / `Ctrl+r` | Rückgängig / wiederherstellen |
| `.` | Letzte Textänderung wiederholen |
| `x` / `dd` / `D` | Zeichen / Zeile / bis zum Zeilenende löschen |
| `yy` / `p` / `P` | Zeile kopieren / hinter bzw. unter / vor bzw. über dem Cursor einfügen |
| `dw` / `cw` | Bis zum nächsten Wortanfang löschen / ändern und schreiben |
| `ciw` / `diw` / `yiw` | Wort unter dem Cursor ändern / löschen / kopieren |
| `ci"` / `ci(` | Inhalt innerhalb von Anführungszeichen / runden Klammern ändern |
| `d` / `y` / `c` im Visualmodus | Auswahl löschen / kopieren / ändern |
| `>>` / `<<` | Zeile einrücken / ausrücken |
| `>` / `<` im Visualmodus | Auswahl einrücken / ausrücken |
| `==` / `gg=G` | Zeile / gesamte Datei nach den Einrückungsregeln einrücken |
| `J` | Aktuelle und nächste Zeile verbinden |
| `"+y` im Visualmodus / `"+p` | In die Systemzwischenablage kopieren / daraus einfügen, sofern ein Clipboard-Provider verfügbar ist |

**Merksatz:** Operator + Bewegung bzw. Textobjekt, z. B. `d$` (bis Zeilenende
löschen), `yap` (Absatz mit angrenzenden Leerzeilen kopieren), `3dd` (drei Zeilen
löschen). Löschen legt Text normalerweise ebenfalls in einem Register ab.
`gg=G` ist Einrücken, kein vollständiges LSP-Formatieren.

### Suchen und ersetzen

| Taste / Befehl | Wirkung |
| --- | --- |
| `/text` / `?text` | Vorwärts / rückwärts in der aktuellen Datei suchen |
| `n` / `N` | Nächster / vorheriger Treffer in Bezug auf die Suchrichtung |
| `*` / `#` | Wort unter dem Cursor vorwärts / rückwärts suchen |
| `:noh` | Suchhervorhebung bis zur nächsten Suche ausblenden |
| `:%s/alt/neu/gc` | In der ganzen Datei ersetzen; jeden Treffer bestätigen |
| `:'<,'>s/alt/neu/gc` | Nur in den ausgewählten Zeilen ersetzen; nach einer visuellen Auswahl setzt `:` den Bereich automatisch |

Such- und Ersetzungsmuster sind reguläre Ausdrücke, kein reiner Klartext.

### Fenster, Buffer und Hilfe

Ein **Buffer** enthält eine geöffnete Datei, ein **Fenster** zeigt einen Buffer.
Eine Neovim-**Tabpage** enthält ein Fensterlayout, nicht bloß eine Datei.

| Taste / Befehl | Wirkung |
| --- | --- |
| `:split` / `:vsplit` | Fenster horizontal / vertikal teilen |
| `Ctrl+w h/j/k/l` | In das Fenster links / unten / oben / rechts wechseln |
| `Ctrl+w w` | Zum nächsten Fenster wechseln |
| `Ctrl+w =` | Fenstergrößen ausgleichen |
| `Ctrl+w c` / `Ctrl+w o` | Aktuelles Fenster / alle anderen Fenster schließen |
| `:ls` | Buffer mit ihren internen IDs auflisten |
| `:bn` / `:bp` / `:b 3` | Nächster / vorheriger Buffer / Buffer mit ID 3 |
| `:bd` | Aktuellen Buffer schließen; ungespeicherte Änderungen verhindern dies |
| `:tabnew` / `gt` / `gT` | Neue Tabpage / nächste / vorherige Tabpage |
| `:pwd` / `:cd pfad` | Arbeitsverzeichnis anzeigen / ändern |
| `:help thema` | Hilfe öffnen, z. B. `:help motion` oder `:help registers` |

## 2. Bedienung deiner Plugins und Konfiguration

### Start und Orientierung

- `nvim`: Alpha-Dashboard mit zuletzt geöffneten Dateien; dort die angezeigten
  Kürzel verwenden.
- `nvim datei.rs`: Datei direkt bearbeiten, ohne Explorer-Fokus.
- `nvim pfad/zum/projekt`: Neo-tree für diesen Ordner öffnen. Das
  Arbeitsverzeichnis wird dabei **nicht** geändert. Für projektweite Suchen
  am besten vorher im Shell-Terminal in das Projekt wechseln.
- Leader ist **Space**, Localleader ist `\`. Relative Zeilennummern helfen bei
  Sprüngen wie `7j`; die Cursorzeile zeigt ihre absolute Nummer.
- Tabulator-Eingaben werden zu Leerzeichen; Einrückungsbreite ist zwei.
  Treesitter liefert für konfigurierte Sprachen Syntaxhervorhebung und Einrückung.

### Dateien suchen und zwischen Buffern wechseln

| Taste / Befehl | Wirkung |
| --- | --- |
| `Space ff` | Telescope: Dateien im aktuellen Arbeitsverzeichnis suchen |
| `Space fg` | Telescope: Dateiinhalte durchsuchen; benötigt `ripgrep` (`rg`) |
| `Space n` | Neo-tree links öffnen/fokussieren und aktuelle Datei zeigen; **kein Toggle** |
| `Space 1` … `Space 9` | Buffer nach Position in der Bufferline öffnen |
| `Space $` | Letzten Buffer in der Bufferline öffnen |
| `:Neotree close` | Explorer schließen |
| `:Telescope buffers` | Offene Buffer mit Telescope auswählen |

Die Nummern der Bufferline sind **Positionen**, nicht die internen IDs aus `:ls`.
Die Leiste zeigt Buffer, keine Tabpages.

**Telescope-Standardbedienung:** Suchtext tippen, mit `Ctrl+n` / `Ctrl+p`
auswählen, mit `Enter` öffnen. `Ctrl+x` / `Ctrl+v` / `Ctrl+t` öffnen im
horizontalen Split / vertikalen Split / einer Tabpage. `Esc` wechselt aus dem
Eingabemodus, ein weiteres `Esc` schließt den Picker.

**Neo-tree-Standardbedienung im Explorer:** `j` / `k` navigieren; `Enter` öffnet
Dateien oder klappt Ordner um. `a` legt eine Datei an (Name mit abschließendem
`/` für einen Ordner), `r` benennt um, `d` löscht mit Bestätigung, `?` zeigt
die verfügbaren Kürzel.

### Sprachfunktionen und Diagnosen

Konfigurierte Language Server: **Lua**, **C/C++** und **Rust**. Die eigenen
LSP-Kürzel gelten nur, wenn ein Server am aktuellen Buffer hängt.

| Taste / Befehl | Wirkung |
| --- | --- |
| `K` | Dokumentation zum Symbol anzeigen |
| `gd` / `gD` | Zur Definition / Deklaration springen |
| `gi` | Zur Implementierung springen |
| `Space ca` | Code-Aktion auswählen; auch für visuell ausgewählten Code |
| `Space cf` | Gesamten Buffer mit einem LSP-Formatter formatieren |
| `grn` / `grr` | Neovim-LSP-Standard: Symbol umbenennen / Referenzen auflisten |
| `[d` / `]d` | Neovim-Standard: vorherige / nächste Diagnose |
| `Ctrl+w d` | Neovim-Standard: Diagnose unter dem Cursor anzeigen |
| `:Mason` | Installierte Sprachserver und Werkzeuge verwalten |
| `:checkhealth vim.lsp` | LSP-Installation prüfen |

**Kein Format-on-save:** `:w` formatiert nicht. Bei mehreren Formatierern bietet
`Space cf` eine Auswahl; ohne passenden Formatter erscheint eine Warnung.
Rust-Formatierung benötigt in der Regel `rustfmt`.

### Vervollständigung und Snippets

Die folgenden Kürzel gelten im **Insertmodus**, Snippet-Sprünge zusätzlich im
Selectmodus. Vorschläge stammen aus LSP, LuaSnip oder Wörtern im aktuellen Buffer.

| Taste | Wirkung |
| --- | --- |
| `Ctrl+Space` | Vervollständigung anfordern |
| `Ctrl+n` / `Ctrl+p` | Nächsten / vorherigen Vorschlag auswählen |
| `Enter` | Ausgewählten Vorschlag übernehmen; ohne Auswahl den ersten |
| `Ctrl+e` | Vervollständigungsmenü abbrechen |
| `Ctrl+b` / `Ctrl+f` | Dokumentation des Vorschlags nach oben / unten scrollen |
| `Ctrl+l` / `Ctrl+h` | Zum nächsten / vorherigen Snippet-Platzhalter springen |

Außerhalb eines aktiven Snippets behalten `Ctrl+l` / `Ctrl+h` ihre normale
Wirkung. `Tab` ist hier weder ein eigenes Snippet-Sprungkürzel noch eine
Copilot-Annahmetaste.

### GitHub Copilot

Copilot ist nur aktiv, wenn die lokale, Git-ignorierte
`copilot-local.lua` im Konfigurationsordner `return "community"` oder
`return "official"` enthält. **Ohne Auswahl ist Copilot deaktiviert.**
Details zu Einrichtung und Anmeldung stehen in der [README](../README.md#github-copilot).

**Inline-Vorschläge, beide Varianten, im Insertmodus:**

| Taste / Befehl | Wirkung |
| --- | --- |
| `Alt+l` | Grauen Inline-Vorschlag übernehmen |
| `Alt+]` / `Alt+[` | Nächsten / vorherigen Inline-Vorschlag anzeigen |
| `Ctrl+]` | Inline-Vorschlag verwerfen |
| `:Copilot status` | Status prüfen |
| `:Copilot disable` / `:Copilot enable` | Inline-Copilot deaktivieren / aktivieren |

Inline-Vorschläge werden verborgen, solange das Vervollständigungsmenü offen
ist. **`Alt+l` übernimmt Copilot; `Ctrl+l` springt im Snippet.**
Automatische Vorschläge senden beim Tippen Codekontext. Dateitypfilter sind kein
Schutz für vertrauliche Inhalte.

**Chat, nur mit `community`:**

| Taste / Befehl | Wirkung |
| --- | --- |
| `Space ac` | Chat öffnen/schließen; auch aus dem Visualmodus |
| `Space ap` / `Space am` | Prompt / verfügbares Modell auswählen |
| `Ctrl+s` im Chat-Insertmodus / `Enter` im Chat-Normalmodus | Frage absenden |
| `Ctrl+y` im Chat | Vorgeschlagenen Diff anwenden; vorher prüfen |
| `:CopilotChatStop` | Laufende Antwort stoppen |
| `:CopilotChatReset` | Chatverlauf zurücksetzen; keine Abmeldung |

Antwortsprache ist Deutsch. Standard-Codekontext ist die **letzte visuelle
Auswahl** im Quellbuffer, nicht automatisch die ganze Datei. Auswahl vor dem
Absenden prüfen; mit `#buffer` / `#file` lässt sich Kontext ausdrücklich
ergänzen (`Tab` vervollständigt). Chat öffnen allein sendet keine Frage.
`:Copilot disable` deaktiviert Inline-Vorschläge, **nicht** den Chat.

### Debugging mit nvim-dap

| Taste / Befehl | Wirkung |
| --- | --- |
| `Space b` | Breakpoint in der aktuellen Zeile setzen/entfernen |
| `F5` | Debugprofil auswählen und starten / Ausführung fortsetzen |
| `F10` | Nächste Anweisung; Funktionsaufrufe überspringen |
| `F11` | In einen Funktionsaufruf hineinspringen |
| `F12` | Aktuelle Funktion verlassen |
| `:lua require("dap").terminate()` | Debugsitzung beenden |
| `:checkhealth dap` | Debugger-Voraussetzungen prüfen |

Benötigt **GDB 14+ mit Python/DAP-Unterstützung** auf `PATH`; GDB wird hier nicht
von Mason installiert. Die Debug-UI öffnet und schließt sich mit der Sitzung.

- **Rust:** `Debug Cargo Project` baut ausführbare Programme;
  `Debug Cargo Test` baut Testprogramme und startet das ausgewählte unter GDB.
  Cargo muss installiert sein. Bei mehreren Zielen erscheint eine Auswahl.
- **Rust/C/C++:** Profile für eigene Binärdateien, Prozess-Attach und
  `gdbserver` auf `localhost:1234`; eigene Binärdateien mit Debugsymbolen bauen.
- Cargo-Programmargumente und `KEY=value`-Umgebungswerte werden durch Leerzeichen
  getrennt eingegeben; Shell-Quoting und Leerzeichen innerhalb einzelner Werte
  werden nicht unterstützt.

### Integriertes Terminal

| Taste / Befehl | Wirkung |
| --- | --- |
| `Alt+t` im Normal- oder Terminalmodus | Terminal unten ein-/ausblenden (15 Zeilen) |
| `Esc` im Terminal | Terminal-Normalmodus; Shell läuft weiter |
| `i` im Terminal-Normalmodus | Wieder Eingaben an die Shell senden |
| `Ctrl+w k` nach `Esc` | Zum Editorfenster oberhalb wechseln |
| `:bdelete!` im Terminal-Normalmodus | Terminalbuffer verwerfen; nächstes `Alt+t` startet eine neue Shell |

Ausblenden erhält Shellprozess, Arbeitsverzeichnis und Ausgabe. `Esc` wird
nicht an Terminalprogramme weitergereicht. `:bdelete!` kann einen noch laufenden
Terminaljob beenden.

### Plugins verwalten und Probleme prüfen

| Befehl | Wirkung |
| --- | --- |
| `:Lazy` | Pluginverwaltung öffnen |
| `:Lazy restore` | Pluginstände aus der Lockdatei wiederherstellen |
| `:Lazy update` | Plugins aktualisieren; verändert die Lockdatei |
| `:Lazy profile` | Ladezeiten der Plugins ansehen |
| `:TSUpdate` | Treesitter-Parser aktualisieren |
| `:checkhealth` | Installation und externe Voraussetzungen prüfen |
| `:messages` | Meldungen und Fehler nachlesen |

Telescope ist auf Tag `0.1.8` festgelegt: `:Lazy update` hebt diese
Versionsvorgabe nicht auf. Nach Pluginupdates Neovim neu starten.
