FROM alpine
RUN apk add --no-cache procps
# Add the binary for redis-dns-server
COPY redis-dns-server.linux /redis-dns-server
COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh

# Add the binary for the d-resolver
# https://github.com/TrueAbility/d
COPY bin/d /d
COPY scripts/liveness_check.sh /liveness_check.sh
RUN chmod +x /liveness_check.sh /redis-dns-server /d

# ENV is not parsed in CMD/ENTRYPOINT?
# ENTRYPOINT ["/go/src/github.com/dustacio/redis-dns-server/scripts/docker-entrypoint.sh"]
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 53