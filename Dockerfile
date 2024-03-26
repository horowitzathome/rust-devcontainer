# Dockerfile

# Use a Rust base image
FROM rust:latest as builder

# Arguments
# Target, e.g. x86_64-unknown-linux-musl
ARG TARGET  

# Install musl-tools
RUN apt update
RUN apt install -y musl-tools

#Update tool chain
RUN rustup target add x86_64-unknown-linux-musl

# Set the working directory
WORKDIR /app

# Copy the Rust project files
COPY Cargo.toml .
COPY src /app/src

# Build the Rust program
RUN cargo build --release --target ${TARGET}

# Create a new image with only the compiled binary
FROM debian:buster-slim

WORKDIR /app

# Copy the binary from the builder image
COPY --from=builder /app/target/${TARGET}/release/rust-devcontainer .

# Set the entry point
CMD ["./rust-devcontainer"]