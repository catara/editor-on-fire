#!/bin/bash
# Author: gemini&catara | Date: 2026-11-22 12:08 CET
# Purpose: Build native Apple Silicon (arm64) Cocoa/Aqua EOF-Cocoa.app with custom Rocksmith toolbar buttons
set -e
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

brew install allegro cmake pkg-config libogg libvorbis fftw rubberband lame vorbis-tools dylibbundler

if [ ! -f /usr/local/lib/liballeg.4.4.2.dylib ]; then
  cd /tmp
  sudo rm -rf Allegro-Legacy
  U=$(printf 'https:\057\057github.com\057NewCreature\057Allegro-Legacy.git')
  git clone "$U"
  cd Allegro-Legacy
  mkdir build && cd build
  cmake .. \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_PREFIX_PATH=/opt/homebrew \
    -DCMAKE_C_FLAGS="-I/opt/homebrew/include" \
    -DCMAKE_INSTALL_PREFIX=/usr/local
  make -j$(sysctl -n hw.ncpu)
  sudo make install
fi

if [ ! -d ~/editor-on-fire/.git ]; then
  cd ~
  E=$(printf 'https:\057\057github.com\057raynebc\057editor-on-fire.git')
  git clone "$E"
fi

cd ~/editor-on-fire/src
cat << 'EOF' > makefile.legacy_config
CC = clang
CXX = clang++
CFLAGS = -O2 -arch arm64 -Wno-implicit-function-declaration -Wno-int-conversion -Wno-incompatible-pointer-types -Ialogg/include -I/usr/local/include -I/opt/homebrew/include -DEOF_BUILD
CXXFLAGS = $(CFLAGS)
LIBS = -L/usr/local/lib -L/opt/homebrew/lib -lalleg -lallegro -lallegro_audio -lallegro_acodec -lallegro_dialog -lallegro_font -lallegro_image -lallegro_memfile -lallegro_primitives -lallegro_main -framework Cocoa -framework OpenGL -framework OpenAL -framework IOKit -framework CoreAudio -framework AudioToolbox -framework AudioUnit -framework Carbon -framework CoreVideo -framework Accelerate -logg -lvorbis -lvorbisfile -lm -lfftw3 -lfftw3f -lrubberband -lc++
EOF

make -f makefile.legacy clean
make -f makefile.legacy -j$(sysctl -n hw.ncpu)

FINAL_APP="$HOME/Desktop/EOF-Cocoa.app"
APP_OUT="/tmp/EOF-Cocoa.app"
# [BEGIN gemini&catara | 2026-11-25 17:14 CET] Persist eof.cfg across rebuilds
CFG_KEEP="$HOME/Library/Application Support/EOF/eof.cfg"
mkdir -p "$(dirname "$CFG_KEEP")"
[ -f "$APP_OUT/Contents/Resources/eof/eof.cfg" ] && cp "$APP_OUT/Contents/Resources/eof/eof.cfg" "$CFG_KEEP"
rm -rf "$APP_OUT"
mv ~/EOF.app "$APP_OUT"
mkdir -p "$APP_OUT/Contents/libs"
# [BEGIN gemini&catara | 2026-11-25 17:14 CET] Restore persisted eof.cfg
[ -f "$CFG_KEEP" ] && cp "$CFG_KEEP" "$APP_OUT/Contents/Resources/eof/eof.cfg"
# [END gemini&catara | 2026-11-25 17:14 CET]
xattr -cr "$APP_OUT"
xattr -cr "$APP_OUT"
xattr -cr "$APP_OUT"
dylibbundler -od -b -s /usr/local/lib -s /opt/homebrew/lib -x "$APP_OUT/Contents/MacOS/eof" -d "$APP_OUT/Contents/libs/" -p @executable_path/../libs/
cp /opt/homebrew/bin/lame /opt/homebrew/bin/oggenc "$APP_OUT/Contents/Resources/eof/" 2>/dev/null || true
cp ~/editor-on-fire/bin/rocksmith.panel.txt "$APP_OUT/Contents/Resources/eof/" 2>/dev/null || true
cp /Applications/Rocksmith/EOF.app/Contents/Resources/eof/rocksmith.panel.txt /Applications/Rocksmith/EOF.app/Contents/Resources/eof/eof.cfg /Applications/Rocksmith/EOF.app/Contents/Resources/eof/oggCat "$APP_OUT/Contents/Resources/eof/" 2>/dev/null || true
xattr -cr "$APP_OUT"
xattr -cr "$APP_OUT"
codesign --force --deep --sign - "$APP_OUT"
rm -rf "$FINAL_APP"
mv "$APP_OUT" "$FINAL_APP"
echo "Built: $APP_OUT"

# [BEGIN gemini&catara | Auto-increment version v0.1.<counter>.<timestamp> in README_MACOS_BUILD.md]
python3 -c '
import datetime, os, re
repo = os.path.expanduser("~/editor-on-fire")
cf = os.path.join(repo, ".build_counter")
rf = os.path.join(repo, "README_MACOS_BUILD.md")
cnt = int(open(cf).read().strip()) + 1 if os.path.exists(cf) else 1
open(cf, "w").write(str(cnt) + "\n")
ts = datetime.datetime.now().strftime("%Y%m%d-%H%M")
hts = datetime.datetime.now().strftime("%Y-%m-%d %H:%M %Z").strip()
ver = f"v0.1.{cnt}.{ts}"
if os.path.exists(rf):
    txt = open(rf).read()
    txt = re.sub(r"`v0\.1\.\d+\.[0-9-]+`", f"`{ver}`", txt, count=1)
    txt = re.sub(r"\*\*Last Built:\*\* .*", f"**Last Built:** {hts}", txt, count=1)
    row = f"| `{ver}` | {hts} | Automated build | Compiled via build script |"
    if row not in txt:
        txt = txt.rstrip() + "\n" + row + "\n"
    open(rf, "w").write(txt)
hf = os.path.join(repo, "src/menu/help.c")
if os.path.exists(hf):
    hraw = open(hf, "rb").read()
    heol = b"\r\n" if b"\r\n" in hraw else b"\n"
    hstr = hraw.decode("latin1").replace("\r\n", "\n")
    d_only = datetime.datetime.now().strftime("%Y-%m-%d")
    hstr = re.sub(r"as of [0-9-]+ \(Catara\x27s fork v0\.1\.\d+\)", f"as of {d_only} (Catara\x27s fork v0.1.{cnt})", hstr)
    open(hf, "wb").write(hstr.replace("\n", "\r\n" if heol == b"\r\n" else "\n").encode("latin1"))
print(f"Updated README_MACOS_BUILD.md -> {ver}")
'
# [END gemini&catara]
