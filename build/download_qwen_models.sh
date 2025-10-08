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

# Verify aria2c is available
if ! command -v aria2c &> /dev/null; then
    echo "ERROR: aria2c is not installed. Installing now..."
    apt-get update -qq && apt-get install -y -qq aria2 > /dev/null 2>&1
fi

# Show disk space before download
echo "Disk space available:"
df -h / | tail -1
echo ""
echo "Using aria2c for high-speed parallel downloads..."
echo ""

# Function to download a file with aria2c (supports parallel connections and resume)
download_file() {
    local url="$1"
    local output_path="$2"
    local filename=$(basename "${output_path}")
    local output_dir=$(dirname "${output_path}")
    
    echo "Downloading: ${filename}"
    echo "  From: ${url}"
    
    # aria2c options:
    # -x 16: Use 16 connections per server
    # -s 16: Split file into 16 parts
    # -k 1M: Set piece size to 1MB
    # -c: Continue/resume download
    # --max-tries=5: Retry up to 5 times
    # --retry-wait=3: Wait 3 seconds between retries
    # --max-connection-per-server=16: Max connections per server
    # --min-split-size=1M: Minimum size for splitting
    # --file-allocation=none: Don't pre-allocate file space (faster start)
    # --allow-overwrite=true: Allow overwriting existing files
    # --auto-file-renaming=false: Don't auto-rename files
    
    if aria2c -x 16 -s 16 -k 1M -c \
        --max-tries=5 \
        --retry-wait=3 \
        --max-connection-per-server=16 \
        --min-split-size=1M \
        --file-allocation=none \
        --allow-overwrite=true \
        --auto-file-renaming=false \
        --summary-interval=0 \
        --console-log-level=warn \
        -d "${output_dir}" \
        -o "${filename}" \
        "${url}"; then
        echo "  ✓ Download successful: ${filename}"
        ls -lh "${output_path}"
        return 0
    else
        echo "  ✗ Download failed: ${filename}"
        return 1
    fi
}

# Start time tracking
START_TIME=$(date +%s)

echo "=== Starting parallel downloads of all models ==="
echo ""

# Array to track background process IDs
PIDS=()

# Download VAE in background
echo "Starting download: VAE (qwen_image_vae.safetensors)"
(
    download_file \
        "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors" \
        "${MODELS_DIR}/vae/qwen_image_vae.safetensors"
) &
PIDS+=($!)

# Download Text Encoder in background
echo "Starting download: Text Encoder (qwen_2.5_vl_7b_fp8_scaled.safetensors)"
(
    download_file \
        "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" \
        "${MODELS_DIR}/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"
) &
PIDS+=($!)

# Download LoRA in background
echo "Starting download: LoRA (Qwen-Image-Lightning-4steps-V1.0.safetensors)"
(
    download_file \
        "https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-4steps-V1.0.safetensors" \
        "${MODELS_DIR}/loras/Qwen-Image-Lightning-4steps-V1.0.safetensors"
) &
PIDS+=($!)

# Download Diffusion Model in background
echo "Starting download: Diffusion Model (qwen_image_edit_2509_fp8_e4m3fn.safetensors)"
(
    download_file \
        "https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_2509_fp8_e4m3fn.safetensors" \
        "${MODELS_DIR}/diffusion_models/qwen_image_edit_2509_fp8_e4m3fn.safetensors"
) &
PIDS+=($!)

echo ""
echo "All downloads started in parallel. Waiting for completion..."
echo ""

# Wait for all background processes and check for failures
FAILED=0
for pid in "${PIDS[@]}"; do
    if ! wait "$pid"; then
        FAILED=1
    fi
done

# Check if any download failed
if [ $FAILED -eq 1 ]; then
    echo ""
    echo "✗ One or more downloads failed!"
    exit 1
fi

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

# Calculate and display total time
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo ""
echo "=== Download Statistics ==="
echo "Total time: ${MINUTES} minutes, ${SECONDS} seconds"
echo "Download method: aria2c with 16 parallel connections per file"
echo "All 4 models downloaded simultaneously"
