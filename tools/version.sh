#!/bin/bash

tag_re='([^-]+)-([^-]+)-g([^ ]+)'
semver_re='v([0-9]+).([0-9]+).([0-9]+)'
stable_re='^stable-'

TAG=$(git describe --tags --abbrev=1000)
if [[ $TAG =~ $tag_re ]]; then
    BASE="${BASH_REMATCH[1]}"
    AHEAD="${BASH_REMATCH[2]}"
    GITHASH="${BASH_REMATCH[3]}"
fi

if [[ $GITHASH == "" ]] ; then
    echo "TAG is exact"
    # Find ref tag
    commit=$(git show $TAG | head -1 | awk '{ print $2 }')
    REAL_VER=$(git tag --points-at $commit | grep -v stable)
    TAG="${TAG//stable/$REAL_VER}-0-g${commit}"
fi

if [[ $TAG =~ $tag_re ]]; then
    BASE="${BASH_REMATCH[1]}"
    AHEAD="${BASH_REMATCH[2]}"
    GITHASH="${BASH_REMATCH[3]}"
fi

if [[ $TAG == tip ]] ; then
    Extra="-tip"
    TAG=$(git describe --tags --abbrev=1000 HEAD^2)
fi

if [[ $BASE == tip ]] ; then
    MajorV="tip"
    MinorV=$(whoami)
    PatchV=$AHEAD
    Extra="-tip"
    Prepart=""
elif [[ $BASE =~ $semver_re ]] ; then
    MajorV=${BASH_REMATCH[1]}
    MinorV=${BASH_REMATCH[2]}
    PatchV=${BASH_REMATCH[3]}
    Extra="$Extra-$AHEAD"
    Prepart="v"
else
    MajorV="$BASE"
    MinorV=$(whoami)
    PatchV=$AHEAD
    Extra="$Extra-strange"
    Prepart=""
fi

echo "Version = $Prepart$MajorV.$MinorV.$PatchV$Extra-$GITHASH"
