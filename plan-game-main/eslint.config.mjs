import globals from 'globals';
import parser from '@typescript-eslint/parser';
import pluginJs from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';

/** @type {import('eslint').Linter.Config[]} */
export default [
  // Set commonjs for .js files
  { files: ['**/*.js'], languageOptions: { sourceType: 'commonjs' } },

  // Match only desired files
  { files: ['src/**/*.{ts,tsx,js,mjs,cjs}'] },

  // Ignore dist and node_modules directories
  { ignores: ['dist/', 'node_modules/', 'eslint.config.mjs'] },

  // Set browser and node globals
  {
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
        Phaser: 'readonly'  // Add Phaser as a readonly global
      }
    }
  },

  // Add JavaScript recommended config
  pluginJs.configs.recommended,

  // Add TypeScript-specific configuration
  {
    languageOptions: {
      parser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        project: './tsconfig.json',
      },
    },
    plugins: {
      '@typescript-eslint': tseslint,
    },
    rules: {
      // TypeScript recommended rules
      ...tseslint.configs.recommended.rules,

      '@typescript-eslint/explicit-module-boundary-types': 'off',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      'eqeqeq': ['error', 'always'],
      'indent': ['error', 2],
      'no-unused-vars': 'off', // Disable no-unused-vars (handled by TS)
      'quotes': ['error', 'single'],
      'semi': ['error', 'always'],
    },
  },
];
