FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG ssh_prv_key
ARG ssh_pub_key
ARG CODE_RELEASE
ARG TERRAFORM_VERSION=1.2.9
ARG AZURERM_VERSION=3.23.0
ARG RANDOM_VERSION=3.4.3
ARG TIME_VERSION=0.8.0
ARG TFLINT_VERSION=0.40.0
ARG TFLINT_AZURERM=0.18.0
ARG AZURE_CLI_VERSION=2.40.0-1~focal
ARG BICEP_VERSION=v0.10.61
LABEL build_version="coderserver version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="banewman"


RUN \
  echo "**** install runtime dependencies ****" && \
  apt-get update && \
  apt-get install -y \
    apt-transport-https \
    wget \
    unzip \
    ca-certificates \
    curl \
    lsb-release \
    gnupg \
    sudo \
    shellcheck \
    git \
    jq \
    libatomic1 \
    nano \
    net-tools \
    netcat \
    software-properties-common \
    gnupg \
    sudo && \
  echo "**** install code-server ****" && \
  if [ -z ${CODE_RELEASE+x} ]; then \
    CODE_RELEASE=$(curl -sX GET https://api.github.com/repos/coder/code-server/releases/latest \
      | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||'); \
  fi && \
  mkdir -p /app/code-server && \
  curl -o \
    /tmp/code-server.tar.gz -L \
    "https://github.com/coder/code-server/releases/download/v${CODE_RELEASE}/code-server-${CODE_RELEASE}-linux-amd64.tar.gz" && \
  tar xf /tmp/code-server.tar.gz -C \
    /app/code-server --strip-components=1 && \
  echo "**** clean up ****" && \
  apt-get clean && \
  rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# Install Terraform and tflint
RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && wget -O tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip \
    && unzip ./terraform.zip -d /usr/local/bin/ \
    && unzip ./tflint.zip -d /usr/local/bin/ \
    && rm terraform.zip \
    && rm tflint.zip

# Download Terraform providers (plugins)
# Setting the TF_PLUGIN_CACHE_DIR environment variable instructs Terraform to search that folder for plugins first
ENV TF_PLUGIN_CACHE_DIR=/usr/lib/tf-plugins
ENV TFLINT_PLUGIN_DIR=/usr/lib/tflint-plugins
ARG AZURERM_LOCAL_PATH="${TF_PLUGIN_CACHE_DIR}/registry.terraform.io/hashicorp/azurerm/${AZURERM_VERSION}/linux_amd64"
ARG RANDOM_LOCAL_PATH="${TF_PLUGIN_CACHE_DIR}/registry.terraform.io/hashicorp/random/${RANDOM_VERSION}/linux_amd64"
ARG TIME_LOCAL_PATH="${TF_PLUGIN_CACHE_DIR}/registry.terraform.io/hashicorp/time/${TIME_VERSION}/linux_amd64"
ARG AZURERM_PROVIDER=https://releases.hashicorp.com/terraform-provider-azurerm/${AZURERM_VERSION}/terraform-provider-azurerm_${AZURERM_VERSION}_linux_amd64.zip
ARG RANDOM_PROVIDER=https://releases.hashicorp.com/terraform-provider-random/${RANDOM_VERSION}/terraform-provider-random_${RANDOM_VERSION}_linux_amd64.zip
ARG TIME_PROVIDER=https://releases.hashicorp.com/terraform-provider-time/${TIME_VERSION}/terraform-provider-time_${TIME_VERSION}_linux_amd64.zip
ARG AZURERM_TFLINT_PLUGIN=https://github.com/terraform-linters/tflint-ruleset-azurerm/releases/download/v${TFLINT_AZURERM}/tflint-ruleset-azurerm_linux_amd64.zip
RUN wget -O azurerm.zip ${AZURERM_PROVIDER} \
    && wget -O random.zip ${RANDOM_PROVIDER} \
    && wget -O time.zip ${TIME_PROVIDER} \
    && wget -O tflintazurerm.zip ${AZURERM_TFLINT_PLUGIN} \
    && mkdir -p ${AZURERM_LOCAL_PATH} \
    && mkdir -p ${RANDOM_LOCAL_PATH} \
    && mkdir -p ${TIME_LOCAL_PATH} \
    && unzip azurerm.zip -d ${AZURERM_LOCAL_PATH} \
    && unzip random.zip -d ${RANDOM_LOCAL_PATH} \
    && unzip time.zip -d ${TIME_LOCAL_PATH} \
    && unzip tflintazurerm.zip -d ${TFLINT_PLUGIN_DIR} \
    && rm azurerm.zip \
    && rm random.zip \
    && rm time.zip \
    && rm tflintazurerm.zip

# Install the Microsoft package key
RUN wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb

# Install the Microsoft signing key
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

# Install the AZ CLI repository
RUN AZ_REPO=$(lsb_release -cs) \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    tee /etc/apt/sources.list.d/azure-cli.list

# Install AZ CLI
RUN apt-get update && apt-get install -y azure-cli

# Install Bicep
RUN curl -Lo /usr/local/bin/bicep https://github.com/Azure/bicep/releases/download/${BICEP_VERSION}/bicep-linux-x64 \
    && chmod +x /usr/local/bin/bicep

ENV SSH_KEY "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzsMAEYwdHzOE8eeiER/68E0dZKOm7qgPcqW1jz+6JnP19nba9Az51/kOw8M9XG1QXLB/ioTjtGAU/uppUw8bc5lEuuZdGYZ1mEllW5hRmIybNYbc1mKCh83hlsF8rDYln4WXmwql7xX9amjsEnvCg5blA1P5fhIek0Al0paKJQ7DovX0eDD0MGtLYcL3bdqYxn3BHRnkN6atjLwUckIS1OchhIBkikenI3wkwycfYDYfFNJUQWiMPmCaUaWNVit6zVqQAup7sxyKLF56F2c+Xg2Z3Afh/qAXM5jODq3Jq5ODH680YrSJsnkSBKAoMSXsq9G3LSSEDGrbAsLCAv97KTLPqefBcRbMYoduO2iuEm+0H4faKDRL+A7t605uyL12YlK0Df6U1LDKC0hUfjVxvfLPTsiEgqfDuxx/hHWey4pmNUtk1hekTz/+FE1v/MtjlCJ6k5g7W7genYI1Dx17U8SaioAzlzTqVec57oHltIpA/YM/Kbufm0M5PPRhxLok= packet@DESKTOP-OSH19PU"

# Configure git user
RUN git config --global user.email "banewman@microsoft.com" && \
    git config --global user.name "Project RX"

# Authorize SSH Host
#RUN mkdir -p /root/.ssh && \
#    chmod 0700 /root/.ssh && \
#    ssh-keyscan gitlabdomain.com > /root/.ssh/known_hosts &&\
#    chmod 644 /root/.ssh/known_hosts

# Authorize SSH Host
#RUN mkdir -p /root/.ssh && \
#    chmod 0700 /root/.ssh && \
#    ssh-keyscan github.com > /root/.ssh/known_hosts

# Add the keys and set permissions
RUN mkdir ~/.ssh && \
    echo "$ssh_prv_key" > ~/.ssh/id_rsa && \
    echo "$ssh_pub_key" > ~/.ssh/id_rsa.pub && \
    chmod 600 ~/.ssh/id_rsa && \
    chmod 600 ~/.ssh/id_rsa.pub && \
    touch ~/.ssh/known_hosts && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

# Add the keys and set permissions
#RUN eval `ssh-agent -s` && \
#    echo "$SSH_KEY" > /root/.ssh/id_rsa && \
#    chmod 600 /root/.ssh/id_rsa

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config"

#pull repo
#RUN git clone git@github.com:BarryJNewman/10th.git

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# add local files
#COPY /root /

# ports and volumes
EXPOSE 443