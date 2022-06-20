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
    ANSIBLE_CFG_PATH='/etc/ansible' && \
    mkdir -p ${ANSIBLE_CFG_PATH} && \
    SITE_PACKAGES_PATH=$(python3 -c 'import site; print(site.getsitepackages()[0])') && \
    echo '[defaults]' >> ${ANSIBLE_CFG_PATH}/ansible.cfg && \
    echo 'strategy = mitogen_linear' >> ${ANSIBLE_CFG_PATH}/ansible.cfg && \
    echo "strategy_plugins = ${SITE_PACKAGES_PATH}/ansible_mitogen/plugins/strategy" >> ${ANSIBLE_CFG_PATH}/ansible.cfg && \
    echo 'localhost' > ${ANSIBLE_CFG_PATH}/hosts

WORKDIR /ansible

ADD requirements.yml /tmp/

RUN ansible-galaxy collection install -r /tmp/requirements.yml && \
    rm -f /tmp/requirements.yml

ENTRYPOINT ["/bin/sh", "-c"]
