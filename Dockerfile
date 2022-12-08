FROM alpine

RUN apk add --no-cache --upgrade bash git

COPY scripts/calculator.sh /bin/calculator
