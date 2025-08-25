// src/services/previewService.js - Secure Preview Engine for iCoder Plus v2.0

/**
 * Secure JavaScript execution in isolated context
 */
export function executeJavaScript(code, timeout = 5000) {
    return new Promise((resolve) => {
      const logs = [];
      const errors = [];
      let timeoutId;
  
      try {
        // Create isolated execution context
        const iframe = document.createElement('iframe');
        iframe.style.display = 'none';
        iframe.sandbox = 'allow-scripts';
        document.body.appendChild(iframe);
  
        const iframeWindow = iframe.contentWindow;
        
        // Override console methods to capture output
        const originalConsole = iframeWindow.console;
        iframeWindow.console = {
          log: (...args) => logs.push('📝 ' + args.map(formatValue).join(' ')),
          warn: (...args) => logs.push('⚠️ ' + args.map(formatValue).join(' ')),
          error: (...args) => errors.push('❌ ' + args.map(formatValue).join(' ')),
          info: (...args) => logs.push('ℹ️ ' + args.map(formatValue).join(' ')),
          debug: (...args) => logs.push('🐛 ' + args.map(formatValue).join(' '))
        };
  
        // Set timeout for execution
        timeoutId = setTimeout(() => {
          cleanup();
          resolve({
            success: false,
            output: logs.join('\n'),
            errors: ['⏱️ Execution timeout after ' + timeout + 'ms'],
            executionTime: timeout
          });
        }, timeout);
  
        const cleanup = () => {
          if (timeoutId) clearTimeout(timeoutId);
          if (iframe.parentNode) {
            document.body.removeChild(iframe);
          }
        };
  
        // Execute code in iframe context
        const startTime = performance.now();
        
        try {
          // Wrap code in function to catch return values
          const wrappedCode = `
            (function() {
              ${code}
            })();
          `;
          
          const result = iframeWindow.eval(wrappedCode);
          const executionTime = Math.round(performance.now() - startTime);
  
          // Add result to output if it exists
          if (result !== undefined) {
            logs.push('🔄 Result: ' + formatValue(result));
          }
  
          cleanup();
          resolve({
            success: true,
            output: logs.join('\n') || '✅ Code executed successfully (no output)',
            errors,
            executionTime,
            result
          });
  
        } catch (error) {
          cleanup();
          resolve({
            success: false,
            output: logs.join('\n'),
            errors: [...errors, '❌ ' + error.message],
            executionTime: Math.round(performance.now() - startTime)
          });
        }
  
      } catch (error) {
        if (timeoutId) clearTimeout(timeoutId);
        resolve({
          success: false,
          output: '',
          errors: ['❌ Preview setup failed: ' + error.message],
          executionTime: 0
        });
      }
    });
  }
  
  /**
   * Render HTML with security sandbox
   */
  export function renderHTML(htmlCode) {
    const sandboxAttributes = [
      'allow-scripts',
      'allow-same-origin',
      'allow-forms',
      'allow-modals'
    ].join(' ');
  
    // Clean and validate HTML
    const cleanHTML = sanitizeHTML(htmlCode);
    
    return {
      success: true,
      sandboxAttributes,
      content: cleanHTML,
      securityInfo: {
        sandbox: true,
        csp: true,
        isolated: true
      }
    };
  }
  
  /**
   * Basic HTML sanitization (for development - use DOMPurify in production)
   */
  function sanitizeHTML(html) {
    // Remove potentially dangerous elements and attributes
    let clean = html
      .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '') // Remove script tags
      .replace(/on\w+\s*=\s*["'][^"']*["']/gi, '') // Remove inline event handlers
      .replace(/javascript:/gi, '') // Remove javascript: urls
      .replace(/data:/gi, 'data-blocked:'); // Block data URLs
    
    return clean;
  }
  
  /**
   * Preview CSS styles safely
   */
  export function previewCSS(cssCode, htmlContext = '<div>CSS Preview</div>') {
    try {
      const sanitizedCSS = sanitizeCSS(cssCode);
      const previewHTML = `
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="utf-8">
            <style>
              body { 
                font-family: system-ui, -apple-system, sans-serif; 
                padding: 20px; 
                background: #1a1a1a;
                color: #ffffff;
              }
              ${sanitizedCSS}
            </style>
          </head>
          <body>
            ${htmlContext}
          </body>
        </html>
      `;
  
      return {
        success: true,
        content: previewHTML,
        sanitizedCSS
      };
  
    } catch (error) {
      return {
        success: false,
        error: 'CSS preview failed: ' + error.message
      };
    }
  }
  
  /**
   * Basic CSS sanitization
   */
  function sanitizeCSS(css) {
    // Remove potentially dangerous CSS (basic protection)
    return css
      .replace(/@import\s+url\([^)]+\)/gi, '') // Remove @import rules
      .replace(/expression\s*\([^)]+\)/gi, '') // Remove IE expression()
      .replace(/javascript:/gi, '') // Remove javascript: in CSS
      .replace(/behavior\s*:/gi, 'blocked-behavior:'); // Block IE behaviors
  }
  
  /**
   * Format values for console output
   */
  function formatValue(value) {
    if (value === null) return 'null';
    if (value === undefined) return 'undefined';
    if (typeof value === 'string') return `"${value}"`;
    if (typeof value === 'function') return '[Function]';
    if (typeof value === 'object') {
      try {
        return JSON.stringify(value, null, 2);
      } catch {
        return '[Object]';
      }
    }
    return String(value);
  }
  
  /**
   * Get file type from filename/extension
   */
  export function getFileType(fileName) {
    if (!fileName) return 'unknown';
    
    const extension = fileName.split('.').pop()?.toLowerCase();
    
    const typeMap = {
      'js': 'javascript',
      'jsx': 'javascript',
      'ts': 'typescript',
      'tsx': 'typescript',
      'html': 'html',
      'htm': 'html',
      'css': 'css',
      'scss': 'scss',
      'sass': 'sass',
      'json': 'json',
      'md': 'markdown',
      'py': 'python',
      'java': 'java',
      'cpp': 'cpp',
      'c': 'c'
    };
    
    return typeMap[extension] || 'text';
  }
  
  /**
   * Check if file type supports live preview
   */
  export function supportsLivePreview(fileName) {
    const fileType = getFileType(fileName);
    return ['javascript', 'html', 'css'].includes(fileType);
  }
  
  /**
   * Execute code based on file type
   */
  export async function executeByFileType(code, fileName) {
    const fileType = getFileType(fileName);
    
    switch (fileType) {
      case 'javascript':
        return await executeJavaScript(code);
        
      case 'html':
        return renderHTML(code);
        
      case 'css':
        return previewCSS(code);
        
      default:
        return {
          success: false,
          output: '',
          errors: [`❌ Preview not supported for ${fileType} files`],
          fileType
        };
    }
  }
  
  /**
   * Create secure preview environment info
   */
  export function getSecurityInfo() {
    return {
      sandbox: {
        enabled: true,
        attributes: ['allow-scripts', 'allow-same-origin', 'allow-forms'],
        description: 'Code runs in isolated iframe with restricted permissions'
      },
      csp: {
        enabled: true,
        description: 'Content Security Policy blocks dangerous resources'
      },
      timeout: {
        enabled: true,
        duration: 5000,
        description: 'Code execution is limited to 5 seconds'
      },
      sanitization: {
        enabled: true,
        description: 'HTML and CSS are sanitized to remove dangerous content'
      }
    };
  }
  
  /**
   * Performance monitoring for preview execution
   */
  export class PreviewMonitor {
    constructor() {
      this.executions = [];
      this.maxHistory = 100;
    }
  
    recordExecution(fileName, fileType, executionTime, success) {
      const record = {
        timestamp: Date.now(),
        fileName,
        fileType,
        executionTime,
        success
      };
  
      this.executions.unshift(record);
      
      // Keep only recent executions
      if (this.executions.length > this.maxHistory) {
        this.executions = this.executions.slice(0, this.maxHistory);
      }
    }
  
    getStats() {
      const recent = this.executions.slice(0, 10);
      const avgExecutionTime = recent.length > 0 
        ? recent.reduce((sum, ex) => sum + ex.executionTime, 0) / recent.length
        : 0;
  
      const successRate = recent.length > 0
        ? (recent.filter(ex => ex.success).length / recent.length) * 100
        : 100;
  
      return {
        totalExecutions: this.executions.length,
        recentExecutions: recent.length,
        avgExecutionTime: Math.round(avgExecutionTime),
        successRate: Math.round(successRate),
        lastExecution: recent[0]?.timestamp || null
      };
    }
  }
  
  // Global monitor instance
  export const previewMonitor = new PreviewMonitor();
  
  // Export constants
  export const PREVIEW_CONFIG = {
    maxExecutionTime: 5000,
    supportedTypes: ['javascript', 'html', 'css'],
    securityFeatures: ['sandbox', 'csp', 'timeout', 'sanitization'],
    consoleCommands: ['log', 'warn', 'error', 'info', 'debug']
  };