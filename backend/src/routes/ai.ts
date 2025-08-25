import { Router, Request, Response, NextFunction } from 'express';
import { AIAnalysisRequest, AIAnalysisResponse, AIChatRequest, AIChatResponse } from '../types/ai';
import { generateCommitNote, generateAIReview, generateAIFix, generateChatResponse } from '../services/aiService';

const router = Router();

// POST /api/ai/analyze - Анализ кода
router.post('/analyze', async (req: Request<{}, AIAnalysisResponse, AIAnalysisRequest>, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { code, filename, language } = req.body;

    if (!code || !filename) {
      res.status(400).json({
        commitNote: '',
        aiReview: ['Error: Missing required fields'],
        suggestions: []
      });
      return;
    }

    const commitNote = await generateCommitNote(code, filename);
    const aiReview = await generateAIReview(code, language || 'javascript');
    const suggestions = aiReview;

    res.json({
      commitNote,
      aiReview,
      suggestions
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/ai/fix - Автоматическое исправление кода
router.post('/fix', async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { code, filename } = req.body;

    if (!code) {
      res.status(400).json({ error: 'Code is required' });
      return;
    }

    const fixedCode = await generateAIFix(code);
    
    res.json({
      original: code,
      fixed: fixedCode,
      changes: ['Applied AI fixes']
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/ai/chat - Чат с AI о коде
router.post('/chat', async (req: Request<{}, AIChatResponse, AIChatRequest>, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { message, code, context } = req.body;

    if (!message) {
      res.status(400).json({ response: 'Message is required' });
      return;
    }

    const response = await generateChatResponse(message, code, context);
    
    res.json({ response });
  } catch (error) {
    next(error);
  }
});

export default router;
