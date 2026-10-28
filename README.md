# VideoRevive Media Engine

Public distribution repository for **Windows x64 FFmpeg and FFprobe binaries** used by VideoRevive. The VideoRevive application source stays in its separate private repository.

## Intended release process

1. GitHub Actions builds a **custom FFmpeg** with a static `libx264` encoder and native AAC support.
2. The workflow tests that both executables run and the required encoders/demuxers exist.
3. On successful checks, a release contains `ffmpeg.exe`, `ffprobe.exe`, and `engine-manifest.json` with **SHA-256 checksums**.
4. VideoRevive downloads **only the required executable** on first use, validates its checksum, and reuses it afterward.

**Status:** This repository initially contains build automation, not a verified published engine release. Do not put placeholder checksums or URLs into the app.

## Releasing

Open **Actions → Build Windows Media Engine → Run workflow** and choose a version, e.g. `engine-v1`. Once the run succeeds, verify the release assets and the resulting manifest before using them in the VideoRevive source.

## Security and licensing

- Only download from HTTPS and validate a checksum baked into the application.
- Do not delete installed engine binaries while a repair job is running.
- The build enables GPL `libx264`. **FFmpeg + x264 binaries built this way are GPL-licensed.** Redistributing them requires complying with the applicable GPL obligations, including providing corresponding source and notices. Review the actual dependencies and licenses before distribution.
- Windows Defender and end-to-end recovery testing are required before publishing a production update.
