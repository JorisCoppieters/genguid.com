'use strict'; // JS: ES5

// ******************************
// Requries:
// ******************************

var c = require('./constants');
var childProcess = require('child_process');
var cprint = require('color-print');
var path = require('path');
var utils = require('./utils');
var files = require('./files');
var args = require('./args');

// ******************************
// Constants:
// ******************************

const MAX_IMPORT_LENGTH = 80;

// ******************************
// Functions:
// ******************************

function fixTsFiles (filesToProcess) {
    if (args.DRY_RUN || !args.INCLUDE_TYPE_SCRIPT_FILES || !args.TSLINT) {
        return Promise.resolve(filesToProcess);
    }

    filesToProcess = filesToProcess || [];

    var tsFilesToFormat = filesToProcess.filter(function (file) { return files.filter(file, c.FILE_EXTENSION_TYPE_SCRIPT); });
    if (!tsFilesToFormat.length) {
        return Promise.resolve(filesToProcess);
    }

    tsFilesToFormat = tsFilesToFormat.map(function (file) {
        return path.resolve(__dirname, '../../../', file);
    });

    return new Promise(function (resolve) {
        try {
            cprint.cyan('Running tslint --fix over changed files to fix up any introduced linting issues...');
            var tslint = path.resolve(__dirname, c.TSLINT_FOLDER);
            var configFile = path.resolve(__dirname, c.TSLINT_CONFIG_FILE);
            var customRulesFolder = path.resolve(__dirname, c.TSLINT_CUSTOM_RULES_FOLDER);

            var filesList = '"' + tsFilesToFormat.join('" "') + '"';

            var cmd = 'node "' + tslint + '" -c "' + configFile + '" -r "' + customRulesFolder + '" --fix' + ' ' + filesList;
            childProcess.exec(cmd, function (_, stdout){
                var fileChangeMade = stdout && stdout.trim().length && stdout.match('Fixed .*');
                if (fileChangeMade) {
                    files.changed();
                }
                resolve();
            });

        } catch (err) {
            cprint.red(err);
            resolve();
        }
    });
}

// ******************************

function formatTsContentsSync (tsContents, tsFile) {
    // var settings = require(c.TS_FORMAT_RULES_COFNIG_FILE);
    var formattedFileContents = tsContents;
    formattedFileContents = formattedFileContents.replace(/(\r\n?|\n)/g, '\n');
    formattedFileContents = _correctTsImports(formattedFileContents, tsFile);
    // formattedFileContents = formattedFileContents.replace(/\n/g, settings.newLineCharacter);
    return formattedFileContents;
}

// ******************************

function _correctTsImports (tsContents, tsFile) {
    var fileName = path.basename(tsFile);

    var fileExtension = utils.getFileExtension(fileName);
    fileName = fileName.replace(new RegExp('.' + fileExtension), '');

    var fileType = utils.getFileExtension(fileName);
    if (fileType === 'spec') {
        fileName = fileName.replace(new RegExp('.' + fileType), '');
        fileType = utils.getFileExtension(fileName);
    }

    tsContents = tsContents.replace(/(\r\n?|\n)/g, '\n');

    var re = '^import (?:(?:([*] as .*) from )|{([\\s\\S]+?)})?(?: from )?\'(.*)\';\\n\\n?';

    var imports = tsContents.match(new RegExp(re, 'mg'));
    if (!imports) {
        return tsContents;
    }
    tsContents = tsContents.replace(new RegExp(re, 'mg'), '');

    var unnamedImport = 'UNNAMED-IMPORT'; // e.g.: import 'rxjs/add/operator/filter';
    var importMappings = [];
    importMappings[unnamedImport] = [];
    imports.forEach(function (importString) {
        var matches = importString.match(re);
        var importNames = matches[1] || matches[2] || unnamedImport;
        var importPath = _convertImportPath(matches[3]);
        if (importNames === unnamedImport) {
            importMappings[importNames].push(importPath);
        } else {
            importNames.split(',').forEach(function (importName) {
                importMappings[importName.trim()] = importPath;
            });
        }
    });

    var importNames = Object.keys(importMappings).filter(function (name) { return name !== unnamedImport; });
    importNames.sort(function (a, b) {
        return a.toLowerCase().localeCompare(b.toLowerCase());
    });

    var pathImportSections = [
        {
            sectionTitle: 'External:',
            pathImports: [],
            sortByImportPath: true,
            importPathMatch: function (importPath) { return !importPath.match('^[.]*/.*'); }
        },
        {
            sectionTitle: 'Internal:',
            pathImports: [],
            sortByImportName: true,
            importPathMatch: function (importPath) { return importPath.match('^[.]*/.*'); }
        }
    ];

    function mapInputPath (inputName, importPath) {
        var matchedPathImportSections = pathImportSections.filter(function (pathImportSection) { return pathImportSection.importPathMatch(importPath); }) || [];
        var pathImportSection = matchedPathImportSections[0];
        if (!pathImportSection) {
            return;
        }

        if (!pathImportSection.pathImports[importPath]) {
            pathImportSection.pathImports[importPath] = [];
        }

        pathImportSection.pathImports[importPath].push(inputName);
    }

    importNames.forEach(function (importName) {
        var importPath = importMappings[importName];
        var matchedPathImportSections = pathImportSections.filter(function (pathImportSection) { return pathImportSection.importPathMatch(importPath); }) || [];
        var pathImportSection = matchedPathImportSections[0];
        if (!pathImportSection) {
            return;
        }

        if (!pathImportSection.pathImports[importPath]) {
            pathImportSection.pathImports[importPath] = [];
        }

        pathImportSection.pathImports[importPath].push(importName);
    });
    importMappings[unnamedImport].forEach(function(importPath) {
        mapInputPath(unnamedImport, importPath);
    });

    var importContents = '';

    pathImportSections.forEach(function (pathImportSection) {
        if (!Object.keys(pathImportSection.pathImports).length) {
            return;
        }

        if (importContents.length) {
            importContents += '\n';
        }

        var importPathKeys = Object.keys(pathImportSection.pathImports);

        if (pathImportSection.sortByImportPath) {
            importPathKeys.sort();
        }

        var importLines = [];

        importPathKeys.forEach(function (importPath) {
            var importNames = pathImportSection.pathImports[importPath];
            if (importNames.length === 1 && importNames[0] === unnamedImport) {
                importLines.push('import \'' + importPath + '\';');
            } else if (importNames.length === 1 && importNames[0].match(/^\* as .*/)) {
                importLines.push('import ' + importNames[0] + ' from \'' + importPath + '\';');
            } else if (importNames.join().length > MAX_IMPORT_LENGTH) {
                importLines.push('import {\n    ' + importNames.join(',\n    ') + '\n} from \'' + importPath + '\';');
            } else {
                importLines.push('import { ' + importNames.join(', ') + ' } from \'' + importPath + '\';');
            }
        });

        if (pathImportSection.sortByImportName) {
            importLines.sort(function (a, b) {
                return a.toLowerCase().localeCompare(b.toLowerCase());
            });
        }

        importContents += importLines.join('\n') + '\n';
    });

    return importContents + '\n' + tsContents;
}

// ******************************

function _convertImportPath (importPath) {
    return importPath;
}

// ******************************
// Exports:
// ******************************

module.exports['fixTsFiles'] = fixTsFiles;
module.exports['formatTsContentsSync'] = formatTsContentsSync;

// ******************************
