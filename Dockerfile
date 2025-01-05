# Use a multi-stage build to minimize image size

# Stage 1: Build the release
FROM elixir:1.18.1-otp-27-alpine AS builder

WORKDIR /app

# Install Hex + Rebar
RUN mix do local.hex --force, local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# Copy project files and dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY config config
COPY lib lib

RUN mix compile
RUN MIX_ENV=prod mix release

# Stage 2: Create the final image
FROM alpine:3.21.0

RUN apk upgrade --no-cache
RUN apk add --no-cache bash openssl libgcc libstdc++ ncurses-libs

WORKDIR /app

# Copy the release from the builder stage
COPY --from=builder /app/_build/prod/rel/j1605_mqtt ./

# Set the user and group to a non-root user for security
RUN addgroup -S app && adduser -S -G app app

USER app

# Set the entrypoint to start your application
CMD ["./bin/j1605_mqtt", "start"]
