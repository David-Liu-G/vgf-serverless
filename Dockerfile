FROM runpod/worker-comfyui:5.7.1-base

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Custom nodes
RUN comfy node install --exit-on-fail comfyui-kjnodes
RUN comfy node install --exit-on-fail comfyui-videohelpersuite
# Skip vrgamedevgirl's requirements.txt — pulls in llama-cpp-python/demucs/librosa
# that fail to wheel-build and we don't need for FastUnsharpSharpen.
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/vrgamegirl19/comfyui-vrgamedevgirl.git
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/princepainter/ComfyUI-PainterI2Vadvanced.git && \
    cd ComfyUI-PainterI2Vadvanced && \
    if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

# Models live on a RunPod Network Volume mounted at /runpod-volume.
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml

RUN pip install requests runpod
COPY workflow_api.json /workflow_api.json
COPY rp_handler.py /rp_handler.py

CMD ["/bin/bash", "-c", "cd /comfyui && python main.py --listen 0.0.0.0 --port 8188 & python /rp_handler.py"]
