# syntax=docker/dockerfile:1.2
ARG SRCVERSION=19_5-mp-i
ARG SRCTAG=2026-01-14
ARG SRCHUBID=dataeditors
ARG WOLFRAMVERSION=14.3.0

# define the source for Stata
FROM ${SRCHUBID}/stata${SRCVERSION}:${SRCTAG} as stata

# use the source for Wolfram Engine

FROM wolframresearch/wolframengine:${WOLFRAMVERSION}
COPY --from=stata /usr/local/stata/ /usr/local/stata/
ENV PATH "$PATH:/usr/local/stata" 

USER root

# Stuff we need from the Stata Docker Image
# https://github.com/AEADataEditor/docker-stata/blob/main/Dockerfile.base
# We need to redo this here, since we are using the base image from `wolframresearch/wolframengine`. 
# Updated to match latest apt installs from docker-stata
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
         libncurses6 \
         libcurl4 \
         git \
         nano \
         unzip \
         locales \
         fontconfig fonts-dejavu-core fonts-dejavu-extra \
         fonts-liberation \
         sudo \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -fv \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Create wolframengine user with proper setup
RUN echo "wolframengine ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/wolframengine \
    && chmod 0440 /etc/sudoers.d/wolframengine 

# Set a few more things
ENV LANG en_US.utf8

#=============================================== REGULAR USER
# install any packages into the home directory as the user
# NOTE: we are using the wolframengine user to keep things consistent

USER wolframengine
RUN echo "export PATH=/usr/local/stata:${PATH}" >> /home/wolframengine/.bashrc



# Setup for standard operation
USER wolframengine
WORKDIR /project
ENTRYPOINT ["stata-mp"]
