'use strict'; // JS: ES5

// ******************************
// Requires:
// ******************************

let cprint = require('color-print');
let fs = require('fs');
let glob = require('glob');
let minimist = require('minimist');
let path = require('path');
let Promise = require('bluebird');
let torisFormat = require('toris-format');

// ******************************
// Constants:
// ******************************

const ARGV = minimist(process.argv.slice(2));

const c_FILE_EXTENSION_HTML = 'html';
const c_FILE_EXTENSION_CSS = 'css';
const c_FILE_EXTENSION_SCSS = 'scss';
const c_FILE_EXTENSION_TS = 'ts';
const c_HTML_FORMAT_RULES_CONFIG_FILE = path.resolve(__dirname, 'format-rules-html.json');
const c_CSS_FORMAT_RULES_CONFIG_FILE = path.resolve(__dirname, 'format-rules-css.json');
const c_TS_FORMAT_RULES_CONFIG_FILE = path.resolve(__dirname, 'format-rules-ts.json');
const c_FIX = !!ARGV['fix'];

// ******************************
// Script:
// ******************************

_listFiles('src')
    .then((files) => formatFiles(files))
    .catch((err) => {
        console.error(`Formatting encountered error(s):`);
        console.error(`${err}`);
        process.exit(-1);
    });

// ******************************
// Main Functions:
// ******************************

function formatFiles(filesToProcess) {
    let filesToFormat = filesToProcess.filter(_filesFilter);
    if (filesToFormat.length === 1) {
        cprint.cyan('Running formatter over file: ' + filesToFormat[0]);
    } else {
        cprint.cyan('Running formatter over files');
    }

    return Promise.all(filesToFormat.map((file) => _formatFile(file)))
        .then((results) => {
            const firstError = results.find((err) => !!err);
            if (firstError) {
                throw firstError;
            }
        })
        .then(() => _formatTsFilesWithPrettier(_getConfig(c_FILE_EXTENSION_TS)));
}

// ******************************

function _listFiles(folder, filter) {
    return new Promise((resolveAll) => {
        var files = fs.readdirSync(folder);
        var fileList = [];

        _processFiles(files, (file, resolve) => {
            var fullPath = folder + '/' + file;

            fs.stat(fullPath, (err, stats) => {
                if (!err && stats.isDirectory()) {
                    _listFiles(fullPath, filter).then((subFileList) => {
                        fileList = fileList.concat(subFileList);
                        resolve();
                    });
                } else {
                    if (!filter || file.match(new RegExp(filter))) {
                        fileList.push(fullPath);
                    }
                    resolve();
                }
            });
        }).then(() => {
            resolveAll(fileList);
        });
    });
}

// ******************************

function _writeFileWithCb(filePath, fileContents, cbSuccess, cbError) {
    var file = path.resolve(process.cwd(), filePath);
    fs.writeFile(file, fileContents, 'utf8', (error, data) => {
        if (error) {
            cprint.red('Could not write to file: ' + file);
            cprint.red('  ' + error);
            if (cbError) {
                cbError(error);
            }
        } else {
            if (cbSuccess) {
                cbSuccess(data);
            }
        }
    });
}

// ******************************

function _processFiles(files, process) {
    return new Promise((resolveAll, rejectAny) =>
        Promise.all(files.map((file) => new Promise((resolve, reject) => process(file, resolve, reject))))
            .then(resolveAll)
            .catch(rejectAny)
    );
}

// ******************************

function _formatFile(fileToFormat) {
    return new Promise((resolve) => {
        try {
            let fileContents = fs.readFileSync(fileToFormat, 'utf-8');
            let fileExtension = _getFileExtension(fileToFormat);
            let config = _getConfig(fileExtension) || {};
            let formattedFileContents;

            switch (fileExtension) {
                case c_FILE_EXTENSION_HTML:
                case c_FILE_EXTENSION_CSS:
                case c_FILE_EXTENSION_SCSS:
                    formattedFileContents = torisFormat.formatFile(fileToFormat, config);
                    break;

                case c_FILE_EXTENSION_TS:
                    formattedFileContents = _formatTsFile(fileToFormat, config);
                    break;

                default:
                    throw 'Cannot format file with extension: ' + fileExtension;
            }

            if (formattedFileContents === false) {
                // Couldn't format file
                cprint.red('✘ ' + fileToFormat);
                return resolve();
            }

            if (fileContents !== formattedFileContents) {
                if (c_FIX) {
                    // Formatting has changed
                    cprint.yellow('✎ ' + fileToFormat + ' - Formatted');
                    return _writeFileWithCb(fileToFormat, formattedFileContents, () => resolve());
                }
                cprint.red('✘ ' + fileToFormat);
                return resolve(new Error(`${fileToFormat} is not formatted correctly`));
            }
            // Formatting is the same as what is already there
            if (c_FIX) {
                cprint.green('✔ ' + fileToFormat);
            }
            return resolve();
        } catch (err) {
            // Something weird happened while trying to format file
            cprint.red('✘ ' + fileToFormat);
            cprint.red(err.stack || err.message || err);
            return resolve(err);
        }
    });
}

