# Video Input Workflow

`workflow_api_video.json` — variant that takes a **video** file as input instead of an image.

## How it works

Wan 2.2 Remix is fundamentally an Image-to-Video model. This workflow uses VHS_LoadVideo to load your reference video and extracts **only the first frame** to use as the start image. The model then generates a new ~5-sec video starting from that frame, guided by your prompt.

This is **not** true motion transfer (the model doesn't copy motion from your reference video — it generates new motion based on the prompt). True V2V/motion-transfer requires kijai's WanVideoWrapper + a different model variant.

## Use it in ComfyUI

1. Open https://t1uk7jp822e28q-8188.proxy.runpod.net/
2. Drag `workflow_api_video.json` onto the canvas
3. Click the **LoadVideo** node (5) → upload your reference video (mp4 / mov / webm)
4. Edit prompt in CLIPTextEncode (7)
5. Click **Run**

## What you can tune

- `frame_load_cap` (node 5): set higher than 1 if you want to extract a different frame; combine with `skip_first_frames` to pick e.g. middle frame
- `motion_amplitude` (node 15): 1.0 = subtle, 2.0 = exaggerated
- `length` (node 15): output frames count, 121 ≈ 5.7s @ 21fps
- `steps` (nodes 16, 18): 8 (fast, Lightx2v lora) or 25-30 (high quality, slower; bypass Lightx2v loras to use full quality)
- `noise_seed` (node 16): change for different results

## True motion-transfer / V2V (future upgrade path)

For a workflow where the output video matches the *motion* of your reference video (not just first frame), you'd need:

1. Install kijai's `ComfyUI-WanVideoWrapper` (`comfy node install comfyui-wanvideowrapper` in ComfyUI Manager, or `git clone https://github.com/kijai/ComfyUI-WanVideoWrapper` into `/comfyui/custom_nodes/`)
2. Switch to a Wan-Animate or Wan 2.2 V2V model variant — these are different model files than what we currently have baked in
3. Use the wrapper's `WanVideoVideoToVideo` / `WanVideoSampler` nodes with motion conditioning

Easier alternative: install **Wan 2.2 Animate** (specifically for character animation from video reference) — it's the standard tool for "make this person do what's in this reference video".

These changes need a Dockerfile rebuild + image push (~30 min build) so they're better done as a planned upgrade, not a runtime tweak.
