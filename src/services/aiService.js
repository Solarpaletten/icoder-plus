// src/services/aiService.js - Real AI Integration for iCoder Plus v2.0
import OpenAI from 'openai';

// Initialize OpenAI client
const openai = new OpenAI({
  apiKey: import.meta.env.VITE_OPENAI_API_KEY,
  dangerouslyAllowBrowser: true // Only for client-side demo - move to backend in production!
});

// Anthropic Claude alternative (uncomment if using Claude)
// import Anthropic from '@anthropic-ai/sdk';
// const anthropic = new Anthropic({
//   apiKey: import.meta.env.VITE_ANTHROPIC_API_KEY,
// });

/**
 * Generate AI commit note based on code changes
 */
export async function generateAIComment(oldCode, newCode, fileName = '') {
  if (!import.meta.env.VITE_OPENAI_API_KEY) {
    return "🤖 AI service not configured - add VITE_OPENAI_API_KEY to .env";
  }

  try {
    if (oldCode === newCode) return "No changes detected.";
    if (!oldCode) return `🆕 New file created: ${fileName}`;
    if (!newCode) return `❌ File deleted: ${fileName}`;

    const prompt = `You are a concise code reviewer. Compare these two code versions and write ONE short sentence describing the change.

File: ${fileName}

OLD CODE:
\`\`\`
${oldCode.slice(0, 500)}
\`\`\`

NEW CODE:
\`\`\`
${newCode.slice(0, 500)}
\`\`\`

Respond with a single sentence starting with an emoji that describes the main change (e.g., "✏️ Refactored login function", "🐛 Fixed validation bug", "✨ Added dark mode support").`;

    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      max_tokens: 50,
      temperature: 0.3
    });

    return response.choices[0].message.content.trim();
  } catch (error) {
    console.error('AI Comment generation failed:', error);
    return "✏️ Code updated (AI analysis failed)";
  }
}

/**
 * Generate AI code review with suggestions
 */
export async function generateAIReview(code, fileName = '') {
  if (!import.meta.env.VITE_OPENAI_API_KEY) {
    return ["⚠️ AI service not configured - add API key to enable reviews"];
  }

  try {
    const prompt = `You are a code reviewer. Analyze this code and provide 2-4 concise suggestions for improvement.

File: ${fileName}
Code:
\`\`\`
${code.slice(0, 1000)}
\`\`\`

Return your response as a JSON array of strings. Each suggestion should start with an emoji and be under 80 characters.
Focus on: performance, security, readability, modern JS practices, potential bugs.

Example format: ["🔒 Use const instead of var for immutable variables", "⚡ Consider memoizing this expensive calculation"]`;

    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      max_tokens: 200,
      temperature: 0.2
    });

    const content = response.choices[0].message.content.trim();
    
    try {
      const suggestions = JSON.parse(content);
      return Array.isArray(suggestions) ? suggestions : [content];
    } catch {
      // Fallback if JSON parsing fails
      return content.split('\n').filter(line => line.trim()).slice(0, 4);
    }
  } catch (error) {
    console.error('AI Review generation failed:', error);
    return ["⚠️ AI review temporarily unavailable"];
  }
}

/**
 * Apply AI-powered automatic fixes to code
 */
export async function applyAIFixes(code, fileName = '') {
  if (!import.meta.env.VITE_OPENAI_API_KEY) {
    // Fallback to basic fixes if AI not available
    return applyBasicFixes(code);
  }

  try {
    const prompt = `You are a code formatter and modernizer. Apply these fixes to the code:

1. Replace 'var' with 'let' or 'const' appropriately
2. Remove console.log statements
3. Fix common syntax issues
4. Modernize JavaScript (arrow functions, destructuring if beneficial)
5. Remove unused imports

Return ONLY the fixed code, no explanations.

Original code:
\`\`\`
${code}
\`\`\``;

    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini", 
      messages: [{ role: "user", content: prompt }],
      max_tokens: Math.min(1500, code.length + 500),
      temperature: 0.1
    });

    const fixedCode = response.choices[0].message.content
      .replace(/^```[\w]*\n?/, '')
      .replace(/\n?```$/, '')
      .trim();

    return fixedCode || applyBasicFixes(code);
  } catch (error) {
    console.error('AI Fix generation failed:', error);
    return applyBasicFixes(code);
  }
}

/**
 * Basic fixes fallback (no AI required)
 */
function applyBasicFixes(code) {
  let fixed = code;
  
  // Replace var with const/let
  fixed = fixed.replace(/\bvar\s+(\w+)\s*=/g, (match, varName) => {
    // Simple heuristic: if assigned once, use const, otherwise let
    const reassignments = (code.match(new RegExp(`\\b${varName}\\s*=`, 'g')) || []).length;
    return reassignments > 1 ? `let ${varName} =` : `const ${varName} =`;
  });
  
  // Remove console.log statements
  fixed = fixed.replace(/console\.log\([^;]*\);?\n?/g, '');
  
  // Remove trailing whitespace
  fixed = fixed.split('\n').map(line => line.trimEnd()).join('\n');
  
  return fixed.trim();
}

/**
 * AI Chat Assistant for code questions
 */
export async function askAI(question, code, fileName = '') {
  if (!import.meta.env.VITE_OPENAI_API_KEY) {
    return "🤖 AI chat not configured - please add your OpenAI API key to .env file";
  }

  try {
    const prompt = `You are an expert coding assistant for iCoder Plus IDE. Help the user with their question about this code.

File: ${fileName}
User Question: ${question}

Code Context:
\`\`\`
${code.slice(0, 1500)}
\`\`\`

Provide a helpful, concise answer. If the question is about a specific function or line, reference it directly. Keep responses under 150 words.`;

    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      max_tokens: 200,
      temperature: 0.4
    });

    return response.choices[0].message.content.trim();
  } catch (error) {
    console.error('AI Chat failed:', error);
    return "🤖 Sorry, I'm having trouble connecting to AI services right now. Please try again later.";
  }
}

/**
 * Generate AI-powered suggestions for code optimization
 */
export async function generateOptimizationSuggestions(code, fileName = '') {
  if (!import.meta.env.VITE_OPENAI_API_KEY) {
    return ["💡 Enable AI features by adding your OpenAI API key"];
  }

  try {
    const prompt = `Analyze this code for performance and optimization opportunities:

File: ${fileName}
\`\`\`
${code.slice(0, 800)}
\`\`\`

Provide 2-3 specific optimization suggestions as a JSON array of strings.
Focus on: performance bottlenecks, memory usage, algorithmic improvements.`;

    const response = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{ role: "user", content: prompt }],
      max_tokens: 150,
      temperature: 0.3
    });

    const suggestions = JSON.parse(response.choices[0].message.content);
    return Array.isArray(suggestions) ? suggestions : [suggestions];
  } catch (error) {
    console.error('Optimization suggestions failed:', error);
    return ["⚡ AI optimization analysis temporarily unavailable"];
  }
}

// Export configuration info
export const AI_CONFIG = {
  isConfigured: !!import.meta.env.VITE_OPENAI_API_KEY,
  provider: 'OpenAI',
  model: 'gpt-4o-mini',
  features: {
    commitNotes: true,
    codeReview: true,
    autoFix: true,
    chat: true,
    optimization: true
  }
};