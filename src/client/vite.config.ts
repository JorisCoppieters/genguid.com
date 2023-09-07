import { defineConfig } from 'vite';

import { CERT_NAME, ENV_HOST, HTTPS_PORT, KEY_NAME } from '../shared/env/vars';

const fs = require('fs');
const path = require('path');

// https://vitejs.dev/config/
export default defineConfig({
    root: path.join(__dirname, `index`),
    build: {
        outDir: path.join(__dirname, `../../dist-app`)
    },
    server: {
        cors: true,
        port: HTTPS_PORT,
        host: ENV_HOST,
        https: {
            key: fs.readFileSync(path.join(__dirname, `../cert/${KEY_NAME}`)),
            cert: fs.readFileSync(path.join(__dirname, `../cert/${CERT_NAME}`)),
        },
    }
});
