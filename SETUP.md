# Setup Guide for ComfyUI Docker with GitHub Actions

This guide will help you configure your forked repository to automatically build and push Docker images to your Docker Hub account.

## Prerequisites

1. A Docker Hub account
2. Your forked GitHub repository

## Step 1: Configure Docker Hub Credentials

You need to add your Docker Hub credentials as GitHub Secrets:

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add the following secrets:

   - **Name:** `DOCKERHUB_USERNAME`
     - **Value:** Your Docker Hub username
   
   - **Name:** `DOCKERHUB_TOKEN`
     - **Value:** Your Docker Hub access token (create one at https://hub.docker.com/settings/security)

## Step 2: Update docker-bake.hcl

Update the `REGISTRY_USER` variable in `docker-bake.hcl` to match your Docker Hub username:

```hcl
variable "REGISTRY_USER" {
    default = "your-dockerhub-username"  # Change this to your Docker Hub username
}
```

You may also want to update the `RELEASE` version:

```hcl
variable "RELEASE" {
    default = "v0.3.63"  # Update this to your desired version
}
```

## Step 3: Trigger the Build

The GitHub Actions workflow will automatically trigger on:

- **Push to main/master branch** - Builds and pushes all Docker image variants
- **Tag creation** (e.g., `v1.0.0`) - Builds and pushes all Docker image variants
- **Pull requests** - Builds images for testing (without pushing)
- **Manual trigger** - Via GitHub Actions UI (workflow_dispatch)

### Manual Trigger

1. Go to your GitHub repository
2. Navigate to **Actions** tab
3. Select **Build and Push Docker Images** workflow
4. Click **Run workflow**
5. Select the branch and click **Run workflow**

## Step 4: Monitor the Build

1. Go to the **Actions** tab in your GitHub repository
2. Click on the running workflow to see the build progress
3. Each matrix job (cu124-py311, cu124-py312, cu128-py311, cu128-py312) will build in parallel

## What Gets Built

The workflow builds 4 Docker image variants:

1. **cu124-py311** - CUDA 12.4 + Python 3.11
2. **cu124-py312** - CUDA 12.4 + Python 3.12
3. **cu128-py311** - CUDA 12.8 + Python 3.11
4. **cu128-py312** - CUDA 12.8 + Python 3.12

Each image will be tagged as:
```
docker.io/your-username/comfyui:cu124-py311-v0.3.63
docker.io/your-username/comfyui:cu124-py312-v0.3.63
docker.io/your-username/comfyui:cu128-py311-v0.3.63
docker.io/your-username/comfyui:cu128-py312-v0.3.63
```

## Qwen Models Included

The Docker images now include the following Qwen models pre-downloaded:

- **VAE:** `qwen_image_vae.safetensors`
  - Location: `/ComfyUI/models/vae/`
  
- **Text Encoder:** `qwen_2.5_vl_7b_fp8_scaled.safetensors`
  - Location: `/ComfyUI/models/text_encoders/`
  
- **LoRA:** `Qwen-Image-Lightning-4steps-V1.0.safetensors`
  - Location: `/ComfyUI/models/loras/`
  
- **Diffusion Model:** `qwen_image_edit_2509_fp8_e4m3fn.safetensors`
  - Location: `/ComfyUI/models/diffusion_models/`

These models are downloaded during the Docker image build process and will be available immediately when you run the container.

## Testing Locally

Before pushing to GitHub, you can test the build locally:

```bash
# Build a specific variant
docker buildx bake -f docker-bake.hcl cu128-py312

# Build all variants
docker buildx bake -f docker-bake.hcl all

# Build and push to Docker Hub (requires docker login)
docker login
docker buildx bake -f docker-bake.hcl cu128-py312 --push
```

## Troubleshooting

### Build Fails Due to Memory

The Qwen models are large files. If the build fails due to memory issues:

1. Ensure your GitHub Actions runner has sufficient resources
2. Consider building locally and pushing manually
3. You can modify `download_qwen_models.sh` to download fewer models if needed

### Authentication Errors

If you see authentication errors:

1. Verify your `DOCKERHUB_USERNAME` secret is correct
2. Verify your `DOCKERHUB_TOKEN` is valid and has write permissions
3. Regenerate your Docker Hub token if needed

### Models Not Downloading

If models fail to download during build:

1. Check the Hugging Face URLs are still valid
2. Check network connectivity from the build environment
3. Review the build logs for specific error messages

## Next Steps

After successful build:

1. Pull your image: `docker pull your-username/comfyui:cu128-py312-v0.3.63`
2. Run the container following the instructions in the main README.md
3. The Qwen models will be pre-loaded and ready to use

## Customization

### Adding More Models

To add more models, edit `build/download_qwen_models.sh`:

```bash
# Add your model download
download_file \
    "https://huggingface.co/path/to/your/model.safetensors" \
    "${MODELS_DIR}/appropriate_folder/model_name.safetensors"
```

### Changing Build Triggers

Edit `.github/workflows/docker-build.yml` to customize when builds are triggered.

### Building Specific Variants Only

Modify the matrix in `.github/workflows/docker-build.yml`:

```yaml
strategy:
  matrix:
    target: [cu128-py312]  # Build only this variant
```
