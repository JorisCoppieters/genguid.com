'use strict'; // JS: ES5

// ******************************
// Requires:
// ******************************

var cprint = require('color-print');
var fs = require('fs');
var fsp = require('fs-process');
var path = require('path');
var torisFormat = require('toris-format');

// ******************************
// Constants:
// ******************************

const c_FILE_EXTENSION_HTML = 'html';
const c_FILE_EXTENSION_CSS = 'css';
const c_HTML_FORMAT_RULES_CONFIG_FILE = path.resolve(__dirname, 'format-rules-html.json');
const c_CSS_FORMAT_RULES_CONFIG_FILE = path.resolve(__dirname, 'format-rules-css.json');

// ******************************
// Script:
// ******************************

fsp.list('src').then(formatFiles);

// ******************************
// Main Functions:
// ******************************

function formatFiles(filesToProcess) {
    var filesToFormat = filesToProcess.filter(_filesFilter);
    if (filesToFormat.length === 1) {
        cprint.cyan('Running formatter over file: ' + filesToFormat[0]);
    } else {
        cprint.cyan('Running formatter over files');
    }
    return fsp.process(filesToFormat, _formatFile);
}

// ******************************

function _formatFile(fileToFormat) {
    return new Promise(function (resolve) {
        try {
            var fileContents = fs.readFileSync(fileToFormat, 'utf-8');
            var fileExtension = _getFileExtension(fileToFormat);
            var config = _getConfig(fileExtension) || {};
            var formattedFileContents;

            switch (fileExtension) {
                case c_FILE_EXTENSION_HTML:
                case c_FILE_EXTENSION_CSS:
                    formattedFileContents = torisFormat.formatFile(fileToFormat, config);
                    break;

                default:
                    throw 'Cannot format file with extension: ' + fileExtension;
            }

            if (formattedFileContents === false) {
                // Couldn't format file
                cprint.red('✘ ' + fileToFormat);
                resolve();
            } else if (fileContents !== formattedFileContents) {
                // Formatting has changed
                cprint.yellow('✎ ' + fileToFormat + ' - Formatted');
                fsp.write(fileToFormat, formattedFileContents, function () {
                    resolve(true);
                });
            } else {
                // Formatting is the same as what is already there
                cprint.green('✔ ' + fileToFormat);
                resolve();
            }
        } catch (err) {
            // Something weird happened while trying to format file
            cprint.red('✘ ' + fileToFormat);
            cprint.red(err.stack || err.message || err);
            resolve();
        }
    });
}

// ******************************

function _getConfig(fileExtension) {
    switch (fileExtension) {
        case c_FILE_EXTENSION_HTML:
            return require(c_HTML_FORMAT_RULES_CONFIG_FILE);

        case c_FILE_EXTENSION_CSS:
            return require(c_CSS_FORMAT_RULES_CONFIG_FILE);
    }
}

// ******************************

function _getFileExtension(file) {
    try {
        var fileParts = file.match(/.*\.(.*)$/);
        var fileExtension = fileParts[1].trim().toLowerCase();
        return fileExtension;
    } catch (err) {
        return '';
    }
}

// ******************************

function _filesFilter(file) {
    var fileExtension = _getFileExtension(file);
    if ([c_FILE_EXTENSION_HTML, c_FILE_EXTENSION_CSS].indexOf(fileExtension) < 0) return false;
    return true;
}

// ******************************
