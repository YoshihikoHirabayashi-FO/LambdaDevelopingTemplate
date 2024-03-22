FROM amazonlinux:2023

RUN yum update -y \
 && yum install -y \
        git \
        gcc \
        make \
        automake \
        autoconf \
        patch \
        openssl-devel \
        readline-devel \
        bzip2-devel \
        sqlite-devel \
        tar \
        zip \
        lzma \
        xz-devel \
        zlib-devel \
        libffi \
        libffi-devel \
        libxml2 \
        libxml2-devel \
        libxslt \
        libxslt-devel \
        libjpeg-turbo \
        libjpeg-turbo-devel \
        libpng \
        libpng-devel \
        freetype \
        freetype-devel \
        rsync

ENV PATH="/root/.pyenv/bin:/root/.pyenv/shims:$PATH"

RUN cd ~ \
 && git clone https://github.com/pyenv/pyenv.git .pyenv \
 && pyenv install 3.12

# エントリポイントを設定
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
