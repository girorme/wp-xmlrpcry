# Stage 1: Build the application
FROM elixir:1.14 AS builder

# Set the working directory inside the container
WORKDIR /app

ENV MIX_ENV=prod

# Build escript app
COPY lib ./lib
COPY mix.exs .
COPY mix.lock .
RUN mix local.rebar --force \
    && mix local.hex --force \
    && mix deps.get \
    && mix escript.build

# Stage 2: Create the final lightweight image
FROM elixir:1.14-alpine

# Set the working directory inside the container
WORKDIR /app/bin

RUN mkdir -p /app/bin/output && chmod 777 /app/bin/output

# Copy from builder stage
COPY --from=builder /app/bin/wpxmlrpcry /app/bin/wpxmlrpcry

# Set the entry point and command to run when the container starts
ENTRYPOINT ["/app/bin/wpxmlrpcry"]
CMD ["--help"]  # Provide a default argument to show usage info