import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class FilesWebSocket {
  static FilesWebSocket? _instance;

  factory FilesWebSocket() => _instance ??= FilesWebSocket._();

  FilesWebSocket._();

  IO.Socket? _socket;
  void Function(String)? _onMessage;

  void setCallback(void Function(String)? func) => _onMessage = func;

  void connectToServer() {
    try {
      _socket = IO.io(
        'http://localhost:3131',
        IO.OptionBuilder().setTransports(['websocket']).build(),
      );
      _socket!.on('connect', (_) => debugPrint('connect: ${_socket!.id}'));
      _socket!.on('message', (message) => _onMessage?.call(message));
      _socket!.on('disconnect', (_) => debugPrint('disconnect'));
    } catch (e) {
      debugPrint('error ${e.toString()}');
    }
  }
}
