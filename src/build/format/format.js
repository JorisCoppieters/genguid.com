'use strict'; // JS: ES5

// ******************************
// Requires:
// ******************************

var args = require('./src/args');
var c = require('./src/constants');
var files = require('./src/files');
var formatBase = require('./src/format-base');
var help = require('./src/help');
var tests = require('./src/tests');
var torisFormat = require('toris-format');

// ******************************
// Script:
// ******************************

if (parseFloat(torisFormat.k_VERSION) < c.TORIS_FORMAT_MIN_VERSION) {
    // Only checking major and minor version for now, patch version is ignored
    help.printUpdateWarning();
} else {
    switch (args.MODE) {
    case c.MODE_HELP:
        help.printHelp();
        break;
    case c.MODE_VERSION:
        help.printVersion();
        break;
    case c.MODE_TEST:
        tests.run();
        break;
    case c.MODE_ALL:
        formatAll();
        break;
    case c.MODE_FILE:
    case c.MODE_FILES:
        formatFiles(args.FILES);
        break;
    case c.MODE_STRING:
        formatString(args.STRING, args.STRING_ENCODED, args.STRING_FILENAME);
        break;
    default:
        formatAll();
        break;
    }
}

// ******************************
// Main Functions:
// ******************************

function formatAll () {
    files.getAll()
        .then(formatBase.formatFiles)
        .then(() => help.printFinalMessage(files.hasChanged()));
}

// ******************************

function formatFiles (filePaths) {
    formatBase.formatFiles(filePaths)
        .then(() => help.printFinalMessage(files.hasChanged()));
}

// ******************************

function formatString (fileContents, encoded, fileName) {
    formatBase.formatStringSync(fileContents, encoded, fileName);
}

// ******************************
