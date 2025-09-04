#!/bin/bash

echo "🔧 ПРЯМОЕ ИСПРАВЛЕНИЕ TYPESCRIPT ОШИБКИ"
echo "======================================"

# Исправить проблемную строку 76 напрямую
sed -i '' '76s/.*/      } else {/' src/components/SmartCodeEditor.tsx

# Добавить безопасную проверку после строки 76
sed -i '' '77i\
        const foldedRange = foldingRanges.find(r => r.isFolded && r.startLine + 1 === index);\
        if (foldedRange) {\
          visibleLines.push("    ... \/\/ collapsed block");\
        }\
      }\
    });\
\
    return visibleLines;\
  };\
\
  const getVisibleLines = () => {\
    const visibleLines: string[] = [];\
    const lineStates: boolean[] = new Array(lines.length).fill(true);\
\
    \/\/ Отмечаем скрытые строки\
    foldingRanges.forEach(range => {\
      if (range.isFolded) {\
        for (let i = range.startLine + 1; i <= range.endLine; i++) {\
          lineStates[i] = false;\
        }\
      }\
    });\
\
    \/\/ Собираем видимые строки - ИСПРАВЛЕНА ПРОБЛЕМА\
    lines.forEach((line, index) => {\
      if (lineStates[index]) {\
        visibleLines.push(line);' src/components/SmartCodeEditor.tsx

echo "✅ Строка 76 исправлена"

# Альтернативный способ - полная замена файла
cat > src/components/SmartCodeEditor.tsx << 'EOF'
import { useState, useRef, useEffect } from 'react';
import { ChevronDown, ChevronRight } from 'lucide-react';

interface SmartCodeEditorProps {
  content: string;
  onChange: (content: string) => void;
  language?: string;
}

interface FoldingRange {
  startLine: number;
  endLine: number;
  isFolded: boolean;
}

export function SmartCodeEditor({ content, onChange, language }: SmartCodeEditorProps) {
  const [foldingRanges, setFoldingRanges] = useState<FoldingRange[]>([]);
  const textareaRef = useRef<HTMLTextAreaElement>(null);
  const lines = content.split('\n');

  // Определяем блоки для сворачивания
  useEffect(() => {
    const ranges: FoldingRange[] = [];
    let braceStack: number[] = [];

    lines.forEach((line, index) => {
      const trimmed = line.trim();
      
      // Обнаружение начала блока
      if (trimmed.includes('{') || trimmed.includes('function') || trimmed.includes('if') || 
          trimmed.includes('for') || trimmed.includes('while') || trimmed.includes('class')) {
        braceStack.push(index);
      }
      
      // Обнаружение конца блока
      if (trimmed.includes('}') && braceStack.length > 0) {
        const startLine = braceStack.pop()!;
        if (index - startLine > 1) {
          ranges.push({
            startLine,
            endLine: index,
            isFolded: false
          });
        }
      }
    });

    setFoldingRanges(ranges);
  }, [content, lines]);

  const toggleFold = (rangeIndex: number) => {
    setFoldingRanges(prev => 
      prev.map((range, index) => 
        index === rangeIndex ? { ...range, isFolded: !range.isFolded } : range
      )
    );
  };

  const getVisibleLines = () => {
    const visibleLines: string[] = [];
    const lineStates: boolean[] = new Array(lines.length).fill(true);

    // Отмечаем скрытые строки
    foldingRanges.forEach(range => {
      if (range.isFolded) {
        for (let i = range.startLine + 1; i <= range.endLine; i++) {
          lineStates[i] = false;
        }
      }
    });

    // Собираем видимые строки - ИСПРАВЛЕННАЯ ВЕРСИЯ
    lines.forEach((line, index) => {
      if (lineStates[index]) {
        visibleLines.push(line);
      } else {
        // Безопасная проверка на undefined
        const foldedRange = foldingRanges.find(r => r.isFolded && r.startLine + 1 === index);
        if (foldedRange) {
          visibleLines.push('    ... // collapsed block');
        }
      }
    });

    return visibleLines;
  };

  const renderLineNumbers = () => {
    const visibleLines = getVisibleLines();
    
    return (
      <div className="w-12 bg-gray-800 border-r border-gray-700 text-right pr-2 py-2 text-xs text-gray-500 font-mono select-none">
        {visibleLines.map((_, index) => {
          const actualLineNumber = index + 1;
          const foldingRange = foldingRanges.find(r => r.startLine === index);
          
          return (
            <div 
              key={index}
              className="flex items-center justify-end h-5 relative hover:bg-gray-700"
            >
              <span className="mr-1">{actualLineNumber}</span>
              
              {foldingRange && (
                <button
                  onClick={() => toggleFold(foldingRanges.indexOf(foldingRange))}
                  className="absolute left-1 w-3 h-3 flex items-center justify-center hover:bg-gray-600 rounded"
                  title={foldingRange.isFolded ? "Expand" : "Collapse"}
                >
                  {foldingRange.isFolded ? 
                    <ChevronRight size={8} className="text-gray-400" /> : 
                    <ChevronDown size={8} className="text-gray-400" />
                  }
                </button>
              )}
            </div>
          );
        })}
      </div>
    );
  };

  return (
    <div className="flex h-full bg-gray-900">
      {/* Line Numbers with Folding Controls */}
      {renderLineNumbers()}
      
      {/* Code Editor */}
      <div className="flex-1 relative">
        <textarea
          ref={textareaRef}
          value={content}
          onChange={(e) => onChange(e.target.value)}
          className="w-full h-full p-2 bg-gray-900 text-white font-mono text-sm resize-none outline-none leading-5"
          placeholder="Start typing your code..."
          spellCheck={false}
          style={{ lineHeight: '20px' }}
        />
        
        {/* Language indicator */}
        {language && (
          <div className="absolute bottom-2 right-2 px-2 py-1 bg-gray-800 rounded text-xs text-gray-400">
            {language.toUpperCase()}
          </div>
        )}
      </div>
    </div>
  );
}
EOF

echo "✅ SmartCodeEditor.tsx полностью перезаписан"

# Проверить сборку
echo "🧪 Тестируем исправленный код..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Сборка успешна!"
else
    echo "❌ Все еще есть ошибки"
fi