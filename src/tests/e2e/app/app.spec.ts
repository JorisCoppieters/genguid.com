import { browser, logging } from 'protractor';

import { AppPage } from '../../shared/app-page';

describe('MyApp', () => {
    let page: AppPage;

    beforeEach(() => {
        page = new AppPage(browser.baseUrl);
        const width = 1024;
        const height = 600;
        browser.driver.manage().window().setSize(width, height);
    });

    it('should show sidebar header', () => {
        page.navigateTo();
        expect(page.getSidebarHeading()).toEqual('MyApp');
    });

    it('should show center header', () => {
        page.navigateTo();
        expect(page.getWelcomeHeading()).toEqual('Welcome!');
    });

    afterEach(async () => {
        // Assert that there are no errors emitted from the browser
        const logs = await browser.manage().logs().get(logging.Type.BROWSER);
        expect(logs).not.toContain(
            (jasmine.objectContaining({
                level: logging.Level.SEVERE,
            } as logging.Entry) as unknown) as logging.Entry
        );
    });
});
