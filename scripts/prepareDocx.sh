#!/usr/bin/env bash

function usage () {
    echo "Usage: ${BASH_SOURCE:-$0} [-f offset] [-o output_dir] <input_file>"
}

# parse arguments
while getopts ":f:ho:" OPTION; do
    case $OPTION in
        'f') offset=$((10#$OPTARG)) ;;
        'h') usage && exit 0 ;;
        'o') outdir="$OPTARG" ;;
        '?') usage && exit 1 ;;
    esac
done

# check that we have a positional argument
[ $(($# + 1)) == $OPTIND ] && usage && exit 1

# set default argument values
offset=${offset:-$((10#1))}
input_basename="$(basename "${!OPTIND}")"
outdir="$(readlink -f ${outdir:-${input_basename%.*}})"

# create conversion target file and working directory
mdout="$(mktemp --tmpdir XXXXXXXXXX.md)"
workdir="$(mktemp -d --tmpdir)"

# convert input file to markdown, and make adjustments to markdown output to taste
pandoc --track-changes=reject -o "$mdout" "${!OPTIND}"
sed -i 's/^###/#/;
        /^#\+ *$/d;
        s/^# \?\(Chapter \)\?[[:digit:]]\+\.\?\( -\)\?/#/;
        s/\\\([-'"'"'"]\)/\1/g;
        s/\\\.\.\./\.\.\./g;
        s/\(\*\+\)"\([^"]*\*[^$]\)/"\1\2/g;
        s/\(\*\+\)'"'"'\([^"]*\*[^$]\)/'"'"'\1\2/g' "$mdout"

cd "$workdir"

# split markdown file by headings and move files to appropriate filename
csplit -sz "$mdout" '/^#\($\| \)/' '{*}'
for f in xx*; do
    # parse filename and first line of file to get chapter number and formatted title
    number=$((10#$(sed 's/xx\([[:digit:]]*\)/\1/' <<< "$f") + offset))
    title="$(head -n1 "$f" | tr '[:upper:] ' '[:lower:]-' | tr -cd '[:alnum:]-')"

    # combine chapter number and title, and move file there
    mv "$f" "$(printf '%02d%s.md' "$number" "$title")"
done

# clean up
rm "$mdout"
mv "$workdir" "$outdir"
