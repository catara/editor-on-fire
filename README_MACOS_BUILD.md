# Editor on Fire (EOF) — Apple Silicon macOS Build & Rocksmith UI Fork

- **Authors:** gemini 3.1 & catara
- **Fork Repository:** `https://github.com` (forked from `raynebc/editor-on-fire` `rc16`)
- **Current Version:** `v0.1.20.20261125-2244` (`v0.1.<compilation_counter>.<compilation_timestamp>`)
- **Last Updated:** 2026-11-25 22:22 CET
- **Target Platform:** Apple Silicon Macs (M1/M2/M3/M4+) running **macOS 27.2.x** (plus portable `linux/amd64` Docker + XQuartz build)
- **Dependencies:** `NewCreature/Allegro-Legacy` + `Allegro 5` + `alogg` + `dylibbundler`

---

## Quality-of-Life (QoL) Improvements

1. **Single-Row Full-Height 15-Button Rocksmith & Editing Toolbar (`src/editor.c`, `y = 3..21`)**
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

2. **CDLC / Fork Metadata Dialog (`Song > Properties > CDLC Meta...`, `src/menu/song.c`)**
   - Adds a **`CDLC Meta...`** button inside Song Properties opening a 29-field dialog saved to `<song_folder>/cdlc_meta.ini` (alongside all 16 standard `[SongProperties]` keys, writing every key unconditionally even when empty):
     - **18 Text Fields (each with a macOS `pbpaste` `Paste` button):** `Version`, `CDLCID`, `txt_EoFPath`, `YBLink`, `BasedOnYB`, `BasedOnCF`, `BaseOnRB`, `BasedOn_GP`, `TabLinks`, `Spotify`, `Description`, `toDo`, `ToneDetails`, `SaveRemotelyPath`, `PackageDate`, `UpdateDate`, `PackageDetails`, `CF_Author`.
     - **8 Checkboxes:** `SaveInVerisonInfo`, `SaveInDB`, `SaveRemotely`, `Has_Slide`, `Has_Acoustic`, `NOTProductionReady`, `Has_AIUsedForGeneration`, `Is_AIFullyGenerated`.
     - **3 Auto-Synced Fields:** `Songtitle`, `Artist`, and `Album` sync automatically from Song Properties on Save/OK.
     - **Sidecar File Design (`<song_folder>/cdlc_meta.ini`):** Creates a dedicated `cdlc_meta.ini` sidecar file in the active song folder rather than altering EOF's strict binary `.eof` format, ensuring 100% compatibility with upstream EOF, Rocksmith Toolkit, and DLC Builder.

3. **Smart Startup & Preference Persistence (`src/main.c`, `build_eof_cocoa.sh`)**
   - **Auto-Load Last Project:** Saves the active `.eof` path to `~/Library/Application Support/EOF/last_song.txt` on exit and re-opens it automatically on next launch if no CLI argument is passed.
   - **Default Track & Difficulty:** Initializes startup into **`PART REAL_BASS`** (`EOF_TRACK_REAL_BASS`) on the **1st difficulty (`0`)**.
   - **Persistent `eof.cfg`:** Automatically backs up `Contents/Resources/eof/eof.cfg` to `~/Library/Application Support/EOF/eof.cfg` before rebuilding and restores it afterward.

4. **Fork Attribution in `Help > About` (`src/menu/help.c`)**
   - Displays `Forked from raynebc/editor-on-fire main as of <YYYY-MM-DD> (Catara's fork v0.1.<counter>)` alongside upstream version and copyright strings.

---

## macOS Functional & Stability Fixes

1. **Native macOS Menu Heap Overflow & `SIGBUS` Crash Fix (`src/menu/native.h`, `src/menu/native.c`)**
   - Upstream `EOF_MAX_MENU_ITEMS` (`1024`) overflowed on startup in `rc16` + Rocksmith Focus submenus, corrupting heap pointers and causing random `SIGBUS` crashes on launch and menu clicks.
   - Raised `EOF_MAX_NATIVE_MENUS` (`256` -> `1024`) and `EOF_MAX_MENU_ITEMS` (`1024` -> `8192`), zero-initialized `a4_menu_item_data` with `calloc`, and added bounds/`NULL` guards to `index_a4_menu_item`, `update_native_menu`, `call_menu_proc`, and `eof_handle_native_menu_clicks`.

