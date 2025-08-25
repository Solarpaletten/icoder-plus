// iCoderBottomSheet.jsx
import { useState } from "react";

// Моковые данные для примера
const files = [
  { name: "src/App.js", oldCode: "function oldFunction() {}", newCode: "function newFunction() {}" },
  { name: "src/utils/helpers.js", oldCode: "export const add = (a,b)=>a+b;", newCode: "export const sum = (a,b)=>a+b;" }
];

export default function iCoderBottomSheet() {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedFile, setSelectedFile] = useState(null);

  // Функция для показа diff
  const renderDiff = (oldCode, newCode) => {
    return (
      <div className="bg-gray-800 rounded p-3 font-mono text-sm">
        <p className="text-red-400">- {oldCode}</p>
        <p className="text-green-400">+ {newCode}</p>
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
          isOpen ? "h-[70vh]" : "h-[10vh]"
        } overflow-y-auto`}
      >
        <div className="p-4 space-y-4">
          <h2 className="text-lg font-bold">📂 File Changes</h2>

          {/* Список файлов */}
          <ul className="space-y-2">
            {files.map((f, idx) => (
              <li
                key={idx}
                className={`p-2 rounded cursor-pointer ${
                  selectedFile === f ? "bg-blue-700" : "bg-gray-700 hover:bg-gray-600"
                }`}
                onClick={() => setSelectedFile(f)}
              >
                {f.name}
              </li>
            ))}
          </ul>

          {/* Diff по выбранному файлу */}
          {selectedFile && (
            <>
              <h3 className="text-md font-semibold mt-4">🔍 Diff: {selectedFile.name}</h3>
              {renderDiff(selectedFile.oldCode, selectedFile.newCode)}

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
