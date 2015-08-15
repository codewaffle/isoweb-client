FROM nginx

RUN apt-get update && apt-get -y install \
    wget git python

RUN wget https://nodejs.org/dist/v0.12.7/node-v0.12.7-linux-x64.tar.gz
RUN tar xzf node-v0.12.7-linux-x64.tar.gz
RUN mkdir -p /opt
RUN mv node-v0.12.7-linux-x64 /opt/node
RUN ln -s /opt/node/bin/node /usr/bin/node
RUN ln -s /opt/node/bin/npm /usr/bin/npm

RUN npm install -g \
    coffee-script \
    gulp

ADD package.json /build/package.json
WORKDIR /build

RUN npm install

ADD . /build

RUN gulp less browserify
WORKDIR dist
RUN rm -rf /usr/share/nginx/html && mv dist /usr/share/nginx/html
