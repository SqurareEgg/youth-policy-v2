module.exports = {
  root: true,

  parserOptions: {
    ecmaVersion: '2021',
    sourceType: 'module'
  },

  env: {
    node: true,
    browser: true,
    'vue/setup-compiler-macros': true
  },

  extends: [
    'plugin:vue/vue3-essential',
    'eslint:recommended'
  ],

  plugins: [
    'vue'
  ],

  globals: {
    process: 'readonly'
  },

  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'vue/multi-word-component-names': 'off'
  }
}
