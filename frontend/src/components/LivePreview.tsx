import { useState, useEffect } from 'react';
import { Play, RefreshCw, ExternalLink, Eye } from 'lucide-react';
import type { TabItem } from '../types';

interface LivePreviewProps {
  activeTab: TabItem | null;
}

export function LivePreview({ activeTab }: LivePreviewProps) {
  const [previewContent, setPreviewContent] = useState('');
  const [counter, setCounter] = useState(0);

  useEffect(() => {
    if (activeTab && activeTab.name.endsWith('.html')) {
      setPreviewContent(activeTab.content);
    } else if (activeTab && activeTab.name.endsWith('.js')) {
      // Create a demo HTML with embedded JS
      setPreviewContent(`
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Live Preview Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 500px;
            margin: 0 auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 30px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            text-align: center;
        }
        h1 { margin-bottom: 20px; }
        .counter { font-size: 24px; margin: 20px 0; }
        button {
            background: #4ecdc4;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            margin: 5px;
            transition: all 0.3s;
        }
        button:hover { background: #45b7aa; transform: translateY(-2px); }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 iCoder Plus Live Preview</h1>
        <p>This HTML file demonstrates the live preview functionality!</p>
        <div class="counter">Counter: <span id="counter">${counter}</span></div>
        <button onclick="increment()">+ Increment</button>
        <button onclick="decrement()">- Decrement</button>
        <button onclick="reset()">🔄 Reset</button>
        <button onclick="logMessage()">📝 Log Message</button>
    </div>
    <script>
        let count = ${counter};
        
        function increment() {
            count++;
            document.getElementById('counter').textContent = count;
            console.log('Counter incremented to:', count);
        }
        
        function decrement() {
            count--;
            document.getElementById('counter').textContent = count;
            console.log('Counter decremented to:', count);
        }
        
        function reset() {
            count = 0;
            document.getElementById('counter').textContent = count;
            console.log('Counter reset');
        }
        
        function logMessage() {
            console.log('Hello from iCoder Plus Live Preview!');
            alert('Check the console for the message!');
        }
        
        // Auto-update from active file
        ${activeTab.content || ''}
    </script>
</body>
</html>
      `);
    }
  }, [activeTab, counter]);

  const runCode = () => {
    if (activeTab) {
      setCounter(prev => prev + 1);
      console.log('Running code:', activeTab.name);
    }
  };

  const refreshPreview = () => {
    setCounter(0);
  };

  if (!activeTab) {
    return (
      <div className="h-full flex items-center justify-center p-4">
        <div className="text-center text-gray-400">
          <Eye size={48} className="mx-auto mb-4 opacity-50" />
          <p className="text-sm">Select a file to see live preview</p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-full flex flex-col">
      {/* Preview Header */}
      <div className="p-3 border-b border-gray-700 bg-gray-750">
        <div className="flex items-center justify-between mb-2">
          <span className="text-xs font-semibold text-gray-300">Live Preview</span>
          <div className="flex space-x-1">
            <button
              onClick={runCode}
              className="p-1.5 bg-green-600 hover:bg-green-500 rounded text-white"
              title="Run Code"
            >
              <Play size={12} />
            </button>
            <button
              onClick={refreshPreview}
              className="p-1.5 bg-gray-600 hover:bg-gray-500 rounded text-white"
              title="Refresh"
            >
              <RefreshCw size={12} />
            </button>
          </div>
        </div>
        <div className="text-xs text-gray-400">
          {activeTab.name} • {activeTab.content?.length || 0} characters
        </div>
      </div>

      {/* Preview Content */}
      <div className="flex-1 bg-white">
        <iframe
          srcDoc={previewContent}
          className="w-full h-full border-none"
          title="Live Preview"
          sandbox="allow-scripts allow-same-origin"
        />
      </div>

      {/* Preview Footer */}
      <div className="p-2 bg-gray-750 border-t border-gray-700 text-xs text-gray-400">
        Language: {activeTab.name.endsWith('.html') ? 'HTML' : 'JavaScript'} • Updated live
      </div>
    </div>
  );
}
