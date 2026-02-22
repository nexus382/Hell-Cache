"""
Split warrior_actions.png into individual sprites for the game
Uses pixel density to find sprite boundaries
"""
from PIL import Image
import os

# Load the spritesheet
sheet = Image.open(r'D:\warrior_actions.png')
print(f'Spritesheet: {sheet.width}x{sheet.height}')

if sheet.mode != 'RGBA':
    sheet = sheet.convert('RGBA')

pixels = sheet.load()

def find_content_bounds(img):
    pix = img.load()
    min_x, min_y = img.width, img.height
    max_x, max_y = 0, 0
    for y in range(img.height):
        for x in range(img.width):
            if pix[x, y][3] > 10:
                min_x = min(min_x, x)
                max_x = max(max_x, x)
                min_y = min(min_y, y)
                max_y = max(max_y, y)
    if min_x > max_x:
        return None
    return (min_x, min_y, max_x + 1, max_y + 1)

# Count pixels per column to find sprite boundaries
col_counts = []
for x in range(sheet.width):
    count = 0
    for y in range(sheet.height):
        if pixels[x, y][3] > 10:
            count += 1
    col_counts.append(count)

# Find content regions (where pixel count > threshold)
threshold = 50
regions = []
in_content = False
start = 0

for x, count in enumerate(col_counts):
    if count >= threshold:
        if not in_content:
            start = x
            in_content = True
    else:
        if in_content:
            regions.append((start, x))
            in_content = False

if in_content:
    regions.append((start, sheet.width))

print(f'Found {len(regions)} sprite regions')

# Names for the sprites
sprite_names = [
    'warrior_stand1',      # Standing front 1
    'warrior_stand2',      # Standing front 2
    'warrior_walk1',       # Walking side 1
    'warrior_walk2',       # Walking side 2
    'warrior_walk3',       # Walking side 3
    'warrior_back',        # Back view
]

sprites_dir = r'C:\Users\KyleN\vmupro-raycaster\sprites'
os.makedirs(sprites_dir, exist_ok=True)

# Track heights for normalization
all_sprites = []

# Extract each sprite
for i, (x1, x2) in enumerate(regions):
    region = sheet.crop((x1, 0, x2, sheet.height))
    bounds = find_content_bounds(region)
    if bounds:
        trimmed = region.crop(bounds)
        if trimmed.width > 30 and trimmed.height > 100:
            if i < len(sprite_names):
                name = sprite_names[i]
            else:
                name = f'warrior_action_{i+1}'
            all_sprites.append((name, trimmed))
            print(f'  {name}: {trimmed.width}x{trimmed.height}')

# Normalize all sprites to the same height
if all_sprites:
    max_height = max(s[1].height for s in all_sprites)
    print(f'\nNormalizing all sprites to height: {max_height}')

    for name, sprite in all_sprites:
        if sprite.height < max_height:
            # Create new image with max height, paste at bottom
            new_img = Image.new('RGBA', (sprite.width, max_height), (0, 0, 0, 0))
            y_offset = max_height - sprite.height
            new_img.paste(sprite, (0, y_offset))
            sprite = new_img

        output_path = os.path.join(sprites_dir, f'{name}.png')
        sprite.save(output_path)
        print(f'  Saved {name}: {sprite.width}x{max_height}')

print('\nDone!')
