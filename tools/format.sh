#!/bin/bash
source ~/.common

function _format_all() {
    npm run format -- --fix
}

function _turn_off_prettier_format() {
    jq .run_prettier=false tools/format/format-rules-ts.json > tools/format/format-rules-ts.json.tmp
    mv tools/format/format-rules-ts.json.tmp tools/format/format-rules-ts.json
}

function _turn_on_prettier_format() {
    jq .run_prettier=true tools/format/format-rules-ts.json > tools/format/format-rules-ts.json.tmp
    mv tools/format/format-rules-ts.json.tmp tools/format/format-rules-ts.json
}

_turn_on_prettier_format
_format_all
_turn_off_prettier_format
