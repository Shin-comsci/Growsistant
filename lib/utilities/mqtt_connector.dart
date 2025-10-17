import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static const _host = '6695964805f24ba0adbbf076242d94c6.s1.eu.hivemq.cloud';
  static const _wssPort = 8884;                 // HiveMQ Cloud WSS
  static const _user = 'growsistant';
  static const _pass = 'A54bjk123FF';

  late final String clientId;
  late final MqttServerClient client;

  final _msgCtrl = StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get messages => _msgCtrl.stream;

  bool get isConnected =>
      client.connectionStatus?.state == MqttConnectionState.connected;

  Future<void> connect() async {
    clientId = 'GS_${DateTime.now().millisecondsSinceEpoch}';

    // 1) Build client with HOSTNAME ONLY (no wss://, no /mqtt)
    client = MqttServerClient.withPort(_host, clientId, _wssPort);

    // 2) FORCE WebSocket + TLS before anything else
    client.useWebSocket = true;                 // << must be true
    client.secure = true;                       // << WSS
    client.keepAlivePeriod = 60;
    client.connectTimeoutPeriod = 20000;
    client.logging(on: true);

    // Optional WS subprotocol (harmless if ignored)
    try { client.websocketProtocols = const ['mqtt']; } catch (_) {}

    // If you're on 9.8.x this property doesn't exist; that's fine.
    // DO NOT set websocketPath on your version since it throws in your build.
    // (Default path on HiveMQ Cloud is /mqtt)

    // 3) Protocol: MQTT 3.1.1 (required by HiveMQ Cloud)
    // Use the explicit API to avoid any downgrade to 3.1
    final conn = MqttConnectMessage()
        .withClientIdentifier(clientId)         // important: use same id
        .authenticateAs(_user, _pass)
        .withWillQos(MqttQos.atLeastOnce)
        .keepAliveFor(60)
        .startClean()
        .withProtocolName('MQTT')               // force 3.1.1
        .withProtocolVersion(4);                // force 3.1.1
    client.connectionMessage = conn;

    // 4) Hooks
    client.onConnected    = () => debugPrint('✅ MQTT connected (WSS)');
    client.onDisconnected = () => debugPrint('❌ MQTT disconnected');

    // 5) Sanity log + hard guard:
    debugPrint('🔧 MQTT cfg: ws=${client.useWebSocket} '
        'secure=${client.secure} port=${client.port} id=$clientId');
    if (client.useWebSocket != true) {
      throw StateError('useWebSocket=false at runtime → would select TCP/TLS connector. Aborting.');
    }

    try {
      await client.connect(); // creds already in connectionMessage
    } catch (e) {
      debugPrint('💥 Connect exception: $e');
      _safeDisconnect();
      rethrow;
    }

    final st = client.connectionStatus;
    debugPrint('ℹ️ After connect: state=${st?.state} rc=${st?.returnCode}');
    if (st?.state != MqttConnectionState.connected) {
      _safeDisconnect();
      throw StateError('Connect failed: $st');
    }

    // 6) Subscribe ONLY to "{clientId}/sensors" as requested
    final topic = '$clientId/sensors';
    client.subscribe(topic, MqttQos.atLeastOnce);
    debugPrint('🎯 Subscribed -> $topic');

    // 7) Listen
    client.updates?.listen((events) {
      if (events.isEmpty) return;
      final rec = events.first;
      final msg = rec.payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.message);
      debugPrint('📥 ${rec.topic} -> $payload');
      _msgCtrl.add({rec.topic: payload});
    });
  }

  void publish(String topic, String payload, {bool retain = false}) {
    if (!isConnected) {
      debugPrint('⚠️ publish skipped (not connected): $topic');
      return;
    }
    final b = MqttClientPayloadBuilder()..addString(payload);
    client.publishMessage(topic, MqttQos.atLeastOnce, b.payload!, retain: retain);
  }

  void _safeDisconnect() { try { client.disconnect(); } catch (_) {} }

  Future<void> dispose() async { _safeDisconnect(); await _msgCtrl.close(); }
}
