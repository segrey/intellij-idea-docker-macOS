FROM amazonlinux:2

ARG INSTALLER_FILENAME

# Amazon Linux 2 ships glibc 2.26. IDEA 263.7031.23 does not start here because its
# bundled JBR needs glibc 2.28; the image exists to reproduce that startup error.
RUN yum install -y \
    wget \
    tar \
    gzip \
    # Provides useradd, which the minimal image does not include.\
    shadow-utils \
    # Provides libXtst.so.6, the X Test extension linked by the AWT X11 toolkit.\
    libXtst \
    # Provides libXi.so.6, the X Input extension linked by the AWT X11 toolkit.\
    libXi \
    # Provides libXrender.so.1, the X Render extension linked by the AWT X11 toolkit.\
    libXrender \
    # Provides libfreetype.so.6, the font rasterizer linked by the JBR font manager.\
    freetype \
    # Provides libfontconfig.so.1, which the JBR loads at startup to find fonts.\
    fontconfig \
    # Gives fontconfig at least one font family; the IDE cannot start without fonts.\
    dejavu-sans-fonts \
    # Provides libEGL.so.1, linked by Skiko, the Skia renderer behind Compose UI parts.\
    mesa-libEGL \
    # Provides libGL.so.1, also linked by Skiko.\
    mesa-libGL \
    && yum clean all && rm -rf /var/cache/yum

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
