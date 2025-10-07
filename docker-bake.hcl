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
    default = "ashleykza/runpod-base"
}

variable "BASE_IMAGE_VERSION" {
    default = "2.4.5"
}

group "default" {
    targets = ["cu124-py312"]
}

group "all" {
    targets = ["cu124-py312"]
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

