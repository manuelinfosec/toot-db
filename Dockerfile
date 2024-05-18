# Initial build
FROM rust:1.53-slim AS build

ARG TARGET=x86_64-unknown-linux-musl
RUN apt-get -q update && apt-get -q install -y musl-dev
RUN rustup target add $TARGET

# FIXME: cargo does not have an option to only build dependencies, so we build
# a dummy main.rs. See: https://github.com/rust-lang/cargo/issues/2644
WORKDIR /usr/src/tootdb

COPY Cargo.toml Cargo.lock ./
RUN mkdir src \
    && echo "fn main() {}" >src/main.rs \
    && echo "fn main() {}" >build.rs
RUN cargo fetch --target=$TARGET
RUN cargo build --release --target=$TARGET \
    && rm -rf build.rs src target/$TARGET/release/tootdb*

COPY . .
RUN cargo install --bin tootdb --locked --offline --path . --target=$TARGET

# Runtime image
FROM alpine:3.14
COPY --from=build /usr/local/cargo/bin/tootdb /usr/local/bin/tootdb
COPY --from=build /usr/src/tootdb/config/tootdb.yaml /etc/tootdb.yaml
CMD ["tootdb"]
