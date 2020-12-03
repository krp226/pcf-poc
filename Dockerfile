# Pull base image.
FROM ubuntu:latest

ENV DEBIAN_FRONTEND noninteractive

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get -y update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget && \
  apt-get install -y openssh-client && \
  apt-get install -y curl && \
  apt-get install -y wget && \
  apt-get install -y jq && \
  apt-get install -y netcat-openbsd && \
  apt-get install -y ca-certificates && \
  apt-get install -y awscli && \
  apt-get install -y telnet && \
  apt-get install -y openssh-client && \
  rm -rf /var/lib/apt/lists/*

RUN ["/bin/bash", "-c", "set -o pipefail && curl -s https://api.github.com/repos/pivotal-cf/om/releases/latest \
     | jq -e -r '.assets[] | select(.name | contains(\"om-linux\")) | select(.name | contains(\"tar.gz\") | not) | .browser_download_url' \
     | wget -qi - -O /bin/om && chmod +x /bin/om"]

RUN ["/bin/bash", "-c", "set -o pipefail && curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest \
    | jq -e -r '.assets[] | .browser_download_url' \
    | grep linux \
    | wget -qi - -O /bin/bosh && chmod +x /bin/bosh"]

RUN ["/bin/bash", "-c", "set -o pipefail && curl -s https://api.github.com/repos/concourse/concourse/releases/latest \
    | jq -e -r '.assets[] | select(.name | contains(\"linux-amd64.tgz\")) | select(.name | contains(\"fly\")) | select(.name | contains(\"sha\") | not) | .browser_download_url' \
    | wget -qi - -O fly.tar.gz && tar xvf fly.tar.gz -C /bin && rm fly.tar.gz && chmod +x /bin/fly"]

RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
RUN echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list

RUN \
  apt-get -y update && \
  apt-get -y upgrade && \
  apt-get install -y cf-cli && \
  rm -rf /var/lib/apt/lists/*


# Define default command.
CMD ["bash"]
