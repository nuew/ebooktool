#!/bin/false
# this is not necessarily to be directly executed but should instead serve as a
# template for processing RR inner html
#
# 'bios3' is embedded in the patch step because laziness
echo "BE CAREFUL! RR mixes in display:none admonations that this is an unauthorized scrape!"
find -name '*.html' -execdir sed -i 's/<p class="[^"]*" data-original-margin="">/<p>/g;
    s/<span style="font-weight: 400">\([^<]*\)<\/span>/\1/g' {} \; \
    -execdir sh -c 'pandoc --from html {} --to markdown -o $(basename -s .html {}).md' \;
find -name '*.html.md' -execdir sed -i '
    s/^###/#/;
    s/^# \?[[:digit:]]\+\.\?/#/;
    s/\\\([-'"'"'"]\)/\1/g;
    s/\\\.\.\./\.\.\./g;
    s/\(\*\+\)"\([^"]*\*[^$]\)/"\1\2/g;
    s/\(\*\+\)'"'"'\([^"]*\*[^$]\)/'"'"'\1\2/g' {} \;
find -name '*.md' -exec sh -c 'diff ~/docs/vigor-mortis/chapters/bios3/$(basename -s .md {})*.md {} | tail -n +4 > $(basename -s .md {}).patch' \;
-type f -name '*.patch' -exec sh -c 'patch ~/docs/vigor-mortis/chapters/bios3/$(basename -s .patch {})*.md < {}' \;
