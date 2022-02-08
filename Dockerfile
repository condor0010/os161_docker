FROM ubuntu:20.04 as base
LABEL maintainer="Louie Orcinolo"
SHELL ["/bin/bash"]
COPY setup.sh /root/
COPY post_setup.sh /root/
RUN /root/setup.sh
ENTRYPOINT /root/post_setup.sh
WORKDIR /root/os161/

