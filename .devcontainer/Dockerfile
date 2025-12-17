FROM debian:bookworm-slim

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    tig \
    zsh \
    sudo \
    openssh-client \
    ca-certificates \
    gnupg \
    libssl-dev \
    libffi-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    liblzma-dev \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/zsh \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install Go 1.23.4
RUN curl -fsSL https://go.dev/dl/go1.23.4.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/home/${USERNAME}/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Switch to non-root user for subsequent installations
USER $USERNAME
WORKDIR /home/$USERNAME

# Install Node.js 24.12.0 via nvm
ENV NVM_DIR="/home/${USERNAME}/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . "$NVM_DIR/nvm.sh" \
    && nvm install 24.12.0 \
    && nvm alias default 24.12.0 \
    && nvm use default
ENV PATH="${NVM_DIR}/versions/node/v24.12.0/bin:${PATH}"

# Install Python 3.13.1 via pyenv
ENV PYENV_ROOT="/home/${USERNAME}/.pyenv"
ENV PATH="${PYENV_ROOT}/bin:${PATH}"
RUN curl https://pyenv.run | bash \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc \
    && echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc \
    && echo 'eval "$(pyenv init -)"' >> ~/.zshrc \
    && ${PYENV_ROOT}/bin/pyenv install 3.13.1 \
    && ${PYENV_ROOT}/bin/pyenv global 3.13.1
ENV PATH="${PYENV_ROOT}/shims:${PATH}"

# Install Ruby 3.4.1 via rbenv
ENV RBENV_ROOT="/home/${USERNAME}/.rbenv"
ENV PATH="${RBENV_ROOT}/bin:${PATH}"
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv \
    && git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build \
    && echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc \
    && echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc \
    && ${RBENV_ROOT}/bin/rbenv install 3.4.1 \
    && ${RBENV_ROOT}/bin/rbenv global 3.4.1
ENV PATH="${RBENV_ROOT}/shims:${PATH}"

# Install oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Copy default zsh configuration
COPY --chown=$USERNAME:$USERNAME default.zshrc /home/$USERNAME/.zshrc.container
COPY --chown=$USERNAME:$USERNAME container.additions.zshrc /home/$USERNAME/.zshrc.container.additions

# Create smart .zshrc loader that prioritizes host config
RUN echo '# Smart Zsh Configuration Loader' > ~/.zshrc \
    && echo '# This checks for host .zshrc and falls back to container default' >> ~/.zshrc \
    && echo '' >> ~/.zshrc \
    && echo '# Check if host .zshrc exists (mounted from host)' >> ~/.zshrc \
    && echo 'if [ -f ~/.zshrc.host ]; then' >> ~/.zshrc \
    && echo '  # Load host configuration' >> ~/.zshrc \
    && echo '  source ~/.zshrc.host' >> ~/.zshrc \
    && echo '  # Optionally add container-specific additions' >> ~/.zshrc \
    && echo '  if [ -f ~/.zshrc.container.additions ]; then' >> ~/.zshrc \
    && echo '    source ~/.zshrc.container.additions' >> ~/.zshrc \
    && echo '  fi' >> ~/.zshrc \
    && echo 'else' >> ~/.zshrc \
    && echo '  # No host config found, use container default' >> ~/.zshrc \
    && echo '  source ~/.zshrc.container' >> ~/.zshrc \
    && echo 'fi' >> ~/.zshrc

# Install Claude Code globally via npm
RUN . "$NVM_DIR/nvm.sh" && npm install -g @anthropic-ai/claude-code

# Copy and setup Claude initialization script
COPY --chown=$USERNAME:$USERNAME init-claude.sh /home/$USERNAME/.local/bin/init-claude.sh
COPY --chown=$USERNAME:$USERNAME test-config.sh /home/$USERNAME/.local/bin/test-config.sh
RUN chmod +x /home/$USERNAME/.local/bin/init-claude.sh \
    && chmod +x /home/$USERNAME/.local/bin/test-config.sh \
    && mkdir -p /home/$USERNAME/.local/bin

# Set working directory
WORKDIR /workspace

# Default command
CMD ["zsh"]
