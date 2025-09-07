import React, { useState, useEffect } from 'react';
import { Package, Download, Star, Settings, Search, Filter, X, Check, AlertCircle } from 'lucide-react';
import type { FileItem } from '../../types';

interface Extension {
  id: string;
  name: string;
  displayName: string;
  description: string;
  version: string;
  author: string;
  downloads: number;
  rating: number;
  installed: boolean;
  enabled: boolean;
  category: 'theme' | 'language' | 'formatter' | 'snippet' | 'debugger' | 'other';
  icon: string;
}

interface ExtensionsPanelProps {
  onClose: () => void;
}

export const ExtensionsPanel: React.FC<ExtensionsPanelProps> = ({ onClose }) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [extensions, setExtensions] = useState<Extension[]>([]);
  const [installingIds, setInstallingIds] = useState<Set<string>>(new Set());
  const [view, setView] = useState<'marketplace' | 'installed'>('marketplace');

  // Mock extensions data
  useEffect(() => {
    const mockExtensions: Extension[] = [
      {
        id: 'prettier',
        name: 'prettier',
        displayName: 'Prettier - Code formatter',
        description: 'Code formatter using prettier',
        version: '9.10.4',
        author: 'Prettier',
        downloads: 25000000,
        rating: 4.8,
        installed: true,
        enabled: true,
        category: 'formatter',
        icon: '🎨'
      },
      {
        id: 'python',
        name: 'python',
        displayName: 'Python',
        description: 'IntelliSense, linting, debugging for Python',
        version: '2023.20.0',
        author: 'Microsoft',
        downloads: 100000000,
        rating: 4.6,
        installed: false,
        enabled: false,
        category: 'language',
        icon: '🐍'
      },
      {
        id: 'eslint',
        name: 'eslint',
        displayName: 'ESLint',
        description: 'Integrates ESLint JavaScript into VS Code',
        version: '2.4.2',
        author: 'Microsoft',
        downloads: 30000000,
        rating: 4.4,
        installed: true,
        enabled: false,
        category: 'other',
        icon: '🔍'
      },
      {
        id: 'material-theme',
        name: 'material-theme',
        displayName: 'Material Theme',
        description: 'The most epic theme now for VS Code',
        version: '34.1.0',
        author: 'Equinusocio',
        downloads: 4500000,
        rating: 4.7,
        installed: false,
        enabled: false,
        category: 'theme',
        icon: '🎭'
      },
      {
        id: 'gitlens',
        name: 'gitlens',
        displayName: 'GitLens — Git supercharged',
        description: 'Supercharge Git within VS Code',
        version: '14.6.0',
        author: 'GitKraken',
        downloads: 20000000,
        rating: 4.5,
        installed: false,
        enabled: false,
        category: 'other',
        icon: '🔧'
      },
      {
        id: 'bracket-pair',
        name: 'bracket-pair-colorizer',
        displayName: 'Bracket Pair Colorizer',
        description: 'Colorize matching brackets',
        version: '1.0.61',
        author: 'CoenraadS',
        downloads: 8000000,
        rating: 4.3,
        installed: true,
        enabled: true,
        category: 'other',
        icon: '🌈'
      }
    ];
    
    setExtensions(mockExtensions);
  }, []);

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.ctrlKey && e.shiftKey && e.key === 'X') {
        e.preventDefault();
        const input = document.querySelector('#extensions-search') as HTMLInputElement;
        input?.focus();
      }
      if (e.key === 'Escape') {
        onClose();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [onClose]);

  const categories = [
    { id: 'all', name: 'All' },
    { id: 'theme', name: 'Themes' },
    { id: 'language', name: 'Languages' },
    { id: 'formatter', name: 'Formatters' },
    { id: 'snippet', name: 'Snippets' },
    { id: 'debugger', name: 'Debuggers' },
    { id: 'other', name: 'Other' }
  ];

  const filteredExtensions = extensions.filter(ext => {
    const matchesSearch = ext.displayName.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         ext.description.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesCategory = selectedCategory === 'all' || ext.category === selectedCategory;
    const matchesView = view === 'marketplace' ? true : ext.installed;
    
    return matchesSearch && matchesCategory && matchesView;
  });

  const installExtension = async (extensionId: string) => {
    setInstallingIds(prev => new Set(prev).add(extensionId));
    
    // Simulate installation
    setTimeout(() => {
      setExtensions(prev => prev.map(ext => 
        ext.id === extensionId 
          ? { ...ext, installed: true, enabled: true }
          : ext
      ));
      setInstallingIds(prev => {
        const newSet = new Set(prev);
        newSet.delete(extensionId);
        return newSet;
      });
    }, 2000);
  };

  const uninstallExtension = (extensionId: string) => {
    setExtensions(prev => prev.map(ext => 
      ext.id === extensionId 
        ? { ...ext, installed: false, enabled: false }
        : ext
    ));
  };

  const toggleExtension = (extensionId: string) => {
    setExtensions(prev => prev.map(ext => 
      ext.id === extensionId 
        ? { ...ext, enabled: !ext.enabled }
        : ext
    ));
  };

  const formatDownloads = (downloads: number) => {
    if (downloads >= 1000000) {
      return `${(downloads / 1000000).toFixed(1)}M`;
    } else if (downloads >= 1000) {
      return `${(downloads / 1000).toFixed(0)}K`;
    }
    return downloads.toString();
  };

  const installedCount = extensions.filter(ext => ext.installed).length;
  const enabledCount = extensions.filter(ext => ext.enabled).length;

  return (
    <div className="h-full bg-gray-900 text-gray-200 flex flex-col">
      {/* Header */}
      <div className="p-3 border-b border-gray-700">
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-sm font-medium text-gray-300">EXTENSIONS</h3>
          <button
            onClick={onClose}
            className="p-1 hover:bg-gray-700 rounded text-gray-400 hover:text-white"
          >
            <X size={14} />
          </button>
        </div>

        {/* View Toggle */}
        <div className="flex mb-3 bg-gray-800 rounded text-xs">
          <button
            onClick={() => setView('marketplace')}
            className={`flex-1 px-3 py-2 rounded-l ${
              view === 'marketplace' 
                ? 'bg-blue-600 text-white' 
                : 'text-gray-400 hover:text-white'
            }`}
          >
            Marketplace
          </button>
          <button
            onClick={() => setView('installed')}
            className={`flex-1 px-3 py-2 rounded-r ${
              view === 'installed' 
                ? 'bg-blue-600 text-white' 
                : 'text-gray-400 hover:text-white'
            }`}
          >
            Installed ({installedCount})
          </button>
        </div>

        {/* Search */}
        <div className="relative mb-3">
          <Search size={14} className="absolute left-2 top-2 text-gray-400" />
          <input
            id="extensions-search"
            type="text"
            placeholder="Search extensions..."
            className="w-full bg-gray-800 text-gray-200 text-xs rounded px-7 py-1.5 
                       border border-gray-600 focus:border-blue-500 focus:outline-none"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>

        {/* Category Filter */}
        <div className="flex items-center gap-1 mb-2">
          <Filter size={12} className="text-gray-400" />
          <select
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className="bg-gray-800 text-gray-200 text-xs border border-gray-600 rounded px-2 py-1"
          >
            {categories.map(category => (
              <option key={category.id} value={category.id}>
                {category.name}
              </option>
            ))}
          </select>
        </div>

        {/* Stats */}
        <div className="text-xs text-gray-400">
          {filteredExtensions.length} extensions • {enabledCount} enabled
        </div>
      </div>

      {/* Extensions List */}
      <div className="flex-1 overflow-y-auto">
        {filteredExtensions.map((extension) => {
          const isInstalling = installingIds.has(extension.id);
          
          return (
            <div key={extension.id} className="border-b border-gray-800 p-3 hover:bg-gray-800">
              <div className="flex items-start gap-3">
                {/* Icon */}
                <div className="w-12 h-12 bg-gray-700 rounded flex items-center justify-center text-xl flex-shrink-0">
                  {extension.icon}
                </div>
                
                {/* Content */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between mb-1">
                    <h4 className="text-sm font-medium text-gray-200 truncate">
                      {extension.displayName}
                    </h4>
                    <div className="flex items-center gap-1 flex-shrink-0">
                      {extension.installed && (
                        <button
                          onClick={() => toggleExtension(extension.id)}
                          className={`p-1 rounded ${
                            extension.enabled 
                              ? 'text-green-400 hover:bg-gray-700' 
                              : 'text-gray-400 hover:bg-gray-700'
                          }`}
                          title={extension.enabled ? 'Disable' : 'Enable'}
                        >
                          {extension.enabled ? <Check size={12} /> : <AlertCircle size={12} />}
                        </button>
                      )}
                      <button
                        className="p-1 text-gray-400 hover:text-white hover:bg-gray-700 rounded"
                        title="Settings"
                      >
                        <Settings size={12} />
                      </button>
                    </div>
                  </div>
                  
                  <p className="text-xs text-gray-400 mb-2 line-clamp-2">
                    {extension.description}
                  </p>
                  
                  <div className="flex items-center justify-between text-xs text-gray-500">
                    <div className="flex items-center gap-3">
                      <span>{extension.author}</span>
                      <div className="flex items-center gap-1">
                        <Download size={10} />
                        {formatDownloads(extension.downloads)}
                      </div>
                      <div className="flex items-center gap-1">
                        <Star size={10} />
                        {extension.rating}
                      </div>
                    </div>
                    <span>v{extension.version}</span>
                  </div>
                </div>
              </div>
              
              {/* Actions */}
              <div className="mt-3 flex items-center justify-end gap-2">
                {extension.installed ? (
                  <button
                    onClick={() => uninstallExtension(extension.id)}
                    className="px-3 py-1 bg-red-600 text-white text-xs rounded hover:bg-red-700 transition-colors"
                  >
                    Uninstall
                  </button>
                ) : (
                  <button
                    onClick={() => installExtension(extension.id)}
                    disabled={isInstalling}
                    className="px-3 py-1 bg-blue-600 text-white text-xs rounded hover:bg-blue-700 transition-colors disabled:bg-gray-600 disabled:opacity-50 flex items-center gap-1"
                  >
                    {isInstalling ? (
                      <>
                        <div className="w-3 h-3 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                        Installing...
                      </>
                    ) : (
                      <>
                        <Download size={12} />
                        Install
                      </>
                    )}
                  </button>
                )}
              </div>
            </div>
          );
        })}

        {/* No Results */}
        {filteredExtensions.length === 0 && (
          <div className="p-4 text-center text-gray-500">
            <Package className="mx-auto mb-2 opacity-50" size={32} />
            <p className="text-sm">No extensions found</p>
            <p className="text-xs mt-1">Try different search terms or category</p>
          </div>
        )}
      </div>
    </div>
  );
};
