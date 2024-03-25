# Dockerfile

# Use a Rust base image
FROM rust:latest as builder

#Update tool chain
RUN rustup target add x86_64-unknown-linux-musl

# Set the working directory
WORKDIR /app

# Copy the Rust project files
COPY Cargo.toml .
COPY src /app/src

# Build the Rust program
RUN cargo build --release --target=x86_64-unknown-linux-musl

# Create a new image with only the compiled binary
FROM debian:buster-slim

WORKDIR /app

# Copy the binary from the builder image
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/rust-devcontainer .

# Set the entry point
CMD ["./rust-devcontainer"]