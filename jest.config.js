module.exports = {
    roots: ['<rootDir>'],
    transform: {
        '^.+\\.ts?$': 'ts-jest',
    },
    testRegex: '.test.ts$',
    testPathIgnorePatterns: ['test/', 'src/client/test.ts', 'src/client/app', 'src/client/env/config.(base|dev|test|prod).ts', 'src/tests'],
    moduleFileExtensions: ['ts', 'js'],
    collectCoverage: true,
    coverageReporters: ['json'],
    coverageDirectory: require('path').join(__dirname, './.coverage/core'),
};
