# Editor on Fire (EOF) — Apple Silicon macOS Build & Rocksmith UI Fork

- **Authors:** gemini 3.1 & catara
- **Fork Repository:** `https://github.com` (forked from `raynebc/editor-on-fire` `rc16`)
- **Current Version:** `v0.1.10.20261125-2144` (`v0.1.<compilation_counter>.<compilation_timestamp>`)
- **Last Updated:** 2026-11-25 20:26 CET
- **Target Platform:** Apple Silicon Macs (M1/M2/M3/M4+) running **macOS 27.2.x** (plus portable `linux/amd64` Docker + XQuartz build)
- **Dependencies:** `NewCreature/Allegro-Legacy` + `Allegro 5` + `alogg` + `dylibbundler`

---

## Implemented Features & Architecture

1. **Native Apple Silicon (`arm64`) Cocoa/Aqua Build (`build_eof_cocoa.sh` -> `~/Desktop/EOF-Cocoa.app`)**
   - Compiles upstream `raynebc/editor-on-fire` (`rc16`) natively for Apple Silicon using `Allegro-Legacy` + `Allegro 5` (bypassing deprecated OS X 10.6 QuickTime/QuickDraw APIs).
   - Native macOS top menu bar, Retina-capable OpenGL window, and CoreAudio/OpenAL sound.
   - Self-contained `.app` bundle: embeds `.dylib` dependencies via `dylibbundler`, bundles `lame`, `oggenc`, `oggCat`, `rocksmith.panel.txt`, and `eof.cfg`, and signs cleanly for macOS Gatekeeper.
   - **Preference Persistence:** Automatically backs up `Contents/Resources/eof/eof.cfg` to `~/Library/Application Support/EOF/eof.cfg` before rebuilding and restores it afterward.

2. **Linux/XQuartz Docker Build (`build_eof_xquartz.sh` -> `~/Desktop/EOF-XQuartz.app`)**
   - Builds the upstream `makefile.linux` target inside a `debian:bookworm-slim` (`linux/amd64`) container via OrbStack/Docker, routing display to **XQuartz** and audio to **PulseAudio** over TCP.

3. **Single-Row Full-Height 15-Button Rocksmith & Editing Toolbar (`src/editor.c`, `y = 3..21`)**
   - **6 Track Switcher Buttons (`Lead`, `Bass`, `Rhy`, `BonG`, `BonB`, `Voc`):**
     - **Green:** Currently active track.
     - **Blue + `*` prefix:** Track contains charted notes or lyrics.
     - **Dark Gray:** Empty track.
     - **Dynamic Arrangement & Flag Tags:** Automatically appends `:R` (Rhythm), `:L` (Lead), `:B` (Bonus), and `:A` (Alternate).
   - **9 Action Shortcut Buttons (`+Tone`, `+Sect`, `FHP`, `Rest`, `Prev`, `Rate`, `Swap`, `Props`, `Imp`):**
     - **`+Tone`:** Add Rocksmith tone change (`eof_track_rs_tone_change_add`).
     - **`+Sect`:** Add Rocksmith section marker (`eof_rocksmith_section_dialog_add`).
     - **`FHP`:** List/edit Fret Hand Positions (`eof_track_fret_hand_positions`).
     - **`Rest` / `Prev`:** Select rest of notes (`eof_menu_edit_select_rest`) or previous notes (`eof_menu_edit_select_previous`).
     - **`Rate`:** Set custom playback speed (`eof_menu_edit_playback_custom`).
     - **`Swap`:** Swap main and secondary piano rolls (`eof_menu_song_swap_piano_rolls`).
     - **`Props`:** Open Song Properties (`eof_menu_song_properties`).
     - **`Imp`:** Context-aware import — opens **Lyrics Import** when `Voc` is active, and **Guitar Pro (.gp5) Import** on Guitar/Bass tracks.

4. **CDLC / Fork Metadata Dialog (`Song > Properties > CDLC Meta...`, `src/menu/song.c`)**
   - Adds a **`CDLC Meta...`** button inside Song Properties opening a 29-field dialog saved to `<song_folder>/cdlc_meta.ini`:
     - **18 Text Fields (each with a macOS `pbpaste` `Paste` button):** `Version`, `CDLCID`, `txt_EoFPath`, `YBLink`, `BasedOnYB`, `BasedOnCF`, `BaseOnRB`, `BasedOn_GP`, `TabLinks`, `Spotify`, `Description`, `toDo`, `ToneDetails`, `SaveRemotelyPath`, `PackageDate`, `UpdateDate`, `PackageDetails`, `CF_Author`.
     - **8 Checkboxes:** `SaveInVerisonInfo`, `SaveInDB`, `SaveRemotely`, `Has_Slide`, `Has_Acoustic`, `NOTProductionReady`, `Has_AIUsedForGeneration`, `Is_AIFullyGenerated`.
     - **3 Auto-Synced Fields:** `Songtitle`, `Artist`, and `Album` sync automatically from Song Properties.

