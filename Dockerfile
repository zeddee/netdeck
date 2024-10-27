FROM alpine:3.20
RUN apk add --no-cache tcpdump net-tools

CMD ["ash"]

