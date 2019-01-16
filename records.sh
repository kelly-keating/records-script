#!/bin/sh
# This is a comment!



# get name(s) / gitub key
name=$1

function get_records {

    echo Copying foundations records file
    # git clone https://github.com/dev-academy-programme/foundations-records.git records

    mkdir records
    mkdir records/$name

    # copy_repo "foundations"
    copy_repo "$name.github.io"
    copy_repo "calculator"
    copy_repo "minesweeper"
}

function copy_repo {
    repo=$1
    git clone https://github.com/$name/$repo.git
    mkdir records/$name/$repo

    cd $repo
    git fetch
    allBranches=$(git branch -r)
    cd ..

    allBranches=${allBranches#*origin/HEAD -> origin/master}

    for branch in $allBranches; do
        copy_branch ${branch#*origin/}
    done
    
    rm -rf $repo
}

function copy_branch {
    branch=$1
    cp -r $repo records/$name/$repo/$branch
    rm -rf records/$name/$repo/$branch/.git
}

get_records
