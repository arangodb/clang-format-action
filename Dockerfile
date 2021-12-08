FROM alpine:3.15
ENV version=12.0.1-r0
RUN apk add --no-cache clang-extra-tools=${version}
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
