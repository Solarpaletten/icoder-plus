declare namespace NodeJS {
  interface ProcessEnv {
    NODE_ENV: 'development' | 'production';
    PORT: string;
    OPENAI_API_KEY?: string;
    ANTHROPIC_API_KEY?: string;
  }
}
