# Arguments
# Target, e.g. x86_64-unknown-linux-musl
ARG TARGET=no-stage-found

# Use a Rust base image
FROM rust:latest as builder

FROM builder AS stage-x86_64-unknown-linux-gnu

FROM builder AS stage-x86_64-unknown-linux-musl

RUN apt update && \
    apt install -y musl-tools && \
    rustup target add x86_64-unknown-linux-musl

FROM builder AS stage-aarch64-unknown-linux-musl

RUN apt update && \
    apt install -y musl-tools && \
    rustup target add aarch64-unknown-linux-musl && \
    apt-get install clang llvm -y 

ENV CC_aarch64_unknown_linux_musl=clang
ENV AR_aarch64_unknown_linux_musl=llvm-ar
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-Clink-self-contained=yes -Clinker=rust-lld"
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_RUNNER="qemu-aarch64 -L /usr/aarch64-linux-gnu"

FROM  stage-${TARGET} AS final-stage

# Install musl-tools and update toolchain
#RUN apt update
#RUN apt install -y musl-tools

#RUN if [ "$TARGET" = "x86_64-unknown-linux-musl" ] ; then \
#    apt update && \
#    apt install -y musl-tools && \
#    rustup target add x86_64-unknown-linux-musl \
#    ; fi

#RUN if [ "$TARGET" = "aarch64-unknown-linux-musl" ] ; then \
#    apt update && \
#    apt install -y musl-tools && \
#    rustup target add aarch64-unknown-linux-musl && \
#    apt-get install clang llvm -y && \
#    export CC_aarch64_unknown_linux_musl=clang && \
#    export AR_aarch64_unknown_linux_musl=llvm-ar && \
#    export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-Clink-self-contained=yes -Clinker=rust-lld" && \
#    export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_RUNNER="qemu-aarch64 -L /usr/aarch64-linux-gnu" \
#    ; fi

#ENV CC_aarch64_unknown_linux_musl=clang
#ENV AR_aarch64_unknown_linux_musl=llvm-ar
#ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-Clink-self-contained=yes -Clinker=rust-lld"
#ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_RUNNER="qemu-aarch64 -L /usr/aarch64-linux-gnu"

#Update tool chain
#RUN rustup target add x86_64-unknown-linux-musl

# Set the working directory
WORKDIR /app

# Copy the Rust project files
COPY Cargo.toml .
COPY src /app/src

# Build the Rust program
RUN cargo build --release --target ${TARGET}

# Copy to a target netral location for next step
RUN cp /app/target/${TARGET}/release/rust-devcontainer /app/target

# Create a new image with only the compiled binary
FROM debian:buster-slim

WORKDIR /app

# Copy the missing files from the Rust image to the Distroless image
# COPY  --from=builder /lib/aarch64-linux-gnu/libgcc_s.so.6 /usr/lib/aarch64-linux-gnu 

# Conditionally copy libgcc_s.so.6 if TARGET is aarch64-unknown-linux-gnu
# ARG TARGET

# Try to copy; if source is not valid, copy will (hopefully) not fail
# COPY --from=builder /lib/aarch64-linux-gnu/libgcc_s.so.1 /usr/lib/aarch64-linux-gnu 

#RUN if [ "${TARGET}" = "aarch64-unknown-linux-gnu" ]; then \
#        COPY --from=builder /lib/aarch64-linux-gnu/libgcc_s.so.6 /usr/lib/aarch64-linux-gnu/; \
#    fi    

# Copy the binary from the builder image
COPY --from=builder /app/target/rust-devcontainer .

# Set the entry point
CMD ["./rust-devcontainer"]