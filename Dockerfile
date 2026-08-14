FROM node:22-alpine

WORKDIR /app

RUN apk add --no-cache openssl \
    && corepack enable \
    && corepack prepare pnpm@10.28.2 --activate

COPY package.json ./
RUN pnpm install --prod --frozen-lockfile=false

COPY app-runtime.tar.gz.enc /opt/tamyez/app-runtime.tar.gz.enc
COPY app-runtime.sha256 /opt/tamyez/app-runtime.sha256
COPY start.sh /usr/local/bin/start-tamyez
RUN chmod 500 /usr/local/bin/start-tamyez \
    && chmod 400 /opt/tamyez/app-runtime.tar.gz.enc /opt/tamyez/app-runtime.sha256

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

CMD ["/usr/local/bin/start-tamyez"]
