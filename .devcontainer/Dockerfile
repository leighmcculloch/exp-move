ARG VARIANT="hirsute"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

RUN apt-get update
RUN apt-get install -y gcc libssl-dev pkg-config

USER vscode
ENV HOME=/home/vscode

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=$HOME/.cargo/bin:$PATH

RUN cargo install --git https://github.com/diem/move move-cli --rev bc6c645db948ddb6f9acec3174826d2f71e58447
