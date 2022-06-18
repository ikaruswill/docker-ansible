FROM alpine:3.16

ARG ANSIBLE_VERSION="2.12.6"

RUN apk --no-cache add \
        sudo \
        python3 \
        py3-pip \
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
    pip3 install --upgrade pip wheel && \
    pip3 install --upgrade cryptography cffi && \
    pip3 install ansible-core==${ANSIBLE_VERSION} && \
    pip3 install mitogen && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache/pip && \
    rm -rf /root/.cargo

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    SITE_PACKAGES_PATH=$(python3 -c 'import site; print(site.getsitepackages()[0])') && \
    echo '[default]' >> /etc/ansible/ansible.cfg && \
    echo 'strategy = mitogen_linear' >> /etc/ansible/ansible.cfg && \
    echo "strategy_plugins = ${SITE_PACKAGES_PATH}/ansible_mitogen/plugins/strategy" >> /etc/ansible/ansible.cfg && \
    echo 'localhost' > /etc/ansible/hosts

WORKDIR /ansible

ADD requirements.yml /tmp/

RUN ansible-galaxy collection install -r /tmp/requirements.yml && \
    rm -f /tmp/requirements.yml

ENTRYPOINT ["/bin/sh", "-c"]
