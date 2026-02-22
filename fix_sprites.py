"""
Fix and properly extract warrior sprites from source files.
"""
from PIL import Image
import os

OUTPUT_DIR = r"C:\Users\KyleN\vmupro-raycaster\sprites"
TARGET_HEIGHT = 517  # Normalize all sprites to this height

def find_content_bounds(img):
    """Find the bounding box of non-transparent pixels."""
    pixels = img.load()
    min_x, max_x = img.width, 0
    min_y, max_y = img.height, 0

    for y in range(img.height):
        for x in range(img.width):
            if pixels[x, y][3] > 20:
                min_x = min(min_x, x)
                max_x = max(max_x, x)
                min_y = min(min_y, y)
                max_y = max(max_y, y)

    return min_x, min_y, max_x + 1, max_y + 1

def extract_and_normalize(img, bounds, name):
    """Extract sprite from bounds and normalize height."""
    x1, y1, x2, y2 = bounds
    sprite = img.crop((x1, y1, x2, y2))

    # Scale to target height
    orig_w, orig_h = sprite.size
    scale = TARGET_HEIGHT / orig_h
    new_w = int(orig_w * scale)
    sprite = sprite.resize((new_w, TARGET_HEIGHT), Image.LANCZOS)

    # Save
    output_path = os.path.join(OUTPUT_DIR, name)
    sprite.save(output_path)
    print(f"Saved {name}: {new_w}x{TARGET_HEIGHT}")
    return sprite

# ============================================
# Extract 4 direction sprites from warrior_sprite.png
# ============================================
print("=" * 50)
print("Extracting direction sprites from warrior_sprite.png")
print("=" * 50)

sprite_sheet = Image.open(r"D:\warrior_sprite.png")

# Based on analysis: 4 sprites at these x-ranges
# Sprite 1: x=78-414 (front)
# Sprite 2: x=459-741 (back)
# Sprite 3: x=814-1131 (left)
# Sprite 4: x=1238-1453 (right)

direction_regions = [
    (78, 0, 415, 1024, "warrior_front.png"),
    (459, 0, 742, 1024, "warrior_back.png"),
    (814, 0, 1132, 1024, "warrior_left.png"),
    (1238, 0, 1454, 1024, "warrior_right.png"),
]

for x1, y1, x2, y2, name in direction_regions:
    region = sprite_sheet.crop((x1, y1, x2, y2))
    bounds = find_content_bounds(region)
    # Adjust bounds relative to region
    final_bounds = (bounds[0], bounds[1], bounds[2], bounds[3])
    extract_and_normalize(region, final_bounds, name)

# ============================================
# Extract walking frames from warrior_actions.png
# ============================================
print()
print("=" * 50)
print("Extracting walk frames from warrior_actions.png")
print("=" * 50)

actions_sheet = Image.open(r"D:\warrior_actions.png")

# The sheet is 933x517, but frames overlap
# Let's extract each third and find the actual content

frame_width = 311

for i in range(3):
    x1 = i * frame_width
    x2 = min((i + 1) * frame_width, actions_sheet.width)

    region = actions_sheet.crop((x1, 0, x2, actions_sheet.height))
    bounds = find_content_bounds(region)

    content_height = bounds[3] - bounds[1]
    print(f"Frame {i+1} content height: {content_height}px")

    # Only save if it looks like a full walking frame (should be ~500+ px tall)
    if content_height > 400:
        name = f"warrior_walk{i+1}.png"
        extract_and_normalize(region, bounds, name)

        # Also create flipped version for right-facing
        region_cropped = region.crop(bounds)
        flipped = region_cropped.transpose(Image.FLIP_LEFT_RIGHT)

        # Scale flipped
        orig_h = flipped.height
        scale = TARGET_HEIGHT / orig_h
        new_w = int(flipped.width * scale)
        flipped = flipped.resize((new_w, TARGET_HEIGHT), Image.LANCZOS)

        flipped_path = os.path.join(OUTPUT_DIR, f"warrior_walk{i+1}_r.png")
        flipped.save(flipped_path)
        print(f"Saved warrior_walk{i+1}_r.png: {new_w}x{TARGET_HEIGHT}")
    else:
        print(f"  Skipping Frame {i+1} - too short (likely wrong pose)")

print()
print("=" * 50)
print("Done! Check the sprites folder.")
print("=" * 50)
