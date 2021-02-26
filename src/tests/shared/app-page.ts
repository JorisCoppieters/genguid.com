import { browser, by, element } from 'protractor';

export class AppPage {
    private readonly _url: string;

    constructor(in_url: string) {
        this._url = in_url;
    }

    navigateTo(): Promise<unknown> {
        return browser.get(this._url) as Promise<unknown>;
    }

    getSidebarHeading(): Promise<string> {
        return element(by.css('app-root .sidebar .heading .icon-text')).getText() as Promise<string>;
    }

    getWelcomeHeading(): Promise<string> {
        return element(by.css('app-root .center .heading h1')).getText() as Promise<string>;
    }
}
