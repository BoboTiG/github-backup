# GitHub Repositories Backup Script

Sync all private, and public, repositories, except forks.

Usage:

```shell
$ GH_TOKEN='<YOUR-TOKEN>' ./backup.sh [DEST_FOLDER]
```

Backups will be synced into the `DEST_FOLDER` folder if provided, else into the current working directory.

## Tweak

You can tweak several contants related to the [repositories fetch endpoint](https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-the-authenticated-user):

- `GH_API_VERSION` (defaults to `2022-11-28`)
- `REPOS_MAX_PAGE` (defaults to `2`)
- `REPOS_PER_PAGE` (defaults to `100`)
- `REPOS_TYPE` (defaults to `owner`)
