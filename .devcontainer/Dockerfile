# 使用预构建的基础镜像
ARG BASE_IMAGE=mark24code/claude-in-docker:latest
FROM ${BASE_IMAGE}

USER vscode
WORKDIR /home/vscode

# Copy default zsh configuration
COPY --chown=vscode:vscode default.zshrc /home/vscode/.zshrc.container
COPY --chown=vscode:vscode container.additions.zshrc /home/vscode/.zshrc.container.additions

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

# Copy and setup Claude initialization script
COPY --chown=vscode:vscode init-claude.sh /home/vscode/.local/bin/init-claude.sh
COPY --chown=vscode:vscode test-config.sh /home/vscode/.local/bin/test-config.sh
RUN chmod +x /home/vscode/.local/bin/init-claude.sh \
    && chmod +x /home/vscode/.local/bin/test-config.sh

# Set working directory
WORKDIR /workspace

# Default command
CMD ["zsh"]
