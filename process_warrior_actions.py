"""
Process warrior_actions.png:
- Remove background
- Detect sprites by finding vertical column gaps
- Extract each sprite's FULL vertical content
- Scale to match warrior_sprite.png
- Arrange in single row
"""
from PIL import Image

# Load images
actions = Image.open(r'D:\warrior_actions.png')
warrior = Image.open(r'D:\warrior_sprite.png')

if actions.mode != 'RGBA':
    actions = actions.convert('RGBA')
if warrior.mode != 'RGBA':
    warrior = warrior.convert('RGBA')

print(f'Actions: {actions.width}x{actions.height}')
print(f'Warrior reference: {warrior.width}x{warrior.height}')

# Find warrior_sprite content height for scaling reference
def find_content_height(img, threshold=240):
    pixels = img.load()
    min_y, max_y = img.height, 0
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = pixels[x, y]
            if a > 10 and not (r > threshold and g > threshold and b > threshold):
                min_y = min(min_y, y)
                max_y = max(max_y, y)
    return max_y - min_y + 1 if max_y >= min_y else 0

target_height = find_content_height(warrior)
print(f'Target height (from warrior_sprite): {target_height}px')

# Remove gray background from actions
def remove_background(img, threshold=185):
    img = img.copy()
    pixels = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = pixels[x, y]
            if r > threshold and g > threshold and b > threshold:
                pixels[x, y] = (r, g, b, 0)
    return img

print('Removing background...')
actions_clean = remove_background(actions)
pixels = actions_clean.load()

def find_content_bounds(img):
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
    return (min_x, min_y, max_x + 1, max_y + 1)

# For each column, find if it has content
col_has_content = []
for x in range(actions_clean.width):
    has_content = False
    for y in range(actions_clean.height):
        if pixels[x, y][3] > 10:
            has_content = True
            break
    col_has_content.append(has_content)

# Find column ranges with content (separated by gaps of 15+ pixels)
ranges = []
in_content = False
start = 0
gap_count = 0
min_gap = 15

for x, has_content in enumerate(col_has_content):
    if has_content:
        if not in_content:
            start = x
            in_content = True
        gap_count = 0
    else:
        if in_content:
            gap_count += 1
            if gap_count >= min_gap:
                ranges.append((start, x - gap_count + 1))
                in_content = False

if in_content:
    ranges.append((start, actions_clean.width))

print(f'Found {len(ranges)} column regions: {ranges}')

# For each column region, check for vertical gaps and split if needed
def find_row_ranges(img, x1, x2, min_gap=15):
    """Find y-ranges that contain content, separated by gaps"""
    row_has_content = []
    for y in range(img.height):
        has_content = False
        for x in range(x1, x2):
            if pixels[x, y][3] > 10:
                has_content = True
                break
        row_has_content.append(has_content)

    ranges = []
    in_content = False
    start = 0
    gap_count = 0

    for y, has_content in enumerate(row_has_content):
        if has_content:
            if not in_content:
                start = y
                in_content = True
            gap_count = 0
        else:
            if in_content:
                gap_count += 1
                if gap_count >= min_gap:
                    ranges.append((start, y - gap_count + 1))
                    in_content = False

    if in_content:
        ranges.append((start, img.height))

    return ranges

all_sprites = []
for i, (x1, x2) in enumerate(ranges):
    # Find vertical sub-ranges within this column (use larger gap to avoid splitting sprites)
    y_ranges = find_row_ranges(actions_clean, x1, x2, min_gap=50)

    for j, (y1, y2) in enumerate(y_ranges):
        # Crop this sprite region
        region = actions_clean.crop((x1, y1, x2, y2))
        # Trim to actual content
        bounds = find_content_bounds(region)
        if bounds:
            trimmed = region.crop(bounds)
            if trimmed.height > 150 and trimmed.width > 50:
                all_sprites.append(trimmed)
                print(f'  Region {i+1}.{j+1}: x={x1}-{x2}, y={y1}-{y2}, content {trimmed.width}x{trimmed.height}')

print(f'Total sprites found: {len(all_sprites)}')

if not all_sprites:
    print('No sprites found!')
    exit()

# Use single scale factor based on tallest sprite
max_height = max(s.height for s in all_sprites)
scale_factor = target_height / max_height
print(f'Tallest sprite: {max_height}px, scale factor: {scale_factor:.3f}')

scaled_sprites = []
for i, sprite in enumerate(all_sprites):
    new_width = int(sprite.width * scale_factor)
    new_height = int(sprite.height * scale_factor)
    scaled = sprite.resize((new_width, new_height), Image.LANCZOS)
    scaled_sprites.append(scaled)
    print(f'  Sprite {i+1}: {sprite.width}x{sprite.height} -> {new_width}x{new_height}')

# Create single row spritesheet
total_width = sum(s.width for s in scaled_sprites)
max_scaled_height = max(s.height for s in scaled_sprites)

print(f'Output spritesheet: {total_width}x{max_scaled_height}')

output = Image.new('RGBA', (total_width, max_scaled_height), (0, 0, 0, 0))

x_offset = 0
for sprite in scaled_sprites:
    y_offset = max_scaled_height - sprite.height
    output.paste(sprite, (x_offset, y_offset))
    x_offset += sprite.width

output.save(r'D:\warrior_actions_processed.png')
print(f'Saved to D:\\warrior_actions_processed.png')
