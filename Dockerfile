# FROM reg.aichallenge.ir/aic/base/infra/compiler:v4
# FROM reg.aichallenge.ir/python:3.8
FROM reg.aichallenge.ir/aic22-infra-compiler:768-c8accdd3

# Docker image for building AIC22 C++ client
# source code should be mounted to /src

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    autoconf \
    libtool \
    pkg-config \
    cmake \
    vim

# Install yaml-cpp
RUN git clone https://github.com/jbeder/yaml-cpp.git --branch yaml-cpp-0.6.0 \
    && cd yaml-cpp \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make install

# Install protobuf
RUN git clone --recurse-submodules -b v1.45.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc \
    && cd grpc/third_party/protobuf \
    && ./autogen.sh \  
    && ./configure \  
    && make -j $(( $(nproc) - 1 )) \
    && make install \
    && ldconfig  

# Install gRPC
RUN export MY_INSTALL_DIR=$HOME/.local \
    && mkdir -p $MY_INSTALL_DIR \
    && export PATH=$MY_INSTALL_DIR/bin:$PATH \
    && cd grpc \
    && mkdir -p cmake/build \
    && pushd cmake/build \
    && cmake -DgRPC_INSTALL=ON \
      -DgRPC_BUILD_TESTS=OFF \
      -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR \
      ../.. \
    && make -j $(( $(nproc) - 1 )) \
    && make install \
    && popd

# Clean up
RUN rm -rf yaml-cpp \
    && rm -rf grpc \
    && apt-get remove -y \
        git \
        build-essential \
        autoconf \
        libtool \
        pkg-config \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN echo 'export PATH="/root/.local/bin":$PATH' >> ~/.bashrc 

RUN apt update && apt install -y vim curl gettext
RUN apt-get update && \
    apt install -y vim curl gettext cmake unzip

COPY ./base_lib_req.txt ./
RUN pip install --upgrade pip
RUN pip install -r base_lib_req.txt -f https://download.pytorch.org/whl/torch_stable.html
# install code
WORKDIR /home
ADD ./requirements.txt ./requirements.txt
# ENV PIP_NO_CACHE_DIR 1
RUN pip install -r ./requirements.txt

ADD ./src ./src
ADD ./scripts ./scripts

RUN chmod +x scripts/compile.sh
RUN chmod +x src/compiler-psudo.sh


# make logging directory
RUN mkdir -p /var/log/compiler
WORKDIR /home/src
ENTRYPOINT ["python", "-u", "main.py"]
