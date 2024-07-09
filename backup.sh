#!/bin/bash
set -eu

list_repos() {
    # https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-the-authenticated-user
    curl --silent -L \
        -H 'Accept: application/vnd.github+json' \
        -H "Authorization: Bearer ${GH_TOKEN}" \
        -H "X-GitHub-Api-Version: ${GH_API_VERSION:-2022-11-28}" \
        "https://api.github.com/user/repos?type=${REPOS_TYPE:-owner}&per_page=${REPOS_PER_PAGE:-100}&page=${1}&sort=pushed" \
        | jq '.[] | select (.fork == false) | .ssh_url'
}

fetch_updates() {
    # https://stackoverflow.com/a/22792124/1117028 (+ comments)
    local branch_ref
    local current_branch_ref
    local remote
    local repos
    local ssh_url

    ssh_url="$(echo "${1}" | /bin/sed 's/"//g')"
    repos="$(echo "${ssh_url#*/}" | /bin/sed 's/\.git$//')"

    echo ">>> Syncing repository ${ssh_url} in folder ${repos}…"

    # First sync
    [ -d "${repos}" ] || git clone "${ssh_url}"

    pushd "${repos}"

    # Update the list of remote branches & tags
    git fetch --prune --tags

    # Sync all branches
    current_branch_ref="$(git symbolic-ref HEAD 2>&-)"
    git branch -r | /bin/grep -v ' -> ' | while read -r remote_branch; do
        # Split <remote>/<branch> into `remote` and `branch_ref` parts
        remote="${remote_branch%%/*}"
        branch_ref="refs/heads/${remote_branch#*/}"

        if [ "${branch_ref}" == "${current_branch_ref}" ]; then
            echo ">>> Updating current branch ${branch_ref} from ${remote}…"
            git pull --ff-only
        else
            echo ">>> Updating non-current ref ${branch_ref} from ${remote}…"
            git fetch "${remote}" "${branch_ref}:${branch_ref}"
        fi
    done

    popd
    echo
    echo
}

main() {
    local dest_folder

    dest_folder="${1:-}"

    if [ -n "${dest_folder}" ]; then
        [ -d "${dest_folder}" ] || mkdir -v "${dest_folder}"
        pushd "${dest_folder}"
    fi

    for page in $(seq 1 "${REPOS_MAX_PAGE:-2}"); do
        echo ">>> Syncing repositories from page n° ${page}…"
        echo

        for repo_ssh_url in $(list_repos "${page}"); do
            fetch_updates "${repo_ssh_url}"
        done
    done

    [ -n "${dest_folder}" ] && popd
}

main "$@"
