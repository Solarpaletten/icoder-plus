import express from 'express'
import { aiService } from '../services/aiService.js'

const router = express.Router()

router.post('/chat', async (req, res) => {
  try {
    const { agent, message, code, targetFile } = req.body
    
    const response = await aiService.processMessage({
      agent,
      message,
      code,
      targetFile
    })
    
    res.json({ success: true, data: response })
  } catch (error) {
    console
  EOF
