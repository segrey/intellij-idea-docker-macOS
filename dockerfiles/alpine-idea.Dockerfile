FROM alpine:3.24.2

ARG INSTALLER_FILENAME

# https://youtrack.jetbrains.com/articles/JBR-A-2/JetBrains-Runtime-on-musl-based-Systems
RUN apk update && apk add --no-cache \
    openjdk25-jdk \
    gcompat \
    libstdc++ \
    wget \
    tar \
    less \
    fontconfig \
    font-liberation \
    # JetBrains Mono and Inter are the IDE's default editor/terminal and UI fonts.
    # They ship inside JBR, which this image does not use.
    font-jetbrains-mono \
    font-inter \
    libxext \
    libxrender \
    libxtst \
    libxi \
    libx11

RUN mkdir -p /opt/intellij-idea
WORKDIR /opt/intellij-idea

COPY ./builds/.keep ./builds/$INSTALLER_FILENAME* /opt/intellij-idea/

RUN if [ ! -f "$INSTALLER_FILENAME" ]; then \
      wget -O $INSTALLER_FILENAME --no-check-certificate "https://download.jetbrains.com/idea/$INSTALLER_FILENAME"; \
    fi
RUN tar -xzvf $INSTALLER_FILENAME -C /opt/intellij-idea --strip-components=1
RUN rm $INSTALLER_FILENAME

RUN adduser -D -h /home/my_user -s /bin/sh my_user
USER my_user

WORKDIR /home/my_user

RUN mkdir -p /home/my_user/projects/my-project

ENV IDEA_JDK /usr/lib/jvm/java-25-openjdk
CMD ["/opt/intellij-idea/bin/idea", "/home/my_user/projects/my-project"]
