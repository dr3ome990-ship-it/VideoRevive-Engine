# Third-party licensing and corresponding source

The engine built by this repository uses:

- **FFmpeg**, release n7.1.2: https://github.com/FFmpeg/FFmpeg/tree/n7.1.2
- **x264**, upstream VideoLAN repository: https://code.videolan.org/videolan/x264

This build explicitly enables **--enable-gpl** and **--enable-libx264**. The distributed FFmpeg binaries are therefore subject to the **GNU General Public License**, not the default LGPL-only FFmpeg configuration. Consult the source repositories for full license text, third-party dependency notices, and corresponding source code.

**Before production redistribution:** Preserve the complete applicable license notices and provide the complete corresponding source (including build scripts, configuration, and any modifications) in a way that meets the GPL obligations. Merely linking to upstream repositories may not be sufficient for every distribution arrangement. Also review whether patent/licensing restrictions apply in the intended jurisdictions.

This repository contains the build recipe. It does not assert that the resulting binaries have been reviewed for production distribution or security.
