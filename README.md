# Gimme Release Now

For people too lazy to checkout and merge themselves.

## Usage

From within the repo you want to make your release for.
```bash
bash mkrelease.sh <release-branch-name> <jira-number>
```

## Known Limitations

- If you have two different feature branches with the same jira number it will pick the first one that comes up when running `git branch -a`.
