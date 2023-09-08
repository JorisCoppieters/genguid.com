'use strict'; // JS: ES5

// ******************************
// Requires:
// ******************************

let cprint = require('color-print');
let fs = require('fs');
let path = require('path');
let Promise = require('bluebird');
let torisFormat = require('toris-format');

// ******************************
// Constants:
// ******************************

const c_FILE_EXTENSION_HTML = 'html';
const c_FILE_EXTENSION_CSS = 'css';
const c_FILE_EXTENSION_SCSS = 'scss';
const c_FILE_EXTENSION_TS = 'ts';
const c_HTML_FORMAT_RULES_CONFIG_FILE = path.resolve(__dirname, 'format-rules-html.json');
const c_CSS_FORMAT_RULES_CONFIG_FILE = path.resolve(__dirname, 'format-rules-css.json');
const c_TS_FORMAT_RULES_CONFIG_FILE = path.resolve(__dirname, 'format-rules-ts.json');

const c_EXTERNAL_LIBS = [
    '@angular',
    'angular2-chartjs',
    'bluebird',
    'body-parser',
    'cors',
    'crypto',
    'express',
    'fast-xml-parser',
    'fs',
    'http',
    'https',
    'md5',
    'multer',
    'nodemailer',
    'os',
    'path',
    'process',
    'protractor',
    'querystring',
    'request',
    'rxjs',
    'sequelize',
    'socket.io',
    'supertest',
    'universal-analytics',
];

// ******************************
// Export Functions:
// ******************************

module.exports['formatFiles'] = (in_filesToProcess, in_fix) => {
    let filesToFormat = in_filesToProcess.filter(_filesFilter);
    if (filesToFormat.length === 1) {
        cprint.cyan('Running formatter over file: ' + filesToFormat[0]);
    } else {
        cprint.cyan('Running formatter over files');
    }

    return Promise.all(filesToFormat.map((file) => _formatFile(file, in_fix)))
        .then((results) => {
            const firstError = results.find((err) => !!err);
            if (firstError) {
                throw firstError;
            }
        })
        .then(() => _formatTsFilesWithPrettier(in_filesToProcess, _getConfig(c_FILE_EXTENSION_TS), in_fix));
};

// ******************************

module.exports['listFiles'] = _listFiles;

// ******************************
// Helper Functions:
// ******************************

function _writeFileWithCb(in_filePath, in_fileContents, in_cbSuccess, in_cbError) {
    var file = path.resolve(process.cwd(), in_filePath);
    fs.writeFile(file, in_fileContents, 'utf8', (error, data) => {
        if (error) {
            cprint.red('Could not write to file: ' + file);
            cprint.red('  ' + error);
            if (in_cbError) {
                in_cbError(error);
            }
        } else {
            if (in_cbSuccess) {
                in_cbSuccess(data);
            }
        }
    });
}

// ******************************

