# Quick Start Guide for Gemini Sprite Generation

## Step 1: Start Gemini Session
Go to gemini.google.com or use Gemini in your preferred interface.

## Step 2: Upload References First
Upload ALL of these images from the `references/` folder:
- warrior_front.png (PRIMARY - always include this one)
- warrior_back.png
- warrior_left.png
- warrior_right.png
- warrior_walk1.png
- warrior_walk2.png
- warrior_walk3.png

## Step 3: Send This Context Message First

```
I'm creating sprites for a video game. I've uploaded reference images of my soldier character. I need you to generate new animation frames that match this character EXACTLY - same armor style, same colors (deep crimson/blood red), same proportions, same art style.

For each sprite I request:
- Create a transparent PNG background
- Match the style of my references exactly
- Show the full body from feet to head
- Use lighting from the upper-left
- Make it suitable for scaling to 517 pixels tall

Please confirm you understand, then I'll give you the first pose to create.
```

## Step 4: Generate Sprites One at a Time

Copy prompts from `GEMINI_MASTER_INSTRUCTIONS.md` for each sprite needed.

### Priority Order:
1. W01, W02, W03 (Front walking)
2. W04, W05, W06 (Back walking)
3. A07, A08, A09 (Left attack)
4. A10, A11, A12 (Right attack)
5. A01-A06 (Front/Back attack)
6. D01-D12 (Death animations)
7. H01-H04 (Hurt animations)

## Step 5: Save Each Result
- Download the PNG
- Name it according to convention (e.g., `warrior_walk_front1.png`)
- Place in `sprites/` folder

## Step 6: Post-Process
- Open in image editor (GIMP, Photoshop, etc.)
- Verify/fix transparent background
- Scale to 517px height
- Save as PNG

## Troubleshooting

**Gemini won't generate the image?**
- Try rephrasing the prompt
- Make sure you're not triggering content filters
- Describe the pose more generically if needed

**Style doesn't match?**
- Re-upload references and emphasize "EXACTLY match this style"
- Point out specific differences and ask for corrections

**Wrong colors?**
- Specify "deep crimson/blood red armor, NOT orange, NOT pink, NOT brown"

**Background not transparent?**
- Explicitly request "PNG with alpha channel transparency, no background whatsoever"
