"""
Split the warrior spritesheet into individual sprites with transparency
"""
from PIL import Image
import os

# Load the spritesheet
sheet = Image.open('D:/warrior_sprite.png')
print(f"Spritesheet size: {sheet.width}x{sheet.height}")

# Convert to RGBA if needed
if sheet.mode != 'RGBA':
    sheet = sheet.convert('RGBA')

os.makedirs('C:/Users/KyleN/vmupro-raycaster/sprites', exist_ok=True)

# Based on visual inspection and content analysis, the 4 sprites are at:
# Sprite 1 (front, sword down): x = 65 to 460
# Sprite 2 (back): x = 465 to 820
# Sprite 3 (front, sword out): x = 825 to 1135
# Sprite 4 (right side): x = 1195 to 1460

sprite_regions = [
    ('warrior_front', 65, 465),    # Front view with sword
    ('warrior_back', 465, 825),    # Back view
    ('warrior_front2', 825, 1140), # Front view (alternate) - skip this
    ('warrior_right', 1190, 1465), # Right side view
]

def find_content_bounds(img):
    """Find the bounding box of non-transparent content"""
    pixels = img.load()
    min_x, min_y = img.width, img.height
    max_x, max_y = 0, 0

    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = pixels[x, y]
            if a > 10:  # Has some opacity
                min_x = min(min_x, x)
                max_x = max(max_x, x)
                min_y = min(min_y, y)
                max_y = max(max_y, y)

    if min_x > max_x:  # No content found
        return 0, 0, img.width, img.height
    return min_x, min_y, max_x + 1, max_y + 1

for name, x1, x2 in sprite_regions:
    if name == 'warrior_front2':
        continue  # Skip the alternate front view

    # Crop this sprite's region
    sprite = sheet.crop((x1, 0, x2, sheet.height))

    # Trim to actual content bounds
    bounds = find_content_bounds(sprite)
    sprite = sprite.crop(bounds)

    # Save
    output_path = f'C:/Users/KyleN/vmupro-raycaster/sprites/{name}.png'
    sprite.save(output_path)
    print(f"Saved {name}: {sprite.width}x{sprite.height} (from x={x1} to x={x2})")

# Create left view by flipping the right view
right_sprite = Image.open('C:/Users/KyleN/vmupro-raycaster/sprites/warrior_right.png')
left_sprite = right_sprite.transpose(Image.FLIP_LEFT_RIGHT)
left_sprite.save('C:/Users/KyleN/vmupro-raycaster/sprites/warrior_left.png')
print(f"Saved warrior_left (flipped from right): {left_sprite.width}x{left_sprite.height}")

print("\nDone! Sprites saved to sprites/ folder")
