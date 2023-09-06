import { v4 as uuidV4 } from 'uuid';

import './imports/favicons';
import './index.css';

// ******************************
// Script:
// ******************************

class Index {
    public copiedTimeout: any = null;

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
        document.execCommand('copy');
        const selection = document.getSelection();
        if (selection) {
            selection.removeAllRanges();
        }

        const copied = document.getElementById('copied');
        if (copied) {
            copied.className = 'show';
        }

        if (this.copiedTimeout) {
            clearTimeout(this.copiedTimeout);
        }
        this.copiedTimeout = setTimeout(() => {
            if (copied) {
                copied.className = '';
            }
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

// tslint:disable-next-line:no-unused-expression
new Index();
