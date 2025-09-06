interface TerminalMessage {
  type: 'command' | 'output' | 'error' | 'connect' | 'disconnect';
  data: string;
  timestamp?: number;
}

class TerminalService {
  private ws: WebSocket | null = null;
  private callbacks: Map<string, Function[]> = new Map();
  private isConnected = false;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;

  constructor() {
    this.initializeCallbacks();
  }

  private initializeCallbacks() {
    this.callbacks.set('data', []);
    this.callbacks.set('connect', []);
    this.callbacks.set('disconnect', []);
    this.callbacks.set('error', []);
  }

  async connect(): Promise<boolean> {
    try {
      // В продакшене используйте WSS и правильный URL
      const wsUrl = process.env.NODE_ENV === 'production' 
        ? 'wss://api.icoder.swapoil.de/terminal'
        : 'ws://localhost:3008/terminal';

      this.ws = new WebSocket(wsUrl);

      this.ws.onopen = () => {
        this.isConnected = true;
        this.reconnectAttempts = 0;
        this.emit('connect', 'Connected to terminal server');
        console.log('Terminal WebSocket connected');
      };

      this.ws.onmessage = (event) => {
        try {
          const message: TerminalMessage = JSON.parse(event.data);
          this.emit('data', message.data);
        } catch (error) {
          // Fallback для простого текста
          this.emit('data', event.data);
        }
      };

      this.ws.onclose = () => {
        this.isConnected = false;
        this.emit('disconnect', 'Terminal connection closed');
        this.handleReconnect();
      };

      this.ws.onerror = (error) => {
        console.error('Terminal WebSocket error:', error);
        this.emit('error', 'Connection error');
      };

      return true;
    } catch (error) {
      console.error('Failed to connect to terminal:', error);
      this.emit('error', 'Failed to connect to terminal server');
      return false;
    }
  }

  private handleReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      setTimeout(() => {
        console.log(`Attempting to reconnect... (${this.reconnectAttempts}/${this.maxReconnectAttempts})`);
        this.connect();
      }, 2000 * this.reconnectAttempts);
    }
  }

  sendCommand(command: string) {
    if (this.ws && this.isConnected) {
      const message: TerminalMessage = {
        type: 'command',
        data: command,
        timestamp: Date.now()
      };
      this.ws.send(JSON.stringify(message));
    } else {
      this.emit('error', 'Terminal not connected');
    }
  }

  sendInput(input: string) {
    if (this.ws && this.isConnected) {
      this.ws.send(input);
    }
  }

  on(event: string, callback: Function) {
    if (!this.callbacks.has(event)) {
      this.callbacks.set(event, []);
    }
    this.callbacks.get(event)?.push(callback);
  }

  off(event: string, callback: Function) {
    const callbacks = this.callbacks.get(event);
    if (callbacks) {
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    }
  }

  private emit(event: string, data: any) {
    const callbacks = this.callbacks.get(event);
    if (callbacks) {
      callbacks.forEach(callback => callback(data));
    }
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
    this.isConnected = false;
  }

  getConnectionStatus(): boolean {
    return this.isConnected;
  }
}

export const terminalService = new TerminalService();
