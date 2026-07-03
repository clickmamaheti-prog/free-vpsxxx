FROM ubuntu:20.04

ARG ZROK_TOKEN
ARG REGION=ap-southeast-1
ARG TZ=Asia/Jakarta

LABEL maintainer="DevCulture <devculture.id>" \
      version="4.0" \
      description="Rairu-Kun2 — Ubuntu 20.04 SSH VPS with zrok + supervisord"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=${TZ} \
    ZROK_TOKEN=${ZROK_TOKEN} \
    REGION=${REGION} \
    NTFY_TOPIC=zrokIP22 \
    ROOT_PASS=DevCulture2026 \
    PORT=8080

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates openssh-server curl python3 python3-pip \
        vim nano sudo net-tools wget htop git unzip \
        iproute2 iputils-ping procps passwd tmux screen \
        lsof dnsutils jq tzdata zstd neofetch \
        nginx supervisor && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/openziti/zrok/releases/latest/download/zrok_0.4.30_linux_amd64.tar.gz \
        -o /tmp/zrok.tar.gz && \
    tar -xzf /tmp/zrok.tar.gz -C /usr/local/bin/ zrok && \
    chmod +x /usr/local/bin/zrok && \
    rm /tmp/zrok.tar.gz

RUN mkdir -p /run/sshd && \
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
COPY nginx-ollama.conf /etc/nginx/sites-available/ollama
RUN ln -sf /etc/nginx/sites-available/ollama /etc/nginx/sites-enabled/ollama

RUN mkdir -p /var/www/ollama-ui
COPY index.html /var/www/ollama-ui/index.html
RUN chmod -R 755 /var/www/ollama-ui

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY devculture-banner.sh /etc/profile.d/99-devculture-banner.sh
RUN chmod +x /etc/profile.d/99-devculture-banner.sh && \
    echo "Banner /etc/ssh/banner.txt" >> /etc/ssh/sshd_config && \
    printf "DevCulture Rairu-Kun2 VPS\n" > /etc/ssh/banner.txt

COPY zrok-setup.sh /usr/local/bin/zrok-setup.sh
RUN chmod +x /usr/local/bin/zrok-setup.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY watchdog.sh /usr/local/bin/watchdog.sh
RUN chmod +x /usr/local/bin/watchdog.sh

RUN apt-get clean && rm -rf /tmp/* /var/tmp/*

EXPOSE 22 80 443 3000 8080 8888

CMD ["/entrypoint.sh"]
