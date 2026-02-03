"""
Generate pixel art warrior sprites for VMU Pro raycaster
Creates PNG files with proper alpha transparency
"""
import struct
import os
import zlib

def create_png(width, height, pixels, filename):
    """Create a PNG file with RGBA pixel data"""
    def png_chunk(chunk_type, data):
        chunk_len = struct.pack('>I', len(data))
        chunk_data = chunk_type + data
        checksum = struct.pack('>I', zlib.crc32(chunk_data) & 0xffffffff)
        return chunk_len + chunk_data + checksum

    # PNG signature
    signature = b'\x89PNG\r\n\x1a\n'

    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)  # 8-bit RGBA
    ihdr = png_chunk(b'IHDR', ihdr_data)

    # IDAT chunk (image data)
    raw_data = b''
    for row in pixels:
        raw_data += b'\x00'  # Filter type: None
        for pixel in row:
            if len(pixel) == 3:
                r, g, b = pixel
                a = 0 if (r, g, b) == (255, 0, 255) else 255  # Magenta = transparent
            else:
                r, g, b, a = pixel
            raw_data += struct.pack('BBBB', r, g, b, a)

    compressed = zlib.compress(raw_data, 9)
    idat = png_chunk(b'IDAT', compressed)

    # IEND chunk
    iend = png_chunk(b'IEND', b'')

    with open(filename, 'wb') as f:
        f.write(signature + ihdr + idat + iend)

# Colors matching the warrior pixel art (RGBA)
TRANSPARENT = (0, 0, 0, 0)  # Fully transparent
MAROON = (128, 24, 24, 255)
DARK_MAROON = (96, 16, 16, 255)
LIGHT_MAROON = (160, 48, 48, 255)
SILVER = (200, 200, 210, 255)
DARK_SILVER = (140, 140, 150, 255)
SKIN = (220, 180, 140, 255)
SKIN_SHADOW = (180, 140, 100, 255)
BROWN_HAIR = (100, 60, 30, 255)
DARK_BROWN = (60, 40, 20, 255)
LIGHT_BROWN = (140, 90, 50, 255)
DARK_GRAY = (60, 60, 70, 255)
BLACK = (20, 20, 20, 255)
WHITE = (240, 240, 240, 255)
BELT_BROWN = (80, 50, 30, 255)
GOLD = (220, 180, 60, 255)
BLADE = (180, 190, 200, 255)

