FROM python:3.10-alpine

ADD requirements.txt requirements.yml /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt \
    && rm -f /tmp/requirements.txt
RUN ansible-galaxy collection install -r /tmp/requirements.yml \
    && rm -f /tmp/requirements.yml

ENTRYPOINT ["/bin/sh", "-c"]
