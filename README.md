# Virtual Girlfriend — RunPod Serverless Worker

Wan 2.2 Remix NSFW I2V on RunPod Serverless. Models live on a RunPod Network Volume (~$2-3/mo idle) for fast cold starts.

Adapted from [bhavya1600/wan-remix](https://github.com/bhavya1600/wan-remix).

## Architecture

```
┌─────────────────┐       ┌──────────────────────────┐
│ Serverless      │       │ Network Volume (~30 GB)  │
│ workers (image) │──────▶│ /runpod-volume/models/   │
│  ~3 GB image    │ mount │  diffusion_models/       │
│  ComfyUI + nodes│       │  text_encoders/          │
│  rp_handler.py  │       │  vae/                    │
└─────────────────┘       │  loras/                  │
                          └──────────────────────────┘
```

## Setup steps

### 1. Create the network volume
RunPod Console → Storage → Network Volumes → New Volume.
- Size: 40 GB (gives ~10 GB headroom)
- Region: pick the same region you'll deploy serverless workers in (e.g. `US-MO-1`)
- Name: `vgf-models`

### 2. Populate the volume (one-time)
Spin up a tiny pod with the volume mounted, run `populate_volume.sh`, terminate.

```bash
# RunPod Console → Pods → Deploy:
#   GPU: cheapest available (RTX 2000 Ada ~$0.12/hr — we just need wget bandwidth)
#   Volume: select vgf-models, mount at /runpod-volume
#   Container disk: 10 GB (we don't write to it)
#   Template: any Ubuntu image with curl
#   Container Start Command: sleep infinity
#
# Then via web terminal or SSH:
curl -O https://raw.githubusercontent.com/<your-fork>/vgf-serverless/main/populate_volume.sh
bash populate_volume.sh
# Wait ~5-10 min for downloads (~30 GB total)
# Verify: du -sh /runpod-volume/models/*
# Terminate the pod when done.
```

### 3. Build & push the worker image
~3 GB image. Any Docker host works.

```bash
export DOCKER_USER=yourname
docker build -t $DOCKER_USER/vgf-worker:latest .
docker push $DOCKER_USER/vgf-worker:latest
```

If you don't have Docker locally, use the same temporary RunPod pod from step 2 (uncomment Docker install in its setup).

### 4. Create the serverless endpoint
RunPod Console → Serverless → New Endpoint.
- Container image: `$DOCKER_USER/vgf-worker:latest`
- GPU: H100 (or A100 80GB / RTX 4090 — fp8 14B fits in 24 GB)
- Network volume: select `vgf-models`, mount at `/runpod-volume`
- Max workers: 1
- Idle timeout: 5 s
- Container disk: 20 GB
- Save → endpoint ID is in the URL.

### 5. Test
```bash
curl -X POST "https://api.runpod.ai/v2/<ENDPOINT_ID>/runsync" \
  -H "Authorization: Bearer <RUNPOD_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "image": "<base64-of-source.png>",
      "prompt": "A cute girl smiling and waving",
      "length": 81,
      "steps": 8
    }
  }'
```

## Inputs

```json
{
  "input": {
    "image":            "<base64 PNG/JPG>",
    "prompt":           "...",
    "negative_prompt":  "...",
    "seed":             12345,
    "steps":            8,
    "split_step":       4,
    "length":           81,
    "width":            1024,
    "height":           1024,
    "frame_rate":       16,
    "motion_amplitude": 1.0,
    "sharpen_strength": 0.5
  }
}
```

Returns `{ "video": "<base64 mp4>", "filename": "...", "seed": ... }`.

## Cost

| | Per |
|---|---|
| Network volume | $0.07/GB/mo × 40 GB = **$2.80/mo** |
| Active GPU | ~$0.001/s on H100 ≈ **$0.06-0.09 per 5-sec video** |
| Idle workers | $0 (5 s timeout) |
