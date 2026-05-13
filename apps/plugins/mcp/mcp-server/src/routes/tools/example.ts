// Example tool registration placeholder
export const exampleTool = {
  name: 'ping',
  description: 'Ping tool example',
  async run(params: { message: string }) {
    return { echo: params.message };
  },
};
