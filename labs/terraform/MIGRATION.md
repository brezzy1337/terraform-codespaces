# Migration: standalone `github_repository` → `github_repository.repo_foreach`

## Goal

Consolidate repository management onto a single `for_each` resource (`github_repository.repo_foreach` over `var.repositories`) instead of one standalone `github_repository` block per environment.

## Starting state

- `github_repository.repo_foreach` (for_each: development / staging / production) — kept.
- `github_repository.development` — separate repo named `var.dev_repository_name` (`development-repo`). Carried `has_issues`, `has_discussions`, `has_wiki`, `merge_settings`, custom description.
- Dependent blocks referenced `github_repository.development` or `github_repository.production` (the latter was already broken — referenced but never declared).

## Changes

### Removed
| Resource | Reason |
| --- | --- |
| `github_repository_file.development_files` | Per request. |
| `github_repository.development` | Folded under `repo_foreach["development"]`. Repo destroyed on GitHub. |
| `github_branch.development` | `auto_init = true` on `repo_foreach` already creates `main`. |
| `github_branch_default.development` | `auto_init` already sets `main` as default. |
| `github_branch_protection.development` (single block) | Conflicted on `main` with `protection_development["main"]`. |
| `github_branch_protection.production` (single block) | Rich settings merged into `protection_production` for_each. |

### Migrated
References swapped from `github_repository.development` / `github_repository.production` to `github_repository.repo_foreach["<env>"]` in:

- `github_branch_protection.protection_*` (no change — already referenced `repo_foreach`)
- `github_repository_environment.production`
- `github_repository_file.production_readme`
- Outputs in [outputs.tf](outputs.tf): `development_repo`, `production_repo`, `development_repo_url`, `production_repo_url`

### Settings merged onto `protection_production`
`enforce_admins`, `require_signed_commits`, and `required_pull_request_reviews { ... }` were lifted off the deleted single-block resource and applied to the for_each block. Every pattern in `var.branch_patterns` on the prod repo now gets the rich rules.

## Errors hit during apply

### `Cannot delete the default branch`

```
DELETE .../development-repo/git/refs/heads/main: 422 Cannot delete the default branch
```

Cause: `github_branch.development` was in state bound to `development-repo`. After removing the block, TF tried to delete `main` from `development-repo`, but `main` was its default branch.

Fix: rename `main` on the old repo before re-applying so the destroy returns 404 (provider treats as already-gone):

```
gh api -X POST /repos/<owner>/development-repo/branches/main/rename -f new_name=main-disabled
```

### `Name already protected: main`

```
Error: Name already protected: main
  with github_branch_protection.production
```

Cause: `protection_production` (for_each over `var.branch_patterns`, which contained `"main"`) was already creating a protection rule for `main` on the prod repo. The standalone `github_branch_protection.production` then tried to create a second rule for the same branch.

Fix: deleted the standalone single-block protection. The for_each block is the sole owner of `main` protection, with the rich settings folded in.

Same conflict existed on the dev side — resolved the same way.

## Apply runbook

1. Rename the old repo's default branch (Step 1 above).
2. `terraform plan` to confirm the planned destroys/replaces look right.
3. `terraform apply`.

## Follow-ups (now-unused, not yet removed)

- [variables.tf:75-97](variables.tf#L75-L97) — `dev_repository_name`, `dev_repo_issues`, `dev_discussions`, `dev_wiki`
- [main.tf:5-22](main.tf#L5-L22) locals — `repo_features`, `merge_settings`, `managed_by`
- [variables.tf:37](variables.tf#L37) — `repo_files` (unused after `development_files` removal)
