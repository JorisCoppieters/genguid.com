import { browser, logging } from 'protractor';

import { AppPage } from '../../../shared/app-page';

describe('https://test.genguid.com', function () {
    let page: AppPage;

    beforeEach(() => {
        page = new AppPage(browser.baseUrl);
        const width = 1024;
        const height = 600;
        browser.driver.manage().window().setSize(width, height);
        browser.waitForAngularEnabled(false);
    });

    it('should show content', async () => {
        page.navigateTo();

        const content = await page.getContent();
        expect(content).toBeDefined();
    });

    afterEach(async () => {
        const logs = await browser.manage().logs().get(logging.Type.BROWSER);
        expect(logs).not.toContain(
            (jasmine.objectContaining({
                level: logging.Level.SEVERE,
            } as logging.Entry) as unknown) as logging.Entry
        );
    });
});
