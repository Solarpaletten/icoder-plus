import { useState, useRef } from 'react';
import { Upload, FolderPlus, FileText, Folder } from 'lucide-react';

interface FileUploaderProps {
  onFileUpload: (files: File[]) => void;
  onFolderUpload: (folder: FileList) => void;
}

/**
 * FileUploader - отдельный компонент
 * Не затирается при обновлениях App.tsx
 * Подключается через импорт
 */
export function FileUploader({ onFileUpload, onFolderUpload }: FileUploaderProps) {
  const [isDragging, setIsDragging] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const folderInputRef = useRef<HTMLInputElement>(null);

  const handleDrag = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
  };

  const handleDragIn = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(true);
  };

  const handleDragOut = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);

    const files = Array.from(e.dataTransfer.files);
    if (files.length > 0) {
      onFileUpload(files);
    }
  };

  return (
    <div className="p-3 border-b border-gray-700">
      {/* Quick Actions */}
      <div className="flex items-center justify-between mb-3">
        <span className="text-xs font-semibold text-gray-300 uppercase">Quick Actions</span>
        <div className="flex space-x-1">
          <button
            onClick={() => fileInputRef.current?.click()}
            className="p-1.5 bg-blue-600 hover:bg-blue-500 rounded text-white"
            title="Upload Files"
          >
            <FileText size={12} />
          </button>
          <button
            onClick={() => folderInputRef.current?.click()}
            className="p-1.5 bg-green-600 hover:bg-green-500 rounded text-white"
            title="Upload Folder"
          >
            <FolderPlus size={12} />
          </button>
        </div>
      </div>

      {/* Drop Zone */}
      <div
        className={`border-2 border-dashed rounded-lg p-4 text-center transition-colors ${
          isDragging
            ? 'border-blue-500 bg-blue-500/10'
            : 'border-gray-600 hover:border-gray-500'
        }`}
        onDragEnter={handleDragIn}
        onDragLeave={handleDragOut}
        onDragOver={handleDrag}
        onDrop={handleDrop}
      >
        <Upload size={24} className="mx-auto mb-2 text-gray-400" />
        <p className="text-xs text-gray-400">
          Drop files here or click upload
        </p>
      </div>

      {/* Hidden Inputs */}
      <input
        ref={fileInputRef}
        type="file"
        multiple
        className="hidden"
        onChange={(e) => {
          const files = Array.from(e.target.files || []);
          if (files.length > 0) onFileUpload(files);
        }}
      />
      <input
        ref={folderInputRef}
        type="file"
        // @ts-ignore
        webkitdirectory=""
        className="hidden"
        onChange={(e) => {
          const files = e.target.files;
          if (files) onFolderUpload(files);
        }}
      />
    </div>
  );
}
