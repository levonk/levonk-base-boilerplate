import type { Config } from '@react-native-community/eslint-config'

const config: Config = {
  extends: ['expo', 'prettier'],
  rules: {
    'import/order': [
      'error',
      {
        groups: ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
        'newlines-between': 'always',
        alphabetize: { order: 'asc', caseInsensitive: true },
      },
    ],
  },
}

export default config
