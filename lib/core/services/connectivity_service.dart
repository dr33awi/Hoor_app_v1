// lib/core/services/connectivity_service.dart
// خدمة مراقبة الاتصال بالإنترنت

import 'dart:async';
import 'dart:io';
import 'logger_service.dart';

/// خدمة مراقبة الاتصال بالإنترنت
class ConnectivityService {
  // Singleton
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final _connectivityController = StreamController<bool>.broadcast();
  Timer? _checkTimer;
  bool _lastKnownState = true;
  bool _isChecking = false;

  /// Stream لحالة الاتصال
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// الحالة الحالية للاتصال
  bool get isConnected => _lastKnownState;

  /// بدء مراقبة الاتصال
  void startMonitoring({Duration interval = const Duration(seconds: 10)}) {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(interval, (_) => checkConnectivity());
    checkConnectivity();
    AppLogger.d('بدء مراقبة الاتصال بالإنترنت');
  }

  /// إيقاف المراقبة
  void stopMonitoring() {
    _checkTimer?.cancel();
    _checkTimer = null;
    AppLogger.d('إيقاف مراقبة الاتصال');
  }

  /// فحص الاتصال
  Future<bool> checkConnectivity() async {
    if (_isChecking) return _lastKnownState;
    _isChecking = true;

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      final isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      if (isConnected != _lastKnownState) {
        _lastKnownState = isConnected;
        _connectivityController.add(isConnected);

        if (isConnected) {
          AppLogger.i('🌐 تم استعادة الاتصال بالإنترنت');
        } else {
          AppLogger.w('📴 فقدان الاتصال بالإنترنت');
        }
      }

      return isConnected;
    } on SocketException catch (_) {
      if (_lastKnownState) {
        _lastKnownState = false;
        _connectivityController.add(false);
        AppLogger.w('📴 فقدان الاتصال بالإنترنت');
      }
      return false;
    } on TimeoutException catch (_) {
      if (_lastKnownState) {
        _lastKnownState = false;
        _connectivityController.add(false);
        AppLogger.w('📴 انتهت مهلة الاتصال');
      }
      return false;
    } catch (e) {
      AppLogger.e('خطأ في فحص الاتصال', error: e);
      return _lastKnownState;
    } finally {
      _isChecking = false;
    }
  }

  /// الانتظار حتى يتوفر الاتصال
  Future<void> waitForConnection({
    Duration timeout = const Duration(minutes: 5),
  }) async {
    if (_lastKnownState) return;

    final completer = Completer<void>();
    StreamSubscription? subscription;

    // Timer للمهلة
    final timer = Timer(timeout, () {
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('انتهت مهلة انتظار الاتصال'));
      }
    });

    subscription = onConnectivityChanged.listen((isConnected) {
      if (isConnected && !completer.isCompleted) {
        timer.cancel();
        subscription?.cancel();
        completer.complete();
      }
    });

    return completer.future;
  }

  /// تنظيف الموارد
  void dispose() {
    stopMonitoring();
    _connectivityController.close();
  }
}

/// Mixin للـ Widgets التي تحتاج مراقبة الاتصال
mixin ConnectivityAware {
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  void initConnectivityListener(void Function(bool isConnected) onChanged) {
    _connectivitySubscription = ConnectivityService().onConnectivityChanged
        .listen((isConnected) {
          _isOnline = isConnected;
          onChanged(isConnected);
        });
    _isOnline = ConnectivityService().isConnected;
  }

  void disposeConnectivityListener() {
    _connectivitySubscription?.cancel();
  }
}
