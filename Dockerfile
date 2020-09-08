FROM docker.io/nodisbr/python

RUN apt-get -y update

RUN apt-get -y install curl wget ca-certificates apt-transport-https gnupg jq
RUN echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get -y update
RUN apt-get -y install kubectl

RUN apt-get -y install git
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]