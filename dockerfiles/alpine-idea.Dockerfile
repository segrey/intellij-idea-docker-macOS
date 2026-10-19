FROM alpine:3.24.2

ARG INSTALLER_FILENAME

# https://youtrack.jetbrains.com/articles/JBR-A-2/JetBrains-Runtime-on-musl-based-Systems
RUN apk update && apk add --no-cache \
    # gcompat is needed to launch `/opt/intellij-idea/bin/idea` executable \
    gcompat \
    libstdc++ \
    wget \
    tar \
    less \
    fontconfig \
    font-liberation \
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

# The IDE's bundled JBR is linked against glibc and does not load on musl, so the IDE
# runs on the musl build of the same JBR version, published by JetBrains.
RUN JBR_VERSION=$(sed -n 's/^JAVA_VERSION="\(.*\)"/\1/p' /opt/intellij-idea/jbr/release) && \
    JBR_BUILD=$(sed -n 's/^JAVA_RUNTIME_VERSION=".*-\(b[0-9.]*\)"/\1/p' /opt/intellij-idea/jbr/release) && \
    case "$(uname -m)" in aarch64) JBR_ARCH=aarch64 ;; x86_64) JBR_ARCH=x64 ;; *) exit 1 ;; esac && \
    JBR_FILENAME="jbr-${JBR_VERSION}-linux-musl-${JBR_ARCH}-${JBR_BUILD}.tar.gz" && \
    wget -O "/tmp/$JBR_FILENAME" "https://cache-redirector.jetbrains.com/intellij-jbr/$JBR_FILENAME" && \
    mkdir -p /opt/jbr && \
    tar -xzf "/tmp/$JBR_FILENAME" -C /opt/jbr --strip-components=1 && \
    rm "/tmp/$JBR_FILENAME"

RUN adduser -D -h /home/my_user -s /bin/sh my_user
USER my_user

WORKDIR /home/my_user

RUN mkdir -p /home/my_user/projects/my-project

ENV IDEA_JDK=/opt/jbr
CMD ["/opt/intellij-idea/bin/idea", "/home/my_user/projects/my-project"]
