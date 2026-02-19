# syntax=docker/dockerfile:1.2
ARG SRCVERSION=17
ARG SRCTAG=2022-01-17
ARG SRCHUBID=dataeditors
ARG WOLFRAMVERSION=latest

# define the source for Stata
FROM ${SRCHUBID}/stata${SRCVERSION}:${SRCTAG} as stata

# use the source for Wolfram Engine

FROM wolframresearch/wolframengine:${WOLFRAMVERSION}
COPY --from=stata /usr/local/stata/ /usr/local/stata/
RUN echo "export PATH=/usr/local/stata:${PATH}" >> /root/.bashrc
ENV PATH "$PATH:/usr/local/stata" 

# copy the license in so we can do the install of packages
USER root
RUN --mount=type=secret,id=statalic \
    cp /run/secrets/statalic /usr/local/stata/stata.lic \
    && chmod a+r /usr/local/stata/stata.lic

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
RUN groupadd -g 2025 stata \ 
    && useradd  -m -u 2000 -g users -G stata,sudo wolframengine \
    && echo "wolframengine ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/wolframengine \
    && chmod 0440 /etc/sudoers.d/wolframengine 

# Set a few more things
ENV LANG en_US.utf8

#=============================================== REGULAR USER
# install any packages into the home directory as the user
# NOTE: we are using the wolframengine user to keep things consistent

USER wolframengine
RUN echo "export PATH=/usr/local/stata:${PATH}" >> /home/wolframengine/.bashrc
COPY setup.do /setup.do
WORKDIR /home/wolframengine
RUN /usr/local/stata/stata do /setup.do | tee setup.$(date +%F).log

#=============================================== Clean up
#  then delete the license again
USER root
RUN rm /usr/local/stata/stata.lic

# Setup for standard operation
USER wolframengine
WORKDIR /code
ENTRYPOINT ["stata-mp"]
