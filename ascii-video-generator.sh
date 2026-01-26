#!/bin/bash

# Function to convert image to ASCII
convert_to_ascii() {
  local img="$1"
  local width=80  # Adjust for terminal width
  local height=40 # Adjust for terminal height
  convert "$img" -resize "${width}x${height}!" -colorspace Gray -contrast-stretch 0 txt:- |
    sed -n 's/.*(//; s/).*//; s/,/ /g; p' |
    awk '{
        for (i=1; i<=NF; i++) {
            val = int($i / 25.5);  # Map 0-255 to 0-9
            chars = " .:-=+*#%@";  # ASCII gradient
            printf substr(chars, val+1, 1);
        }
        print "";
    }'
}

# Process all frames
for frame in frames/frame_*.png; do
  clear # Clear terminal for next frame
  convert_to_ascii "$frame"
  sleep 0.1 # Adjust delay for playback speed (e.g., 0.1s for ~10 FPS)
done
