import { useState, useCallback } from 'react';

interface PanelState {
  leftWidth: number;
  rightWidth: number;
  bottomHeight: number;
  isLeftCollapsed: boolean;
  isRightCollapsed: boolean;
  isBottomCollapsed: boolean;
  isStatusCollapsed: boolean;
  leftVisible: boolean;
  rightVisible: boolean;
  bottomVisible: boolean;
}

export function usePanelState() {
  const [panelState, setPanelState] = useState<PanelState>({
    leftWidth: 280,
    rightWidth: 350,
    bottomHeight: 250, // Increased default height
    isLeftCollapsed: false,
    isRightCollapsed: false,
    isBottomCollapsed: false,
    isStatusCollapsed: false,
    leftVisible: true,
    rightVisible: true,
    bottomVisible: true,
  });

  const toggleLeft = useCallback(() => {
    setPanelState(prev => ({ 
      ...prev, 
      isLeftCollapsed: !prev.isLeftCollapsed,
      leftVisible: !prev.leftVisible 
    }));
  }, []);

  const toggleRight = useCallback(() => {
    setPanelState(prev => ({ 
      ...prev, 
      isRightCollapsed: !prev.isRightCollapsed,
      rightVisible: !prev.rightVisible 
    }));
  }, []);

  const toggleBottom = useCallback(() => {
    setPanelState(prev => ({ 
      ...prev, 
      isBottomCollapsed: !prev.isBottomCollapsed,
      bottomVisible: !prev.bottomVisible 
    }));
  }, []);

  const toggleStatus = useCallback(() => {
    setPanelState(prev => ({ ...prev, isStatusCollapsed: !prev.isStatusCollapsed }));
  }, []);

  const setBottomHeight = useCallback((height: number) => {
    // VS Code style limits: минимум 80px, максимум вычисляется динамически
    const windowHeight = window.innerHeight;
    const maxHeight = (windowHeight - 150) * 0.95; // 95% от доступной высоты
    const minHeight = 80;
    
    const clampedHeight = Math.max(minHeight, Math.min(maxHeight, height));
    setPanelState(prev => ({ ...prev, bottomHeight: clampedHeight }));
  }, []);

  const setLeftWidth = useCallback((width: number) => {
    setPanelState(prev => ({ ...prev, leftWidth: Math.max(200, Math.min(500, width)) }));
  }, []);

  const setRightWidth = useCallback((width: number) => {
    setPanelState(prev => ({ ...prev, rightWidth: Math.max(250, Math.min(500, width)) }));
  }, []);

  const setBottomVisible = useCallback((visible: boolean) => {
    setPanelState(prev => ({ ...prev, bottomVisible: visible }));
  }, []);

  return {
    ...panelState,
    toggleLeft,
    toggleRight,
    toggleBottom,
    toggleStatus,
    setBottomHeight,
    setLeftWidth,
    setRightWidth,
    setBottomVisible,
  };
}
