# Spritesheet Fix-inator 🛠️

**Put an end to the HELL of public spritesheets with inconsistent spacing between frames.**

*Repo name inspired by certain meme legend*

<img width="1280" height="720" alt="image" src="https://github.com/user-attachments/assets/9c593254-919e-4798-94f4-1692561b2af3" />

---

If you've ever downloaded a sprite sheet from the internet only to discover the frames are **inconsistently** spaced, you know the pain. `spritesheet_fixinator.sh` saves you from debugging hell. All thanks to `ImageMagick`: a tool that sits within your favourite linux distro (if you use linux) and you never used it, or at least never found a use-case for it...

## Table of Contents

- [How It Works](#how-it-works)
- [Use Cases](#use-cases)
- [Requirements](#requirements)
- [Usage](#usage)
- [Limitations](#limitations)

## How It Works

1. `magick -connected-components` extracts bounding boxes of all non-transparent regions.
2. The widest frame determines the uniform canvas width.
3. A minimal spacing (≥1px) is found such that `(max_width × num_frames) + spacing × (num_frames − 1)` is divisible by `num_frames`. This guarantees even division for sprite-sheet slicing.
4. Each frame is cropped, centered, and padded to the uniform width.
5. Frames are concatenated horizontally with `+append`.

The output is a perfectly aligned horizontal spritesheet where every frame has the same width and identical spacing between each neighboring frame.

## Use Cases

- **Game developers** who want to slap code with `FRAME_W = SPRITESHEET_W / TOTAL_FRAMES` and move on.
- **Anyone** who has screamed "just pick a spacing and stick with it" at a PNG file

## Requirements

- **ImageMagick** (`magick` command) installed and on your PATH
- Input single row spritesheet with frames on a transparent background

## Usage

```bash
./spritesheet_fixinator.sh input.png output.png
```

The script writes the fixed spritesheet to `output.png`.

## Limitations

- **Single-row spritesheets only.** This script does not handle multi-row or multi-column layouts. All detected frames are concatenated into one horizontal strip. If your spritesheet has multiple rows, the rows will be flattened into a single long row.
- Frames **must be separated** by at least 1 pixel of transparency. Touching/adjacent frames will be detected as a single bounding box.
- Frames are **bottom-aligned** (`-gravity South`). If your frames have varying vertical positions, they will sit on a common baseline.
- The script uses **connected-components sorting** (`sort=X`) which sorts regions from left to right by their centroid. This should handle left-to-right frame order correctly for well-formed spritesheets.

