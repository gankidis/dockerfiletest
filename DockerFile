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

# Unlocking Root Account for SSH
RUN export ROOTPASSWORD=$(openssl rand -base64 1000)
RUN echo "root:$ROOTPASSWORD" | chpasswd

# ADD USER HIRO for Action Handler to Work
ENV USER=hiro
ENV UID=1000
ENV GID=1000
ENV HOMEDIR=/home/$USER

RUN addgroup -S $USER -g $GID
RUN adduser \
    -h "$HOMEDIR" \
    -G "$USER" \
    -u "$UID" \
    -S "$USER"
RUN echo "hiro:dummypass" | chpasswd


# Action Handlers Python Scripts
ADD ActionHandler_MessageQueueService/pushnotificationhandler.py /action-handlers/pushnotificationhandler.py
ADD ActionHandler_InputDataService/pushinputdatahandler.py /action-handlers/pushinputdatahandler.py
ADD ActionHandler_ExternalQueryService/externalqueryhandler.py /action-handlers/externalqueryhandler.py
ADD ActionHandler_BotServer/emaactionhandler.py /action-handlers/emaactionhandler.py

# SSH Service
COPY ./sshd_config /etc/ssh/sshd_config
EXPOSE 22
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd","-D","-E", "/var/log/sshd.log"]

# Exported volume for ssh keys
VOLUME ["/home/hiro/.ssh"]
