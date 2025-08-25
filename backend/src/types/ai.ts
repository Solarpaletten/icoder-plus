// AI service types for iCoder Plus Backend

export interface AIAnalysisRequest {
  code: string;
  fileName?: string;
  oldCode?: string;
  analysisType: 'review' | 'fix' | 'commit' | 'optimize';
}

export interface AIAnalysisResponse {
  success: boolean;
  data: any;
  analysisType: string;
  fileName: string;
  timestamp: string;
  error?: string;
}

export interface AIChatRequest {
  message: string;
  code?: string;
  fileName?: string;
  conversationId?: string;
}

export interface AIChatResponse {
  success: boolean;
  data: {
    message: string;
    conversationId: string;
    timestamp: string;
  };
  error?: string;
}

export interface AIFixRequest {
  code: string;
  fileName?: string;
}

export interface AIFixResponse {
  success: boolean;
  data: {
    originalCode: string;
    fixedCode: string;
    fileName: string;
    appliedAt: string;
  };
  error?: string;
}

export interface AIStatusResponse {
  success: boolean;
  data: {
    configured: boolean;
    provider: string;
    model: string;
    features: string[];
    timestamp: string;
  };
}

export interface AIConfig {
  isConfigured: boolean;
  provider: string;
  model: string;
  features: {
    commitNotes: boolean;
    codeReview: boolean;
    autoFix: boolean;
    chat: boolean;
    optimization: boolean;
  };
}