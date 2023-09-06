#!/bin/bash
source ~/.common

function _prettier_format() {
    f="$1"
    npx prettier --write --tab-width 4 --single-quote $f
}

function _get_line_num() {
    f="$1"
    shift 1;
    s="$@"
    grep -n "$s" "$f" | head -n 1 | cut -d: -f1
}

function _parse_name() {
    f="$1"
    echo $(basename $1 | sed 's/.spec.ts//;s/.component//;s/.store//')
}

function _parse_type() {
    f="$1"
    name=$(basename $1 | sed 's/.spec.ts//')
    if [[ $name == *".component" ]]; then
        echo "component"
        return;
    fi
    if [[ $name == *".store" ]]; then
        echo "store"
        return;
    fi
    if [[ $name == *".service" ]]; then
        echo "service"
        return;
    fi
    echo "unknown"
}

function _parse_providers() {
    f="$1"
    cat $f | grep "provide: "  | sed 's/ *provide: \(.*\?\),/\1/'
}

function _has_date_set() {
    f="$1"
    cat $f | grep "beforeAll(() => setNow("
}

function _add_date_set() {
    f="$1"

    print_warning "Adding date set to \"$f\"..."

    add="import { setNow, unsetNow } from '../../shared/core/date';"
    ln=$(_get_line_num $f "describe(")
    i=$(( $ln - 2 ))
    i1=$(( $i + 1 ))
    { head -n ${i} $f; echo -e $add; tail -n +${i1} $f; } > "$f.tmp"
    mv "$f.tmp" "$f"

    add="\nbeforeAll(() => setNow(new Date('2020-01-01T10:59:59.000Z')));\nafterAll(() => unsetNow());"
    ln=$(_get_line_num $f "return TestBed.inject(")
    i=$(( $ln + 1 ))
    i1=$(( $i + 1 ))
    { head -n ${i} $f; echo -e $add; tail -n +${i1} $f; } > "$f.tmp"
    mv "$f.tmp" "$f"
    # _prettier_format $f
}

function _has_create_test() {
    f="$1"
    cat $f | grep "it('should create the store'"
}

function _add_create_test() {
    f="$1"

    print_warning "Adding create test to \"$f\"..."

    add="\nit('should create the store', async () => expect(await createMocks()).toBeDefined());"
    ln=$(_get_line_num $f "afterAll(() => unsetNow());")
    i=$(( $ln ))
    i1=$(( $i + 1 ))
    { head -n ${i} $f; echo -e $add; tail -n +${i1} $f; } > "$f.tmp"
    mv "$f.tmp" "$f"
}

spec_files=$(find ./src -type f \( -iname "*.store.spec.ts" ! -path "./src/tests/*" \))
for f in $spec_files; do
    name=$(_parse_name $f)
    type=$(_parse_type $f)
    providers=$(_parse_providers $f)
    bad=""

    if [[ $type == "store" ]]; then
        if [[ -z $(_has_date_set $f) ]]; then _add_date_set $f; fi
        if [[ -z $(_has_create_test $f) ]]; then _add_create_test $f; fi
    elif [[ $type == "service" ]]; then
        has_date_set=$(_has_date_set $f)
    elif [[ $type == "component" ]]; then
        has_date_set=$(_has_date_set $f)
    else
        print_warning "Unknown test type: $f"
        bad="true"
    fi

    if [[ -z $bad ]]; then
        print_success "✓ $name [${type}]"
    fi
    # for p in $providers; do
    #     print_info "Provider: $p"
    # done
done
