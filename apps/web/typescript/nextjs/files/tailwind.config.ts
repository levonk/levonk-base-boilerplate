import { createTailwindPreset } from '@job-aide/tools-css-config/tailwind';
// TODO: replace with your app's tokens package or adjust ./src/tokens
import tokens from './src/tokens';

export default createTailwindPreset(tokens, {});

// vim: set ft=typescript:
