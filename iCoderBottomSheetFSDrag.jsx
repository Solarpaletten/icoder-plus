// iCoderBottomSheetFSDrag.jsx
import { useState } from "react";

export default function iCoderBottomSheetFSDrag() {
  const [isOpen, setIsOpen] = useState(false);
  const [files, setFiles] = useState([]);
  const [selectedFile, setSelectedFile] = useState(null);
  const [diff, setDiff] = useState(null);

  // Открыть папку и прочитать файлы
  const openFolder = async () => {
    try {
      const dirHandle = await window.showDirectoryPicker();
      const newFiles = [];
      for await (const [name, handle] of dirHandle.entries()) {
        if (handle.kind === "file") {
          const file = await handle.getFile();
          const text = await file.text();
          newFiles.push({ name, content: text });
        }
      }
      setFiles(newFiles);
    } catch (e) {
      console.error("Folder open canceled", e);
    }
  };

  // Сравнение простое (в будущем можно подключить diff-алгоритм)
  const compare = (oldText, newText) => {
    if (oldText === newText) {
      return <p className="text-gray-400">No changes detected ✅</p>;
    }
    return (
      <div className="bg-gray-800 rounded p-3 font-mono text-sm">
        <p className="text-red-400">- {oldText.slice(0, 100)}...</p>
        <p className="text-green-400">+ {newText.slice(0, 100)}...</p>
      </div>
    );
  };

  // Drag&Drop загрузка файла
  const handleDrop = async (event) => {
    event.preventDefault();
    const file = event.dataTransfer.files[0];
    if (file) {
      const text = await file.text();
      // Поиск соответствующего файла по имени
      const oldFile = files.find((f) => f.name === file.name);
      if (oldFile) {
        setSelectedFile(file.name);
        setDiff(compare(oldFile.content, text));
      } else {
        setDiff(
          <p className="text-yellow-400">⚠️ Новый файл {file.name}, ранее не существовал.</p>
        );
      }
    }
  };

  return (
    <div className="fixed inset-x-0 bottom-0">
      {/* Хедер-ручка */}
      <div
        className="flex justify-center p-2 bg-gray-800 cursor-pointer"
        onClick={() => setIsOpen(!isOpen)}
      >
        <div className="w-12 h-1.5 rounded bg-gray-400"></div>
      </div>

      {/* Контент */}
      <div
        className={`bg-gray-900 text-white transition-all duration-300 ${
          isOpen ? "h-[70vh]" : "h-[12vh]"
        } overflow-y-auto`}
        onDragOver={(e) => e.preventDefault()}
        onDrop={handleDrop}
      >
        <div className="p-4 space-y-4">
          <h2 className="text-lg font-bold">📂 iCoder Plus – File Changes</h2>

          <button
            onClick={openFolder}
            className="bg-blue-600 px-4 py-2 rounded hover:bg-blue-700"
          >
            Open Project Folder
          </button>

          {/* Список файлов */}
          <ul className="space-y-2">
            {files.map((f, idx) => (
              <li
                key={idx}
                className={`p-2 rounded cursor-pointer ${
                  selectedFile === f.name ? "bg-blue-700" : "bg-gray-700 hover:bg-gray-600"
                }`}
                onClick={() => {
                  setSelectedFile(f.name);
                  setDiff(compare("// old placeholder", f.content));
                }}
              >
                {f.name}
              </li>
            ))}
          </ul>

          {/* Diff */}
          {diff && (
            <div className="mt-4">
              <h3 className="text-md font-semibold">🔍 Diff Result</h3>
              {diff}
            </div>
          )}

          <p className="text-gray-400 text-sm italic mt-3">
            💡 Tip: You can drag & drop a file here to compare it with the project version.
          </p>
        </div>
      </div>
    </div>
  );
}
