import { useState, useEffect, useCallback } from 'react';

interface PanelSizes {
  leftWidth: number;
  rightWidth: number;
  bottomHeight: number;
}

const DEFAULT_SIZES: PanelSizes = {
  leftWidth: 280,   // Увеличил с 256px для комфорта
  rightWidth: 350,  // Увеличил с 320px для AI Assistants
  bottomHeight: 250
};

const STORAGE_KEY = 'icoder-plus-panel-sizes';

export const usePanelResize = () => {
  const [sizes, setSizes] = useState<PanelSizes>(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      return saved ? { ...DEFAULT_SIZES, ...JSON.parse(saved) } : DEFAULT_SIZES;
    } catch {
      return DEFAULT_SIZES;
    }
  });

  // Сохранение в localStorage при изменении
  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(sizes));
    } catch (error) {
      console.warn('Failed to save panel sizes:', error);
    }
  }, [sizes]);

  const updateLeftWidth = useCallback((width: number) => {
    setSizes(prev => ({ ...prev, leftWidth: Math.max(200, Math.min(800, width)) }));
  }, []);

  const updateRightWidth = useCallback((width: number) => {
    setSizes(prev => ({ ...prev, rightWidth: Math.max(250, Math.min(600, width)) }));
  }, []);

  const updateBottomHeight = useCallback((height: number) => {
    setSizes(prev => ({ ...prev, bottomHeight: Math.max(100, Math.min(500, height)) }));
  }, []);

  const resetToDefaults = useCallback(() => {
    setSizes(DEFAULT_SIZES);
  }, []);

  return {
    sizes,
    updateLeftWidth,
    updateRightWidth,
    updateBottomHeight,
    resetToDefaults
  };
};
