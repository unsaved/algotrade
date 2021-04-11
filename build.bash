#!/usr/bin/env bash
PROGNAME="${0##*/}"

# $Id$

set +u
shopt -s xpg_echo

unset DO_RM
[ $# -gt 0 ] && [ "$1" = -r ] && {
    DO_RM=true
    shift
}

[ $# -lt 1 ] && {
    echo "SYNTAX:  $PROGNAME MainClass [gradle args...]
Use env vars to override these defaults:
VERSION:  0.1a
DEST_URL: file:/tmp/repo
" 1>&2
    exit 3
}
MAINCLASS="$1"; shift

[ -n "$DEST_URL" ] || DEST_URL=file:/tmp/repo
[ -n "$VERSION" ] || VERSION=0.1a
[ -n "$PROJECT_NAME" ] || PROJECT_NAME="$(basename $PWD)"

Abort() {
    echo "Aborting $PROGNAME:  $*" 1>&2
    exit 1
}


[ -n "$DO_RM" ] && {
    case "$DEST_URL" in file:*);; *)
        echo 'Can only use -r switch with file DEST_URLs' 1>&2; exit 3;;
    esac
    echo "Wiping ${DEST_URL#file:}..."
    rm -rf "${DEST_URL#file:}"
}
gradlew -Pmc="$MAINCLASS" -Purl="$DEST_URL" "$@" clean uploadArchives &&
echo -n "From build/libs/${PROJECT_NAME}-$VERSION.jar:  " &&
java -jar build/libs/${PROJECT_NAME}-$VERSION.jar &&
case "$DEST_URL" in file:*)
    BASEDIR=${DEST_URL#file:}
    [ -d "$BASEDIR" ] || Abort "Target repost dir missing: BASEDIR"
    [ -f "$BASEDIR/com/admc/$PROJECT_NAME/$VERSION/${PROJECT_NAME}-$VERSION.jar" ] ||
    Abort "Reposed base jar missing: $BASEDIR/com/admc/$PROJECT_NAME/$VERSION/${PROJECT_NAME}-$VERSION.jar"
    echo -n "From $BASEDIR/com/admc/$PROJECT_NAME/$VERSION/${PROJECT_NAME}-$VERSION.jar:  " &&
    java -jar "$BASEDIR/com/admc/$PROJECT_NAME/$VERSION/${PROJECT_NAME}-$VERSION.jar"
;; esac
