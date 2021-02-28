#!/bin/bash

scss_files=$(find ./src/ -type f -name "*.scss")
for f in ${scss_files}; do
    screen_statements=$(cat ${f} | grep '@media screen and [(]max-width:')
    screen_statements="$(echo "$screen_statements" \
        | grep -v "max-width: 991px" \
        | grep -v "max-width: 767px" \
        | grep -v "max-width: 479px")"

    if [[ ${screen_statements} ]]; then
        echo "${f}: Has screen statement that isn't one of (991px, 767px, 479px)"
        exit -1;
    fi
done
