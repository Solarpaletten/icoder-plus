import { Router, Request, Response, NextFunction } from 'express'
import Joi from 'joi'
import { aiService } from '@services/aiService'
import { validateRequest } from '@middleware/validation'
import { AIAnalysisRequest, AIAnalysisResponse, AIChatRequest, AIChatResponse } from '@types/ai'

const router = Router()

// Validation schemas
const analysisSchema = Joi.object({
  code: Joi.string().required().max(50000),
  fileName: Joi.string().optional().max(255),
  oldCode: Joi.string().optional().max(50000),
  analysisType: Joi.string().valid('review', 'fix', 'commit', 'optimize').required()
})

const chatSchema = Joi.object({
  message: Joi.string().required().max(1000),
  code: Joi.string().optional().max(50000),
  fileName: Joi.string().optional().max(255),
  conversationId: Joi.string().optional().uuid()
})

/**
 * POST /api/ai/analyze
 * Analyze code and return AI suggestions
 */
router.post('/analyze', validateRequest(analysisSchema), async (req: Request<{}, AIAnalysisResponse, AIAnalysisRequest>, res: Response, next: NextFunction) => {
  try {
    const { code, fileName, oldCode, analysisType } = req.body

    let result: any

    switch (analysisType) {
      case 'review':
        result = await aiService.generateReview(code, fileName)
        break
      case 'fix':
        result = await aiService.generateFixes(code, fileName)
        break
      case 'commit':
        result = await aiService.generateCommitNote(oldCode || '', code, fileName)
        break
      case 'optimize':
        result = await aiService.generateOptimizations(code, fileName)
        break
      default:
        return res.status(400).json({
          success: false,
          error: 'Invalid analysis type'
        })
    }

    res.json({
      success: true,
      data: result,
      analysisType,
      fileName: fileName || 'untitled',
      timestamp: new Date().toISOString()
    })

  } catch (error) {
    next(error)
  }
})

/**
 * POST /api/ai/chat
 * Chat with AI about code
 */
router.post('/chat', validateRequest(chatSchema), async (req: Request<{}, AIChatResponse, AIChatRequest>, res: Response, next: NextFunction) => {
  try {
    const { message, code, fileName, conversationId } = req.body

    const response = await aiService.chat({
      message,
      code,
      fileName,
      conversationId
    })

    res.json({
      success: true,
      data: {
        message: response,
        conversationId: conversationId || `conv_${Date.now()}`,
        timestamp: new Date().toISOString()
      }
    })

  } catch (error) {
    next(error)
  }
})

/**
 * POST /api/ai/fix/apply
 * Apply AI fixes to code and return fixed version
 */
router.post('/fix/apply', validateRequest(analysisSchema), async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { code, fileName } = req.body

    const fixedCode = await aiService.applyFixes(code, fileName)

    res.json({
      success: true,
      data: {
        originalCode: code,
        fixedCode,
        fileName: fileName || 'untitled',
        appliedAt: new Date().toISOString()
      }
    })

  } catch (error) {
    next(error)
  }
})

/**
 * GET /api/ai/status
 * Check AI service status and configuration
 */
router.get('/status', (req: Request, res: Response) => {
  const status = aiService.getStatus()
  
  res.json({
    success: true,
    data: {
      configured: status.isConfigured,
      provider: status.provider,
      model: status.model,
      features: status.features,
      timestamp: new Date().toISOString()
    }
  })
})

export default router