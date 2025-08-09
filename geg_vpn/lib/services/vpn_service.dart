import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';
import 'firestore_service.dart';

enum VpnStatus { disconnected, connecting, connected, disconnecting, error }

class VpnService {
  final Reader _read;
  VpnService(this._read) {
    _engine = OpenVPN(
      onVpnStatusChanged: _onStatus,
      onVpnStageChanged: (stage, raw) {},
    );
  }

  late final OpenVPN _engine;
  final _statusController = StreamController<VpnStatus>.broadcast();
  Stream<VpnStatus> get statusStream => _statusController.stream;
  VpnStatus _status = VpnStatus.disconnected;
  VpnStatus get status => _status;

  void _onStatus(VPNStatus? status) {
    switch (status) {
      case VPNStatus.connected:
        _status = VpnStatus.connected;
        break;
      case VPNStatus.connecting:
        _status = VpnStatus.connecting;
        break;
      case VPNStatus.disconnected:
        _status = VpnStatus.disconnected;
        break;
      case VPNStatus.disconnecting:
        _status = VpnStatus.disconnecting;
        break;
      default:
        _status = VpnStatus.error;
    }
    _statusController.add(_status);
  }

  Future<void> connect() async {
    try {
      final servers = await _read(firestoreServiceProvider).fetchServers();
      if (servers.isEmpty) {
        throw Exception('No VPN servers configured.');
      }
      final server = servers.first; // simple selection; could be improved
      final config = server['ovpn'] as String; // full .ovpn content stored in Firestore
      final username = server['username'] as String?;
      final password = server['password'] as String?;

      await _engine.initialize(groupIdentifier: null, providerBundleIdentifier: null, localizedDescription: 'GEG VPN');
      await _engine.connect(config, username: username, password: password);
    } catch (e) {
      debugPrint('VPN connect error: $e');
      _statusController.add(VpnStatus.error);
    }
  }

  Future<void> disconnect() async {
    try {
      await _engine.disconnect();
    } catch (_) {}
  }
}