# Provider Checkout Recipes

Use these only when the user asks to check out a provider review branch into a worktree. Keep the core workflow native Git: create an isolated worktree first, then run the provider checkout command inside it.

Sources:

- GitHub CLI `gh pr checkout`: https://cli.github.com/manual/gh_pr_checkout
- GitLab CLI `glab mr checkout`: https://docs.gitlab.com/cli/mr/checkout/
- Azure DevOps CLI `az repos pr checkout`: https://learn.microsoft.com/en-us/cli/azure/repos/pr?view=azure-cli-latest#az-repos-pr-checkout

## Common Preflight

```bash
git rev-parse --show-toplevel
git status --short --branch
git worktree list --porcelain
```

Check the required CLI before using a recipe:

```bash
command -v gh
command -v glab
command -v az
```

If the command needs network access and the environment gates network, request approval before running it.

## GitHub Pull Request

Use `gh` when GitHub is the remote provider.

```bash
pr="<number-or-url>"
path="../<repo-name>-worktrees/pr-<number-or-slug>"
git worktree add --detach "$path" HEAD
```

Run the `gh pr checkout` command from inside the worktree:

```bash
git -C "$path" status --short --branch
cd "$path"
gh pr checkout "$pr"
```

Notes:

- Use `gh pr view "$pr" --json headRefName,headRepositoryOwner,baseRefName` first when branch naming or fork ownership matters.
- If the checkout fails, remove the clean detached worktree with `git worktree remove "$path"`.

## GitLab Merge Request

Use `glab` when GitLab is the remote provider.

```bash
mr="<number-or-url>"
path="../<repo-name>-worktrees/mr-<number-or-slug>"
git worktree add --detach "$path" HEAD
cd "$path"
glab mr checkout "$mr"
```

Notes:

- Use `glab mr view "$mr"` first when project, source branch, or fork behavior is unclear.
- If the checkout fails, remove the clean detached worktree with `git worktree remove "$path"`.

## Azure DevOps Pull Request

Use Azure DevOps CLI when the repo is hosted in Azure Repos.

```bash
pr="<number>"
path="../<repo-name>-worktrees/azpr-<number>"
git worktree add --detach "$path" HEAD
cd "$path"
az repos pr checkout --id "$pr"
```

If organization, project, or repository are not configured in the current Azure CLI defaults, pass them explicitly:

```bash
az repos pr checkout \
  --id "$pr" \
  --organization "<https://dev.azure.com/org>" \
  --project "<project>" \
  --repository "<repo>"
```

Notes:

- Check authentication and defaults with `az account show` and `az devops configure --list`.
- If the checkout fails, remove the clean detached worktree with `git worktree remove "$path"`.

## After Checkout

Always report:

- final worktree path;
- checked-out branch or detached state;
- upstream/tracking state when visible;
- any cleanup performed or skipped.
