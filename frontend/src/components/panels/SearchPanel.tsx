import React, { useState, useEffect, useCallback } from 'react';
import { Search, X, ChevronDown, ChevronRight, File, Replace, ArrowUpDown } from 'lucide-react';
import type { FileItem } from '../../types';

interface SearchResult {
  fileId: string;
  fileName: string;
  filePath: string;
  matches: {
    line: number;
    content: string;
    startIndex: number;
    endIndex: number;
  }[];
}

interface SearchPanelProps {
  files: FileItem[];
  onFileSelect: (file: FileItem) => void;
  onClose: () => void;
}

export const SearchPanel: React.FC<SearchPanelProps> = ({
  files,
  onFileSelect,
  onClose
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [replaceQuery, setReplaceQuery] = useState('');
  const [showReplace, setShowReplace] = useState(false);
  const [matchCase, setMatchCase] = useState(false);
  const [wholeWord, setWholeWord] = useState(false);
  const [useRegex, setUseRegex] = useState(false);
  const [results, setResults] = useState<SearchResult[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [expandedFiles, setExpandedFiles] = useState<Set<string>>(new Set());

  // Функция для поиска в файлах
  const searchInFiles = useCallback((query: string) => {
    if (!query.trim()) {
      setResults([]);
      return;
    }

    setIsSearching(true);
    const searchResults: SearchResult[] = [];

    const searchInFileTree = (fileItems: FileItem[], path = '') => {
      fileItems.forEach(file => {
        if (file.type === 'file' && file.content) {
          const filePath = path ? `${path}/${file.name}` : file.name;
          const matches = searchInContent(file.content, query);
          
          if (matches.length > 0) {
            searchResults.push({
              fileId: file.id,
              fileName: file.name,
              filePath,
              matches
            });
          }
        } else if (file.type === 'folder' && file.children) {
          const folderPath = path ? `${path}/${file.name}` : file.name;
          searchInFileTree(file.children, folderPath);
        }
      });
    };

    searchInFileTree(files);
    setResults(searchResults);
    setIsSearching(false);
  }, [files, matchCase, wholeWord, useRegex]);

  // Функция поиска в содержимом файла
  const searchInContent = (content: string, query: string) => {
    const lines = content.split('\n');
    const matches: SearchResult['matches'] = [];
    
    let searchFlags = 'g';
    if (!matchCase) searchFlags += 'i';
    
    let pattern = query;
    if (!useRegex) {
      pattern = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }
    if (wholeWord) {
      pattern = `\\b${pattern}\\b`;
    }

    try {
      const regex = new RegExp(pattern, searchFlags);
      
      lines.forEach((line, lineIndex) => {
        let match;
        while ((match = regex.exec(line)) !== null) {
          matches.push({
            line: lineIndex + 1,
            content: line,
            startIndex: match.index,
            endIndex: match.index + match[0].length
          });
          
          if (match.index === regex.lastIndex) {
            regex.lastIndex++;
          }
        }
      });
    } catch (error) {
      console.warn('Invalid regex pattern:', error);
    }

    return matches;
  };

  // Debounced search
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      searchInFiles(searchQuery);
    }, 300);

    return () => clearTimeout(timeoutId);
  }, [searchQuery, searchInFiles]);

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.ctrlKey && e.shiftKey && e.key === 'F') {
        e.preventDefault();
        const input = document.querySelector('#search-input') as HTMLInputElement;
        input?.focus();
      }
      if (e.key === 'Escape') {
        onClose();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onClose]);

  const toggleFileExpansion = (fileId: string) => {
    setExpandedFiles(prev => {
      const newSet = new Set(prev);
      if (newSet.has(fileId)) {
        newSet.delete(fileId);
      } else {
        newSet.add(fileId);
      }
      return newSet;
    });
  };

  const handleMatchClick = (result: SearchResult, match: SearchResult['matches'][0]) => {
    const findFile = (items: FileItem[]): FileItem | null => {
      for (const item of items) {
        if (item.id === result.fileId) return item;
        if (item.children) {
          const found = findFile(item.children);
          if (found) return found;
        }
      }
      return null;
    };

    const file = findFile(files);
    if (file) {
      onFileSelect(file);
    }
  };

  const totalMatches = results.reduce((sum, result) => sum + result.matches.length, 0);

  return (
    <div className="h-full bg-gray-900 text-gray-200 flex flex-col">
      {/* Header */}
      <div className="p-3 border-b border-gray-700">
        <div className="flex items-center justify-between mb-2">
          <h3 className="text-sm font-medium text-gray-300">SEARCH</h3>
          <button
            onClick={onClose}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
          >
            <X size={14} />
          </button>
        </div>

        {/* Search Input */}
        <div className="space-y-2">
          <div className="relative">
            <Search size={14} className="absolute left-2 top-2 text-gray-400" />
            <input
              id="search-input"
              type="text"
              placeholder="Search..."
              className="w-full bg-gray-800 text-gray-200 text-xs rounded px-7 py-1.5 
                         border border-gray-600 focus:border-blue-500 focus:outline-none"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              autoFocus
            />
          </div>

          {/* Replace Input */}
          {showReplace && (
            <div className="relative">
              <Replace size={14} className="absolute left-2 top-2 text-gray-400" />
              <input
                type="text"
                placeholder="Replace..."
                className="w-full bg-gray-800 text-gray-200 text-xs rounded px-7 py-1.5 
                           border border-gray-600 focus:border-blue-500 focus:outline-none"
                value={replaceQuery}
                onChange={(e) => setReplaceQuery(e.target.value)}
              />
            </div>
          )}

          {/* Search Options */}
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-1">
              <button
                onClick={() => setMatchCase(!matchCase)}
                className={`p-1 text-xs rounded ${matchCase ? 'bg-blue-600 text-white' : 'text-gray-400 hover:bg-gray-700'}`}
                title="Match Case"
              >
                Aa
              </button>
              <button
                onClick={() => setWholeWord(!wholeWord)}
                className={`p-1 text-xs rounded ${wholeWord ? 'bg-blue-600 text-white' : 'text-gray-400 hover:bg-gray-700'}`}
                title="Match Whole Word"
              >
                Ab
              </button>
              <button
                onClick={() => setUseRegex(!useRegex)}
                className={`p-1 text-xs rounded ${useRegex ? 'bg-blue-600 text-white' : 'text-gray-400 hover:bg-gray-700'}`}
                title="Use Regular Expression"
              >
                .*
              </button>
            </div>
            <button
              onClick={() => setShowReplace(!showReplace)}
              className="p-1 text-gray-400 hover:text-white hover:bg-gray-700 rounded"
              title="Toggle Replace"
            >
              <ArrowUpDown size={14} />
            </button>
          </div>
        </div>

        {/* Results Summary */}
        {searchQuery && (
          <div className="mt-2 text-xs text-gray-400">
            {isSearching ? (
              'Searching...'
            ) : (
              `${totalMatches} results in ${results.length} files`
            )}
          </div>
        )}
      </div>

      {/* Results */}
      <div className="flex-1 overflow-y-auto">
        {results.map((result) => {
          const isExpanded = expandedFiles.has(result.fileId);
          
          return (
            <div key={result.fileId} className="border-b border-gray-800">
              {/* File Header */}
              <div
                className="flex items-center px-3 py-2 hover:bg-gray-800 cursor-pointer"
                onClick={() => toggleFileExpansion(result.fileId)}
              >
                <div className="mr-1">
                  {isExpanded ? <ChevronDown size={14} /> : <ChevronRight size={14} />}
                </div>
                <File size={14} className="mr-2 text-blue-400" />
                <span className="text-sm flex-1">{result.fileName}</span>
                <span className="text-xs text-gray-400">{result.matches.length}</span>
              </div>

              {/* Matches */}
              {isExpanded && (
                <div className="bg-gray-800">
                  {result.matches.map((match, index) => (
                    <div
                      key={index}
                      className="px-8 py-1 hover:bg-gray-700 cursor-pointer text-xs"
                      onClick={() => handleMatchClick(result, match)}
                    >
                      <div className="flex items-center">
                        <span className="text-gray-400 mr-2 w-8">{match.line}</span>
                        <span className="font-mono">
                          {match.content.substring(0, match.startIndex)}
                          <span className="bg-yellow-600 text-black">
                            {match.content.substring(match.startIndex, match.endIndex)}
                          </span>
                          {match.content.substring(match.endIndex)}
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          );
        })}

        {/* No Results */}
        {searchQuery && !isSearching && results.length === 0 && (
          <div className="p-4 text-center text-gray-500">
            <Search className="mx-auto mb-2 opacity-50" size={32} />
            <p className="text-sm">No results found</p>
            <p className="text-xs mt-1">Try different search terms</p>
          </div>
        )}

        {/* Empty State */}
        {!searchQuery && (
          <div className="p-4 text-center text-gray-500">
            <Search className="mx-auto mb-2 opacity-50" size={32} />
            <p className="text-sm">Search across files</p>
            <div className="text-xs mt-2 space-y-1">
              <p>• Use Ctrl+Shift+F to open search</p>
              <p>• Toggle search options with buttons</p>
              <p>• Click results to jump to file</p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
