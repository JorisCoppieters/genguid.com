// Protractor configuration file, see link for more information
// https://github.com/angular/protractor/blob/master/lib/config.ts

const { SpecReporter, StacktraceOption } = require('jasmine-spec-reporter');

/**
 * @type { import("protractor").Config }
 */
exports.config = {
    directConnect: true,
    allScriptsTimeout: 11000,
    specs: ['./**/*.spec.ts'],
    capabilities: {
        browserName: 'chrome',
    },
    baseUrl: 'http://localhost:4200/',
    framework: 'jasmine',
    jasmineNodeOpts: {
        showColors: true,
        defaultTimeoutInterval: 30000,
        print: () => null,
    },
    useAllAngular2AppRoots: true,
    beforeLaunch: () => {
        require('ts-node').register({
            project: require('path').join(__dirname, './tsconfig.json'),
        });
    },
    onPrepare: () => {
        jasmine.getEnv().addReporter(
            new SpecReporter({
                spec: {
                    displayStacktrace: StacktraceOption.PRETTY,
                },
            })
        );
    },
};
