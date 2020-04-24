const { CheckerPlugin } = require('awesome-typescript-loader');
const path = require('path');

const rootFolder = path.join(__dirname, '../../../');

module.exports = {
    entry: {
        index: path.join(rootFolder, 'src/site/index/index.ts'),
    },
    module: {
        rules: [
            {
                test: [/robots.txt/, /sitemap.xml/],
                include: path.join(rootFolder, 'src/site'),
                use: [
                    {
                        loader: 'file-loader',
                        options: {
                            name: '[name].[ext]',
                        },
                    },
                ],
            },
            {
                test: /\.(png|svg|jpg|gif)$/,
                include: path.join(rootFolder, 'src/_assets/images'),
                use: [
                    {
                        loader: 'file-loader',
                        options: {
                            name: 'assets/images/[name].[ext]',
                        },
                    },
                ],
            },
            {
                test: /\.(png|ico)$/,
                include: path.join(rootFolder, 'src/_assets/favicon'),
                use: [
                    {
                        loader: 'file-loader',
                        options: {
                            name: 'assets/favicon/[name].[ext]',
                        },
                    },
                ],
            },
            {
                test: /\.(woff|woff2|eot|ttf|otf|svg)$/,
                include: path.join(rootFolder, 'src/_assets/fonts'),
                use: [
                    {
                        loader: 'file-loader',
                        options: {
                            name: 'assets/fonts/[name].[ext]',
                        },
                    },
                ],
            },
            {
                test: /\.(html)$/,
                include: path.join(rootFolder, 'src/site'),
                use: [
                    {
                        loader: 'file-loader',
                        options: {
                            name: '[name].[ext]',
                        },
                    },
                    {
                        loader: 'extract-loader',
                    },
                    {
                        loader: 'html-loader',
                    },
                ],
            },
            {
                test: /\.ts?$/,
                include: [path.join(rootFolder, 'src/_common/ts'), path.join(rootFolder, 'src/site')],
                exclude: /node_modules/,
                use: [
                    {
                        loader: 'awesome-typescript-loader',
                        options: {
                            configFileName: path.join(rootFolder, './tsconfig.json'),
                        },
                    },
                ],
            },
        ],
    },
    output: {
        path: path.join(rootFolder, 'dist/site'),
        filename: '[name].js',
        publicPath: '/',
    },
    resolve: {
        extensions: ['.ts', '.js'],
    },
    plugins: [new CheckerPlugin()],
};
