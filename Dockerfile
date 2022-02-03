FROM ubuntu:18.04 as base
LABEL maintainer="Louie Orcinolo"
SHELL ["/bin/bash"]
COPY setup.sh /root/
RUN /root/setup.sh
RUN rm /root/setup.sh
WORKDIR /root/os161/

