#!/bin/bash

target=$2     # output file

# Get bounding boxes of all non-transparent regions from the spritesheet
bboxArr=($(magick $1 \
  -alpha extract -type bilevel \
  -define connected-components:verbose=true \
  -define connected-components:mean-color=true \
  -define connected-components:sort=X \
  -connected-components 8 null: | grep "gray(255)" | awk '{print $2}'))

num=${#bboxArr[@]}

# Get the width of each frame to find the maximum width
frame_widths=()
for ((i=0; i<num; i++)); do
  bbox="${bboxArr[$i]}"
  width=$(echo $bbox | cut -d'x' -f1)
  frame_widths+=($width)
done

# Find max frame width
max_width=0
for w in "${frame_widths[@]}"; do
  if [ $w -gt $max_width ]; then
    max_width=$w
  fi
done

echo "Max frame width: $max_width"
echo "Number of frames: $num"

# Calculate the minimum spacing needed (at least 1 pixel between frames)
spacing=1
total_fixed_width=$((max_width * num))

# Find the smallest spacing that makes total width divisible by num
while true; do
    test_total=$((total_fixed_width + spacing * (num - 1)))
    if [ $((test_total % num)) -eq 0 ]; then
        break
    fi
    spacing=$((spacing + 1))
done

final_width=$((total_fixed_width + spacing * (num - 1)))

echo "Determined spacing: $spacing pixels between frames"
echo "Final width: $final_width (divisible by $num)"
echo "Each frame will be: $((final_width / num)) pixels wide"

# Generate the spritesheet with spacing BETWEEN elements
# Create an array to hold temporary file names
temp_files=()

for ((i=0; i<num; i++)); do
  bbox="${bboxArr[$i]}"
  temp_file="/tmp/frame_${i}.png"
  temp_files+=("$temp_file")
  
  # Extract, center, and ensure exact width
  magick $1 -crop "$bbox" +repage \
    -background none -gravity center \
    -extent ${max_width}x-1 \
    -alpha on \
    "$temp_file"
done

# Now combine all frames with the calculated spacing using -smush (without +)
# Use parentheses and -smush with positive value for spacing BETWEEN images
magick "${temp_files[@]}" -background none -gravity South +append "$target"

# Clean up temp files
for temp_file in "${temp_files[@]}"; do
  rm -f "$temp_file"
done

echo "Finished!"
final_w=$(magick $target -format "%w" info:)
echo "Final spritesheet width: $final_w"
echo "Divisible by $num? $((final_w % num == 0))"
echo "Calculated FRAME_W = $((final_w / num))"

