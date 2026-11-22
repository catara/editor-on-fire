#!/bin/bash
# Author: gemini&catara | Date: 2026-11-22 12:08 CET
# Purpose: Build Docker (linux/amd64) + XQuartz + PulseAudio EOF-XQuartz.app bundle
set -e
export PATH="/opt/homebrew/bin:/usr/local/bin:/opt/X11/bin:$PATH"

brew list --cask orbstack >/dev/null 2>&1 || brew install --cask orbstack
brew list --cask xquartz >/dev/null 2>&1 || brew install --cask xquartz
brew list pulseaudio >/dev/null 2>&1 || brew install pulseaudio

mkdir -p ~/.config/pulse
printf '.include /opt/homebrew/etc/pulse/default.pa\nload-module module-native-protocol-tcp auth-ip-acl=127.0.0.1;172.16.0.0/12;192.168.0.0/16 auth-anonymous=1\n' > ~/.config/pulse/default.pa
printf 'default-sample-rate = 44100\nalternate-sample-rate = 48000\ndefault-fragments = 8\ndefault-fragment-size-msec = 40\n' > ~/.config/pulse/daemon.conf
brew services restart pulseaudio >/dev/null 2>&1 || true
defaults write org.xquartz.X11 nolisten_tcp -bool false

if [ ! -d ~/editor-on-fire/.git ]; then
  cd ~
  E=$(printf 'https:\057\057github.com\057raynebc\057editor-on-fire.git')
  git clone "$E"
fi

cd ~/editor-on-fire
cat << 'DOCKER' > Dockerfile.eof
FROM debian:bookworm-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential pkg-config liballegro4-dev libogg-dev libvorbis-dev libfftw3-dev librubberband-dev
COPY . /eof
WORKDIR /eof/src
RUN make -f makefile.linux clean && make -f makefile.linux

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    liballegro4.4 libogg0 libvorbisfile3 libfftw3-double3 libfftw3-single3 librubberband2 \
    lame vorbis-tools oggvideotools libasound2-plugins pulseaudio-utils \
    && rm -rf /var/lib/apt/lists/* \
    && printf 'pcm.!default {\n  type pulse\n}\nctl.!default {\n  type pulse\n}\n' > /etc/asound.conf
COPY --from=builder /eof/bin /eof/bin
WORKDIR /eof/bin
CMD ["./eof"]
DOCKER

command -v orb >/dev/null 2>&1 && orb start >/dev/null 2>&1
docker build --platform linux/amd64 -t eof-arm64:latest -f Dockerfile.eof .

APP_OUT="$HOME/Desktop/EOF-XQuartz.app"
rm -rf "$APP_OUT"
mkdir -p "$APP_OUT/Contents/MacOS" "$APP_OUT/Contents/Resources"
docker save eof-arm64:latest -o "$APP_OUT/Contents/Resources/eof-image.tar"

cat << 'PLIST' > "$APP_OUT/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://apple.com">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>EOF</string>
  <key>CFBundleIdentifier</key>
  <string>com.eof.xquartz</string>
  <key>CFBundleName</key>
  <string>EOF-XQuartz</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
</dict>
</plist>
PLIST

cat << 'LAUNCHER' > "$APP_OUT/Contents/MacOS/EOF"
#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/opt/X11/bin:$PATH"
DIR="$(cd "$(dirname "$0")/.." && pwd)"
RES="$DIR/Resources"
CFG_DIR="$HOME/Library/Application Support/EOF"
CFG_FILE="$CFG_DIR/eof.cfg"

mkdir -p "$CFG_DIR"
[ ! -f "$CFG_FILE" ] && printf '[directories]\nsong_path = /desktop/\n\n[config]\nbuffer_size = 32768\n' > "$CFG_FILE"

command -v brew >/dev/null 2>&1 && brew services start pulseaudio >/dev/null 2>&1
command -v orb >/dev/null 2>&1 && orb start >/dev/null 2>&1
open -a XQuartz

for i in {1..15}; do
  if DISPLAY=:0 xhost +127.0.0.1 >/dev/null 2>&1; then
    DISPLAY=:0 xhost + >/dev/null 2>&1
    break
  fi
  sleep 1
done

docker image inspect eof-arm64:latest >/dev/null 2>&1 || docker load -i "$RES/eof-image.tar"
docker ps -q --filter ancestor=eof-arm64:latest | xargs -r docker stop >/dev/null 2>&1

docker run --rm --platform linux/amd64 \
  -v "$HOME/Desktop":/desktop \
  -v "$CFG_FILE":/eof/bin/eof.cfg \
  -e DISPLAY=host.docker.internal:0 \
  -e PULSE_SERVER=tcp:host.docker.internal:4713 \
  -e PULSE_LATENCY_MSEC=120 \
  eof-arm64:latest ./eof 2>/dev/null | grep -v "Error opening log file"
LAUNCHER
chmod +x "$APP_OUT/Contents/MacOS/EOF"
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
print(f"Updated README_MACOS_BUILD.md -> {ver}")
'
# [END gemini&catara]
