#!/bin/bash

found_unused=""

scss_files=$(find ./src/ -type f -name "*.scss")
for f in ${scss_files}; do
    screen_statements=$(cat ${f} | grep '@media screen and [(]max-width:')
    screen_statements="$(echo "$screen_statements" \
        | grep -v "max-width: 1550px" \
        | grep -v "max-width: 1240px" \
        | grep -v "max-width: 991px" \
        | grep -v "max-width: 767px" \
        | grep -v "max-width: 479px" \
        | grep -v "max-width: 340px")"

    if [[ ${screen_statements} ]]; then
        echo "${f}: Has screen statement that isn't one of (1550px, 1240px, 991px, 767px, 479px, 340px)"
        exit -1;
    fi

    pascal_case_class=$(cat ${f} | grep "\.[a-z]*[A-Z]")

    if [[ ${pascal_case_class} ]]; then
        echo -e "${f}: Has pascal case class: \n${pascal_case_class}"
        exit -1;
    fi

    if [[ $f != *"/base.scss"* ]]; then
        hex_color=$(cat ${f} | grep "[^&]#[a-fA-F0-9]\{3,8\}")
        if [[ ${hex_color} ]]; then
            echo -e "${f}: Has hex color value: \n${hex_color}"
            exit -1;
        fi

        rgb_color=$(cat ${f} | grep "rgb(")
        if [[ ${rgb_color} ]]; then
            echo -e "${f}: Has RGB color value: \n${rgb_color}"
            exit -1;
        fi

        rgba_color=$(cat ${f} | grep "rgba(")
        if [[ ${rgba_color} ]]; then
            echo -e "${f}: Has RGBA color value: \n${rgba_color}"
            exit -1;
        fi

        hsl_color=$(cat ${f} | grep "hsl(")
        if [[ ${hsl_color} ]]; then
            echo -e "${f}: Has HSL color value: \n${hsl_color}"
            exit -1;
        fi

        hwb_color=$(cat ${f} | grep "hwb(")
        if [[ ${hwb_color} ]]; then
            echo -e "${f}: Has HWB color value: \n${hwb_color}"
            exit -1;
        fi
    fi
done

if [[ -f .tmp.all.scss.txt ]]; then
    rm .tmp.all.scss.txt
fi

find ./src/ -type f -name "*.scss" -exec cat {} \; > .tmp.all.scss.txt

cat .tmp.all.scss.txt \
    | grep -v "^ *//" \
    | grep "^\$.*:" \
    | sed -s 's/:.*//g' \
    | sort -u > .tmp.variables.scss.txt

for p in $(cat .tmp.variables.scss.txt); do
    p2=$(echo $p | sed -s 's/\$/\\\$/g')
    scss_lines=$(cat .tmp.all.scss.txt | grep "$p2 *[+;]")
    scss_lines_2=$(cat .tmp.all.scss.txt | grep "($p2[,)]")
    if [[ ! $scss_lines && ! $scss_lines_2 ]]; then
        echo "variable $p not used";
        found_unused="$p"
    fi;
done

if [[ $found_unused ]]; then
    exit 1;
fi

rm .tmp.variables.scss.txt
rm .tmp.all.scss.txt
