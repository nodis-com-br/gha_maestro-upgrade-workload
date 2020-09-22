FROM docker.io/nodisbr/python

RUN apt-get -y update
RUN apt-get -y install git curl apt-transport-https

RUN curl https://baltocdn.com/helm/signing.asc | apt-key add -
RUN echo "deb https://baltocdn.com/helm/stable/debian/ all main" > /etc/apt/sources.list.d/helm-stable-debian.list
RUN apt-get -y update
RUN apt-get -y install helm

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]