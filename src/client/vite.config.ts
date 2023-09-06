const fs = require('fs');
const path = require('path');

import { defineConfig } from 'vite';
import { CERT_NAME, ENV_HOST, HTTPS_PORT, KEY_NAME } from '../shared/env/vars';

// https://vitejs.dev/config/
export default defineConfig({
    root: path.join(__dirname, `index`),
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