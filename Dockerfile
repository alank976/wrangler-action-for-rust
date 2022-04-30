FROM rust:1
ENV WRANGLER_HOME /github/workspace

RUN cargo install wasm-pack
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
