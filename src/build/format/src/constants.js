'use strict'; // JS: ES5

// ******************************
// Requires:
// ******************************

var fs = require('fs');
var path = require('path');

// ******************************
// Constants:
// ******************************

const c_FILE_EXTENSION_HTML = 'html';
const c_FILE_EXTENSION_SASS = 'css';
const c_FILE_EXTENSION_TYPE_SCRIPT = 'ts';
const c_SOURCE_PATH = 'src';
const c_TORIS_FORMAT_MIN_VERSION = 1.7;
const c_VERSION = '0.5 alpha';

const c_MODE_HELP = '[HELP]';
const c_MODE_VERSION = '[VERSION]';
const c_MODE_TEST = '[TEST]';
const c_MODE_ALL = '[ALL]';
const c_MODE_FILE = '[FILE]';
const c_MODE_FILES = '[FILES]';
const c_MODE_STRING = '[STRING]';
const c_MODE_CHANGES = '[CHANGES]';

// ******************************
// Globals:
// ******************************

var g_CONFIG = false;
var g_RELATIVE_BASE_PATH = path.resolve(__dirname, '../../../');

// ******************************
// Functions:
// ******************************

function getConfigPath (key, defaultValue) {
    var configPathValue = _getConfig()[key] || defaultValue;
    return path.resolve(g_RELATIVE_BASE_PATH, configPathValue);
}

// ******************************

function getConfigValue (key, defaultValue) {
    return _getConfig()[key] || defaultValue;
}

// ******************************

function _getConfig () {
    if (g_CONFIG) {
        return g_CONFIG;
    }

    var repositoryConfigFile = path.resolve(g_RELATIVE_BASE_PATH, 'build/format/format-repository-config.json');
    if (fs.existsSync(repositoryConfigFile)) {
        var config = require(repositoryConfigFile);
        g_CONFIG = config;
        return g_CONFIG;
    }

    g_CONFIG = {};
    return g_CONFIG;
}

// ******************************
// Exports:
// ******************************

module.exports['BASE_BRANCH'] = getConfigValue('baseBranch', 'default');
module.exports['IGNORED_FILES'] = getConfigValue('ignoredFiles', []);
module.exports['HTML_FORMAT_RULES_COFNIG_FILE'] = getConfigPath('htmlFormatRulesConfigFile');
module.exports['SASS_FORMAT_RULES_COFNIG_FILE'] = getConfigPath('sassFormatRulesConfigFile');
module.exports['WORKSPACE_FOLDER'] = getConfigValue('workspaceFolder', '');

module.exports['MODE_HELP'] = c_MODE_HELP;
module.exports['MODE_VERSION'] = c_MODE_VERSION;
module.exports['MODE_TEST'] = c_MODE_TEST;
module.exports['MODE_ALL'] = c_MODE_ALL;
module.exports['MODE_FILE'] = c_MODE_FILE;
module.exports['MODE_FILES'] = c_MODE_FILES;
module.exports['MODE_STRING'] = c_MODE_STRING;
module.exports['MODE_CHANGES'] = c_MODE_CHANGES;

module.exports['FILE_EXTENSION_HTML'] = c_FILE_EXTENSION_HTML;
module.exports['FILE_EXTENSION_SASS'] = c_FILE_EXTENSION_SASS;
module.exports['FILE_EXTENSION_TYPE_SCRIPT'] = c_FILE_EXTENSION_TYPE_SCRIPT;
module.exports['SOURCE_PATH'] = c_SOURCE_PATH;
module.exports['TORIS_FORMAT_MIN_VERSION'] = c_TORIS_FORMAT_MIN_VERSION;
module.exports['VERSION'] = c_VERSION;

// ******************************
