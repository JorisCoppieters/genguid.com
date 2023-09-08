import { browser, logging } from 'protractor';

import { APP_TITLE, APP_TITLE_AND_SLOGAN } from '../../shared/vars';
import { AppPage } from '../../shared/app-page';

describe('app', () => {
    let document: AppPage;

    beforeEach(() => {
        document = new AppPage(browser.baseUrl);
        const width = 1024;
        const height = 1000;
        browser.driver.manage().window().setSize(width, height);
    });

    it('should show sidebar header', async () => {
        document.navigateTo();

        const title = browser.getTitle();
        expect(title).toEqual(APP_TITLE_AND_SLOGAN);

        const bannerHomeHeading = await document.querySelector('app-root .banner .home .icon-text').getText();
        expect(bannerHomeHeading).toEqual(APP_TITLE);
    });

    it('should show center header', async () => {
        document.navigateTo();

        const title = browser.getTitle();
        expect(title).toEqual('My Slogan! | My App!');
    });

    afterEach(async () => {
        const logs = await browser.manage().logs().get(logging.Type.BROWSER);
        expect(logs).not.toContain(
            jasmine.objectContaining({
                level: logging.Level.SEVERE,
            } as logging.Entry) as unknown as logging.Entry,
        );
    });
});
