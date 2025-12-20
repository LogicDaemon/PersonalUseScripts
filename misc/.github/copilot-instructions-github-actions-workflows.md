### Github Actions Workflows:
  - Prefer `hashicorp/vault-action` for secret retrieval over manual CLI commands.
    * Use [RFC021: Leveraging Hashicorp Vault as a Secret Store via GitHub Actions](https://intermedia.atlassian.net/wiki/spaces/IDP/pages/1003978867/) as an example for secret management. Note that RFC refers a PSA vault which may be different from what this repository use.
  - Define static environment variables in the YAML `env` block rather than using `echo "..." >> $GITHUB_ENV` in run steps.
