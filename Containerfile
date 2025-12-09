FROM ubuntu:22.04

ENV XCRYSDEN_TAR_FILE=xcrysden-1.6.2-linux_x86_64-shared.tar.gz
ENV XCRYSDEN_DOWNLOAD_URL="http://www.xcrysden.org/download/${XCRYSDEN_TAR_FILE}"
ENV XCRYSDEN_INSTALL_DIR=/opt/xcrysden

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bc \
        wget \
        tar \
        tk \
        libglu1-mesa \
        libtogl2 \
        libfftw3-3 \
        libxmu6 \
        imagemagick \
        openbabel \
        libgfortran5 \
        mesa-utils \
        && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${XCRYSDEN_INSTALL_DIR} && \
    wget -O /tmp/${XCRYSDEN_TAR_FILE} ${XCRYSDEN_DOWNLOAD_URL} && \
    tar -xzf /tmp/${XCRYSDEN_TAR_FILE} -C ${XCRYSDEN_INSTALL_DIR} --strip-components=1 && \
    rm /tmp/${XCRYSDEN_TAR_FILE}

RUN sed -i '/set toglOpt(accum)/s/^#//g' \
    "${XCRYSDEN_INSTALL_DIR}/Tcl/custom-definitions"

ENV PATH="${XCRYSDEN_INSTALL_DIR}/bin:${PATH}"

CMD "${XCRYSDEN_INSTALL_DIR}/xcrysden"
