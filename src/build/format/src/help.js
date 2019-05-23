'use strict'; // JS: ES5

// ******************************
// Requries:
// ******************************

var c = require('./constants');
var cprint = require('color-print');
var torisFormat = require('toris-format');

// ******************************
// Functions:
// ******************************

function printHelp () {
    cprint.rainbow('Formatting Tool Help');
    process.stdout.write('\n');
    cprint.yellow('Version ' + c.VERSION + ' (using toris-format v' + torisFormat.k_VERSION + ')');
    process.stdout.write('\n');
    cprint.green('General Options:');
    process.stdout.write(cprint.toWhite('--help') + '\t\t\t\t\t\t\t' + cprint.toCyan('Show this menu') + '\n');
    process.stdout.write(cprint.toWhite('--test') + '\t\t\t\t\t\t\t' + cprint.toCyan('Run format tests') + '\n');
    process.stdout.write('\n');
    cprint.green('Target Options:');
    process.stdout.write(cprint.toLightGrey('--changed (default)') + '\t\t\t\t\t' + cprint.toCyan('Format only changed files') + '\n');
    process.stdout.write(cprint.toWhite('--all') + '\t\t\t\t\t\t\t' + cprint.toCyan('Format all files') + '\n');
    process.stdout.write(cprint.toWhite('--file [FILE]') + '\t\t\t\t\t\t' + cprint.toCyan('Format a specific file') + '\n');
    process.stdout.write(cprint.toWhite('--files [COMMA SEPARATED FILE LIST]') + '\t\t\t' + cprint.toCyan('Format specific files') + '\n');
    process.stdout.write(cprint.toWhite('--string (--encoded) (--filename FILENAME) [STRING]') + '\t' + cprint.toCyan('Format string') + '\n');
    process.stdout.write('\t\t\t\t\t\t\t  ' + cprint.toCyan('add the') + ' ' + cprint.toLightBlue('--encoded') + ' ' + cprint.toCyan('flag for the input/output to be base64 encoded') + '\n');
    process.stdout.write('\t\t\t\t\t\t\t  ' + cprint.toCyan('add the') + ' ' + cprint.toLightBlue('--filename') + ' ' + cprint.toCyan('flag to specifiy the file name') + '\n');
    process.stdout.write('\n');
    cprint.green('Modifiers:');
    process.stdout.write(cprint.toLightGrey('--print-all (default)') + '\t\t\t\t\t' + cprint.toCyan('Print out all files') + '\n');
    process.stdout.write(cprint.toWhite('--print-changed') + '\t\t\t\t\t\t' + cprint.toCyan('Print out only files that needed changing') + '\n');
    process.stdout.write(cprint.toWhite('--print-errors') + '\t\t\t\t\t\t' + cprint.toCyan('Print out only files that had errors formatting') + '\n');
    process.stdout.write(cprint.toWhite('--dry-run') + '\t\t\t\t\t\t' + cprint.toCyan('Don\'t make any file changes') + '\n');
    process.stdout.write(cprint.toWhite('--no-sass') + '\t\t\t\t\t\t' + cprint.toCyan('Ignore Sass files') + '\n');
    process.stdout.write(cprint.toWhite('--no-html') + '\t\t\t\t\t\t' + cprint.toCyan('Ignore HTML files') + '\n');
    process.stdout.write(cprint.toWhite('--no-ts') + '\t\t\t\t\t\t\t' + cprint.toCyan('Ignore TypeScript files') + '\n');
}

// ******************************

function printVersion () {
    cprint.yellow('Version ' + c.VERSION + ' (using toris-format v' + torisFormat.k_VERSION + ')');
}

// ******************************

function printFinalMessage (fileChangesMade) {
    if (fileChangesMade) {
        cprint.white('-------------------------------------------------------------------------------------');
        process.stdout.write(cprint.toWhite('Please run ') + cprint.toLightYellow('hg diff') + cprint.toWhite(' (or ') + cprint.toLightYellow('hg vdiff') + cprint.toWhite(') to see what was changed and commit if you are happy.') + '\n');
        process.stdout.write(cprint.toWhite('If anything doesn\'t appear to be formatted correctly, please contact') + ' '+ cprint.toLightGreen('joris') + '\n');
        cprint.white('-------------------------------------------------------------------------------------');
    } else {
        cprint.green('No formatting changes made');
    }
}

// ******************************

function printNoChangesAllowedWarning () {
    cprint.lightRed('-----------------------------------------------------------------------------------------------------------');
    cprint.lightYellow('This tools is in an \'alpha\' phase at the moment. Please commit all your changes before running this script.');
    cprint.lightRed('-----------------------------------------------------------------------------------------------------------');
}

// ******************************

function printUpdateWarning () {
    cprint.lightRed('------------------------------------------------------------');
    cprint.lightYellow('You have an outdated version of toris-format, please update.');
    cprint.lightRed('------------------------------------------------------------');
}

// ******************************
// Exports:
// ******************************

module.exports['printHelp'] = printHelp;
module.exports['printVersion'] = printVersion;
module.exports['printFinalMessage'] = printFinalMessage;
module.exports['printNoChangesAllowedWarning'] = printNoChangesAllowedWarning;
module.exports['printUpdateWarning'] = printUpdateWarning;

// ******************************
