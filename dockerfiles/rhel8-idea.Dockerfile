FROM redhat/ubi8

ARG INSTALLER_FILENAME

# Red Hat UBI 8 ships glibc 2.28, the oldest glibc the bundled JBR starts on.
RUN dnf install -y --setopt=install_weak_deps=False \
    wget \
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
    && dnf clean all

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
