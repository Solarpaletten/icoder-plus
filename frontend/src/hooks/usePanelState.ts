import { useState, useCallback } from 'react';

interface PanelState {
  leftWidth: number;
  rightWidth: number;
  bottomHeight: number;
  isLeftCollapsed: boolean;
  isRightCollapsed: boolean;
  isBottomCollapsed: boolean;
  isStatusCollapsed: boolean;
}

export function usePanelState() {
  const [panelState, setPanelState] = useState<PanelState>({
    leftWidth: 280,
    rightWidth: 350,
    bottomHeight: 200,
    isLeftCollapsed: false,
    isRightCollapsed: false,
    isBottomCollapsed: false,
    isStatusCollapsed: false,
  });

  const toggleLeft = useCallback(() => {
    setPanelState(prev => ({ ...prev, isLeftCollapsed: !prev.isLeftCollapsed }));
  }, []);

  const toggleRight = useCallback(() => {
    setPanelState(prev => ({ ...prev, isRightCollapsed: !prev.isRightCollapsed }));
  }, []);

  const toggleBottom = useCallback(() => {
    setPanelState(prev => ({ ...prev, isBottomCollapsed: !prev.isBottomCollapsed }));
  }, []);

  const toggleStatus = useCallback(() => {
    setPanelState(prev => ({ ...prev, isStatusCollapsed: !prev.isStatusCollapsed }));
  }, []);

  const setBottomHeight = useCallback((height: number) => {
    setPanelState(prev => ({ ...prev, bottomHeight: Math.max(80, Math.min(400, height)) }));
  }, []);

  const setLeftWidth = useCallback((width: number) => {
    setPanelState(prev => ({ ...prev, leftWidth: Math.max(200, Math.min(500, width)) }));
  }, []);

  const setRightWidth = useCallback((width: number) => {
    setPanelState(prev => ({ ...prev, rightWidth: Math.max(250, Math.min(500, width)) }));
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
  };
}
