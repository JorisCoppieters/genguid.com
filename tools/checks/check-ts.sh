#!/bin/bash

found_unused=""

for file in $(find ./src/ -type f -name "*.spec.ts");do
    cat $file > .tmp.spec.ts.txt

    cat .tmp.spec.ts.txt | \
        grep -v "^ *//" | \
        grep "const mock.* = in_mocks" | \
        grep -v "function createMocks" | \
        sed 's/,/\n/g' | \
        grep -i "\(store\|service\)" | \
        sed '
            s/const //g;
            s/ = in_mocks.\+//g;
            s/ \+//g;
        ' > .tmp.mock.declaration1.ts.txt

    cat .tmp.spec.ts.txt | \
        grep -v "^ *//" | \
        grep "|| createMock" | \
        grep -i "\(store\|service\)" | \
        tr "," "\n" | \
        grep -i "createM" | \
        sed '
            s/\.concat(in_mocks\.Router ? (\[{ provide: Router//g;
            s/.\+|| createM/m/g;
            s/,//g;
            s/[()},]//g;
            s/]//g;
            s/ \+$//g;
            s/ \.concat//g;
        ' > .tmp.mock.declaration2.ts.txt

    cat .tmp.mock.declaration1.ts.txt .tmp.mock.declaration2.ts.txt | \
        sort -u > .tmp.mock.declaration.ts.txt

    cat .tmp.spec.ts.txt | \
        grep -v "^ *//" | \
        grep ": mock" | \
        grep -v "useValue: " | \
        grep -v -e "mock.*[.]" | \
        sed 's/,/\n/g' | \
        grep -i "\(store\|service\)" | \
        sed '
            s/.*: //g;
            s/,//g;
            s/ \+//g;
            s/[});]//g;
        ' > .tmp.mock.usage1.ts.txt

    cat .tmp.spec.ts.txt | \
        grep -v "^ *//" | \
        grep "= TestBed.inject(" | \
        grep -i "\(store\|service\)" | \
        sed '
            s/const //g;
            s/ = TestBed.\+//g;
            s/ \+//g;
        ' > .tmp.mock.usage2.ts.txt

    cat .tmp.mock.usage1.ts.txt .tmp.mock.usage2.ts.txt | \
        sort -u > .tmp.mock.usage.ts.txt

    for p in $(cat .tmp.mock.declaration.ts.txt); do
        p2=$(echo "$p" | sed -s 's/\//\\\//g')
        ts_lines=$(cat .tmp.mock.usage.ts.txt | grep "^$p2$")
        if [[ ! $ts_lines ]]; then
            echo "$file: $p not used";
            found_unused="$p"
        fi;
    done

    for p in $(cat .tmp.mock.usage.ts.txt); do
        p2=$(echo "$p" | sed -s 's/\//\\\//g')
        ts_lines=$(cat .tmp.mock.declaration.ts.txt | grep "^$p2$")
        if [[ ! $ts_lines ]]; then
            echo "$file: $p not declared";
            found_unused="$p"
        fi;
    done

    if [[ $found_unused ]]; then
        exit 1;
    fi

    rm .tmp.mock.declaration1.ts.txt
    rm .tmp.mock.declaration2.ts.txt
    rm .tmp.mock.declaration.ts.txt
    rm .tmp.mock.usage1.ts.txt
    rm .tmp.mock.usage2.ts.txt
    rm .tmp.mock.usage.ts.txt
    rm .tmp.spec.ts.txt

done

for file in $(find ./src/ -type f -name "*.ts" ! -name "*.mock.ts" ! -name "*.spec.ts" ! -name "*.test.ts");do
    found_math_floor=""

    math_floor=$(cat $file | grep -v "^ *//" | grep -e "Math.floor(" | grep -v "// Ignore Math.floor()")
    if [[ ${math_floor} ]]; then
        echo "$file: has a 'Math.floor' operation";
        found_math_floor="$file"
    fi

    if [[ $found_math_floor ]]; then
        exit 1;
    fi

    found_new_date=""

    new_date=$(cat $file | grep -v "^ *//" | grep -e "new Date()" | grep -v "// Ignore new Date()")
    if [[ ${new_date} ]]; then
        echo "$file: has a 'new Date()' operation";
        found_new_date="$file"
    fi

    if [[ $found_new_date ]]; then
        exit 1;
    fi

    found_date_mult=""

    numeric_content=$(cat $file | grep -v "^ *//" | grep -e "\(1000\|60\|24\)" | grep -v "// Ignore multiplier")
    if [[ ! ${numeric_content} ]]; then
        continue
    fi

    date_mult=$(echo "${numeric_content}" | grep -e "\(1000\|60\|24\) \*")
    if [[ $date_mult ]]; then
        echo "$file: has a '1000|60|24 *' equation";
        found_date_mult="$file"
    fi

    date_mult=$(echo "${numeric_content}" | grep -e "\* \(1000\|60\|24\)")
    if [[ $date_mult ]]; then
        echo "$file: has a '* 1000|60|24' equation";
        found_date_mult="$file"
    fi

    date_mult=$(echo "${numeric_content}" | grep -e "\(1000\|60\|24\) \/")
    if [[ $date_mult ]]; then
        echo "$file: has a '1000|60|24 /' equation";
        found_date_mult="$file"
    fi

    date_mult=$(echo "${numeric_content}" | grep -e "\/ \(1000\|60\|24\)")
    if [[ $date_mult ]]; then
        echo "$file: has a '/ 1000|60|24' equation";
        found_date_mult="$file"
    fi

    if [[ $found_date_mult ]]; then
        exit 1;
    fi