def create_warrior_front(size=32):
    """Create front-facing warrior sprite"""
    pixels = [[TRANSPARENT] * size for _ in range(size)]

    # Scale factor
    s = size / 32

    def put(x, y, color):
        if 0 <= int(x) < size and 0 <= int(y) < size:
            pixels[int(y)][int(x)] = color

    def fill_rect(x1, y1, x2, y2, color):
        for y in range(int(y1), int(y2)):
            for x in range(int(x1), int(x2)):
                put(x, y, color)

    # Hair (spiky)
    fill_rect(12*s, 2*s, 20*s, 6*s, BROWN_HAIR)
    fill_rect(10*s, 4*s, 12*s, 7*s, BROWN_HAIR)  # Left spike
    fill_rect(20*s, 4*s, 22*s, 7*s, BROWN_HAIR)  # Right spike
    fill_rect(14*s, 1*s, 18*s, 4*s, BROWN_HAIR)  # Top spike

    # Face
    fill_rect(12*s, 5*s, 20*s, 11*s, SKIN)
    fill_rect(11*s, 6*s, 12*s, 10*s, SKIN_SHADOW)  # Left shadow
    fill_rect(20*s, 6*s, 21*s, 10*s, SKIN_SHADOW)  # Right shadow

    # Eyes
    fill_rect(13*s, 7*s, 15*s, 9*s, WHITE)
    fill_rect(17*s, 7*s, 19*s, 9*s, WHITE)
    put(14*s, 8*s, BLACK)  # Left pupil
    put(18*s, 8*s, BLACK)  # Right pupil

    # Mouth
    fill_rect(14*s, 10*s, 18*s, 11*s, DARK_BROWN)

    # Shoulder pauldrons
    fill_rect(7*s, 11*s, 12*s, 15*s, SILVER)
    fill_rect(20*s, 11*s, 25*s, 15*s, SILVER)
    fill_rect(8*s, 12*s, 11*s, 14*s, DARK_SILVER)  # Highlight
    fill_rect(21*s, 12*s, 24*s, 14*s, DARK_SILVER)

    # Body armor
    fill_rect(11*s, 11*s, 21*s, 22*s, MAROON)
    fill_rect(12*s, 12*s, 20*s, 14*s, LIGHT_MAROON)  # Chest highlight
    fill_rect(13*s, 16*s, 19*s, 17*s, DARK_MAROON)  # Armor line
    fill_rect(13*s, 19*s, 19*s, 20*s, DARK_MAROON)  # Armor line
    fill_rect(15*s, 12*s, 17*s, 21*s, DARK_MAROON)  # Center line

    # Belt
    fill_rect(11*s, 21*s, 21*s, 23*s, BELT_BROWN)
    fill_rect(14*s, 21*s, 18*s, 23*s, GOLD)  # Belt buckle

    # Arms
    fill_rect(7*s, 14*s, 11*s, 21*s, MAROON)
    fill_rect(21*s, 14*s, 25*s, 21*s, MAROON)
    fill_rect(8*s, 15*s, 10*s, 20*s, DARK_MAROON)
    fill_rect(22*s, 15*s, 24*s, 20*s, DARK_MAROON)

    # Hands
    fill_rect(7*s, 20*s, 11*s, 22*s, SKIN)
    fill_rect(21*s, 20*s, 25*s, 22*s, SKIN)

    # Skirt/tasset
    fill_rect(11*s, 22*s, 21*s, 25*s, MAROON)
    fill_rect(12*s, 23*s, 13*s, 25*s, DARK_MAROON)
    fill_rect(15*s, 23*s, 17*s, 25*s, DARK_MAROON)
    fill_rect(19*s, 23*s, 20*s, 25*s, DARK_MAROON)

    # Legs
    fill_rect(12*s, 25*s, 15*s, 30*s, DARK_GRAY)
    fill_rect(17*s, 25*s, 20*s, 30*s, DARK_GRAY)

    # Boots
    fill_rect(11*s, 29*s, 16*s, 32*s, DARK_BROWN)
    fill_rect(16*s, 29*s, 21*s, 32*s, DARK_BROWN)

    # Sword at right side
    fill_rect(24*s, 14*s, 26*s, 28*s, BLADE)
    fill_rect(23*s, 20*s, 27*s, 22*s, BROWN_HAIR)  # Sword hilt

    return pixels

def create_warrior_back(size=32):
    """Create back-facing warrior sprite"""
    pixels = [[TRANSPARENT] * size for _ in range(size)]
    s = size / 32

    def fill_rect(x1, y1, x2, y2, color):
        for y in range(int(y1), int(y2)):
            for x in range(int(x1), int(x2)):
                if 0 <= x < size and 0 <= y < size:
                    pixels[y][x] = color

    # Hair (back of head)
    fill_rect(11*s, 2*s, 21*s, 11*s, BROWN_HAIR)
    fill_rect(14*s, 1*s, 18*s, 4*s, BROWN_HAIR)  # Top spike

    # Shoulder pauldrons
    fill_rect(7*s, 11*s, 12*s, 15*s, SILVER)
    fill_rect(20*s, 11*s, 25*s, 15*s, SILVER)

    # Back armor
    fill_rect(11*s, 11*s, 21*s, 22*s, DARK_MAROON)
    fill_rect(15*s, 12*s, 17*s, 21*s, MAROON)  # Center seam

    # Belt
    fill_rect(11*s, 21*s, 21*s, 23*s, BELT_BROWN)

    # Arms
    fill_rect(7*s, 14*s, 11*s, 21*s, DARK_MAROON)
    fill_rect(21*s, 14*s, 25*s, 21*s, DARK_MAROON)

    # Skirt back
    fill_rect(11*s, 22*s, 21*s, 25*s, DARK_MAROON)

    # Legs
    fill_rect(12*s, 25*s, 15*s, 30*s, DARK_GRAY)
    fill_rect(17*s, 25*s, 20*s, 30*s, DARK_GRAY)

    # Boots
    fill_rect(11*s, 29*s, 16*s, 32*s, DARK_BROWN)
    fill_rect(16*s, 29*s, 21*s, 32*s, DARK_BROWN)

    # Sword on back
    fill_rect(14*s, 6*s, 18*s, 26*s, BLADE)
    fill_rect(13*s, 18*s, 19*s, 21*s, BROWN_HAIR)  # Crossguard

    return pixels

