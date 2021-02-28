const { optimize } = require('webpack');
const common = require('./webpack.common.js');
const { merge } = require('webpack-merge');
const path = require('path');
const TerserJSPlugin = require('terser-webpack-plugin');

const rootFolder = path.join(__dirname, '../../../');

module.exports = merge(common, {
    mode: 'production',
    optimization: {
        minimizer: [new TerserJSPlugin({})],
    },
    plugins: [new optimize.AggressiveMergingPlugin()],
    module: {
        rules: [
            {
                test: /\.css$/i,
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
                    'css-loader',
                ],
            },
        ],
    },
});
