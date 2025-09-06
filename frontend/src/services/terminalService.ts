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
  private maxReconnectAttempts = 3;

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
      // ИСПРАВЛЕН URL - используем правильный порт 3000
      const wsUrl = process.env.NODE_ENV === 'production' 
        ? 'wss://api.icoder.swapoil.de/terminal'
        : 'ws://localhost:3000/terminal';

      console.log('Connecting to:', wsUrl);
      this.ws = new WebSocket(wsUrl);

      this.ws.onopen = () => {
        this.isConnected = true;
        this.reconnectAttempts = 0;
        this.emit('connect', 'Connected to terminal server');
        console.log('Terminal WebSocket connected to', wsUrl);
      };

      this.ws.onmessage = (event) => {
        // Прямо передаем данные от сервера
        this.emit('data', event.data);
      };

      this.ws.onclose = (event) => {
        this.isConnected = false;
        console.log('Terminal WebSocket closed:', event.code, event.reason);
        this.emit('disconnect', 'Terminal connection closed');
        
        if (event.code !== 1000) { // Не нормальное закрытие
          this.handleReconnect();
        }
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
      const delay = 1000 * this.reconnectAttempts;
      
      console.log(`Reconnecting in ${delay}ms... (${this.reconnectAttempts}/${this.maxReconnectAttempts})`);
      
      setTimeout(() => {
        this.connect();
      }, delay);
    } else {
      this.emit('error', 'Max reconnection attempts reached');
    }
  }

  sendInput(input: string) {
    if (this.ws && this.isConnected) {
      // Отправляем raw данные, без JSON обертки
      this.ws.send(input);
    } else {
      console.warn('Terminal not connected, cannot send:', input);
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
      this.ws.close(1000, 'User disconnect');
      this.ws = null;
    }
    this.isConnected = false;
  }

  getConnectionStatus(): boolean {
    return this.isConnected;
  }
}

export const terminalService = new TerminalService();
