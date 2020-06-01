#!/bin/sh
# This is a comment!


# change these variables :)
students=("emilyparkes" "josephquested" "kelly-keating" "oliver-harcourt")
cohort="COHORT-YEAR"

# create your own access token (with repo permissions) - https://github.com/settings/tokens/new
my_access_token="somerandomstringofchars"

# change these at your own risk ;)
# (aka pls don't)
remote="https://github.com/eda-foundations-records"
out="$(pwd)/records-output-$cohort.txt"

function get_records {
    echo "Copying foundations records file...\n" 
    echo "Foundations work recorded - $(date '+%a %d %b %Y')" > $out

    create_records_repo
    git clone $remote/$cohort.git

    cd $cohort

    for name in "${students[@]}"; do
        echo "\n\n"
        ( mkdir $name ) || ( echo "Student already exists. Copying to existing folder" )
        
        echo "\n------ $name ------" && log "\n------ $name ------"
        cd $name 

        repos=("$name.github.io" "reflections" "DOM-interactions" "minesweeper" "javascript-carnival" "calculator")

        for repo in "${repos[@]}"; do
            copy_repo $repo
        done
        cd ..
    done

    echo "\n\n\nFinished all students\n"
    cp ../records-output-$cohort.txt records-output-$cohort.txt
    echo "\nRecords copied :)\n"
    git add -A
    git commit -qm "$cohort - $(date '+%a %d %b %Y')"
    echo "--> Commited: $(date '+%a %d %b %Y')\n\n" 

    git push origin master
    echo "\nEverything pushed to repo\nRemoving repo folder..."

    cd ..
    rm -rf $cohort
    echo "\nDone :)"
}

function create_records_repo {
    new_repo_data='{"name":"'"$cohort"'", "private": true}'

    ( curl -H "Authorization: token $my_access_token" -X POST --data "$new_repo_data" https://api.github.com/orgs/eda-foundations-records/repos > /dev/null ) && ( echo "\n\nCreated repo $cohort\n" )
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
