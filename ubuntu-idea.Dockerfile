FROM ubuntu:24.04

ARG INSTALLER_FILENAME

RUN apt-get update -y && apt-get install -y --no-install-recommends --allow-remove-essential \
    bash- \
    wget \
    tar \
    libxtst6 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/intellij-idea
WORKDIR /opt/intellij-idea

COPY ./builds/.keep ./builds/$INSTALLER_FILENAME* /opt/intellij-idea/

RUN if [ ! -f "$INSTALLER_FILENAME" ]; then \
      wget -O $INSTALLER_FILENAME --no-check-certificate "https://download.jetbrains.com/idea/$INSTALLER_FILENAME"; \
    fi
RUN tar -xzvf $INSTALLER_FILENAME -C /opt/intellij-idea --strip-components=1
RUN rm $INSTALLER_FILENAME

RUN useradd -m -d /home/my_user -s /bin/sh my_user
USER my_user

WORKDIR /home/my_user

RUN mkdir -p /home/my_user/projects/my-project

CMD ["/opt/intellij-idea/bin/idea", "/home/my_user/projects/my-project"]
