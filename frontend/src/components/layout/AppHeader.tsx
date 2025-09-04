import { useState } from 'react';
import { Menu, X, FolderOpen, Settings, HelpCircle } from 'lucide-react';

export function AppHeader() {
  const [activeMenu, setActiveMenu] = useState<string | null>(null);

  const menus = {
    File: ['New File', 'New Folder', 'Open File', 'Save', 'Save All', 'Close'],
    Edit: ['Undo', 'Redo', 'Cut', 'Copy', 'Paste', 'Find', 'Replace'],
    View: ['Explorer', 'Terminal', 'AI Assistant', 'Command Palette'],
    Help: ['Documentation', 'Shortcuts', 'About']
  };

  return (
    <div className="h-8 bg-gray-800 border-b border-gray-700 flex items-center px-4 text-xs">
      {/* Logo */}
      <div className="flex items-center mr-6">
        <span className="font-semibold text-blue-400">iCoder Plus v2.2</span>
        <span className="ml-2 text-gray-500 text-xs">IDE Shell</span>
      </div>
      
      {/* Menu Items */}
      <div className="flex space-x-1">
        {Object.keys(menus).map(menuName => (
          <div key={menuName} className="relative">
            <button
              className={`px-2 py-1 hover:bg-gray-700 rounded text-gray-300 ${
                activeMenu === menuName ? 'bg-gray-700' : ''
              }`}
              onClick={() => setActiveMenu(activeMenu === menuName ? null : menuName)}
            >
              {menuName}
            </button>
            
            {activeMenu === menuName && (
              <div className="absolute top-full left-0 mt-1 bg-gray-700 border border-gray-600 rounded shadow-lg z-50">
                {menus[menuName as keyof typeof menus].map(item => (
                  <button
                    key={item}
                    className="block w-full text-left px-3 py-1 hover:bg-gray-600 text-gray-300 text-xs"
                    onClick={() => setActiveMenu(null)}
                  >
                    {item}
                  </button>
                ))}
              </div>
            )}
          </div>
        ))}
      </div>
      
      {/* Right Side Info */}
      <div className="ml-auto flex items-center space-x-4 text-gray-400">
        <span className="text-xs">Backend: Online</span>
        <span className="text-xs">Branch: main</span>
      </div>
    </div>
  );
}
