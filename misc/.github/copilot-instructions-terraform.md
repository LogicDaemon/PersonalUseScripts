### Terraform
  - Avoid redundant `try`/`coalesce` guards; rely on defauls and prefer direct lookups (`var["key"]` over `lookup(var, "key")`)
