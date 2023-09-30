FROM debian:bookworm as compile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs npm

ADD postmarks/ /app/

WORKDIR /app

RUN npm install

ADD account.json /app/account.json

ADD util.js /app/src/util.js

CMD npm run start
