var removeAllRangesTimeout = null;
const getGuid = () => {
    const s4 = () => Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
};
const selectGuid = () => {
    document.getElementById('guid').select();
    if (removeAllRangesTimeout) {
        clearTimeout(removeAllRangesTimeout);
    }
    removeAllRangesTimeout = setTimeout(() => {
        document.getSelection().removeAllRanges();
    }, 1000)
};
const setRandomGuid = () => {
    const guid = getGuid().toUpperCase();
    document.getElementById('guid').value = guid;
    setTimeout(() => {
        document.getElementById('guid').select();
        document.execCommand('copy');
        document.getSelection().removeAllRanges();
    }, 200);
}
