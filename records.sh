#!/bin/sh
# This is a comment!

Remote="https://github.com/dev-academy-programme/foundations-records.git"

Students=('oliver-harcourt' 'kelly-keating' 'engie15' 'josephquested')


name=$1
out="$(pwd)/records-output.txt"

function get_records {
    echo "Copying foundations records file...\n" 
    echo "Foundations work recorded - $(date '+%a %d %b %Y')" > $out

    git clone $Remote records-of-students-work
    cd records-of-students-work

    for name in "${Students[@]}"; do
        echo "\n\n"
        ( mkdir $name ) || ( echo "Student already exists. Copying to existing folder" )
        
        echo "\n------ $name ------" && log "\n------ $name ------"
        cd $name 

        Repos=("foundations" "minesweeper" "calculator" "$name.github.io")

        for repo in "${Repos[@]}"; do
            copy_repo $repo
        done
        cd ..
    done

    echo "\n\n\nFinished all students\n"
    git add -A
    git commit -qm "$(date '+%a %d %b %Y')"
    echo "--> Commited: $(date '+%a %d %b %Y')\n\n"

    git push origin master
    echo "\nEverything pushed to repo\nRemoving repo folder..."

    cd ..
    rm -rf records-of-students-work
    echo "\nDone :)"
}

function copy_repo {
    repo=$1

    echo "\n\nCopying $repo - https://github.com/$name/$repo.git\n"

    ( git ls-remote https://github.com/$name/$repo.git -q ) && ( 

        git clone https://github.com/$name/$repo.git original-$repo

        # if [ -d "$repo" ]; then
        #     rm -rf $repo
        # fi

        mkdir $repo

        cd original-$repo
        git fetch
        allBranches=$(git branch -r)
        cd ..

        allBranches=${allBranches#*origin/HEAD -> origin/master}

        for branch in $allBranches; do
            copy_branch ${branch#*origin/}
        done
 
        log "$repo  -  Done"
        rm -rf original-$repo

    ) || ( echo "Moving on....." && log "$repo  -  No such repo https://github.com/$name/$repo.git")
}

function copy_branch {
    branch=$1
    echo "\nCopying branch $branch"
    # log "    -  $branch"

    cd original-$repo
    git checkout $branch
    cd ..

    if [ -d "$repo/$branch" ]; then
        rm -rf $repo/$branch
    fi
    
    cp -r original-$repo $repo/$branch
    rm -rf $repo/$branch/.git
}

function log {
    echo $1 >> $out
}


get_records
