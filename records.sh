#!/bin/sh
# This is a comment!

Students=('kelly-keating' 'engie15' 'josephquested' 'oliver-harcourt')

name=$1

function get_records {
    echo "Copying foundations records file...\n"
    git clone https://github.com/dev-academy-programme/foundations-records.git records-of-students-work

    cd records-of-students-work
    git pull origin master

    for name in "${Students[@]}"; do
        echo "\n\n"
        ( mkdir $name ) || ( echo "Student already exists. Copying to existing folder" )
        
        echo "\n------ $name ------"
        cd $name 
        copy_repo "foundations"
        copy_repo "$name.github.io"
        copy_repo "calculator"
        copy_repo "minesweeper"
        cd ..
    done

    echo "\nFinished all students\n"
    git add -A
    git commit -qm "$(date '+%a %d %b %Y')"
    echo "--> Commited: $(date '+%a %d %b %Y')\n\n"

    git push origin master
    echo "\n\nPushed to repo"

    cd ..
    rm -rf records-of-students-work
    echo "\nDone :)"
}

function copy_repo {
    repo=$1

    echo "\n\nCopying $repo - https://github.com/$name/$repo.git\n"

    ( git ls-remote https://github.com/$name/$repo.git -q ) && ( 

        git clone https://github.com/$name/$repo.git original-$repo

        if [ -d "$repo" ]; then
            rm -rf $repo
        fi

        mkdir $repo

        cd original-$repo
        git fetch
        allBranches=$(git branch -r)
        cd ..

        allBranches=${allBranches#*origin/HEAD -> origin/master}

        for branch in $allBranches; do
            copy_branch ${branch#*origin/}
        done
        
        rm -rf original-$repo

    ) || ( echo "Moving on....." )
}

function copy_branch {
    branch=$1
    echo "\nCopying branch $branch"

    cd original-$repo
    git checkout $branch
    cd ..

    if [ -d "$repo/$branch" ]; then
        rm -rf $repo/$branch
    fi
    
    cp -r original-$repo $repo/$branch
    rm -rf $repo/$branch/.git
}

get_records
