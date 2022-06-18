FROM python:3.10-alpine

RUN pip install -r requirements.txt
RUN ansible-galaxy collection install -r requirements.yml

ENTRYPOINT ["/bin/sh", "-c"]
