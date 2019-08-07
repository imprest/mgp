module.exports = {
    "env": {
        "browser": true,
        "es6": true
    },
    "plugins": [
        "svelte3"
    ],
    "extends": "eslint:recommended",
    "globals": {
        "Atomics": "readonly",
        "SharedArrayBuffer": "readonly"
    },
    "parserOptions": {
        "ecmaVersion": 2019,
        "sourceType": "module",
        "allowImportExportEverywhere": true
    },
    "rules": {}
};