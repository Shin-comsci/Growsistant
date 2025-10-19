// lib/utilities/mqtt_connector.dart
import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static const String _host   = '6695964805f24ba0adbbf076242d94c6.s1.eu.hivemq.cloud';
  static const int    _port   = 8883;               // TLS over TCP
  static const String _user   = 'growsistant';
  static const String _pass   = 'A54bjk123FF';
  static const int    _keepAlive = 60;
  static const int    _connTimeoutMs = 5000;

  late final String topic;                          // {clientId}/sensors
  late final MqttServerClient client;
  late final String clientId;

  final _msgCtrl = StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get messages => _msgCtrl.stream;

  MqttService({required String clientId}) {
    this.clientId = clientId;
    topic = '$clientId/sensors';

    client = MqttServerClient.withPort(_host, topic, _port)
      ..logging(on: true)
      ..keepAlivePeriod = _keepAlive
      ..secure = true
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed
      ..onSubscribeFail = _onSubscribeFail
      ..onUnsubscribed = _onUnsubscribed; // <- keep if your version exposes this

    // Force MQTT 3.1.1
    client.setProtocolV311();

    client.connectTimeoutPeriod = _connTimeoutMs;

    // Provide a default SecurityContext (system CAs). No client cert required.
    final ctx = SecurityContext.defaultContext;
    client.securityContext = ctx;
  }

  Future<void> connect() async {
    print('Connecting to $_host:$_port over TLS as $clientId');

    final connMsg = MqttConnectMessage()
        .withClientIdentifier(clientId)           // important: set it here too
        .authenticateAs(_user, _pass)
        .startClean()                              // clean session
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMsg;


    try {
      final status = await client.connect();
      if (status?.state == MqttConnectionState.connected) {
        print('Connected (MQTT v3.1.1)');

        // Subscribe after real connection
        client.subscribe(topic, MqttQos.atLeastOnce);
        // Listen to updates
        client.updates?.listen((events) {
          if (events.isEmpty) return;
          final first = events.first;
          final pub = first.payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(pub.payload.message);
          final top = first.topic;
          print('📩 [$top] $payload');
          _msgCtrl.add({top: payload});
        });
      } else {
        print('❌ Connect failed. Status: ${client.connectionStatus}');
        _safeDisconnect();
      }
    } on NoConnectionException catch (e) {
      print('❌ NoConnectionException: $e');
      _safeDisconnect();
      rethrow;
    } on SocketException catch (e) {
      print('❌ SocketException: $e');
      _safeDisconnect();
      rethrow;
    } catch (e) {
      print('❌ Unexpected connect error: $e');
      _safeDisconnect();
      rethrow;
    }
  }

  Future<void> publish(String payload) async {
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      print('⚠️ Not connected; skip publish.');
      return;
    }
    final builder = MqttClientPayloadBuilder()..addString(payload);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print('📤 Published to $topic: $payload');
  }

  void _onConnected() {
    print('🔗 Connected — state=${client.connectionStatus?.state}');
  }

  void _onDisconnected() {
    final origin = client.connectionStatus?.disconnectionOrigin;
    print('🔌 Disconnected — origin=$origin, status=${client.connectionStatus}');
  }

  void _safeDisconnect() {
    try { client.disconnect(); } catch (_) {}
  }
  void _onSubscribed(String topic) {
    print('✅ Subscribed: $topic');
    publish("UPD");
  }
  void _onSubscribeFail(String topic) => print('❌ Subscribe failed: $topic');
  void _onUnsubscribed(String? topic) => print('↩️ Unsubscribed: $topic');

  void dispose() {
    _msgCtrl.close();
    _safeDisconnect();
  }
}