// ******************************

function _formatTsFile(in_file, in_config) {
    let fileContents = fs.readFileSync(in_file, 'utf-8');
    const lineEnding = in_config.line_ending || '\n';

    if (in_config.convert_line_endings) {
        fileContents = fileContents.replace(/(\r\n?|\n)/g, lineEnding);
    }

    if (in_config.sort_imports) {
        fileContents = _formatTsFileImports(fileContents, in_config);
    }

    return fileContents;
}

// ******************************

function _formatTsFileImports(in_contents, in_config) {
    const lineEnding = in_config.line_ending || '\n';
    const maxImportLength = Math.max(80, in_config.line_length || 80);

    let tsContents = in_contents;

    let re = `^import (?:(?:(.*{[\\s\\S]+?})|([*] as [a-zA-Z0-9]+)|([a-zA-Z0-9]+)) from )?'(.*)';${lineEnding}?${lineEnding}?`;

    let imports = tsContents.match(new RegExp(re, 'mg'));
    if (!imports) {
        return tsContents;
    }
    tsContents = tsContents.replace(new RegExp(re, 'mg'), '').trim();

    let unnamedImport = 'UNNAMED-IMPORT'; // e.g.: import 'rxjs/add/operator/filter';
    let importMappings = [];
    importMappings[unnamedImport] = [];
    imports.forEach((importString) => {
        let matches = importString.match(re);
        let importNames = matches[1] || matches[2] || matches[3] || unnamedImport;
        let importPath = matches[4];
        let destructured = false;
        if (importNames.match(/{[\s\S]+?}/m)) {
            destructured = true;
            matches = importNames.match(/(.*){([\s\S]+)}/m);
            importNames = matches[2].trim();
            let nonDestructuredImportNames = matches[1];
            nonDestructuredImportNames
                .split(',')
                .map((importName) => importName.trim())
                .filter((importName) => !!importName)
                .forEach((importName) => (importMappings[`${importName}:DEFAULT`] = importPath));
        }

        if (importNames === unnamedImport) {
            importMappings[importNames].push(importPath);
        } else {
            importNames
                .split(',')
                .map((importName) => importName.trim())
                .filter((importName) => !!importName)
                .forEach((importName) => (importMappings[`${importName}${destructured ? '' : ':DEFAULT'}`] = importPath));
        }
    });

    let importNames = Object.keys(importMappings)
        .filter((name) => !!name)
        .filter((name) => name !== unnamedImport)
        .sort((a, b) => a.toLowerCase().localeCompare(b.toLowerCase()));

    let pathImportSections = [
        {
            sectionTitle: 'External:',
            pathImports: [],
            sortByImportPath: true,
            importPathMatch: (importPath) => !importPath.match('^[.]*/.*'),
        },
        {
            sectionTitle: 'Internal:',
            pathImports: [],
            sortByImportName: true,
            importPathMatch: (importPath) => importPath.match('^[.]*/.*'),
        },
    ];

    function mapInputPath(inputName, importPath) {
        let matchedPathImportSections =
            pathImportSections.filter((pathImportSection) => pathImportSection.importPathMatch(importPath)) || [];

        let pathImportSection = matchedPathImportSections[0];
        if (!pathImportSection) {
            return;
        }

        if (!pathImportSection.pathImports[importPath]) {
            pathImportSection.pathImports[importPath] = [];
        }

        pathImportSection.pathImports[importPath].push(inputName);
    }

    importNames.forEach((importName) => {
        let importPath = importMappings[importName];

        let matchedPathImportSections =
            pathImportSections.filter((pathImportSection) => pathImportSection.importPathMatch(importPath)) || [];

        let pathImportSection = matchedPathImportSections[0];
        if (!pathImportSection) {
            return;
        }

        if (!pathImportSection.pathImports[importPath]) {
            pathImportSection.pathImports[importPath] = [];
        }

        pathImportSection.pathImports[importPath].push(importName);
    });
    importMappings[unnamedImport].forEach((importPath) => mapInputPath(unnamedImport, importPath));

    let importContents = '';

    pathImportSections.forEach((pathImportSection) => {
        if (!Object.keys(pathImportSection.pathImports).length) {
            return;
        }

        if (importContents.length) {
            importContents += lineEnding;
        }

        let importPathKeys = Object.keys(pathImportSection.pathImports);

        if (pathImportSection.sortByImportPath) {
            importPathKeys.sort();
        }

        let importLines = [];

        importPathKeys.forEach((importPath) => {
            let importNames = pathImportSection.pathImports[importPath];
            importNames = importNames.filter((importName) => !!importName);

            if (importNames.length === 1) {
                const singleImportName = importNames[0];
                if (singleImportName === unnamedImport) {
                    importLines.push(`import '${importPath}';`);
                    return;
                }
                if (singleImportName.match(/^\* as .*/)) {
                    importLines.push(`import ${singleImportName.replace(/:DEFAULT/, '')} from '${importPath}';`);
                    return;
                }
                if (singleImportName.match(/:DEFAULT$/)) {
                    importLines.push(`import ${singleImportName.replace(/:DEFAULT/, '')} from '${importPath}';`);
                    return;
                }
            }

            const nonDestructuredImports = importNames
                .filter((importName) => importName.match(/:DEFAULT/))
                .map((importName) => importName.replace(/:DEFAULT/, ''));

            const destructuredImports = importNames.filter((importName) => !importName.match(/:DEFAULT/));

            const fullImportPath = `import ${
                nonDestructuredImports.length ? `${nonDestructuredImports.join(', ')}, ` : ''
            }{ ${destructuredImports.join(', ')} } from '${importPath}';`;

            if (fullImportPath.length > maxImportLength) {
                importLines.push(
                    `import ${
                        nonDestructuredImports.length ? `${nonDestructuredImports.join(', ')}, ` : ''
                    }{${lineEnding}    ${destructuredImports
                        .filter((importName) => !importName.match(/:DEFAULT/))
                        .join(`,${lineEnding}    `)},${lineEnding}} from '${importPath}';`
                );
                return;
            }

            importLines.push(fullImportPath);
        });

        if (pathImportSection.sortByImportName) {
            importLines.sort((a, b) => a.toLowerCase().localeCompare(b.toLowerCase()));
        }

        importContents += importLines.join(lineEnding) + lineEnding;
    });

    if (!tsContents) {
        return importContents;
    }

    return importContents + lineEnding + tsContents + lineEnding;
}

