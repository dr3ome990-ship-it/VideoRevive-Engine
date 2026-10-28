#!/usr/bin/env bash
# Build a small Windows x64 FFmpeg/FFprobe pair with static x264.
# Runs on Ubuntu GitHub Actions with MinGW-w64, NASM, pkg-config and make.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="${RUNNER_TEMP:-/tmp}/videorevive-engine"
PREFIX="$WORK/prefix"
OUT="$ROOT/dist"
JOBS="${JOBS:-2}"
mkdir -p "$WORK" "$PREFIX" "$OUT"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_ALLOW_CROSS=1
export PATH="$PREFIX/bin:$PATH"
CROSS="x86_64-w64-mingw32-"

if [[ ! -d "$WORK/x264/.git" ]]; then
  git clone --depth 1 https://code.videolan.org/videolan/x264.git "$WORK/x264"
fi
cd "$WORK/x264"
./configure --host=x86_64-w64-mingw32 --cross-prefix="$CROSS" \
  --prefix="$PREFIX" --enable-static --disable-cli --disable-opencl
make -j"$JOBS"
make install

if [[ ! -d "$WORK/ffmpeg/.git" ]]; then
  git clone --depth 1 --branch n7.1.2 https://github.com/FFmpeg/FFmpeg.git "$WORK/ffmpeg"
fi
cd "$WORK/ffmpeg"
./configure \
  --prefix="$PREFIX" --target-os=mingw32 --arch=x86_64 \
  --cross-prefix="$CROSS" --enable-cross-compile \
  --disable-shared --enable-static --enable-gpl --enable-libx264 \
  --disable-debug --disable-doc --disable-ffplay --disable-autodetect \
  --disable-network --disable-devices --disable-everything --enable-small \
  --enable-protocol=file,pipe \
  --enable-demuxer=mov,matroska,avi,flv,mpegts,mpegvideo,h264,hevc,aac,mp3,ogg,wav,rawvideo \
  --enable-muxer=mp4,mov,matroska,null,adts,mp3,wav \
  --enable-parser=h264,hevc,aac,mpeg4video,opus,vp9,av1,mpegaudio \
  --enable-decoder=h264,hevc,mpeg4,mpeg2video,aac,mp3,opus,vorbis,vp8,vp9,av1,pcm_s16le,pcm_s24le,rawvideo \
  --enable-encoder=libx264,aac,pcm_s16le,pcm_s24le \
  --enable-bsf=aac_adtstoasc,h264_mp4toannexb,hevc_mp4toannexb \
  --enable-filter=anull,null,format,aresample,scale \
  --enable-ffmpeg --enable-ffprobe \
  --pkg-config=pkg-config --pkg-config-flags=--static \
  --extra-cflags="-I$PREFIX/include" \
  --extra-ldflags="-L$PREFIX/lib -static" \
  --extra-libs="-lwinpthread"
make -j"$JOBS"
cp ffmpeg.exe ffprobe.exe "$OUT/"
for f in "$OUT/ffmpeg.exe" "$OUT/ffprobe.exe"; do
  test -s "$f"
  file "$f"
  "$CROSS"objdump -p "$f" | grep 'DLL Name' || true
  if "$CROSS"objdump -p "$f" | grep -Ei 'DLL Name: (libwinpthread|libgcc|libstdc\+\+)'; then
    echo "Unexpected non-system runtime DLL in $f" >&2
    exit 1
  fi
done
sha256sum "$OUT/ffmpeg.exe" "$OUT/ffprobe.exe"
