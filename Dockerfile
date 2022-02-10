ARG cuda_version=10.2
ARG cudnn_version=7
ARG ubuntu=18.04
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
RUN wget -O - https://github.com/Kitware/CMake/releases/download/v3.22.2/cmake-3.22.2.tar.gz | tar zxvf -
WORKDIR /home/cmake-3.22.2/
RUN ./bootstrap && make && make install && rm -r /home/cmake-3.22.2

# LibTorch
WORKDIR /home
RUN wget https://download.pytorch.org/libtorch/cu102/libtorch-cxx11-abi-shared-with-deps-1.7.1.zip
RUN unzip libtorch-cxx11-abi-shared-with-deps-1.7.1.zip
RUN rm libtorch-cxx11-abi-shared-with-deps-1.7.1.zip

# OpenCV
WORKDIR /home
RUN wget -O - https://github.com/opencv/opencv/archive/4.5.0.tar.gz | tar zxvf -
WORKDIR /home/opencv-4.5.0/build
RUN cmake -D WITH_CUDA=OFF \
		  -D BUILD_DOCS=OFF \
		  -D BUILD_TESTS=OFF .. && \
	make -j $(nproc) && \
	make install && \
	rm -r /home/opencv-4.5.0

# Google Test
WORKDIR /home
RUN wget -O - https://github.com/google/googletest/archive/release-1.10.0.tar.gz | tar zxvf -
WORKDIR /home/googletest-release-1.10.0/build
RUN cmake .. && \
	make install && \
	rm -r /home/googletest-release-1.10.0

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install setuptools==60.8.1

RUN python3 -m pip install hydra-core==1.1.1
RUN python3 -m pip install optuna==2.10.0
RUN python3 -m pip install pandas==1.1.5
RUN python3 -m pip install tqdm==4.62.3

RUN python3 -m pip install mlflow==1.23.1
RUN python3 -m pip install boto3==1.20.51

RUN python3 -m pip install matplotlib==3.5.1
RUN python3 -m pip install seaborn==0.11.2

WORKDIR /home
