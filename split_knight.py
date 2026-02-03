"""
Split the knight spritesheet into individual sprites with transparency
Ensures all sprites have consistent height for proper scaling
"""
from PIL import Image
import os

# Load the spritesheet
sheet = Image.open('D:/knight_sprite.png')
print(f"Spritesheet size: {sheet.width}x{sheet.height}")

# Convert to RGBA if needed
if sheet.mode != 'RGBA':
    sheet = sheet.convert('RGBA')

# Remove light gray/white background (make transparent)
def remove_background(img, threshold=200):
    """Remove light colored background by making it transparent"""
    img = img.copy()
    pixels = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = pixels[x, y]
            if r > threshold and g > threshold and b > threshold:
                pixels[x, y] = (r, g, b, 0)
    return img

print("Removing background...")
sheet = remove_background(sheet)

os.makedirs('C:/Users/KyleN/vmupro-raycaster/sprites', exist_ok=True)

# Divide into 4 equal sections
sprite_width = sheet.width // 4
sprite_regions = [
    ('knight_left', 0, sprite_width),
    ('knight_front', sprite_width, sprite_width * 2),
    ('knight_back', sprite_width * 2, sprite_width * 3),
    ('knight_right', sprite_width * 3, sheet.width),
]

def find_content_bounds(img):
    """Find the bounding box of non-transparent content"""
    pixels = img.load()
    min_x, min_y = img.width, img.height
    max_x, max_y = 0, 0

    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = pixels[x, y]
            if a > 10:
                min_x = min(min_x, x)
                max_x = max(max_x, x)
                min_y = min(min_y, y)
                max_y = max(max_y, y)

    if min_x > max_x:
        return None
    return min_x, min_y, max_x + 1, max_y + 1

# First pass: find the global min_y and max_y across all sprites
# This ensures consistent vertical positioning
global_min_y = sheet.height
global_max_y = 0

for name, x1, x2 in sprite_regions:
    sprite = sheet.crop((x1, 0, x2, sheet.height))
    bounds = find_content_bounds(sprite)
    if bounds:
        global_min_y = min(global_min_y, bounds[1])
        global_max_y = max(global_max_y, bounds[3])

target_height = global_max_y - global_min_y
print(f"Global content Y range: {global_min_y} to {global_max_y} (height: {target_height})")

# Second pass: extract sprites with consistent height
for name, x1, x2 in sprite_regions:
    # Crop this sprite's region using global Y bounds
    sprite = sheet.crop((x1, global_min_y, x2, global_max_y))

    # Now trim only horizontally (find X bounds within this region)
    bounds = find_content_bounds(sprite)
    if bounds:
        # Crop horizontally only, keep full height
        sprite = sprite.crop((bounds[0], 0, bounds[2], sprite.height))

    # Save
    output_path = f'C:/Users/KyleN/vmupro-raycaster/sprites/{name}.png'
    sprite.save(output_path)
    print(f"Saved {name}: {sprite.width}x{sprite.height}")

print("\nDone! All knight sprites have consistent height for proper scaling.")
