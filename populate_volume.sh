#!/bin/bash
# Populate the RunPod Network Volume with all models needed by the wan2.2-remix-nsfw worker.
# Run this ONCE on a pod that has the network volume mounted at /runpod-volume.
#
# Usage: bash populate_volume.sh
set -e

VOL=/runpod-volume

echo "[1/8] VAE"
curl -L --create-dirs -o "$VOL/models/vae/wan_2.1_vae.safetensors" \
  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

echo "[2/8] Diffusion: high lighting"
curl -L --create-dirs \
  -o "$VOL/models/diffusion_models/Wan2.2_Remix_NSFW_i2v_14b_high_lighting_fp8_e4m3fn_v2.1.safetensors" \
  "https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_high_lighting_fp8_e4m3fn_v2.1.safetensors"

echo "[3/8] Diffusion: low lighting"
curl -L --create-dirs \
  -o "$VOL/models/diffusion_models/Wan2.2_Remix_NSFW_i2v_14b_low_lighting_fp8_e4m3fn_v2.1.safetensors" \
  "https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_low_lighting_fp8_e4m3fn_v2.1.safetensors"

echo "[4/8] Text encoder"
curl -L --create-dirs \
  -o "$VOL/models/text_encoders/nsfw_wan_umt5-xxl_bf16_fixed.safetensors" \
  "https://huggingface.co/zootkitty/nsfw_wan_umt5-xxl_bf16_fixed/resolve/main/nsfw_wan_umt5-xxl_bf16_fixed.safetensors"

echo "[5/8] LoRA: DR34ML4Y high"
curl -L --create-dirs \
  -o "$VOL/models/loras/DR34ML4Y_I2V_14B_HIGH_V2.safetensors" \
  "https://huggingface.co/Serenak/chilloutmix/resolve/main/DR34ML4Y_I2V_14B_HIGH_V2.safetensors"

echo "[6/8] LoRA: DR34ML4Y low"
curl -L --create-dirs \
  -o "$VOL/models/loras/DR34ML4Y_I2V_14B_LOW_V2.safetensors" \
  "https://huggingface.co/Serenak/chilloutmix/resolve/main/DR34ML4Y_I2V_14B_LOW_V2.safetensors"

echo "[7/8] LoRA: lightx2v high"
curl -L --create-dirs \
  -o "$VOL/models/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" \
  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors"

echo "[8/8] LoRA: lightx2v low"
curl -L --create-dirs \
  -o "$VOL/models/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors" \
  "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors"

echo ""
echo "Done. Volume contents:"
du -sh "$VOL/models"/*
