FROM alpine:3.13

LABEL description="Data network host"

# Install debug tools ~ 100MB (if DEBUG_TOOLS is set to true)
RUN apk add -U vim strace net-tools curl netcat-openbsd tcpdump iptables