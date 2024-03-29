FROM ubuntu:latest

# Rust toolchains
ENV RUST_TOOLCHAIN="nightly-x86_64-unknown-linux-gnu"
ENV RUST_TARGETS="x86_64-pc-windows-gnu x86_64-unknown-linux-gnu x86_64-unknown-linux-musl"
ENV SHELL="/usr/bin/zsh"
ENV RUSTC_WRAPPER="sccache"

# Create my user
RUN useradd -m dev

# Get the required packages from apt
RUN apt-get update -y
RUN apt-get install -y zsh python3 python3-pip tmux software-properties-common curl git file
# Build dependencies
RUN apt-get update -y
RUN apt-get install -y mingw-w64 gcc musl musl-tools libclang-dev llvm-dev clang libc6-dev gcc-arm-none-eabi pkg-config libssl-dev libx11-dev libasound2-dev libudev-dev libxkbcommon-x11-0 libwayland-dev libxkbcommon-dev mesa-vulkan-drivers

# Install helix
RUN add-apt-repository ppa:maveonair/helix-editor
RUN apt-get update -y 
RUN apt install helix

# Install rust
RUN su dev -c "curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain $RUST_TOOLCHAIN --target $RUST_TARGETS --component rust-src rustfmt clippy cargo rustc rust-std rust-docs rust-analyzer"

# Install bacon, taplo, sccache and bat
RUN su dev -c "export RUSTC_WRAPPER=\"\" && /home/dev/.cargo/bin/cargo install bacon taplo-cli sccache bat"
# Install pros-cli (for vexv5 dev)
RUN su dev -c "pip install pros-cli"

# Configure git (change this if you're not me)
RUN su dev -c "git config --global user.email \"greenchild04@protonmail.com\""
RUN su dev -c "git config --global user.name \"GreenChild04\""

# Setup home dir
RUN mkdir /home/dev/project
COPY include/zshrc /home/dev/.zshrc
COPY include/helix /home/dev/.config/helix
COPY include/tmux.conf /home/dev/.tmux.conf
WORKDIR /home/dev/project

# Set correct permissions
RUN chmod -R a+rwX /home/dev/.config

CMD su dev -c "SHELL='/usr/bin/zsh' tmux new-session -ds dev && tmux attach-session -t dev"