// ******************************

function _formatTsFilesWithPrettier(in_config) {
    if (!in_config.run_prettier) return;

    const tabWidth = Math.max(2, in_config.tab_width || 4);
    const singleQuote = in_config.quote_style || 'single' === 'single';
    const lineLength = Math.max(80, in_config.line_length || 80);
    const globPath = './src/**/*.ts';

    const files = glob.sync(globPath);
    if (!files.length) {
        return;
    }

    let args = [`--tab-width ${tabWidth}`, `${singleQuote ? `--single-quote` : ''}`, `--print-width ${lineLength}`];
    if (c_FIX) {
        args.push('--write');
    }
    args.push(globPath);

    let child_process = require('child_process');
    child_process.execSync(`yarn prettier ${args.join(' ')}`, { stdio: 'inherit' });
    return;
}

// ******************************

function _getConfig(fileExtension) {
    switch (fileExtension) {
        case c_FILE_EXTENSION_HTML:
            return require(c_HTML_FORMAT_RULES_CONFIG_FILE);

        case c_FILE_EXTENSION_CSS:
        case c_FILE_EXTENSION_SCSS:
            return require(c_CSS_FORMAT_RULES_CONFIG_FILE);

        case c_FILE_EXTENSION_TS:
            return require(c_TS_FORMAT_RULES_CONFIG_FILE);
    }
}

// ******************************

function _getFileExtension(file) {
    try {
        let fileParts = file.match(/.*\.(.*)$/);
        let fileExtension = fileParts[1].trim().toLowerCase();
        return fileExtension;
    } catch (err) {
        return '';
    }
}

// ******************************

function _filesFilter(in_file) {
    let fileExtension = _getFileExtension(in_file);
    let config = _getConfig(fileExtension) || {};
    if ((config.ignore_paths || []).find((ignorePath) => in_file.match(ignorePath))) return false;

    if ([c_FILE_EXTENSION_HTML, c_FILE_EXTENSION_CSS, c_FILE_EXTENSION_SCSS, c_FILE_EXTENSION_TS].indexOf(fileExtension) < 0) return false;
    return true;
}

// ******************************
