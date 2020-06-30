# Pull base image.
FROM ubuntu:14.04

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget && \
  rm -rf /var/lib/apt/lists/*

COPY pipelines/upload-tiles-to-s3/check.sh /opt/resource/check
COPY pipelines/upload-tiles-to-s3/in.sh /opt/resource/in
COPY pipelines/upload-tiles-to-s3/out.sh /opt/resource/out

RUN chmod +x /opt/resource/check /opt/resource/in /opt/resource/in

# Define working directory.
WORKDIR /opt/resource

# Define default command.
CMD ["bash"]
