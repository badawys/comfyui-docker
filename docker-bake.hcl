variable "REGISTRY" {
    default = "docker.io"
}

variable "REGISTRY_USER" {
    default = "badawys"
}

variable "APP" {
    default = "comfyui"
}

variable "RELEASE" {
    default = "v0.3.63"
}

variable "BASE_IMAGE_REPOSITORY" {
    default = "badawys/runpod-qwen-image-edit-comfyui"
}

variable "BASE_IMAGE_VERSION" {
    default = "1.0.0"
}

group "default" {
    targets = ["cu124-py312"]
}

group "all" {
    targets = [
        "cu124-py311",
        "cu124-py312",
        "cu128-py311",
        "cu128-py312"
    ]
}

target "cu124-py311" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:cu124-py311-${RELEASE}"]
    args = {
        RELEASE                    = "${RELEASE}"
        BASE_IMAGE                 = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}-python3.11-cuda12.4.1-torch2.6.0"
        INDEX_URL                  = "https://download.pytorch.org/whl/cu124"
        TORCH_VERSION              = "2.6.0+cu124"
        XFORMERS_VERSION           = "0.0.29.post3"
        COMFYUI_VERSION            = "${RELEASE}"
        APP_MANAGER_VERSION        = "1.2.2"
        CIVITAI_DOWNLOADER_VERSION = "2.1.0"
    }
    platforms = ["linux/amd64"]
}

target "cu124-py312" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:cu124-py312-${RELEASE}"]
    args = {
        RELEASE                    = "${RELEASE}"
        BASE_IMAGE                 = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}-python3.12-cuda12.4.1-torch2.6.0"
        INDEX_URL                  = "https://download.pytorch.org/whl/cu124"
        TORCH_VERSION              = "2.6.0+cu124"
        XFORMERS_VERSION           = "0.0.29.post3"
        COMFYUI_VERSION            = "${RELEASE}"
        APP_MANAGER_VERSION        = "1.2.2"
        CIVITAI_DOWNLOADER_VERSION = "2.1.0"
    }
    platforms = ["linux/amd64"]
}

target "cu128-py311" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:cu128-py311-${RELEASE}"]
    args = {
        RELEASE                    = "${RELEASE}"
        BASE_IMAGE                 = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}-python3.11-cuda12.8.1-torch2.8.0"
        INDEX_URL                  = "https://download.pytorch.org/whl/cu128"
        TORCH_VERSION              = "2.8.0+cu128"
        XFORMERS_VERSION           = "0.0.32.post1"
        COMFYUI_VERSION            = "${RELEASE}"
        APP_MANAGER_VERSION        = "1.2.2"
        CIVITAI_DOWNLOADER_VERSION = "2.1.0"
    }
    platforms = ["linux/amd64"]
}

target "cu128-py312" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:cu128-py312-${RELEASE}"]
    args = {
        RELEASE                    = "${RELEASE}"
        BASE_IMAGE                 = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}-python3.12-cuda12.8.1-torch2.8.0"
        INDEX_URL                  = "https://download.pytorch.org/whl/cu128"
        TORCH_VERSION              = "2.8.0+cu128"
        XFORMERS_VERSION           = "0.0.32.post1"
        COMFYUI_VERSION            = "${RELEASE}"
        APP_MANAGER_VERSION        = "1.2.2"
        CIVITAI_DOWNLOADER_VERSION = "2.1.0"
    }
    platforms = ["linux/amd64"]
}