5. **Smart Startup & macOS Menu Stability (`src/main.c`, `src/menu/native.h`, `src/menu/native.c`, `src/menu/help.c`)**
   - **Auto-Load Last Project:** Saves the active `.eof` path to `~/Library/Application Support/EOF/last_song.txt` on exit and re-opens it automatically on next launch if no CLI argument is passed.
   - **Default Track & Difficulty:** Initializes startup into **`PART REAL_BASS`** (`EOF_TRACK_REAL_BASS`) on the **1st difficulty (`0`)**.
   - **Native Menu Crash Fix:** Increased `EOF_MAX_NATIVE_MENUS` (`256` -> `1024`) and `EOF_MAX_MENU_ITEMS` (`1024` -> `8192`), zero-initialized `a4_menu_item_data` with `calloc`, and added bounds/`NULL` guards to prevent `SIGBUS` heap overflows on startup and menu clicks.
   - **Fork Attribution in `Help > About`:** Displays `Forked from raynebc/editor-on-fire main as of 2026-11-25 (Catara's fork v0.1.4)` alongside upstream version and copyright strings.

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

## Version Control & Fork Sync (`catara/editor-on-fire`)

- **Remotes:**
  - `origin` -> `https://github.com.git` (your fork)
  - `upstream` -> `https://github.com` (upstream `rc16`)
- **Automated Version Tracking:**
  - `.build_counter` (local untracked counter `y`) increments automatically every time `build_eof_cocoa.sh` or `build_eof_xquartz.sh` runs.
  - Both scripts update `v0.1.<y>.<YYYYMMDD-HHMM>` in `README_MACOS_BUILD.md` and `src/menu/help.c` (`Help > About`).
- **Source Code Attribution:**
  - All custom modifications in `src/editor.c`, `src/main.c`, `src/menu/help.c`, `src/menu/native.h`, `src/menu/native.c`, `src/menu/song.c`, `build_eof_cocoa.sh`, and `build_eof_xquartz.sh` are bracketed with `// [BEGIN gemini&catara | <timestamp>]` and `// [END gemini&catara | <timestamp>]`.
- **Pulling Upstream Updates Cleanly (Preserving CRLF Line Endings):**
  ```bash
  cd ~/editor-on-fire
  git fetch upstream
  git -c core.autocrlf=false rebase upstream/master
  git push --force-with-lease origin master
  ```

---

## Build Changelog

| Version | Timestamp | Target | Notes |
| :--- | :--- | :--- | :--- |
| `v0.1.1.20261122-1228` | 2026-11-22 12:28 CET | `arm64` Cocoa & `amd64` XQuartz | Initial macOS ARM64 Cocoa and Linux XQuartz build scripts with 8-button Rocksmith toolbar (`Lead`, `Bass`, `Rhy`, `BonG`, `BonB`, `Voc`, `+Tone`, `Import`) and content/arrangement indicators. |
| `v0.1.2.20261122-1404` | 2026-11-22 14:04 CET | `arm64` Cocoa | Fixed `SIGBUS` startup/menu crash by raising `EOF_MAX_MENU_ITEMS` (`1024` -> `8192`) with `calloc` + bounds checks; added fork info to `Help > About`. |
| `v0.1.3.20261124-1532` | 2026-11-24 15:32 CET | `arm64` Cocoa | Added 29-field `CDLC Meta...` dialog (`BasedOn*` as text boxes + macOS `pbpaste` `Paste` buttons), `eof.cfg` persistence, auto-reload last song, and `PART REAL_BASS` + 1st difficulty startup. |
| `v0.1.4.20261125-2026` | 2026-11-25 20:26 CET | `arm64` Cocoa | Finalized single-row full-height 15-button toolbar (`y=3..21`: `Lead`, `Bass`, `Rhy`, `BonG`, `BonB`, `Voc`, `+Tone`, `+Sect`, `FHP`, `Rest`, `Prev`, `Rate`, `Swap`, `Props`, `Imp`), synced upstream `raynebc/editor-on-fire:master`, and updated documentation. |
| `v0.1.5.20261125-2034` | 2026-11-25 20:34 | Automated build | Compiled via build script |
| `v0.1.6.20261125-2038` | 2026-11-25 20:38 | Automated build | Compiled via build script |
| `v0.1.7.20261125-2042` | 2026-11-25 20:42 | Automated build | Compiled via build script |
| `v0.1.8.20261125-2139` | 2026-11-25 21:39 | Automated build | Compiled via build script |
| `v0.1.9.20261125-2142` | 2026-11-25 21:42 | Automated build | Compiled via build script |
| `v0.1.10.20261125-2144` | 2026-11-25 21:44 | Automated build | Compiled via build script |
