#!/usr/bin/env bash
set -e

echo "Downloading Qwen models for ComfyUI..."

# Define the ComfyUI models directory (use workspace if available, fallback to /ComfyUI)
MODELS_DIR="${1:-/workspace/ComfyUI/models}"

# Create a marker file to track if models have been downloaded
MARKER_FILE="${MODELS_DIR}/.qwen_models_downloaded"

# Check if models are already downloaded
if [ -f "${MARKER_FILE}" ]; then
    echo "Qwen models already downloaded. Skipping..."
    exit 0
fi

# Create necessary subdirectories
mkdir -p "${MODELS_DIR}/vae"
mkdir -p "${MODELS_DIR}/text_encoders"
mkdir -p "${MODELS_DIR}/loras"
mkdir -p "${MODELS_DIR}/diffusion_models"

# Function to download a file with retry logic
download_file() {
    local url="$1"
    local output_path="$2"
    local max_retries=3
    local retry_count=0
    
    echo "Downloading: $(basename ${output_path})"
    echo "  From: ${url}"
    echo "  To: ${output_path}"
    
    # Show disk space before download
    echo "  Disk space available:"
    df -h / | tail -1
    
    while [ $retry_count -lt $max_retries ]; do
        if wget --progress=dot:giga -c "${url}" -O "${output_path}"; then
            echo "  ✓ Download successful"
            # Show file size
            ls -lh "${output_path}"
            return 0
        else
            retry_count=$((retry_count + 1))
            echo "  ✗ Download failed. Retry ${retry_count}/${max_retries}..."
            sleep 5
        fi
    done
    
    echo "  ✗ Failed to download after ${max_retries} attempts"
    return 1
}

# Download VAE
echo ""
echo "=== Downloading VAE ==="
download_file \
    "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors" \
    "${MODELS_DIR}/vae/qwen_image_vae.safetensors"

# Download Text Encoder
echo ""
echo "=== Downloading Text Encoder ==="
download_file \
    "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" \
    "${MODELS_DIR}/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"

# Download LoRA
echo ""
echo "=== Downloading LoRA ==="
download_file \
    "https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-4steps-V1.0.safetensors" \
    "${MODELS_DIR}/loras/Qwen-Image-Lightning-4steps-V1.0.safetensors"

# Download Diffusion Model
echo ""
echo "=== Downloading Diffusion Model ==="
download_file \
    "https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_2509_fp8_e4m3fn.safetensors" \
    "${MODELS_DIR}/diffusion_models/qwen_image_edit_2509_fp8_e4m3fn.safetensors"

echo ""
echo "=== All Qwen models downloaded successfully! ==="
echo ""
echo "Model locations:"
echo "  VAE: ${MODELS_DIR}/vae/qwen_image_vae.safetensors"
echo "  Text Encoder: ${MODELS_DIR}/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"
echo "  LoRA: ${MODELS_DIR}/loras/Qwen-Image-Lightning-4steps-V1.0.safetensors"
echo "  Diffusion Model: ${MODELS_DIR}/diffusion_models/qwen_image_edit_2509_fp8_e4m3fn.safetensors"

# Create marker file to indicate successful download
touch "${MARKER_FILE}"
echo ""
echo "Created marker file: ${MARKER_FILE}"
