'use strict'; // JS: ES5

// ******************************
// Functions:
// ******************************

function getFileExtension (file) {
    try {
        var fileParts = file.match(/.*\.(.*)$/);
        var fileExtension = fileParts[1].trim().toLowerCase();
        return fileExtension;
    } catch (err) {
        return '';
    }
}

// ******************************
// Exports:
// ******************************

module.exports['getFileExtension'] = getFileExtension;

// ******************************
