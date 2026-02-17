---
description: GitHub Actions workflows configuration and best practices
name: GitHub Actions Workflows
applyTo: '.github/workflows/**/*.yml, .github/workflows/**/*.yaml'
---
# GitHub Actions Workflows
- Prefer `hashicorp/vault-action` for secret retrieval over manual CLI commands
  * Refer to [RFC021: Leveraging Hashicorp Vault as a Secret Store via GitHub Actions](https://intermedia.atlassian.net/wiki/spaces/IDP/pages/1003978867/) for implementation patterns, adapting the Vault instance details as needed
- Define static environment variables in the YAML `env` block rather than using `echo "..." >> $GITHUB_ENV` in run steps
