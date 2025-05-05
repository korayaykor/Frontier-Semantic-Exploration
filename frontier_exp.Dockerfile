FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

# Set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    curl \
    vim \
    wget \
    ca-certificates \
    libjpeg-dev \
    libpng-dev \
    libglfw3-dev \
    libglm-dev \
    libx11-dev \
    libomp-dev \
    libegl1-mesa-dev \
    pkg-config \
    software-properties-common \
    python3-pip \
    python3-setuptools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.7
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.7 python3.7-dev python3.7-distutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set Python 3.7 as default
RUN curl https://bootstrap.pypa.io/pip/3.7/get-pip.py -o get-pip.py && \
    python3.7 get-pip.py && \
    rm get-pip.py && \
    ln -sf /usr/bin/python3.7 /usr/bin/python3 && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    python3.7 -m pip --version && \
    ln -sf /usr/local/bin/pip3.7 /usr/local/bin/pip

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install pytorch and torchvision compatible with CUDA 11.7
# Using PyTorch 1.13.1 which supports CUDA 11.7
RUN pip install --no-cache-dir torch==1.13.1+cu117 torchvision==0.14.1+cu117 -f https://download.pytorch.org/whl/torch_stable.html

# Set CUDA home for detectron2
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0 8.6+PTX"
ENV FORCE_CUDA="1"

# Install detectron2 compatible with PyTorch 1.13
RUN pip install --no-cache-dir git+https://github.com/facebookresearch/detectron2.git@v0.6

# Create a working directory
WORKDIR /workspace

# Install habitat-sim
RUN git clone https://github.com/facebookresearch/habitat-sim.git && \
    cd habitat-sim && \
    git checkout tags/challenge-2022 && \
    pip install --no-cache-dir -r requirements.txt && \
    python setup.py install --headless

# Install habitat-lab
RUN git clone https://github.com/facebookresearch/habitat-lab.git && \
    cd habitat-lab && \
    git checkout tags/challenge-2022 && \
    pip install --no-cache-dir -e .

# Set the working directory
WORKDIR /workspace

# Command to run when container starts
CMD ["/bin/bash"]
