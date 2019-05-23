'use strict'; // JS: ES5

// ******************************
// Requries:
// ******************************

var args = require('./args');
var cprint = require('color-print');
var formatTypescript = require('./format-typescript');
var fs = require('fs');
var path = require('path');
var torisFormat = require('toris-format');

// ******************************
// Functions:
// ******************************

function runTests () {
    cprint.cyan('Running tests...');
    torisFormat.setupTest(
        {
            base_path: path.resolve(__dirname, '../../../')
        }
    );

    if (args.INCLUDE_SASS_FILES) {
        torisFormat.formatTests('./_build/format/test/scss');
        torisFormat.printTests('./_build/format/test/scss');
    }

    if (args.INCLUDE_HTML_FILES) {
        torisFormat.formatTests('./_build/format/test/html');
    }

    if (args.INCLUDE_TYPE_SCRIPT_FILES) {
        torisFormat.formatTests('./_build/format/test/ts', function(inputFile) {
            var inputContents = fs.readFileSync(inputFile, 'utf-8');
            try {
                return formatTypescript.formatTsContentsSync(inputContents, inputFile);
            } catch (err) {
                cprint.red(err);
                return '';
            }
        });
    }
}

// ******************************
// Exports:
// ******************************

module.exports['run'] = runTests;

// ******************************
