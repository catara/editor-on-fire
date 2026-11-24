# Editor on Fire (EOF) — Apple Silicon macOS Build & Rocksmith UI Fork

- **Authors:** gemini 3.1 & catara
- **Current Version:** `v0.1.1.20261124-1541` (`v0.1.<compilation_counter>.<compilation_timestamp>`)
- **Last Built:** 2026-11-24 15:41 CET
- **Target Platform:** Apple Silicon Macs (M1/M2/M3/M4+) running **macOS 27.2.x** (plus portable `linux/amd64` Docker + XQuartz build)
- **Upstream Base:** `raynebc/editor-on-fire` (`rc16`) + `NewCreature/Allegro-Legacy` + `Allegro 5`

---

## What This Fork Provides

1. **Native Apple Silicon (`arm64`) Cocoa/Aqua Build (`build_eof_cocoa.sh` -> `~/Desktop/EOF-Cocoa.app`)**
   - Compiles upstream `rc16` natively for Apple Silicon using `Allegro-Legacy` + `Allegro 5` (bypassing deprecated OS X 10.6 QuickTime/QuickDraw APIs).
   - Native macOS top menu bar, Retina-capable OpenGL window, and crackle-free CoreAudio/OpenAL sound.
   - Self-contained bundle: embeds all `.dylib` dependencies via `dylibbundler`, includes `lame`, `oggenc`, `oggCat`, `rocksmith.panel.txt`, and `eof.cfg`, and signs cleanly for macOS Gatekeeper.

2. **Linux/XQuartz Docker Build (`build_eof_xquartz.sh` -> `~/Desktop/EOF-XQuartz.app`)**
   - Builds the upstream `makefile.linux` target inside a `debian:bookworm-slim` (`linux/amd64`) container via OrbStack/Docker, routing display to **XQuartz** and audio to **PulseAudio** over TCP.

3. **Custom Rocksmith UI Toolbar & Workflow Enhancements (`src/editor.c`, `src/main.c`, `src/menu/song.c`, `src/menu/help.c`, `src/menu/native.c`)**
   - **Row 1 Track Switcher (`Lead`, `Bass`, `Rhy`, `BonG`, `BonB`, `Voc`):** One-click switching with active green highlight, blue `*` content indicator, and `:R`/`:L`/`:B`/`:A` arrangement/flag tags.
   - **Row 2 Action Toolbar (`+Tone`, `+Sect`, `FHP`, `SelRest`, `SelPrev`, `Rate`, `SwapPR`, `Props`, `Import`):** Positioned strictly above the timeline (`y=15..27`) for one-click Tone Change, Rocksmith Section, List Fret Hand Positions, Select Rest/Previous Notes, Custom Playback Rate, Swap Main Piano Roll, Song Properties, and context-aware GP5/Lyrics Import.
   - **CDLC / Fork Metadata Dialog (`Song > Properties > CDLC Meta...`):** 29 fields (18 text inputs with macOS clipboard `Paste` buttons + 8 checkboxes + synced `Songtitle`, `Artist`, `Album`) persisted automatically to `<song_folder>/cdlc_meta.ini`.
   - **Smart Startup & Preference Persistence:** Automatically persists `eof.cfg` across rebuilds (`~/Library/Application Support/EOF/eof.cfg`), auto-reloads the last opened `.eof` project, and defaults to `PART REAL_BASS` on the 1st difficulty.
   - **macOS Native Menu Stability & About Dialog:** Increased `EOF_MAX_MENU_ITEMS` (`1024` -> `8192`) with bounds/null guards in `src/menu/native.c` and added `Catara's fork` version & upstream base details in `Help > About`.
---

## How to Compile

### Option A: Native macOS Cocoa/Aqua (`arm64`)
```bash
sh ~/editor-on-fire/build_eof_cocoa.sh
open ~/Desktop/EOF-Cocoa.app
```

### Option B: Linux Container via XQuartz + PulseAudio
```bash
sh ~/editor-on-fire/build_eof_xquartz.sh
open ~/Desktop/EOF-XQuartz.app
```

---

## Build Changelog

| Version | Timestamp | Target | Notes |
| :--- | :--- | :--- | :--- |
| `v0.1.1.20261122-1228` | 2026-11-22 12:28 CET | `arm64` Cocoa & `amd64` XQuartz | Initial version-tracked release with 8-button Rocksmith toolbar (`Lead`, `Bass`, `Rhy`, `BonG`, `BonB`, `Voc`, `+Tone`, `Import`), content indicators, and automated build scripts. |
| `v0.1.1.20261124-1541` | 2026-11-24 15:41 CET | `arm64` Cocoa | Added 15-button 2-row toolbar (`FHP`, `SwapPR`, `Props`), 29-field `CDLC Meta...` dialog w/ `Paste`, `eof.cfg` persistence, auto-reload last song & `PART REAL_BASS` startup |
