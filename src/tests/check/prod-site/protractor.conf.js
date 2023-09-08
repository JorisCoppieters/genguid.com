const { SpecReporter, StacktraceOption } = require('jasmine-spec-reporter');

/**
 * @type { import("protractor").Config }
 */
exports.config = {
    directConnect: true,
    baseUrl: 'https://my-app.jobot-software.com',
    specs: ['../../e2e/**/*.spec.ts'],
    framework: 'jasmine',
    jasmineNodeOpts: {
        showColors: true,
        defaultTimeoutInterval: 30000,
        print: () => null,
    },
    onPrepare() {
        require('ts-node').register({
            project: require('path').join(__dirname, '../tsconfig.json'),
        });
        jasmine.getEnv().addReporter(
            new SpecReporter({
                spec: {
                    displayStacktrace: StacktraceOption.PRETTY,
                },
            })
        );
    },
};
