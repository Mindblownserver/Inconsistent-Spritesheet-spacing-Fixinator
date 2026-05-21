# spritesheet_fixinator 🛠️

**Put an end to the HELL of public spritesheets with inconsistent spacing between frames.**

If you've ever downloaded a sprite sheet from the internet only to discover the frames are unevenly spaced — some too tight, some too loose, with no discernible grid — you know the pain. `spritesheet_fixinator` automates the misery away.

## What It Does

Given a spritesheet with non-transparent frames, the script:

1. **Detects each frame** using ImageMagick's connected-components analysis (finds non-transparent regions)
2. **Measures every frame** to find the widest one
3. **Extracts and centers** each frame on a canvas of uniform width
4. **Adds consistent spacing** between every frame (auto-calculated so the total width is evenly divisible by the frame count)
5. **Stitches them** into a clean, single-row spritesheet

The output is a perfectly aligned horizontal spritesheet where every frame has the same width and identical spacing between each neighboring frame.

## Use Cases

- **Game developers** using free/public asset spritesheets that were slapped together with inconsistent padding
- **Animation programmers** who need predictable `FRAME_WIDTH` and `FRAME_COUNT` for their sprite-rendering code
- **Pixel artists** who want to clean up a rough spritesheet without manually cutting and aligning each frame
- **Tooling pipelines** that require a normalized spritesheet format (single row, uniform spacing, divisible width)
- **Anyone** who has screamed "just pick a spacing and stick with it" at a PNG file

## Requirements

- **ImageMagick** (`magick` command) installed and on your PATH
- Input spritesheet with **non-transparent frames** on a transparent background (connected-components needs opacity contrast to detect each frame)

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

## How It Works (Briefly)

1. `magick -connected-components` extracts bounding boxes of all non-transparent regions.
2. The widest frame determines the uniform canvas width.
3. A minimal spacing (≥1px) is found such that `(max_width × num_frames) + spacing × (num_frames − 1)` is divisible by `num_frames`. This guarantees even division for sprite-sheet slicing.
4. Each frame is cropped, centered, and padded to the uniform width.
5. Frames are concatenated horizontally with `+append`.

## Example

| Before | After |
|--------|-------|
| Unevenly spaced frames, inconsistent widths, unpredictable grid | Single row, uniform frame width, consistent spacing, total width divisible by frame count |
