# Use the official Vault image as a base
FROM hashicorp/vault:latest

LABEL maintainer="Yannnick Djoumbi <ydjoumbi@gmail.com>"

# Expose the port that Vault will listen on
EXPOSE 8200

# Set environment variables (you can customize these as needed)
ENV VAULT_ADDR='http://0.0.0.0:8200'
ENV VAULT_PORT='8200'

# Entry point command to run Vault
ENTRYPOINT ["vault"]
CMD ["server", "-dev", "-dev-root-token-id=root"]
