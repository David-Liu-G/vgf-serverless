FROM runpod/worker-comfyui:5.7.1-base

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Custom nodes
RUN comfy node install --exit-on-fail comfyui-kjnodes
RUN comfy node install --exit-on-fail comfyui-videohelpersuite
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/vrgamegirl19/comfyui-vrgamedevgirl.git
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/princepainter/ComfyUI-PainterI2Vadvanced.git && \
    cd ComfyUI-PainterI2Vadvanced && \
    if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

# Bake models into the image — eliminates region-lock from network volumes.
# Total ~41 GB across vae/diffusion_models/text_encoders/loras.
USER root
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
WORKDIR /comfyui/models

RUN curl -fL --create-dirs -o vae/wan_2.1_vae.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"

RUN curl -fL --create-dirs -o diffusion_models/Wan2.2_Remix_NSFW_i2v_14b_high_lighting_fp8_e4m3fn_v2.1.safetensors \
    "https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_high_lighting_fp8_e4m3fn_v2.1.safetensors"

RUN curl -fL --create-dirs -o diffusion_models/Wan2.2_Remix_NSFW_i2v_14b_low_lighting_fp8_e4m3fn_v2.1.safetensors \
    "https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_low_lighting_fp8_e4m3fn_v2.1.safetensors"

RUN curl -fL --create-dirs -o text_encoders/nsfw_wan_umt5-xxl_bf16_fixed.safetensors \
    "https://huggingface.co/zootkitty/nsfw_wan_umt5-xxl_bf16_fixed/resolve/main/nsfw_wan_umt5-xxl_bf16_fixed.safetensors"

RUN curl -fL --create-dirs -o loras/DR34ML4Y_I2V_14B_HIGH_V2.safetensors \
    "https://huggingface.co/Serenak/chilloutmix/resolve/main/DR34ML4Y_I2V_14B_HIGH_V2.safetensors"
RUN curl -fL --create-dirs -o loras/DR34ML4Y_I2V_14B_LOW_V2.safetensors \
    "https://huggingface.co/Serenak/chilloutmix/resolve/main/DR34ML4Y_I2V_14B_LOW_V2.safetensors"
RUN curl -fL --create-dirs -o loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors"
RUN curl -fL --create-dirs -o loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors"

RUN pip install requests runpod
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

CMD ["/bin/bash", "-c", "python /rp_handler.py 2>&1 & cd /comfyui && exec python main.py --listen 0.0.0.0 --port 8188"]
