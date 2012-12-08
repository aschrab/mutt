#!/bin/sh

HG=hg

# Switch to directory where this script lives so that further commands are run
# from the root directory of the source.  The script path and srcdir are double
# quoted to allow the space character to appear in the path.
srcdir=`dirname "$0"` && cd "$srcdir" || exit 1

# If there's a mercurial repo and hg is installed,
# use that to build a detailed version string
if [ -d .hg ] && $HG >/dev/null 2>&1; then
	# This is a mercurial repo and we have the hg command.

	# Get essential properties of the current working copy
	set -- `$HG parents --template='{rev} {node|short}\n'`
	rev="$1"
	node="$2"

	# translate release tags into ##.##.## notation
	cleantag () {
		case "$1" in
			mutt-*-rel) echo "$1" | sed -e 's/mutt-//' -e 's/-rel//' | tr - . ;;
			*)          echo "$1" ;;
		esac
	}

	getdistance_old () {
		# fudge it
		set -- `$HG tags | sort -n -k 2 | egrep 'mutt-.*rel' | tail -1 | cut -d: -f1`
		latesttag="$1"
		latestrev="$2"
		distance=`expr $rev - $latestrev`
		echo $latesttag $distance
	}

	getdistance_new () {
		$HG parents --template='{latesttag} {latesttagdistance}\n'
	}


	# latesttag appeared in hg 1.4.  Test for it.
	[ "`$HG log -r . --template='{latesttag}'`" = '' ] && 
	set -- `getdistance_old` ||
	set -- `getdistance_new`

	tag=`cleantag "$1"`
	dist=$2

	if [ $dist -eq 0 ]; then
		dist=
	else
		dist="+$dist"
	fi

	# if we have mq patches applied, mention it
	qparent=`$HG log -r qparent --template='{rev}\n' 2>/dev/null || echo $rev`
	qdelta=`expr $rev - $qparent`
	if [ $qdelta -eq 0 ]; then
		qdist=""
	else
		qdist=",mq+$qdelta"
	fi

	echo "$tag$dist$qdist ($node)"
	exit 0
fi

# If git is present and in a git repo use that to build detailed version string
if git rev-parse 2> /dev/null; then
	# Transform string like "mutt-1-6-1-rel-108-g2415feb+" into "1.6.1+108 (g2415feb+)"
	git describe --long --tags --match 'mutt-*-rel' --dirty=+ | sed \
		-e 's/mutt-//' \
		-e 's/-rel-\([0-9]*\)/+\1/' \
		-e 's/-\(g.*\)/ (\1)/' \
		-e 's/-/./g'
	exit 0
fi

# If nothing else worked, just cat the VERSION file;
# it contains the latest release number.
cat VERSION
