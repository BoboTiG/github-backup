# GitHub Repositories Backup Script

Sync all private, and public, repositories, except forks.

Usage:

```shell
$ GH_TOKEN='<YOUR-TOKEN>' ./backup.sh [DEST_FOLDER]
```

Backups will be synced into the `DEST_FOLDER` folder if provided, else into the current working directory.