done

if [[ -f .tmp.all.ts.txt ]]; then
    rm .tmp.all.ts.txt
fi

if [[ -f .tmp.all.html.txt ]]; then
    rm .tmp.all.html.txt
fi

find ./src/ -type f -name "*.ts" ! -name "*.mock.ts" ! -name "*.spec.ts" ! -name "*.test.ts" -exec cat {} \; \
    | grep -v "^$" \
    | grep -v "^ *//" \
    > .tmp.all.ts.txt
    # | grep -v "^ *[/][*][*]" \
    # | grep -v "return;$" \
    # | grep -v " *try { *$" \
    # | grep -v " *{ *$" \
    # | grep -v " *} catch*$" \
    # | grep -v " case .*$" \

find ./src/ -type f -name "*.html" -exec cat {} \; > .tmp.all.html.txt

cat .tmp.all.ts.txt \
    | grep "export function " \
    | sed -s 's/export function //g;s/(.*//;s/<.*\?>//' \
    | sort -u > .tmp.export.ts.txt

for p in $(cat .tmp.export.ts.txt); do
    p2=$(echo $p | sed -s 's/\$/\\\$/g')
    ts_lines=$(cat .tmp.all.ts.txt | grep "\($p2(\|$p2<\|then($p2\)\|{ $p2\|$p2 }\|, $p2\|$p2, " | grep -v "export function $p2");
    html_lines=$(cat .tmp.all.html.txt | grep "$p2(")
    if [[ ! $ts_lines && ! $html_lines ]]; then
        echo "exported function $p not used";
        found_unused="$p"
    fi;
done

if [[ $found_unused ]]; then
    exit 1;
fi

rm .tmp.export.ts.txt

cat .tmp.all.ts.txt \
    | grep "public get " \
    | sed -s 's/ \+public get //g;s/(.*//' \
    | sort -u > .tmp.public.get.ts.txt

for p in $(cat .tmp.public.get.ts.txt); do
    p2=$(echo $p | sed -s 's/\$/\\\$/g')
    ts_lines=$(cat .tmp.all.ts.txt | grep "\.$p2")
    html_lines=$(cat .tmp.all.html.txt | grep "\(of \|&& \|{{\|: \|[.\"]\|\!\)$p2")
    if [[ ! $ts_lines && ! $html_lines ]]; then
        echo "get $p not used";
        found_unused="$p"
    fi;
done

if [[ $found_unused ]]; then
    exit 1;
fi

rm .tmp.public.get.ts.txt

cat .tmp.all.ts.txt \
    | grep "public set " \
    | sed -s 's/ \+public set //g;s/(.*//' \
    | sort -u > .tmp.public.set.ts.txt

for p in $(cat .tmp.public.set.ts.txt); do
    p2=$(echo $p | sed -s 's/\$/\\\$/g')
    ts_lines=$(cat .tmp.all.ts.txt | grep "$p2 =")
    html_lines=$(cat .tmp.all.html.txt | grep "\(\"$p2\|\.$p2\)")
    if [[ ! $ts_lines && ! $html_lines ]]; then
        echo "set $p not used";
        found_unused="$p"
    fi;
done

if [[ $found_unused ]]; then
    exit 1;
fi

rm .tmp.public.set.ts.txt

cat .tmp.all.ts.txt \
    | grep "export const " \
    | sed -s 's/export const //g;s/ *=.*//;s/:.*//' \
    | sort -u > .tmp.public.const.ts.txt

