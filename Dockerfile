FROM ubuntu:20.04

ARG BORE_SERVER=bore.pub
ARG REGION=ap-southeast-1
ARG TZ=Asia/Jakarta

LABEL maintainer="DevCulture <devculture.id>" \
      version="5.0" \
      description="Rairu-Kun2 — Ubuntu 20.04 SSH VPS with bore + supervisord"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=${TZ} \
    BORE_SERVER=${BORE_SERVER} \
    REGION=${REGION} \
    NTFY_TOPIC=Rosma-vps \
    ROOT_PASS=DevCulture2026 \
    PORT=8080

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates openssh-server curl \
        vim nano sudo net-tools wget htop git unzip \
        iproute2 iputils-ping procps passwd tmux screen \
        lsof dnsutils jq tzdata zstd neofetch \
        nginx supervisor && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install bore (replaces zrok — no registration required)
RUN curl -fsSL https://github.com/ekzhang/bore/releases/download/v0.6.0/bore-v0.6.0-x86_64-unknown-linux-musl.tar.gz \
        -o /tmp/bore.tar.gz && \
    tar -xzf /tmp/bore.tar.gz -C /usr/local/bin/ bore && \
    chmod +x /usr/local/bin/bore && \
    rm /tmp/bore.tar.gz

RUN mkdir -p /run/sshd /var/log/supervisor && \
    echo "root:${ROOT_PASS}" | chpasswd && \
    ssh-keygen -A && \
    sed -i \
      -e 's/#PermitRootLogin.*/PermitRootLogin yes/' \
      -e 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' \
      -e 's/#PasswordAuthentication.*/PasswordAuthentication yes/' \
      -e 's/PasswordAuthentication no/PasswordAuthentication yes/' \
      -e 's/#ClientAliveInterval.*/ClientAliveInterval 60/' \
      -e 's/#ClientAliveCountMax.*/ClientAliveCountMax 10/' \
      -e 's/#MaxSessions.*/MaxSessions 50/' \
      -e 's/#TCPKeepAlive.*/TCPKeepAlive yes/' \
      /etc/ssh/sshd_config

RUN rm -f /etc/nginx/sites-enabled/default
COPY nginx-web.conf /etc/nginx/sites-available/web
RUN ln -sf /etc/nginx/sites-available/web /etc/nginx/sites-enabled/web

RUN mkdir -p /var/www/web-ui
COPY index.html /var/www/web-ui/index.html
RUN chmod -R 755 /var/www/web-ui

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY devculture-banner.sh /etc/profile.d/99-devculture-banner.sh
RUN chmod +x /etc/profile.d/99-devculture-banner.sh && \
    echo "Banner /etc/ssh/banner.txt" >> /etc/ssh/sshd_config && \
    printf "DevCulture Rairu-Kun2 VPS (bore powered)\n" > /etc/ssh/banner.txt

COPY bore-setup.sh /usr/local/bin/bore-setup.sh
RUN chmod +x /usr/local/bin/bore-setup.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY watchdog.sh /usr/local/bin/watchdog.sh
RUN chmod +x /usr/local/bin/watchdog.sh

RUN apt-get clean && rm -rf /tmp/* /var/tmp/*

EXPOSE 22 80 443 3000 8080 8888

CMD ["/entrypoint.sh"]
