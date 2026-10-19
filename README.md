Docker container to run IntelliJ IDEA Community Edition on macOS.

Prerequisites
===
* macOS
* running Docker Desktop (https://docs.docker.com/desktop/)
* running XQuartz (see below)

Usage
===

Run IntelliJ IDEA Community in Docker:
```
./dockerized-idea.sh ubuntu 2026.2.3
./dockerized-idea.sh ubuntu 253.15192 # place manually ./builds/ideaIC-253.15192-aarch64.tar.gz

./dockerized-idea.sh alpine 2025.1.4.1
./dockerized-idea.sh alpine 2025.2
./dockerized-idea.sh alpine 253.15192 # place manually ./builds/ideaIC-253.15192-aarch64.tar.gz
```

XQuartz configuration
===
1. Install [XQuartz](https://www.xquartz.org/).
2. Open XQuartz, go to "Settings | Security" and enable `Allow connections from network clients` there.
   It might require restarting the system.
3. If you're on macOS with Apple Silicon (M1), then you probably need to apply a workaround for https://github.com/XQuartz/XQuartz/issues/31 ([JBR-6133](https://youtrack.jetbrains.com/issue/JBR-6133/PERPIXELTRANSLUCENT-translucency-is-not-supported)). To fix the black background, run the following command in Terminal:
```
defaults write org.xquartz.X11 enable_render_extension -int 0
```
4. Run XQuartz with `./start-xquartz.sh`
