var copiedTimeout = null;
const getGuid = () => {
    const s4 = () => Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
};
const selectGuid = () => {
    copyGuid();
};
const setRandomGuid = () => {
    const guid = getGuid().toUpperCase();
    document.getElementById('guid').value = guid;
    setTimeout(() => {
        copyGuid();
    }, 200);
}
const copyGuid = () => {
    document.getElementById('guid').focus();
    document.getElementById('guid').select();
    if (!document.execCommand('copy')) {
        console.error('Failed to copy GUID!');
    }
    document.getSelection().removeAllRanges();

    document.getElementById('copied').className = 'show';
    if (copiedTimeout) {
        clearTimeout(copiedTimeout);
    }
    copiedTimeout = setTimeout(() => {
        document.getElementById('copied').className = '';
    }, 1000)
}
const init = () => {
    document.getElementById('guid').value = '<CLICK GENERATE>';
}
