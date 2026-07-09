import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/constants/api_constants.dart';

class WsService {
  io.Socket? _socket;
  bool _connected = false;

  void connect(String namespace) {
    _socket = io.io(
      '${ApiConstants.wsUrl}/$namespace',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );
    _socket!.onConnect((_) => _connected = true);
    _socket!.onDisconnect((_) => _connected = false);
    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _connected = false;
  }

  void emit(String event, [dynamic data]) => _socket?.emit(event, data);
  void on(String event, Function(dynamic) callback) => _socket?.on(event, callback);
  void off(String event) => _socket?.off(event);
  bool get connected => _connected;

  static final WsService greeting = WsService()..connect('greeting');
  static final WsService games = WsService()..connect('games');
  static final WsService map = WsService()..connect('map');
}
