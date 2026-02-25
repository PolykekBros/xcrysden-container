FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV XCRYSDEN_VERSION=1.6.2
ENV XCRYSDEN_TAR_SRC=xcrysden-${XCRYSDEN_VERSION}.tar.gz
ENV XCRYSDEN_INSTALL_DIR=/opt/xcrysden

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    bc \
    wget \
    ca-certificates \
    tar \
    tk \
    libglu1-mesa \
    libtogl2 \
    libtogl-dev \
    libfftw3-3 \
    libxmu6 \
    imagemagick \
    openbabel \
    libgfortran5 \
    mesa-utils \
    make \
    gcc \
    gfortran \
    tcl-dev \
    tk-dev \
    libgl1-mesa-dev \
    libgl1-mesa-dri \
    libosmesa6 \
    libglu1-mesa-dev \
    libfftw3-dev \
    libxmu-dev \
    libx11-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "Building XCrySDen from source..." && \
    mkdir -p /tmp/xcrysden-src && \
    wget -qO- "http://www.xcrysden.org/download/${XCRYSDEN_TAR_SRC}" | tar -xzf - -C /tmp/xcrysden-src --strip-components=1 && \
    cd /tmp/xcrysden-src && \
    cp system/Make.sys-shared Make.sys && \
    sed -i 's/CFLAGS +=/CFLAGS += -fcommon /' Make.sys && \
    make all && \
    make prefix=${XCRYSDEN_INSTALL_DIR} install && \
    cd / && \
    rm -rf /tmp/xcrysden-src && \
    apt-get remove -y make gcc gfortran tcl-dev tk-dev libgl1-mesa-dev libglu1-mesa-dev libfftw3-dev libxmu-dev libx11-dev libtogl-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="${XCRYSDEN_INSTALL_DIR}/bin:${PATH}"

RUN sed -i 's/#set toglOpt(accum)  false/set toglOpt(accum)  false/' \
    "${XCRYSDEN_INSTALL_DIR}/share/xcrysden-${XCRYSDEN_VERSION}/Tcl/custom-definitions"

CMD ["xcrysden"]
