import { browser, by, element, ElementArrayFinder, ElementFinder } from 'protractor';
import request from 'request';

import { API_METHOD_TYPE } from '../../shared/enums/api-method-type';
import { WEB_URL } from './vars';

export class AppPage {
    private readonly _url: string;

    constructor(in_url: string) {
        this._url = in_url;
    }

    navigateTo(in_path?: string): Promise<unknown> {
        return browser.get(`${this._url}${in_path ? `/${in_path}` : ''}`) as Promise<unknown>;
    }

    async click(in_css: string) {
        await this.scrollToElement(this.querySelector(in_css), -50);
        await this.querySelector(in_css).click();
    }

    async setInputValue(in_css: string, in_value: string) {
        await this.querySelector(in_css).click();
        await this.querySelector(in_css).clear();
        await this.querySelector(in_css).sendKeys(in_value);
    }

    async getSelectValue(in_css: string) {
        const id = await this.querySelector(in_css).getAttribute('value');
        let found = '';
        await this.querySelector(in_css)
            .all(by.css('option'))
            .each(async (option) => {
                if ((await option?.getAttribute('value')) === id) {
                    found = (await option?.getText()) || '';
                }
            });
        return found;
    }

    async setSelectValue(in_css: string, in_value: string) {
        await this.querySelector(in_css).click();
        await this.querySelector(in_css)
            .all(by.css('option'))
            .each(async (option) => {
                if ((await option?.getText()) === in_value) {
                    await option?.click();
                }
            });
    }

    querySelector(in_css: string) {
        return element(by.css(in_css)) as ElementFinder;
    }

    querySelectorAll(in_css: string) {
        return element.all(by.css(in_css)) as ElementArrayFinder;
    }

    buttonByTitle(in_title: string, in_parent?: ElementFinder) {
        return in_parent ? in_parent.element(by.css(`button[title="${in_title}"]`)) : element(by.css(`button[title="${in_title}"]`));
    }

    async scrollToElement(in_element: ElementFinder, in_bottomPadding?: number) {
        await browser.executeScript(`arguments[0].scrollIntoView({ block: 'start' });`, in_element.getWebElement());
        await browser.sleep(50);
        await browser.executeScript(`window.scrollBy(0, ${in_bottomPadding || 0});`, in_element.getWebElement());
        await browser.sleep(50);
    }

    async request(in_url: string, in_method: API_METHOD_TYPE, in_requestData: { [key: string]: any }, in_headers: { [key: string]: any }, in_fileData?: Buffer, in_fileName?: string) {
        let url = in_url;
        const requestData = in_requestData || {};

        if (in_method === API_METHOD_TYPE.GET || in_method === API_METHOD_TYPE.DELETE) {
            if (Object.keys(requestData).length) {
                url += '?' + new URLSearchParams(requestData);
            }
        }

        const uri = `${WEB_URL}/${url}`;

        const requestOptions: { [key: string]: any } = {
            uri: uri,
            method: in_method,
            timeout: 120000,
            headers: Object.assign(
                {
                    'Cache-Control': 'no-cache',
                },
                in_headers
            ),
            rejectUnauthorized: false,
            requestCert: true,
            agent: false,
        };

        if (in_fileData) {
            requestOptions['formData'] = {
                fileUpload: {
                    value: in_fileData,
                    options: {
                        filename: in_fileName,
                    },
                },
            };
        } else if ([API_METHOD_TYPE.POST, API_METHOD_TYPE.PUT].indexOf(in_method) >= 0) {
            requestOptions['json'] = requestData;
        } else {
            requestOptions['json'] = true;
        }

        return await new Promise<any>((resolve, reject) => {
            request(uri, requestOptions, (error: string, response: any, body: any) => {
                if (error) {
                    return reject(new Error(error));
                }
                if (response.statusCode !== 200) {
                    return reject(new Error(`HTTP Response: [${response.statusCode}] ${response.statusMessage} (${uri})`));
                }

                return resolve(body);
            });
        });
    }
}
