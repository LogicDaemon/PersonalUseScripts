---
description: playbooks, tasks, roles, and templates
applyTo: '**/meta/main.yml, **/defaults/*.yml, **/vars/*.yml, **/tasks/*.yml, **/tasks/**/*.yml, **/handlers/*.yml, **/templates/*.j2, **/templates/**/*.j2, **/roles/**/*.yml'
---
# Ansible
- Avoid `\\` in strings, use single-quoted strings in yaml to achieve that
- Avoid `shell`
- Use `block` with `vars` instead of `set_fact` if possible
