const common = require('./webpack.common.js');
const { merge } = require('webpack-merge');
const path = require('path');

const rootFolder = path.join(__dirname, '../../../');

module.exports = merge(common, {
    mode: 'development',
    devtool: 'inline-source-map',
    module: {
        devServer: {
            https: {
                cert: path.join(rootFolder, 'src/cert/dev.genguid.com.crt'),
                key: path.join(rootFolder, 'src/cert/dev.genguid.com.key')
            },
        },
        rules: [
            {
                test: /\.css$/,
                include: [path.join(rootFolder, 'src/client')],
                use: [
                    {
                        loader: 'file-loader',
                        options: {
                            name: '[name][hash].[ext]',
                        },
                    },
                    {
                        loader: 'extract-loader',
                        options: {
                            publicPath: '/',
                        },
                    },
                    {
                        loader: 'css-loader',
                        options: {
                            sourceMap: true,
                        },
                    },
                ],
            },
        ],
    },
});
