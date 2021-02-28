#!/bin/bash

found_unused=""

for file in $(find ./src/ -type f -name "*.spec.ts");do
    cat $file > .tmp.spec.ts.txt

    cat .tmp.spec.ts.txt | \
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
        grep "|| createMock" | \
        grep -i "\(store\|service\)" | \
        sed '
            s/.\+|| createM/m/g;
            s/,//g;
            s/[(),]//g;
        ' > .tmp.mock.declaration2.ts.txt

    cat .tmp.mock.declaration1.ts.txt .tmp.mock.declaration2.ts.txt | \
        sort -u > .tmp.mock.declaration.ts.txt

    cat .tmp.spec.ts.txt | \
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

if [[ -f .tmp.all.ts.txt ]]; then
    rm .tmp.all.ts.txt
fi

if [[ -f .tmp.all.html.txt ]]; then
    rm .tmp.all.html.txt
fi

find ./src/ -type f -name "*.ts" ! -name "*.spec.ts" ! -name "*.test.ts" -exec cat {} \; > .tmp.all.ts.txt
find ./src/ -type f -name "*.html" -exec cat {} \; > .tmp.all.html.txt

cat .tmp.all.ts.txt \
    | grep "public get " \
    | sed -s 's/ \+public get //g;s/(.*//' \
    | sort -u > .tmp.public.get.ts.txt

for p in $(cat .tmp.public.get.ts.txt); do
    p2=$(echo $p | sed -s 's/\$/\\\$/g')
    ts_lines=$(cat .tmp.all.ts.txt | grep "\.$p2")
    html_lines=$(cat .tmp.all.html.txt | grep "\(of \|{{\|: \|[.\"]\)$p2")
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
    html_lines=$(cat .tmp.all.html.txt | grep "\"$p2")
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
    | grep -v "public get " \
    | grep -v "public set " \
    | sed -s '
        s/static //g;
        s/readonly //g;
        s/ \+public //g;
        s/(.*//' \
    | sort -u > .tmp.public.ts.txt

for p in $(cat .tmp.public.ts.txt); do
    p2=$(echo $p | sed -s 's/\$/\\\$/g')
    ts_lines=$(cat .tmp.all.ts.txt | grep "$p2(" | grep -v "public $p2");
    html_lines=$(cat .tmp.all.html.txt | grep "$p2(")
    if [[ ! $ts_lines && ! $html_lines ]]; then
        echo "$p not used";
        found_unused="$p"
    fi;
done

if [[ $found_unused ]]; then
    exit 1;
fi

rm .tmp.public.ts.txt

cat .tmp.all.ts.txt \
    | grep "export enum " \
    | sed -s 's/export enum //g;s/ {//' \
    | sort -u > .tmp.enum.ts.txt

for p in $(cat .tmp.enum.ts.txt); do
    ts_lines=$(cat .tmp.all.ts.txt | grep "\([(]$p[)]\|$p[\[\.]\)")
    if [[ ! $ts_lines ]]; then
        echo "$p not used";
        found_unused="$p"
    fi;
done

if [[ $found_unused ]]; then
    exit 1;
fi

rm .tmp.enum.ts.txt

cat .tmp.all.ts.txt \
    | grep "<any>(\`\\\${SERVER_URL}" \
    | sed 's/.*\.\(post\|get\|put\|delete\)<any>(`\${SERVER_URL}\/v1\/\(.*\)`.*/\U\1\E-\2/' \
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
