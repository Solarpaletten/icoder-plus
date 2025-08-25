// iCoderBottomSheetFS.jsx
import { useState } from "react";

export default function iCoderBottomSheetFS() {
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

  // Сравнение старого и нового содержимого (простая версия)
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
                  selectedFile === f ? "bg-blue-700" : "bg-gray-700 hover:bg-gray-600"
                }`}
                onClick={() => {
                  setSelectedFile(f);
                  // пример: сравнение с "старым кодом"
                  setDiff(compare("// old placeholder", f.content));
                }}
              >
                {f.name}
              </li>
            ))}
          </ul>

          {/* Diff по выбранному файлу */}
          {selectedFile && (
            <>
              <h3 className="text-md font-semibold mt-4">🔍 Diff: {selectedFile.name}</h3>
              {diff}

              {/* Кнопки */}
              <div className="flex space-x-3 mt-3">
                <button className="bg-green-600 px-4 py-2 rounded hover:bg-green-700">
                  Apply
                </button>
                <button className="bg-yellow-600 px-4 py-2 rounded hover:bg-yellow-700">
                  Save for Later
                </button>
                <button className="bg-red-600 px-4 py-2 rounded hover:bg-red-700">
                  Revert
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
