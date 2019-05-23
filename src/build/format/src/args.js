'use strict'; // JS: ES5

// ******************************
// Requires:
// ******************************

var c = require('./constants');
var minimist = require('minimist');

// ******************************
// Arguments:
// ******************************

var _ARGV = minimist(process.argv.slice(2));

// ******************************
// Exports:
// ******************************

module.exports['DRY_RUN'] = _ARGV['dry-run'];
module.exports['FORMAT'] = _ARGV['format'] !== false;
module.exports['TSLINT'] = _ARGV['tslint'] !== false;
module.exports['IGNORE_UNCOMMITTED_CHANGES'] = _ARGV['ignore-uncommitted'] || _ARGV['dry-run'];
module.exports['PRINT_CHANGED_ONLY'] = _ARGV['print-changed'];
module.exports['PRINT_ERRORS_ONLY'] = _ARGV['print-errors'];

var fileExtensionsToInclude = [];

if (_ARGV['sass'] !== false && _ARGV['scss'] !== false) {
    module.exports['INCLUDE_SASS_FILES'] = true;
    fileExtensionsToInclude.push(c.FILE_EXTENSION_SASS);
}

if (_ARGV['html'] !== false) {
    module.exports['INCLUDE_HTML_FILES'] = true;
    fileExtensionsToInclude.push(c.FILE_EXTENSION_HTML);
}

if (_ARGV['ts'] !== false && _ARGV['typescript'] !== false) {
    module.exports['INCLUDE_TYPE_SCRIPT_FILES'] = true;
    fileExtensionsToInclude.push(c.FILE_EXTENSION_TYPE_SCRIPT);
}

module.exports['FILE_EXTENSIONS_TO_INCLUDE'] = fileExtensionsToInclude;

if (_ARGV['help']) {
    module.exports['MODE'] = c.MODE_HELP;

} else if (_ARGV['version']) {
    module.exports['MODE'] = c.MODE_VERSION;

} else if (_ARGV['test']) {
    module.exports['MODE'] = c.MODE_TEST;

} else if (_ARGV['all']) {
    module.exports['MODE'] = c.MODE_ALL;

} else if (_ARGV['file']) {
    module.exports['MODE'] = c.MODE_FILE;
    module.exports['FILES'] = [_ARGV['file']];

} else if (_ARGV['files']) {
    module.exports['MODE'] = c.MODE_FILES;
    module.exports['FILES'] = _ARGV['files'].split(/[,; ]/);

} else if (_ARGV['string']) {
    module.exports['MODE'] = c.MODE_STRING;
    module.exports['STRING'] = _ARGV['string'];
    module.exports['STRING_ENCODED'] = _ARGV['encoded'];
    module.exports['STRING_FILENAME'] = _ARGV['filename'];

} else {
    module.exports['MODE'] = c.MODE_CHANGES;
}

// ******************************