function _listFiles(in_folder, in_filter) {
    return new Promise((resolveAll) => {
        var files = fs.readdirSync(in_folder);
        var fileList = [];

        _processFiles(files, (file, resolve) => {
            var fullPath = in_folder + '/' + file;

            fs.stat(fullPath, (err, stats) => {
                if (!err && stats.isDirectory()) {
                    _listFiles(fullPath, in_filter).then((subFileList) => {
                        fileList = fileList.concat(subFileList);
                        resolve();
                    });
                } else {
                    if (!in_filter || file.match(new RegExp(in_filter))) {
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

function _processFiles(in_files, in_process) {
    return new Promise((resolveAll, rejectAny) =>
        Promise.all(in_files.map((file) => new Promise((resolve, reject) => in_process(file, resolve, reject))))
            .then(resolveAll)
            .catch(rejectAny)
    );
}

// ******************************

function _formatFile(in_fileToFormat, in_fix) {
    return new Promise((resolve) => {
        try {
            let fileContents = fs.readFileSync(in_fileToFormat, 'utf-8');
            let fileExtension = _getFileExtension(in_fileToFormat);
            let config = _getConfig(fileExtension) || {};
            let formattedFileContents;

            switch (fileExtension) {
                case c_FILE_EXTENSION_HTML:
                case c_FILE_EXTENSION_CSS:
                case c_FILE_EXTENSION_SCSS:
                    formattedFileContents = torisFormat.formatFile(in_fileToFormat, config);
                    break;

                case c_FILE_EXTENSION_TS:
                    formattedFileContents = _formatTsFile(in_fileToFormat, config);
                    break;

                default:
                    throw new Error('Cannot format file with extension: ' + fileExtension);
            }

            if (formattedFileContents === false) {
                // Couldn't format file
                cprint.red('✘ ' + in_fileToFormat);
                return resolve();
            }

            if (fileContents !== formattedFileContents) {
                if (in_fix) {
                    // Formatting has changed
                    cprint.yellow('✎ ' + in_fileToFormat + ' - Formatted');
                    return _writeFileWithCb(in_fileToFormat, formattedFileContents, () => resolve());
                }
                cprint.red('✘ ' + in_fileToFormat);
                return resolve(new Error(`${in_fileToFormat} is not formatted correctly`));
            }
            // Formatting is the same as what is already there
            if (in_fix) {
                cprint.green('✔ ' + in_fileToFormat);
            }
            return resolve();
        } catch (err) {
            // Something weird happened while trying to format file
            cprint.red('✘ ' + in_fileToFormat);
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
        fileContents = _formatTsFileImports(fileContents, in_file, in_config);
    }

    return fileContents;
}

// ******************************

function _getImportRe(in_config) {
    const lineEnding = in_config.line_ending || '\n';
    return `^import (?:(?:(.*{[\\s\\S]+?})|([*] as [a-zA-Z0-9]+)|([a-zA-Z0-9]+)) from )?'(.*)';${lineEnding}?${lineEnding}?`;
}

// ******************************

function _getUnamedImportKey() {
    return 'UNNAMED-IMPORT'; // e.g.: import 'rxjs/add/operator/filter';
}

// ******************************

function _isInternal(in_path) {
    return !!in_path.match(/^[.]*\/.*/);
}

// ******************************

function _isExternal(in_path) {
    if (in_path === `nodemailer/lib/mailer`) {
        return true;
    }

    if (c_EXTERNAL_LIBS.find((externalLib) => externalLib.match(in_path))) {
        return true;
    }

    return false;
}

// ******************************

function _getImportMappings(in_imports, in_file, in_config) {
    const re = _getImportRe(in_config);
    const unnamedImport = _getUnamedImportKey();
    const fileFolder = path.dirname(in_file);
    const maxDirNum = fileFolder.split('/').length;

    let importMappings = [];
    importMappings[unnamedImport] = [];
    in_imports.forEach((importString) => {
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
            importMappings[unnamedImport].push(importPath);
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

    const internalImports = {};
    const externalImports = {};

    importNames.forEach((importName) => {
        let importPath = importMappings[importName];
        let isInternal = _isInternal(importPath);
        let isExternal = _isExternal(importPath);

        if (!isExternal) {
            let dirNum = 0;
            let found = false;

            let fullPath = path.join(fileFolder, importPath);
            if (!fs.existsSync(`${fullPath}.ts`)) {
                while (!found && dirNum < maxDirNum) {
                    const parentFolder = path.join(fileFolder, '../'.repeat(dirNum));

                    fullPath = path.join(parentFolder, importPath);
                    if (fs.existsSync(`${fullPath}.ts`)) {
                        const newImportPath = path.relative(fileFolder, fullPath).replace(/\\/g, '/');
                        cprint.yellow(`${in_file} - Correcting path "${importPath}" => "${newImportPath}"`);
                        importPath = newImportPath;
                        isInternal = _isInternal(importPath);
                        found = true;
                        break;
                    }

                    const folders = fs
                        .readdirSync(parentFolder)
                        .map((f) => path.join(parentFolder, f))
                        .filter((f) => fs.statSync(f).isDirectory());

                    folders.forEach((folder) => {
                        const childPath = path.join(folder, path.basename(importPath));
                        if (fs.existsSync(`${childPath}.ts`)) {
                            const newImportPath = path.relative(fileFolder, childPath).replace(/\\/g, '/');
                            cprint.yellow(`${in_file} - Correcting path "${importPath}" => "${newImportPath}"`);
                            importPath = newImportPath;
                            isInternal = _isInternal(importPath);
                            found = true;
                            return;
                        }

                        const fullPath = path.join(folder, importPath);
                        if (fs.existsSync(`${fullPath}.ts`)) {
                            const newImportPath = path.relative(fileFolder, fullPath).replace(/\\/g, '/');
                            cprint.yellow(`${in_file} - Correcting path "${importPath}" => "${newImportPath}"`);
                            importPath = newImportPath;
                            isInternal = _isInternal(importPath);
                            found = true;
                            return;
                        }
                    });

                    dirNum++;
                }

                if (!found && isInternal) {
                    throw new Error(`Path doesn't exist: ${importPath}`);
                }
            }
        }
        if (importPath.match('^stores/.*')) {
            throw new Error(`Stores path wasn't corrected: ${importPath}`)
        }
        if (importPath.match('^services/.*')) {
            throw new Error(`Services path wasn't corrected: ${importPath}`)
        }

        if (isInternal) {
            if (!internalImports[importPath]) {
                internalImports[importPath] = [];
            }
            internalImports[importPath].push(importName);
        } else {
            if (!externalImports[importPath]) {
                externalImports[importPath] = [];
            }
            externalImports[importPath].push(importName);
        }
    });

    importMappings[unnamedImport].forEach((importPath) => {
        const importName = unnamedImport;
        const isInternal = importPath.match('^[.]*/.*');
        if (isInternal) {
            if (!internalImports[importPath]) {
                internalImports[importPath] = [];
            }
            internalImports[importPath].push(importName);
        } else {
            if (!externalImports[importPath]) {
                externalImports[importPath] = [];
            }
            externalImports[importPath].push(importName);
        }
    });

    const pathImportSections = [
        {
            isInternal: false,
            pathImports: externalImports,
            sortByImportPath: true,
        },
        {
            isInternal: true,
            pathImports: internalImports,
            sortByImportName: true,
        },
    ];

    return pathImportSections;
}

// ******************************

function _getImportContents(in_imports, in_file, in_config) {
    const lineEnding = in_config.line_ending || '\n';
    const maxImportLength = Math.max(80, in_config.line_length || 80);
    const unnamedImport = _getUnamedImportKey();

    let pathImportSections = _getImportMappings(in_imports, in_file, in_config);

    let importContents = '';

    pathImportSections.forEach((pathImportSection) => {
        let importPathKeys = Object.keys(pathImportSection.pathImports);
        if (!importPathKeys.length) {
            return;
        }

        if (importContents.length) {
            importContents += lineEnding;
        }

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

            const nonDestructuredImports = importNames.filter((importName) => importName.match(/:DEFAULT/)).map((importName) => importName.replace(/:DEFAULT/, ''));
            const destructuredImports = importNames.filter((importName) => !importName.match(/:DEFAULT/));

            const nonDestructuredImportsStr = nonDestructuredImports.length ? `${nonDestructuredImports.join(', ')}, ` : '';

            const fullImportPath = `import ${nonDestructuredImportsStr}{ ${destructuredImports.join(', ')} } from '${importPath}';`;

            if (fullImportPath.length > maxImportLength) {
                importLines.push(
                    `import ${nonDestructuredImportsStr}{${lineEnding}    ${destructuredImports
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

    return importContents;
}

// ******************************

function _formatTsFileImports(in_contents, in_file, in_config) {
    const lineEnding = in_config.line_ending || '\n';
    const re = _getImportRe(in_config);

    let tsContents = in_contents;

    let imports = tsContents.match(new RegExp(re, 'mg'));
    if (!imports) {
        return tsContents;
    }
    tsContents = tsContents.replace(new RegExp(re, 'mg'), '').trim();

    let importContents = _getImportContents(imports, in_file, in_config);

    if (!tsContents) {
        return importContents;
    }

    return importContents + lineEnding + tsContents + lineEnding;
}

// ******************************

function _formatTsFilesWithPrettier(in_files, in_config, in_fix) {
    if (!in_config.run_prettier) return;

    const tabWidth = Math.max(2, in_config.tab_width || 4);
    const singleQuote = in_config.quote_style || 'single' === 'single';
    const lineLength = Math.max(80, in_config.line_length || 80);

    let args = [`--tab-width ${tabWidth}`, `${singleQuote ? `--single-quote` : ''}`, `--print-width ${lineLength}`];
    if (in_fix) {
        args.push('--write');
    } else {
        args.push('--check');
    }

    if (in_files.length > 20) {
        args.push('src/**/*.ts');
    } else {
        args = args.concat(in_files.map((f) => `"${f}"`));
    }

    let child_process = require('child_process');
    child_process.execSync(`npx prettier ${args.join(' ')}`, { stdio: 'inherit' });
    return;
}

// ******************************

function _getConfig(in_fileExtension) {
    switch (in_fileExtension) {
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

function _getFileExtension(in_file) {
    try {
        let fileParts = in_file.match(/.*\.(.*)$/);
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