def create_warrior_side(size=32, flip=False):
    """Create side-facing warrior sprite"""
    pixels = [[TRANSPARENT] * size for _ in range(size)]
    s = size / 32

    def fill_rect(x1, y1, x2, y2, color):
        if flip:
            x1, x2 = size - x2, size - x1
        for y in range(int(y1), int(y2)):
            for x in range(int(x1), int(x2)):
                if 0 <= x < size and 0 <= y < size:
                    pixels[y][x] = color

    # Hair (side)
    fill_rect(12*s, 2*s, 20*s, 10*s, BROWN_HAIR)
    fill_rect(16*s, 1*s, 20*s, 4*s, BROWN_HAIR)  # Top spike

    # Face (side)
    fill_rect(10*s, 5*s, 14*s, 11*s, SKIN)
    fill_rect(9*s, 6*s, 10*s, 10*s, SKIN_SHADOW)

    # Eye
    fill_rect(10*s, 7*s, 12*s, 9*s, WHITE)
    fill_rect(10*s, 7*s, 11*s, 8*s, BLACK)

    # Shoulder pauldron (one side visible)
    fill_rect(8*s, 11*s, 14*s, 15*s, SILVER)
    fill_rect(9*s, 12*s, 13*s, 14*s, DARK_SILVER)

    # Body (side view - narrower)
    fill_rect(12*s, 11*s, 20*s, 22*s, MAROON)
    fill_rect(13*s, 12*s, 19*s, 14*s, LIGHT_MAROON)
    fill_rect(15*s, 15*s, 17*s, 21*s, DARK_MAROON)

    # Belt
    fill_rect(12*s, 21*s, 20*s, 23*s, BELT_BROWN)

    # Arm (visible)
    fill_rect(8*s, 14*s, 12*s, 21*s, MAROON)
    fill_rect(9*s, 15*s, 11*s, 20*s, DARK_MAROON)
    fill_rect(8*s, 20*s, 12*s, 22*s, SKIN)

    # Skirt side
    fill_rect(12*s, 22*s, 20*s, 25*s, MAROON)

    # Leg (visible - single)
    fill_rect(13*s, 25*s, 19*s, 30*s, DARK_GRAY)

    # Boot
    fill_rect(12*s, 29*s, 20*s, 32*s, DARK_BROWN)

    # Sword at side
    fill_rect(20*s, 14*s, 23*s, 28*s, BLADE)
    fill_rect(19*s, 20*s, 24*s, 22*s, BROWN_HAIR)

    return pixels

def create_wall_texture(size=32, wall_type='stone'):
    """Create wall texture"""
    pixels = [[TRANSPARENT] * size for _ in range(size)]

    if wall_type == 'stone':
        base = (100, 100, 110)
        dark = (70, 70, 80)
        light = (130, 130, 140)
    elif wall_type == 'brick':
        base = (140, 60, 50)
        dark = (100, 40, 30)
        light = (180, 90, 70)
    elif wall_type == 'moss':
        base = (60, 90, 60)
        dark = (40, 60, 40)
        light = (80, 120, 80)

    # Fill with base color
    for y in range(size):
        for x in range(size):
            pixels[y][x] = base

    # Add stone/brick pattern
    for y in range(size):
        for x in range(size):
            # Brick pattern
            brick_h = 8
            brick_w = 16
            row = y // brick_h
            offset = (brick_w // 2) if row % 2 else 0

            # Mortar lines
            if y % brick_h == 0 or (x + offset) % brick_w == 0:
                pixels[y][x] = dark
            # Random lighter spots for texture
            elif (x * 7 + y * 13) % 23 < 3:
                pixels[y][x] = light
            elif (x * 11 + y * 17) % 29 < 2:
                pixels[y][x] = dark

    return pixels

# Generate all sprites
os.makedirs('C:/Users/KyleN/vmupro-raycaster/sprites', exist_ok=True)

# Warrior sprites at 32x32
print("Creating warrior front...")
create_png(32, 32, create_warrior_front(32),
           'C:/Users/KyleN/vmupro-raycaster/sprites/warrior_front.png')

print("Creating warrior back...")
create_png(32, 32, create_warrior_back(32),
           'C:/Users/KyleN/vmupro-raycaster/sprites/warrior_back.png')

print("Creating warrior left...")
create_png(32, 32, create_warrior_side(32, flip=False),
           'C:/Users/KyleN/vmupro-raycaster/sprites/warrior_left.png')

print("Creating warrior right...")
create_png(32, 32, create_warrior_side(32, flip=True),
           'C:/Users/KyleN/vmupro-raycaster/sprites/warrior_right.png')

print("Done! Sprites created in sprites/ folder")
