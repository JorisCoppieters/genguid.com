import { browser, by, element } from 'protractor';

export class AppPage {
    private readonly _url: string;

    constructor(in_url: string) {
        this._url = in_url;
    }

    navigateTo(): Promise<unknown> {
        return browser.get(this._url) as Promise<unknown>;
    }

    getContent(): Promise<string> {
        return element(by.css('body .content')).getText() as Promise<string>;
    }
}
