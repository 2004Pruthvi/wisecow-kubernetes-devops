FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    netcat-openbsd \
    fortune-mod \
    fortunes-min \
    cowsay \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/games:${PATH}"

RUN useradd --system --uid 10001 --create-home wisecow

WORKDIR /app

COPY --chown=wisecow:wisecow app/wisecow.sh /app/wisecow.sh

RUN chmod 755 /app/wisecow.sh && \
    chown wisecow:wisecow /app

USER 10001

EXPOSE 4499

CMD ["/bin/bash", "/app/wisecow.sh"]
