const { optimize } = require('webpack');
const common = require('./webpack.common.js');
const { merge } = require('webpack-merge');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const path = require('path');
const TerserJSPlugin = require('terser-webpack-plugin');

const rootFolder = path.join(__dirname, '../../../');

module.exports = merge(common, {
    mode: 'production',
    optimization: {
        minimizer: [new TerserJSPlugin({}), new OptimizeCSSAssetsPlugin({})],
    },
    plugins: [new optimize.AggressiveMergingPlugin(), new optimize.OccurrenceOrderPlugin()],
    module: {
        rules: [
            {
                test: /\.css$/i,
                include: [path.join(rootFolder, 'src/client'), path.join(rootFolder, 'src/_common/css')],
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
