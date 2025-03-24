FROM debian:stable-slim AS os
RUN apt update \
    && apt install -y --no-install-recommends git racket ca-certificates curl sqlite3 \
    && apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/

FROM os AS build
WORKDIR /app
# Correct clone path, but this is my mirror
# RUN git clone --depth=1 https://gitdab.com/cadence/breezewiki.git .
RUN git clone --depth=1 https://github.com/offbyone/breezewiki.git .
RUN raco pkg install --batch --auto --no-docs --skip-installed req-lib \
    && raco req -d
EXPOSE 10416
CMD ["racket", "dist.rkt"]