2. **Transport Controls Fix (`Play`, `Seek Start`, `Seek End`) on macOS (`src/editor.c`)**
   - Fixed a bug where `|<`, `Play`, and `>|` visually depressed on click without triggering playback or seeking because `eof_blclick_released` was cleared earlier in `eof_editor_logic()` or invalidated by sub-pixel trackpad drift on mouse-up.
   - Replaced the release condition with a dedicated `transport_btn_down` press/release tracker so all 5 transport controls fire reliably.

3. **Idle CPU & OpenGL Redraw Throttling When Paused (`src/main.c`)**
   - Upstream `#ifndef ALLEGRO_LEGACY` skipped `eof_idle_logic()` on macOS, causing `while(!eof_quit)` to spin at ~156% CPU while paused.
   - Added `al_rest(0.025)` when paused and skipped redundant software-to-OpenGL blits unless playback is active, mouse/keyboard input occurs, or 10 idle ticks (~250ms) elapse—dropping idle CPU to ~5%.

4. **macOS `codesign` & `dylibbundler` Provenance Detritus Fix (`build_eof_cocoa.sh`)**
   - Assembles, runs `dylibbundler`, strips extended attributes (`xattr -cr`), and ad-hoc signs inside `/tmp/EOF-Cocoa.app` before moving to `~/Desktop/EOF-Cocoa.app`, preventing macOS Desktop `com.apple.provenance` xattrs from breaking `codesign`.

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
  - `origin` -> `https://github.com.git` (fork)
  - `upstream` -> `https://github.com` (upstream `rc16`)
- **Automated Version Tracking:**
  - `.build_counter` (local untracked counter `y`) increments automatically every time `build_eof_cocoa.sh` or `build_eof_xquartz.sh` runs, updating `v0.1.<y>.<YYYYMMDD-HHMM>` in `README_MACOS_BUILD.md` and `src/menu/help.c` (`Help > About`).
- **Source Code Attribution:**
  - Every custom QoL addition and functional fix across `src/editor.c`, `src/main.c`, `src/menu/help.c`, `src/menu/native.h`, `src/menu/native.c`, `src/menu/song.c`, `build_eof_cocoa.sh`, and `build_eof_xquartz.sh` is bracketed with `// [BEGIN gemini&catara | <timestamp>]` and `// [END gemini&catara | <timestamp>]`.
- **Syncing Upstream Updates Cleanly (Preserving CRLF Line Endings):**
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
| `v0.1.1.20261122-1228` | 2026-11-22 12:28 CET | `arm64` Cocoa & `amd64` XQuartz | Initial macOS ARM64 Cocoa and Linux XQuartz build scripts with Rocksmith toolbar and content/arrangement indicators. |
| `v0.1.2.20261122-1404` | 2026-11-22 14:04 CET | `arm64` Cocoa | **Functional Fix:** Resolved `SIGBUS` startup/menu crash (`EOF_MAX_MENU_ITEMS` 1024 -> 8192 + `calloc` + bounds checks); added fork info to `Help > About`. |
| `v0.1.3.20261124-1532` | 2026-11-24 15:32 CET | `arm64` Cocoa | **QoL:** Added 29-field `CDLC Meta...` dialog (`BasedOn*` text boxes + macOS `pbpaste` `Paste` buttons), `eof.cfg` persistence, auto-reload last song, and `PART REAL_BASS` + 1st difficulty startup. |
| `v0.1.4.20261125-2026` | 2026-11-25 20:26 CET | `arm64` Cocoa | **QoL & Functional Fix:** Finalized single-row 15-button toolbar (`y=3..21`), synced `raynebc/editor-on-fire:master`, fixed `/tmp` `codesign` build path, and exported all 45 keys to `cdlc_meta.ini`. |
| `v0.1.15.20261125-2222` | 2026-11-25 22:22 CET | `arm64` Cocoa | **Functional Fixes:** Fixed macOS `Play`/`Seek Start`/`Seek End` transport buttons (`transport_btn_down`), reduced idle CPU from 156% to ~5% (`al_rest` + input-aware redraws), and separated QoL vs. Functional Fixes in `README_MACOS_BUILD.md`. |
| `v0.1.16.20261125-2226` | 2026-11-25 22:26 | Automated build | Compiled via build script |
| `v0.1.17.20261125-2229` | 2026-11-25 22:29 | Automated build | Compiled via build script |
| `v0.1.18.20261125-2231` | 2026-11-25 22:31 | Automated build | Compiled via build script |
| `v0.1.19.20261125-2235` | 2026-11-25 22:35 | Automated build | Compiled via build script |
| `v0.1.20.20261125-2244` | 2026-11-25 22:44 | Automated build | Compiled via build script |
