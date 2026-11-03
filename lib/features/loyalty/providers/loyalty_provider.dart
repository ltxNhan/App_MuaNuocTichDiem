import 'dart:async';
import 'package:flutter/material.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/loyalty_log_model.dart';
import '../models/voucher_model.dart';
import '../repositories/loyalty_repository.dart';

class LoyaltyProvider extends ChangeNotifier {
  final LoyaltyRepository _repository;

  String? _dynamicQrToken;
  int _secondsRemaining = 60;
  Timer? _countdownTimer;
  bool _isLoadingQr = false;

  List<LoyaltyLogModel> _logs = [];
  List<VoucherModel> _vouchers = [];
  List<VoucherModel> _myVouchers = []; // Kho voucher đã sở hữu của người dùng
  bool _isLoadingData = false;
  bool _isRedeeming = false; // Cờ khóa chống click liên tục

  LoyaltyProvider(this._repository) {
    loadLoyaltyData();
  }

  String? get dynamicQrToken => _dynamicQrToken;
  int get secondsRemaining => _secondsRemaining;
  bool get isLoadingQr => _isLoadingQr;
  List<LoyaltyLogModel> get logs => _logs;
  List<VoucherModel> get vouchers => _vouchers;
  List<VoucherModel> get myVouchers => _myVouchers;
  bool get isLoadingData => _isLoadingData;
  bool get isRedeeming => _isRedeeming;

  Future<void> loadLoyaltyData() async {
    _isLoadingData = true;
    notifyListeners();

    try {
      final fetchedLogs = await _repository.getLoyaltyLogs();
      // Dedup logs theo ID và mô tả
      final seenLogIds = <int>{};
      final uniqueLogs = <LoyaltyLogModel>[];
      for (final log in fetchedLogs) {
        if (!seenLogIds.contains(log.id)) {
          seenLogIds.add(log.id);
          uniqueLogs.add(log);
        }
      }
      _logs = uniqueLogs;

      _vouchers = await _repository.getAvailableVouchers();

      // Khởi tạo các voucher khả dụng mặc định cho khách hàng
      if (_myVouchers.isEmpty) {
        _myVouchers = _vouchers.where((v) => v.pointsRequired == 0).toList();
      }
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewDynamicQr() async {
    _isLoadingQr = true;
    notifyListeners();

    try {
      final result = await _repository.getDynamicQr();
      _dynamicQrToken = result.qrToken;
      _secondsRemaining = result.expiresInSeconds;

      _startQrTimer();
    } finally {
      _isLoadingQr = false;
      notifyListeners();
    }
  }

  void _startQrTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        _secondsRemaining--;
        notifyListeners();
      } else {
        // Automatically refresh QR when expired
        timer.cancel();
        fetchNewDynamicQr();
      }
    });
  }

  void stopQrTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  Future<bool> redeemVoucher(VoucherModel voucher, AuthProvider authProvider) async {
    if (_isRedeeming) return false;

    final user = authProvider.currentUser;
    if (user == null || user.points < voucher.pointsRequired) {
      return false;
    }

    _isRedeeming = true;
    notifyListeners();

    try {
      final success = await _repository.redeemVoucher(voucher.id);
      if (success) {
        final newPoints = user.points - voucher.pointsRequired;
        authProvider.updatePointsAndTier(newPoints, user.membershipTier, 0);

        // Lưu voucher vào Kho voucher của người dùng nếu chưa có
        if (!_myVouchers.any((v) => v.code == voucher.code)) {
          _myVouchers.insert(0, voucher);
        }

        // Tạo 1 log duy nhất với ID ngẫu nhiên không trùng lặp
        final newLogId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final newLog = LoyaltyLogModel(
          id: newLogId,
          userId: user.id,
          pointsChanged: -voucher.pointsRequired,
          balanceAfter: newPoints,
          action: 'redeem',
          description: 'Đổi mã giảm giá ${voucher.code}',
          createdAt: DateTime.now().toIso8601String(),
        );

        _logs.insert(0, newLog);

        _isRedeeming = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    _isRedeeming = false;
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
