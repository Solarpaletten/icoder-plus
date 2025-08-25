// BottomSheet.jsx
import { useState } from "react";

export default function BottomSheet() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="fixed inset-x-0 bottom-0">
      {/* Заголовок с "ручкой" для растягивания */}
      <div
        className="flex justify-center p-2 bg-gray-800 cursor-pointer"
        onClick={() => setIsOpen(!isOpen)}
      >
        <div className="w-12 h-1.5 rounded bg-gray-400"></div>
      </div>

      {/* Контент внутри экранчика */}
      <div
        className={`bg-gray-900 text-white transition-all duration-300 ${
          isOpen ? "h-[60vh]" : "h-[10vh]"
        } overflow-y-auto`}
      >
        <div className="p-4 space-y-4">
          <h2 className="text-lg font-bold">📂 File Changes</h2>

          {/* Пример блока с diff */}
          <div className="bg-gray-800 rounded p-3 font-mono text-sm">
            <p className="text-red-400">- oldFunction()</p>
            <p className="text-green-400">+ newFunction()</p>
          </div>

          {/* Кнопки управления */}
          <div className="flex space-x-3">
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
        </div>
      </div>
    </div>
  );
}
