import { Router, Request, Response, NextFunction } from 'express';
import Joi from 'joi';
import * as aiService from '@services/aiService';
import type { AIAnalysisRequest, AIAnalysisResponse, AIChatRequest, AIChatResponse, AIConfig } from '../types/ai';

const router = Router();

// Validation schemas
const analysisSchema = Joi.object({
  code: Joi.string().required().max(50000),
  fileName: Joi.string().optional().max(255),
  oldCode: Joi.string().optional().max(50000),
  analysisType: Joi.string().valid('review', 'fix', 'commit', 'optimize').required()
});

const chatSchema = Joi.object({
  message: Joi.string().required().max(1000),
  code: Joi.string().optional().max(50000),
  fileName: Joi.string().optional().max(255),
  conversationId: Joi.string().optional()
});


// Validation middleware
const validateRequest = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    const { error } = schema.validate(req.body);
    if (error) {
      res.status(400).json({
        success: false,
        error: error.details[0].message
      });
      return; // ✅ завершили выполнение, но не возвращаем Response
    }
    next();
  };
};


/**
 * POST /api/ai/analyze
 * Analyze code and return AI suggestions
 */

router.post('/analyze', validateRequest(analysisSchema), async (
  req: Request<{}, AIAnalysisResponse, AIAnalysisRequest>, 
  res: Response, 
  next: NextFunction
): Promise<void> => {
  try {
    const { code, fileName, oldCode, analysisType } = req.body;

    let result: any;

    switch (analysisType) {
      case 'review':
        result = await aiService.generateAIReview(code, fileName);
        break;
      case 'fix':
        result = await aiService.applyAIFixes(code, fileName);
        break;
      case 'commit':
        result = await aiService.generateAIComment(oldCode || '', code, fileName);
        break;
      case 'optimize':
        result = await aiService.generateOptimizationSuggestions(code, fileName);
        break;
      default:
        res.status(400).json({
          success: false,
          error: 'Invalid analysis type'
        });
        return; // ✅ вместо return res.status(...)
    }

    res.json({
      success: true,
      data: result,
      analysisType,
      fileName: fileName || 'untitled',
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/ai/chat
 * Chat with AI about code
 */
router.post('/chat', validateRequest(chatSchema), async (
  req: Request<{}, AIChatResponse, AIChatRequest>, 
  res: Response, 
  next: NextFunction
): Promise<void> => {
  try {
    const { message, code, fileName, conversationId } = req.body;

    const response = await aiService.chat({
      message,
      code,
      fileName,
      conversationId
    });

    res.json({
      success: true,
      data: {
        message: response,
        conversationId: conversationId || `conv_${Date.now()}`,
        timestamp: new Date().toISOString()
      }
    });

  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/ai/fix/apply
 * Apply AI fixes to code and return fixed version
 */
router.post('/fix/apply', validateRequest(analysisSchema), async (
  req: Request, 
  res: Response, 
  next: NextFunction
): Promise<void> => {
  try {
    const { code, fileName } = req.body;

    const fixedCode = await aiService.applyAIFixes(code, fileName);

    res.json({
      success: true,
      data: {
        originalCode: code,
        fixedCode,
        fileName: fileName || 'untitled',
        appliedAt: new Date().toISOString()
      }
    });

  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/ai/status
 * Check AI service status and configuration
 */
router.get('/status', (req: Request, res: Response) => {
  const status = aiService.getStatus();
  
  res.json({
    success: true,
    data: {
      configured: status.isConfigured,
      provider: status.provider,
      model: status.model,
      features: Object.keys(status.features).filter(key => 
        status.features[key as keyof typeof status.features]
      ),
      timestamp: new Date().toISOString()
    }
  });
});

export default router;

