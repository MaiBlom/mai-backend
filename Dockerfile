# Dockerfile for Elixir Phoenix API (Elixir 1.18.4)
FROM hexpm/elixir:1.16.2-erlang-26.2.5-alpine-3.19.1 AS build

# Install build dependencies
RUN apk add --no-cache build-base git npm

# Set build argument and environment variable for MIX_ENV
ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}

# Set workdir
WORKDIR /app

# Install Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files and install deps
COPY mix.exs mix.lock ./
COPY config ./config
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy the rest of the app
COPY . .

# Compile the project
RUN mix compile

# Release
RUN mix release

# -- Release image --
FROM alpine:3.19.1 AS app
RUN apk add --no-cache libstdc++ openssl ncurses-libs
WORKDIR /app

# Copy release from build
COPY --from=build /app/_build/prod/rel .

# Ensure the release script is executable
RUN chmod +x ./src/bin/src

# Set environment variables (override in docker-compose)
ENV LANG=en_US.UTF-8
ENV REPLACE_OS_VARS=true
ENV PORT=4000

# Expose port
EXPOSE 4000

# Start the server
CMD ["sh", "-c", "./src/bin/src start"]
