FROM python:3.10-alpine

ARG ANSIBLE_VERSION "2.12.1"

RUN apk --no-cache add \
        sudo \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        rsync \
        git && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        musl-dev \
        gcc \
        cargo \
        openssl-dev \
        libressl-dev \
        build-base && \
    pip install --upgrade pip wheel && \
    pip install --upgrade cryptography cffi && \
    pip install ansible-core==${ANSIBLE_VERSION} && \
    pip install mitogen && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip && \
    rm -rf /root/.cargo

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

ADD requirements.yml /ansible/

RUN ansible-galaxy collection install -r /tmp/requirements.yml && \
    rm -f /tmp/requirements.yml

ENTRYPOINT ["/bin/sh", "-c"]
