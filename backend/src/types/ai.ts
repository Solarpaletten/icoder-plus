// Типы для AI сервисов
export interface AIAnalysisRequest {
  code: string;
  filename: string;
  language?: string;
}

export interface AIAnalysisResponse {
  commitNote: string;
  aiReview: string[];
  suggestions: string[];
  aiFixed?: string;
}

export interface AIChatRequest {
  message: string;
  code?: string;
  context?: string;
}

export interface AIChatResponse {
  response: string;
}

export interface AIConfig {
  openaiApiKey: string;
  anthropicApiKey?: string;
  model: string;
  temperature: number;
  maxTokens: number;
}
