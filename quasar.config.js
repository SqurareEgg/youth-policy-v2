/* eslint-env node */

import { configure } from 'quasar/wrappers'

export default configure(function (/* ctx */) {
  return {
    eslint: {
      warnings: true,
      errors: true
    },

    boot: [
      'supabase'
    ],

    css: [
      'app.scss'
    ],

    extras: [
      'roboto-font',
      'material-icons'
    ],

    build: {
      target: {
        browser: ['es2019', 'edge88', 'firefox78', 'chrome87', 'safari13.1'],
        node: 'node16'
      },

      vueRouterMode: 'history',

      env: {
        VITE_SUPABASE_URL: process.env.VITE_SUPABASE_URL,
        VITE_SUPABASE_ANON_KEY: process.env.VITE_SUPABASE_ANON_KEY
      }
    },

    devServer: {
      open: true,
      port: 9000
    },

    framework: {
      config: {},

      plugins: [
        'Notify',
        'Dialog',
        'Loading'
      ]
    },

    animations: [],

    ssr: {
      pwa: false,
      prodPort: 3000,
      middlewares: [
        'render'
      ]
    },

    pwa: {
      workboxMode: 'generateSW',
      injectPwaMetaTags: true,
      swFilename: 'sw.js',
      manifestFilename: 'manifest.json',
      useCredentialsForManifestTag: false
    },

    cordova: {},

    capacitor: {
      hideSplashscreen: true
    },

    electron: {
      inspectPort: 5858,

      bundler: 'packager',

      packager: {},

      builder: {
        appId: 'youth-policy-v2'
      }
    },

    bex: {
      contentScripts: [
        'my-content-script'
      ]
    }
  }
})
