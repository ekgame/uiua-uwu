FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && \
  apt-get install -y git curl build-essential && \
  rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Clone uiua repository at specific commit and build
WORKDIR /tmp
RUN git clone https://github.com/uiua-lang/uiua.git && \
  cd uiua && \
  git checkout ec5fad242ac719c126373419037a5fc0e4a69686 && \
  cargo build --release && \
  cp target/release/uiua /usr/local/bin/uiua

WORKDIR /app
COPY . /app

# Set entrypoint
ENTRYPOINT ["uiua", "run", "example/main.ua"]