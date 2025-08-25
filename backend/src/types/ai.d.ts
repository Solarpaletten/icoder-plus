export interface AIAnalysisRequest {
    code: string;
    fileName?: string;
    oldCode?: string;
    analysisType: "review" | "fix" | "commit" | "optimize";
  }
  
  export interface AIAnalysisResponse {
    summary?: string;
    issues?: string[];
    success?: boolean;
    data?: any;
  }
  
  export interface AIChatRequest {
    message: string;
    code?: string;
    fileName?: string;
    conversationId?: string;
  }
  
  export interface AIChatResponse {
    reply: string;
    conversationId?: string;
  }
  