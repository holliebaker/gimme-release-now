#!/bin/bash

set -e

print_usage() {
    echo "Usego: $0 <release-branch-name> <jira-number>"
}

print_message() {
    echo "---> $1"
}

if [ -z $1 ] || [ -z $2 ]
then
    print_usage
    exit 1
fi

RELEASE_BRANCH=$1
JIRA_NUMBER=$2

git fetch origin

print_message "Checkout origin/master"
git checkout master && git pull

# create the release, or pull if it already exists
if [ -z `git branch --list $RELEASE_BRANCH` ]
then
    print_message "Creating release $RELEASE_BRANCH"
    git checkout -b $RELEASE_BRANCH
    git push -u origin $RELEASE_BRANCH
else
    print_message "$RELEASE_BRANCH already exists... fetching"
    git checkout $RELEASE_BRANCH && git pull
fi

# find branch based on jira number
# search for whole jira number to avoid accidental partial matches
FEATURE_BRANCH=`git branch -a |\
    grep "\-$JIRA_NUMBER/" |\
    head -n 1 |\
    tr -d '[:space:]' |\
    sed -e 's~remotes/origin/~~g'`

if [ -z $FEATURE_BRANCH ]
then
    print_message "ERROR: can't find a branch matching $JIRA_NUMBER"
    exit 1
fi

# check if it has already been merged
if ! [ -z `git log --merges | grep $FEATURE_BRANCH` ]
then
    print_message "ALREADY MERGED! $FEATURE_BRANCH has been merged into this release before."
    exit 1
fi

# merge it!
print_message "Merging $FEATURE_BRANCH into $RELEASE_BRANCH"
git checkout $FEATURE_BRANCH && git pull && git checkout $RELEASE_BRANCH
git merge --no-ff origin/$FEATURE_BRANCH
git push origin $RELEASE_BRANCH

# copy the merge hash to clipboard
MERGE_HASH=`git log --pretty=format:'%h' -n 1`
print_message "MERGED! Hash: $MERGE_HASH"
echo $MERGE_HASH | pbcopy
