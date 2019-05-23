'use strict'; // JS: ES5

// ******************************
// Requires:
// ******************************

var args = require('./args');
var c = require('./constants');
var cprint = require('color-print');
var files = require('./files');
var formatTypescript = require('./format-typescript');
var fs = require('fs');
var fsp = require('fs-process');
var torisFormat = require('toris-format');
var utils = require('./utils');

// ******************************
// Functions:
// ******************************

function formatFiles (filesToProcess) {
    if (!args.FORMAT) {
        return Promise.resolve(filesToProcess);
    }

    var filesToFormat = filesToProcess.filter(function (file) { return files.filter(file); });

    if (filesToFormat.length === 1) {
        cprint.cyan('Running formatter over file: ' + filesToFormat[0]);
    } else {
        cprint.cyan('Running formatter over files');
    }

    return fsp.process(filesToFormat, function(fileToFormat, cbResolve) {
        _formatFile(fileToFormat).then(cbResolve);
    })
        .then(function (fileChangesMade) {
            var fileChangeMade = Array.isArray(fileChangesMade) && fileChangesMade.filter(function(fileChangeMade) { return fileChangeMade; }).length;
            if (fileChangeMade) {
                files.changed();
            }
        })
        .then(formatTypescript.fixTsFiles);
}

// ******************************

function _formatFile (fileToFormat) {
    return new Promise(function (resolve) {
        try {

            var fileContents = fs.readFileSync(fileToFormat, 'utf-8');
            var fileExtension = utils.getFileExtension(fileToFormat);
            var config = _getConfig(fileExtension) || {};
            var formattedFileContents;

            switch (fileExtension) {
            case c.FILE_EXTENSION_HTML:
            case c.FILE_EXTENSION_SASS:
                formattedFileContents = torisFormat.formatFile(fileToFormat, config);
                break;

            case c.FILE_EXTENSION_TYPE_SCRIPT:
                formattedFileContents = formatTypescript.formatTsContentsSync(fileContents, fileToFormat);
                break;

            default:
                throw 'Cannot format file with extension: ' + fileExtension;
            }

            if (formattedFileContents === false) { // Couldn't format file
                cprint.red('✘ ' + fileToFormat);
                resolve();

            } else if (fileContents !== formattedFileContents) { // Formatting has changed
                if (!args.PRINT_ERRORS_ONLY) {
                    cprint.yellow('✎ ' + fileToFormat + ' - Formatted');
                }

                if (!args.DRY_RUN) {
                    fsp.write(fileToFormat, formattedFileContents, function () {
                        resolve(true);
                    });
                } else {
                    resolve();
                }

            } else { // Formatting is the same as what is already there
                if (!args.PRINT_CHANGED_ONLY && !args.PRINT_ERRORS_ONLY) {
                    cprint.green('✔ ' + fileToFormat);
                }
                resolve();
            }
        } catch (err) { // Something weird happened while trying to format file
            cprint.red('✘ ' + fileToFormat);
            cprint.red(err.stack || err.message || err);
            resolve();
        }
    });
}

// ******************************

function formatStringSync (fileContents, encoded, fileName) {
    var indent = '    ';
    var indentCount = 0;

    var input;

    if (encoded) {
        var encoded_content = fileContents;
        input = new Buffer(encoded_content, 'base64').toString('utf-8');
    } else {
        input = fileContents;
    }

    var matches = input.match(/^[\n\r]?([ ]*)/);
    if (matches) {
        var tab = matches[1] || '';
        while (tab.substr(0, indent.length) === indent) {
            tab = tab.substr(indent.length);
            indentCount++;
        }
    }

    var output = input;
    var formattedFileContents;

    var fileExtension = utils.getFileExtension(fileName || '.html');
    var config = _getConfig(fileExtension) || {};

    switch (fileExtension) {
    case c.FILE_EXTENSION_HTML:
    case c.FILE_EXTENSION_SASS:
        config.indent_count = indentCount;
        config.line_ending = '\n';

        formattedFileContents = torisFormat.formatFile(fileName, config);
        break;

    case c.FILE_EXTENSION_TYPE_SCRIPT:
        formattedFileContents = formatTypescript.formatTsContentsSync(fileContents, fileName);
        break;

    default:
        throw 'Cannot format file with extension: ' + fileExtension;
    }

    if (formattedFileContents && input !== formattedFileContents) {
        output = formattedFileContents;
    }

    if (encoded) {
        output = Buffer(output, 'utf-8').toString('base64');
    }

    process.stdout.write(output + '\n');
}

// ******************************

function _getConfig (fileExtension) {
    switch (fileExtension) {
    case c.FILE_EXTENSION_HTML:
        return require(c.HTML_FORMAT_RULES_COFNIG_FILE);

    case c.FILE_EXTENSION_SASS:
        return require(c.SASS_FORMAT_RULES_COFNIG_FILE);

    case c.FILE_EXTENSION_TYPE_SCRIPT:
        return null;
    }
}

// ******************************
// Exports:
// ******************************

module.exports['formatFiles'] = formatFiles;
module.exports['formatStringSync'] = formatStringSync;

// ******************************
