var copiedTimeout = null;
function getGuid () {
    const s4 = () => Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
};
function copyGuid () {
    const element = document.getElementById('guid');
    element.focus();
    element.select();
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
function setRandomGuid () {
    const element = document.getElementById('guid');
    const guid = getGuid().toUpperCase();
    element.value = guid;
}
function showHelp () {
    const element = document.getElementById('help');
    element.style = "display: inline-block";
}
function selectGuid () {
    copyGuid();
};
function newGuid () {
    showHelp();
    setRandomGuid();
    setTimeout(() => {
        copyGuid();
    }, 100);
};

function init () {
    setRandomGuid();
}
