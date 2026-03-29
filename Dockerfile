FROM ghcr.io/railwayapp/nixpacks:ubuntu-1745885067

ENTRYPOINT ["/bin/bash", "-l", "-c"]
WORKDIR /app/
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs
ENV PATH="/usr/local/bin:/usr/bin:/bin:$PATH"




ARG CI NIXPACKS_METADATA NODE_ENV NPM_CONFIG_PRODUCTION
ENV CI=$CI NIXPACKS_METADATA=$NIXPACKS_METADATA NODE_ENV=$NODE_ENV NPM_CONFIG_PRODUCTION=$NPM_CONFIG_PRODUCTION

# setup phase
# noop

# install phase
ENV NIXPACKS_PATH=/app/node_modules/.bin:$NIXPACKS_PATH
COPY . /app/.
RUN --mount=type=cache,id=0V4592seSI-/usr/local/share/cache/yarn/v6,target=/usr/local/share/.cache/yarn/v6 npm install -g corepack@0.24.1 && corepack enable
RUN --mount=type=cache,id=0V4592seSI-/usr/local/share/cache/yarn/v6,target=/usr/local/share/.cache/yarn/v6 yarn install --frozen-lockfile

# build phase
COPY . /app/.
RUN --mount=type=cache,id=0V4592seSI-node_modules/cache,target=/app/node_modules/.cache yarn run build


RUN printf '\nPATH=/app/node_modules/.bin:$PATH' >> /root/.profile


# start
COPY . /app

CMD ["yarn run start"]