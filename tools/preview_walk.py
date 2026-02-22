import argparse
import os
import time
import tkinter as tk
from PIL import Image, ImageTk

DEFAULT_FRAMES = [
    "warrior_walk1.png",
    "warrior_walk2.png",
    "warrior_walk3.png",
]


def load_frames(sprite_dir, frame_names, target_height):
    frames = []
    for name in frame_names:
        path = os.path.join(sprite_dir, name)
        img = Image.open(path).convert("RGBA")
        if target_height:
            w, h = img.size
            scale = target_height / float(h)
            new_w = int(round(w * scale))
            img = img.resize((new_w, target_height), Image.NEAREST)
        frames.append((name, img))
    return frames


def make_checkerboard(w, h, cell=8):
    bg = Image.new("RGBA", (w, h), (60, 60, 60, 255))
    pixels = bg.load()
    for y in range(h):
        for x in range(w):
            if ((x // cell) + (y // cell)) % 2 == 0:
                pixels[x, y] = (80, 80, 80, 255)
    return bg


def main():
    parser = argparse.ArgumentParser(description="Simple sprite flipbook viewer")
    parser.add_argument("--dir", default=os.path.join(os.getcwd(), "sprites"), help="Sprite directory")
    parser.add_argument("--frames", nargs="*", default=DEFAULT_FRAMES, help="Frame filenames")
    parser.add_argument("--height", type=int, default=120, help="Target display height (px)")
    parser.add_argument("--fps", type=int, default=6, help="Frames per second")
    parser.add_argument("--diff", action="store_true", help="Enable diff blink mode (first two frames)")
    parser.add_argument("--diff-overlay", action="store_true", help="Show difference overlay in diff mode")
    parser.add_argument("--pair", nargs=2, metavar=("A", "B"), help="Two frame filenames to diff-blink")
    parser.add_argument("--device-preview", action="store_true", help="Preview at 240x240 with ground alignment")
    parser.add_argument("--device-scale", type=float, default=1.0, help="Scale factor in device preview")
    parser.add_argument("--grid", action="store_true", help="Show 10px grid overlay in device preview")
    parser.add_argument("--ground-line", action="store_true", help="Show ground line in device preview")
    args = parser.parse_args()

    frames = load_frames(args.dir, args.frames, args.height)
    if args.pair:
        # Replace frames list with the selected pair
        frames = load_frames(args.dir, list(args.pair), args.height)
    if not frames:
        raise SystemExit("No frames loaded")

    max_w = max(img.width for _, img in frames)
    max_h = max(img.height for _, img in frames)
    if args.device_preview:
        max_w = 240
        max_h = 240

    root = tk.Tk()
    root.title("Sprite Flipbook")
    canvas = tk.Canvas(root, width=max_w + 40, height=max_h + 60, bg="#222")
    canvas.pack()

    checker = make_checkerboard(max_w, max_h)
    checker_tk = ImageTk.PhotoImage(checker)
    bg_id = canvas.create_image(20, 20, anchor="nw", image=checker_tk)

    current = {"idx": 0, "paused": False}

    def render_frame():
        name, img = frames[current["idx"]]
        frame = Image.new("RGBA", (max_w, max_h), (0, 0, 0, 0))
        if args.device_preview:
            # Center horizontally, align to "ground" at bottom of 240x240
            scaled = img
            if args.device_scale != 1.0:
                sw = int(round(img.width * args.device_scale))
                sh = int(round(img.height * args.device_scale))
                scaled = img.resize((sw, sh), Image.NEAREST)
            x = (max_w - scaled.width) // 2
            y = max_h - scaled.height
            frame.paste(scaled, (x, y), scaled)
            if args.grid:
                # 10px grid
                for gx in range(0, max_w, 10):
                    for gy in range(0, max_h, 10):
                        if (gx % 20 == 0) or (gy % 20 == 0):
                            frame.putpixel((gx, gy), (120, 120, 120, 255))
            if args.ground_line:
                # Ground line at bottom
                for gx in range(max_w):
                    frame.putpixel((gx, max_h - 1), (255, 255, 255, 255))
        else:
            x = (max_w - img.width) // 2
            y = max_h - img.height
            frame.paste(img, (x, y), img)

        if args.diff and len(frames) >= 2 and args.diff_overlay:
            # Overlay absolute diff between first two frames
            base = frames[0][1].resize((max_w, max_h), Image.NEAREST)
            other = frames[1][1].resize((max_w, max_h), Image.NEAREST)
            diff = ImageChops.difference(base, other)
            # Boost diff visibility
            diff = diff.point(lambda p: 255 if p > 20 else 0)
            frame = Image.alpha_composite(frame, diff)

        tk_img = ImageTk.PhotoImage(frame)
        canvas.image = tk_img
        canvas.create_image(20, 20, anchor="nw", image=tk_img)
        canvas.delete("label")
        label = f"{current['idx'] + 1}/{len(frames)}  {name}"
        canvas.create_text(20, max_h + 35, anchor="nw", fill="#fff", text=label, tags="label")

    def tick():
        if not current["paused"]:
            if args.diff and len(frames) >= 2:
                # Blink between first two frames
                current["idx"] = 1 if current["idx"] == 0 else 0
            else:
                current["idx"] = (current["idx"] + 1) % len(frames)
            render_frame()
        root.after(int(1000 / args.fps), tick)

    def on_key(event):
        if event.keysym == "space":
            current["paused"] = not current["paused"]
        elif event.keysym == "Right":
            current["idx"] = (current["idx"] + 1) % len(frames)
            render_frame()
        elif event.keysym == "Left":
            current["idx"] = (current["idx"] - 1) % len(frames)
            render_frame()
        elif event.keysym == "Escape":
            root.destroy()

    root.bind("<Key>", on_key)
    render_frame()
    root.after(int(1000 / args.fps), tick)
    root.mainloop()


if __name__ == "__main__":
    main()
