#!/usr/bin/env bash
PROGNAME="${0##*/}"

# $Id$

set +u
shopt -s xpg_echo

[ $# -ne 1 ] && {
    echo "SYNTAX:  $PROGNAME MainClass
Use env vars to override these defaults:
VERSION:  0.1a
DEST_URL: file:/tmp/repo
" 1>&2
    exit 3
}
MAINCLASS="$1"; shift

[ -n "$DEST_URL" ] || DEST_URL=file:/tmp/repo
[ -n "$VERSION" ] || VERSION=0.1a

Abort() {
    echo "Aborting $PROGNAME:  $*" 1>&2
    exit 1
}


gradlew -Pmc="$MAINCLASS" -Purl="$DEST_URL" clean build uploadArchives &&
echo -n "From build/libs/repotst-$VERSION.jar:  " &&
java -jar build/libs/repotst-$VERSION.jar &&
case "$DEST_URL" in file:*)
    BASEDIR=${DEST_URL#file:}
    [ -d "$BASEDIR" ] || Abort "Target repost dir missing: BASEDIR"
    [ -f "$BASEDIR/repotst/$VERSION/repotst-$VERSION.jar" ] ||
    Abort "Reposed base jar missing: $BASEDIR/repotst/$VERSION/repotst-$VERSION.jar"
    echo -n "From $BASEDIR/repotst/$VERSION/repotst-$VERSION.jar:  " &&
    java -jar "$BASEDIR/repotst/$VERSION/repotst-$VERSION.jar"
;; esac
