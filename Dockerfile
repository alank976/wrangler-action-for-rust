FROM rust:1
ENV NVM_VERSION 0.38.0
ENV NVM_DIR /usr/local/nvm
RUN mkdir -p $NVM_DIR 
ENV NODE_VERSION 16.2.0
ENV WRANGLER_HOME /github/workspace

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash
RUN bash -c "source $NVM_DIR/nvm.sh \ 
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default"
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN cargo install wasm-pack
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]