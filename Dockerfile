FROM python:3.8-alpine

# Commands by ROOT user
USER root

# Installing base packages
RUN apk add --no-cache openssl openssh py-pip
RUN pip install --no-cache-dir wheel
RUN pip install --no-cache-dir --user docopt==0.6.2
RUN pip install --no-cache-dir --user requests
RUN pip install --no-cache-dir awscli
RUN ssh-keygen -A
