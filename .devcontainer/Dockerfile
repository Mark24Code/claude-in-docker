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

# Configure zsh with plugins (git and z)
RUN sed -i 's/plugins=(git)/plugins=(git z)/' ~/.zshrc

# Add .env file loading to .zshrc
RUN echo '' >> ~/.zshrc \
    && echo '# Load environment variables from .env file if it exists' >> ~/.zshrc \
    && echo 'if [ -f /workspace/.devcontainer/.env ]; then' >> ~/.zshrc \
    && echo '  set -a' >> ~/.zshrc \
    && echo '  source /workspace/.devcontainer/.env' >> ~/.zshrc \
    && echo '  set +a' >> ~/.zshrc \
    && echo 'fi' >> ~/.zshrc

# Install Claude Code globally via npm
RUN . "$NVM_DIR/nvm.sh" && npm install -g @anthropic-ai/claude-code

# Copy and setup Claude initialization script
COPY --chown=$USERNAME:$USERNAME init-claude.sh /home/$USERNAME/.local/bin/init-claude.sh
RUN chmod +x /home/$USERNAME/.local/bin/init-claude.sh \
    && mkdir -p /home/$USERNAME/.local/bin

# Set working directory
WORKDIR /workspace

# Default command
CMD ["zsh"]
