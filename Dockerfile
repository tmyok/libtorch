ARG cuda_version=11.6.2
ARG cudnn_version=8
ARG ubuntu=20.04
FROM nvidia/cuda:${cuda_version}-cudnn${cudnn_version}-devel-ubuntu${ubuntu}

LABEL maintainer "Tomoya Okazaki"

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt -y update && apt -y upgrade && \
        apt install -y --no-install-recommends \
        build-essential \
        git \
        less \
        libgl1-mesa-dev \
        libglib2.0-0 \
        libgtk2.0-dev \
        libjpeg-dev \
        libopenexr-dev \
        libpng-dev \
        libsm6 \
        libssl-dev \
        libtiff-dev \
        libwebp-dev \
        libxext-dev \
        libxrender1 \
        pkg-config \
        python3-dev \
        python3-numpy \
        python3-pip \
        unzip \
        vim \
        wget && \
        apt -y clean && \
    rm -rf /var/lib/apt/lists/*

# CMake
WORKDIR /home
RUN wget -O - https://github.com/Kitware/CMake/releases/download/v3.23.2/cmake-3.23.2.tar.gz | tar zxvf -
WORKDIR /home/cmake-3.23.2/
RUN ./bootstrap && make && make install && rm -r /home/cmake-3.23.2

# LibTorch
WORKDIR /home
RUN wget https://download.pytorch.org/libtorch/cu113/libtorch-cxx11-abi-shared-with-deps-1.11.0%2Bcu113.zip
RUN unzip libtorch-cxx11-abi-shared-with-deps-1.11.0+cu113.zip
RUN rm libtorch-cxx11-abi-shared-with-deps-1.11.0+cu113.zip

# OpenCV
WORKDIR /home
RUN wget -O - https://github.com/opencv/opencv/archive/4.6.0.tar.gz | tar zxvf -
WORKDIR /home/opencv-4.6.0/build
RUN cmake -D WITH_CUDA=OFF \
          -D BUILD_DOCS=OFF \
          -D BUILD_TESTS=OFF .. && \
    make -j $(nproc) && \
    make install && \
    rm -r /home/opencv-4.6.0

# Google Test
WORKDIR /home
RUN wget -O - https://github.com/google/googletest/archive/release-1.10.0.tar.gz | tar zxvf -
WORKDIR /home/googletest-release-1.10.0/build
RUN cmake .. && \
    make install && \
    rm -r /home/googletest-release-1.10.0

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install setuptools==62.6.0

RUN python3 -m pip install hydra-core==1.2.0
RUN python3 -m pip install optuna==2.10.1
RUN python3 -m pip install hydra-optuna-sweeper==1.2.0
RUN python3 -m pip install pandas==1.4.3
RUN python3 -m pip install scikit-learn==1.1.1
RUN python3 -m pip install tqdm==4.64.0

RUN python3 -m pip install mlflow==1.26.1
RUN python3 -m pip install boto3==1.24.16

RUN python3 -m pip install matplotlib==3.5.2
RUN python3 -m pip install seaborn==0.11.2

WORKDIR /home
