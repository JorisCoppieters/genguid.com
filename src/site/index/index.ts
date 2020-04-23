import './index.html';

import { v4 as uuidV4 } from 'uuid';

class Index {
    public copiedTimeout = null;

    constructor() {
        this.init();
    }

    public getGuid() {
        return uuidV4();
    }

    public copyGuid() {
        const element = document.getElementById('guid') as HTMLInputElement;
        if (!element) return;

        element.focus();
        element.select();
        if (!document.execCommand('copy')) {
            console.error('Failed to copy GUID!');
        }
        document.getSelection().removeAllRanges();

        document.getElementById('copied').className = 'show';
        if (this.copiedTimeout) {
            clearTimeout(this.copiedTimeout);
        }
        this.copiedTimeout = setTimeout(() => {
            document.getElementById('copied').className = '';
        }, 1000);
    }

    public setRandomGuid() {
        const element = document.getElementById('guid') as HTMLInputElement;
        if (!element) return;
        const guid = this.getGuid().toUpperCase();
        element.value = guid;
    }

    public showHelp() {
        const element = document.getElementById('help') as HTMLDivElement;
        if (!element) return;
        element.style.display = 'inline-block';
    }

    public selectGuid() {
        this.copyGuid();
    }

    public newGuid() {
        this.showHelp();
        this.setRandomGuid();
        setTimeout(() => {
            this.copyGuid();
        }, 100);
    }

    public init() {
        (document.getElementById('guid') as HTMLInputElement).onclick = () => this.selectGuid();
        (document.getElementById('generate_random_guid') as HTMLElement).onclick = () => this.newGuid();
        this.setRandomGuid();
    }
}

new Index();
