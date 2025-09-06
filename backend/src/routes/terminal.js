const express = require('express');
const { spawn } = require('child_process');
const WebSocket = require('ws');

const router = express.Router();

// WebSocket сервер для терминала
function setupTerminalWebSocket(server) {
  const wss = new WebSocket.Server({ 
    server,
    path: '/terminal'
  });

  wss.on('connection', (ws) => {
    console.log('Terminal WebSocket connected');

    // Создаем процесс bash
    const shell = spawn('bash', ['-i'], {
      cwd: process.cwd(),
      env: process.env
    });

    // Перенаправляем stdout в WebSocket
    shell.stdout.on('data', (data) => {
      ws.send(data.toString());
    });

    // Перенаправляем stderr в WebSocket
    shell.stderr.on('data', (data) => {
      ws.send(data.toString());
    });

    // Обрабатываем ввод от WebSocket
    ws.on('message', (data) => {
      try {
        const message = JSON.parse(data);
        if (message.type === 'command') {
          shell.stdin.write(message.data);
        }
      } catch (error) {
        // Fallback для простого текста
        shell.stdin.write(data);
      }
    });

    // Закрытие соединения
    ws.on('close', () => {
      console.log('Terminal WebSocket disconnected');
      shell.kill();
    });

    shell.on('exit', () => {
      ws.close();
    });
  });

  return wss;
}

module.exports = { router, setupTerminalWebSocket };
