'use strict'; // JS: ES5

// ******************************
// Requires:
// ******************************

let minimist = require('minimist');
let format = require('./format');

// ******************************
// Constants:
// ******************************

const ARGV = minimist(process.argv.slice(2));
const c_FIX = !!ARGV['fix'];

// ******************************
// Script:
// ******************************

format
    .listFiles('src')
    // .then((files) => files.filter((file) => file.match(/mailer/)))
    .then((files) => format.formatFiles(files, c_FIX))
    .catch((err) => {
        console.error(`Formatting encountered error(s):`);
        console.error(`${err}`);
        process.exit(-1);
    });

// ******************************
