'use strict'; // JS: ES5

// ******************************
// Requires:
// ******************************

var args = require('./args');
var c = require('./constants');
var fsp = require('fs-process');
var utils = require('./utils');

// ******************************
// Globals:
// ******************************

var g_CHANGED_FILE = false;

// ******************************
// Functions:
// ******************************

function changedFile () {
    g_CHANGED_FILE = true;
}

// ******************************

function hasChangedFile () {
    return !!g_CHANGED_FILE;
}

// ******************************

function getAllFiles () {
    return fsp.list(c.SOURCE_PATH);
}

// ******************************

function fileFilter (file, desiredFileExtension) {
    var fileExtension = utils.getFileExtension(file);
    if (args.FILE_EXTENSIONS_TO_INCLUDE.indexOf(fileExtension) < 0) {
        return false;
    }

    if (desiredFileExtension && fileExtension !== desiredFileExtension) {
        return false;
    }

    var matchedIgnore = c.IGNORED_FILES.filter(function (regexp) { return file.match(new RegExp(regexp.replace(/\\/g, '\\\\'))); });
    if (matchedIgnore.length) {
        return false;
    }

    return true;
}

// ******************************
// Exports:
// ******************************

module.exports['changed'] = changedFile;
module.exports['hasChanged'] = hasChangedFile;
module.exports['filter'] = fileFilter;
module.exports['getAll'] = getAllFiles;

// ******************************