for p in $(cat .tmp.public.const.ts.txt); do
    p2=$(echo $p | sed -s 's/\$/\\\$/g')
    ts_lines=$(cat .tmp.all.ts.txt | grep "\({.*\)\?$p2,\?")
    if [[ ! $ts_lines ]]; then
        echo "const $p not used";
        found_unused="$p"
    fi;
done

if [[ $found_unused ]]; then
    exit 1;
fi

rm .tmp.public.const.ts.txt

cat .tmp.all.ts.txt \
    | grep "public " \
    | grep "(.*)" \
    | grep -v -e "public get " -e "public set " -e "this.public" -e "\-public" -e "in_public" \
    | sed -s '
        s/static //g;
        s/readonly //g;
        s/override //g;
        s/ \+public //g;
        s/ = .*//g;
        s/(.*//;
        s/://' \
    | sort -u > .tmp.public.ts.txt

cat .tmp.all.ts.txt \
    | grep -v "public " \
    | grep "(" \
    | sort -u > .tmp.no.public.ts.txt

for p in $(cat .tmp.public.ts.txt); do
    p2=$(echo $p | sed -s 's/\$/\\\$/g')
    ts_lines=$(cat .tmp.no.public.ts.txt | grep "$p2(");
    html_lines=$(cat .tmp.all.html.txt | grep "$p2(")
    if [[ ! $ts_lines && ! $html_lines ]]; then
        echo "public $p not used";
        found_unused="$p"
    fi;
done

if [[ $found_unused ]]; then
    exit 1;
fi

rm .tmp.public.ts.txt
rm .tmp.no.public.ts.txt

cat .tmp.all.ts.txt \
    | grep "export enum " \
    | sed -s 's/\}export/export/' \
    | sed -s 's/export enum //g;s/ {//' \
    | sort -u > .tmp.enum.ts.txt

for p in $(cat .tmp.enum.ts.txt); do
    ts_lines=$(cat .tmp.all.ts.txt | grep "\([(]$p[)]\|$p[\[\.]\)")
    if [[ ! $ts_lines ]]; then
        echo "enum $p not used";
        found_unused="$p"
    fi;
done

if [[ $found_unused ]]; then
    exit 1;
fi

rm .tmp.enum.ts.txt

cat .tmp.all.ts.txt \
    | grep "<any>(\`\\\${WEB_URL}" \
    | sed 's/.*\.\(post\|get\|put\|delete\)<any>(`\${WEB_URL}\/v1\/\(.*\)`.*/\U\1\E-\2/' \
    | sed 's/\${[^\}]\+\}/_/g' \
    | sed 's/\(.*\)?.*/\1/g' > .tmp.endpoints.usage1.ts.txt

cat .tmp.all.ts.txt \
    | grep "USAGE:TOOLING -" \
    |  sed 's/.*\(post\|get\|put\|delete\).*\/v1\/\(.*\).*/\U\1\E-\2/i' > .tmp.endpoints.usage2.ts.txt

cat .tmp.endpoints.usage1.ts.txt .tmp.endpoints.usage2.ts.txt | \
    sort -u > .tmp.endpoints.usage.ts.txt

cat .tmp.all.ts.txt \
    | sed 's/ //g' \
    | tr "\n" " " \
    | tr ";" "\n" \
    | grep " router\.\(post\|get\|put\|delete\)" \
    | sed "s/.*router\.\(post\|get\|put\|delete\)( \?'\([^']\+\)'.*/\U\1\E-\2/" \
    | sed 's/:[a-zA-Z]\+/_/g' \
    | sort -u > .tmp.endpoints.declaration.ts.txt

for p in $(cat .tmp.endpoints.declaration.ts.txt); do
    p2=$(echo "$p" | sed -s 's/\//\\\//g')
    ts_lines=$(cat .tmp.endpoints.usage.ts.txt | grep "^$p2$")
    if [[ ! $ts_lines ]]; then
        echo "$p (endpoint not used)";
        found_unused="$p"
    fi;
done

for p in $(cat .tmp.endpoints.usage.ts.txt); do
    p2=$(echo "$p" | sed -s 's/\//\\\//g')
    ts_lines=$(cat .tmp.endpoints.declaration.ts.txt | grep "^$p2$")
    if [[ ! $ts_lines ]]; then
        echo "$p (endpoint doesn't exist)";
        found_unused="$p"
    fi;
done

if [[ $found_unused ]]; then
    exit 1;
fi

rm .tmp.endpoints.declaration.ts.txt
rm .tmp.endpoints.usage1.ts.txt
rm .tmp.endpoints.usage2.ts.txt
rm .tmp.endpoints.usage.ts.txt

rm .tmp.all.ts.txt
rm .tmp.all.html.txt
