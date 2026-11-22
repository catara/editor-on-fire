# Editor on Fire (EOF) — Apple Silicon macOS Build & Rocksmith UI Fork

- **Authors:** gemini 3.1 & catara
- **Current Version:** `v0.1.1.20261122-1228` (`v0.1.<compilation_counter>.<compilation_timestamp>`)
- **Last Built:** 2026-11-22 12:28 CET
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

3. **Custom Rocksmith UI Toolbar Shortcuts (`src/editor.c`)**
   - **`Lead`**, **`Bass`**, **`Rhy`**, **`BonG`**, **`BonB`**, **`Voc`**: One-click switching across all 5 Rocksmith `REAL` string tracks + Vocals (no drum tracks).
   - **Dynamic Track Status Indicators**:
     - **Green:** Currently active track.
     - **Blue + `*` prefix:** Track contains charted notes/lyrics.
     - **Dark Gray:** Empty track.
     - **Arrangement & Flag Suffixes:** Automatically appends `:R` (Rhythm), `:L` (Lead), `:B` (Bonus), and `:A` (Alternate).
   - **`+Tone`**: Opens the Rocksmith *Add Tone Change* dialog at the current seek position.
   - **`Import`**: Context-aware import button — opens **Lyrics Import** when `Voc` is active, and **Guitar Pro (.gp5) Import** when any Guitar/Bass track is active.

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
