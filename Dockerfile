FROM ubuntu:20.04 as base
LABEL maintainer="Louie Orcinolo"
SHELL ["/bin/bash"]
COPY setup.sh /root/
COPY bos /bin/
RUN /root/setup.sh
ENTRYPOINT /bin/bash
WORKDIR /root/os161/

