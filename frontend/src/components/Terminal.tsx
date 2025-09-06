import { VSCodeTerminal } from './VSCodeTerminal';

interface TerminalProps {
  isVisible?: boolean;
  height?: number;
}

export function Terminal({ isVisible = true, height = 200 }: TerminalProps) {
  return <VSCodeTerminal isVisible={isVisible} height={height} />;
}
