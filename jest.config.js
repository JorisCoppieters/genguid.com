module.exports = {
    roots: ['<rootDir>'],
    transform: {
        '^.+\\.ts?$': 'ts-jest',
    },
    testRegex: '.test.ts$',
    testPathIgnorePatterns: ['test/', 'src/client/test.ts', 'src/client/app', 'src/client/environments', 'src/e2e'],
    moduleFileExtensions: ['ts', 'js'],
    collectCoverage: true,
    coverageReporters: ['json', 'html'],
};
