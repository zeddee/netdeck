FROM alpine:3.20
SHELL ["/bin/ash", "-c"]
RUN apk add --no-cache tcpdump net-tools

# We want `root` as user
USER 0:0

CMD ["ash"]

