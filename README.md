Docker container to run IntelliJ IDEA on macOS.

Prerequisites
===
* macOS
* running Docker Desktop (https://docs.docker.com/desktop/)
* running XQuartz (see below)

Usage
===

Run IntelliJ IDEA Community in Docker:
```
# Ubuntu
./dockerized-idea.sh ubuntu 2026.2.3
./dockerized-idea.sh ubuntu 263.7031.23 # place manually ./builds/idea-263.7031.23-aarch64.tar.gz

# Alpine
./dockerized-idea.sh alpine 2026.2.3
./dockerized-idea.sh alpine 271.994 # place manually ./builds/idea-271.994-aarch64.tar.gz

# Red Hat Enterprise Linux (RHEL)
./dockerized-idea.sh rhel8 263.7031.23

# Amazon Linux 2
# It doesn't start as it has glibc 2.26 and the bundled JBR needs glibc 2.28
./dockerized-idea.sh amazonlinux2 2026.2.3
```

XQuartz configuration
===
1. Install [XQuartz](https://www.xquartz.org/).
2. Open XQuartz, go to "Settings | Security" and enable `Allow connections from network clients` there.
   It might require restarting the system.
3. Run XQuartz with `./start-xquartz.sh`
