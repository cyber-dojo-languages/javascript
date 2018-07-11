FROM  cyberdojofoundation/ubuntu-build-essential:18.04
LABEL maintainer=jon@jaggersoft.com

RUN apt-get update

RUN apt-get install --yes curl
RUN curl --silent --location https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install --yes nodejs
RUN npm install --global jshint

RUN npm install --global n
# keep old version for backward compatibility with old Katas
RUN n 0.12.7
RUN n 4.1.1
RUN n 4.2.1
RUN n 6.11.1
RUN n 8.2.1
RUN n 8.4.0
RUN n 9.4.0
RUN n 9.10.1
RUN n 10.1.0

RUN chmod -R a+w /usr/local
