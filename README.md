# ci-config-itamae

## Requires
* Ruby
* [ghq](https://github.com/motemen/ghq)
* [hub](https://github.com/github/hub)

## Setup
```bash
cp .env.example .env
vi .env
```

[Create personal access token](https://github.com/settings/tokens/new?description=ci-config-itamae&scopes=repo) and put to `.env` as `GITHUB_TOKEN`

## Usage
### 1. Generate migration file
```bash
$ ./bin/generate --help
Usage: generate [options]
    -t, --template=TEMPLATE
```

e.g.

```bash
$ ./bin/generate --template=github_actions some_migration
Write to /path/to/ci-config-itamae/cookbooks/migrate/github_actions/20200311232827_some_migration.rb
```

### 2. Apply migration file
```bash
$ ./bin/migrate --help
Usage: migrate [options]
        --dry-run
        --log-level=LOG_LEVEL
        --recipe=RECIPE
        --repo=REPO
    -m, --message=COMMIT_MESSAGE
        --include=TAGS
        --exclude=TAGS
```

e.g.

```bash
# Apply to a repo
$ ./bin/migrate --recipe=cookbooks/migrate/github_actions/20200311232827_some_migration.rb -m "This is commit message" --repo=github.com/sue445/rubicure --dry-run

# Apply to multiple repos
$ ./bin/migrate --recipe=cookbooks/migrate/github_actions/20200311232827_some_migration.rb -m "This is commit message" --include=gem --dry-run
```

Run `./bin/migrate` without `--dry-run`.
