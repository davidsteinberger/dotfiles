import * as emoji from 'node-emoji';
import type { Hooks } from '@opencode-ai/plugin';

export const MyPlugin = async (ctx) => {
  return {
    'experimental.text.complete': async (input, output) => {
      if (output && typeof output.text === 'string') {
        try {
          output.text = emoji.emojify(output.text);
        } catch (error) {
          console.error('Error emojifying text:', error);
          output.text = output.text;
        }
      }
    }
  }
}
