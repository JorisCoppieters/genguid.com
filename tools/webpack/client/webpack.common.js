const { CheckerPlugin } = require('awesome-typescript-loader');
const HtmlWebPackPlugin = require('html-webpack-plugin');
const path = require('path');
const RobotstxtPlugin = require('robotstxt-webpack-plugin');
const SitemapPlugin = require('sitemap-webpack-plugin').default;

const env = process.env['webpack_env'];
const envPrefix = env !== 'prod' ? `${env}.` : '';

let host = process.env['npm_package_config_host'];
host = `${envPrefix}${host}`;

const rootFolder = path.join(__dirname, '../../../');

module.exports = {
    entry: {
        index: path.join(rootFolder, 'src/client/index/index.ts'),
    },
    module: {
        rules: [
            {
                test: /\.(png|svg|jpg|gif)$/,
                include: path.join(rootFolder, 'src/assets/images'),
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
                include: path.join(rootFolder, 'src/assets/favicon'),
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
                include: path.join(rootFolder, 'src/assets/fonts'),
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
                include: path.join(rootFolder, 'src/client'),
                use: [
                    {
                        loader: 'html-loader',
                    },
                ],
            },
            {
                test: /\.ts?$/,
                include: [path.join(rootFolder, 'src/client')],
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
        path: path.join(rootFolder, 'dist/client'),
        filename: '[name][hash].js',
    },
    resolve: {
        extensions: ['.ts', '.js'],
    },
    plugins: [
        new SitemapPlugin(
            `https://${host}`,
            [
                {
                    path: '/',
                    lastmod: '2020-01-01',
                    priority: '1',
                    changefreq: 'yearly',
                },
            ],
            {
                skipgzip: true,
            }
        ),
        new RobotstxtPlugin({
            policy: [
                {
                    userAgent: '*',
                    allow: '/',
                    crawlDelay: 2,
                },
            ],
            sitemap: `https://${host}/sitemap.xml`,
            host: host,
        }),
        new CheckerPlugin(),
        new HtmlWebPackPlugin({
            template: path.join(rootFolder, 'src/client/index/index.html'),
            filename: './index.html',
            minify: false,
            chunks: ['index'],
            meta: {
                'google-site-verification': 'google-site-verification=1VJ4fItCgcxK2vWvdBrX9nttQNP2e73j6Ot-1aAGtr4',
            },
        }),
    ],
};
