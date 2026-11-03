import '../../cart_checkout/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/voucher_model.dart';
import '../providers/loyalty_provider.dart';
import 'dynamic_qr_modal.dart';

class LoyaltyScreen extends StatelessWidget {
  final Function(int)? onTabChange;

  const LoyaltyScreen({super.key, this.onTabChange});

  void _onRedeem(BuildContext context, VoucherModel voucher, LoyaltyProvider loyalty, AuthProvider auth) async {
    final user = auth.currentUser;
    if (user == null || user.points < voucher.pointsRequired) {
      CustomToast.showError(context, 'Bạn chưa đủ điểm tích lũy để đổi voucher này');
      return;
    }

    if (loyalty.isRedeeming) return;

    final success = await loyalty.redeemVoucher(voucher, auth);
    if (context.mounted) {
      if (success) {
        _showRedeemSuccessDialog(context, voucher);
      } else {
        CustomToast.showError(context, 'Đổi voucher thất bại hoặc đã hết lượt.');
      }
    }
  }

  void _showRedeemSuccessDialog(BuildContext context, VoucherModel voucher) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration_rounded, color: AppColors.primaryGold, size: 24),
            SizedBox(width: 8),
            Text(
              'ĐỔI MÃ THÀNH CÔNG!',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn đã đổi thành công mã ưu đãi:',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.confirmation_number_rounded, color: AppColors.primaryGold, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voucher.code,
                          style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          voucher.title,
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Mã này đã được lưu vào Kho Voucher trong Giỏ hàng của bạn để sử dụng.',
              style: TextStyle(color: AppColors.success, fontSize: 12, height: 1.3),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Để sau', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final cart = Provider.of<CartProvider>(context, listen: false);
              cart.applyVoucherModel(voucher);
              CustomToast.showSuccess(context, 'Đã áp dụng mã ${voucher.code} vào giỏ hàng!');
              onTabChange?.call(2); // Chuyển sang Tab 2 (Giỏ hàng)
            },
            icon: const Icon(Icons.shopping_bag_rounded, size: 16),
            label: const Text('Đến Giỏ hàng dùng ngay', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final loyalty = Provider.of<LoyaltyProvider>(context);
    final user = auth.currentUser;

    final points = user?.points ?? 0;
    final tier = user?.membershipTier ?? 'Gold';
    final totalSpent = user?.totalSpent ?? 0.0;

    // Next tier target calculation
    double targetSpent = 10000000.0;
    String nextTier = 'Platinum';
    if (tier == 'Bronze') {
      targetSpent = 1000000.0;
      nextTier = 'Silver';
    } else if (tier == 'Silver') {
      targetSpent = 3000000.0;
      nextTier = 'Gold';
    } else if (tier == 'Gold') {
      targetSpent = 10000000.0;
      nextTier = 'Platinum';
    }
    final tierProgress = (totalSpent / targetSpent).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: const Text('Thành viên & Điểm thưởng', style: AppTextStyles.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryGold, size: 26),
            tooltip: 'Mã QR thành viên',
            onPressed: () => DynamicQrModal.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white, size: 26),
            tooltip: 'Đăng nhập / Đăng ký',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Luxury Member Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: tier == 'Platinum'
                    ? const LinearGradient(
                        colors: [Color(0xFF3A3D40), Color(0xFF1E2022)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : AppColors.goldGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: (tier == 'Platinum' ? Colors.white24 : AppColors.primaryGold).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_cafe_rounded, color: Colors.black87, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'BREWPOINT REWARDS',
                            style: AppTextStyles.titleMedium.copyWith(color: Colors.black87, letterSpacing: 1),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$tier Tier',
                          style: TextStyle(
                            color: tier == 'Platinum' ? AppColors.tierPlatinum : AppColors.tierGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ĐIỂM KHẢ DỤNG',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$points',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('điểm', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => DynamicQrModal.show(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        icon: const Icon(Icons.qr_code_rounded, size: 18, color: Colors.white),
                        label: const Text('Mã QR tích điểm', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress to next tier
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiến độ lên hạng $nextTier',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      Text(
                        '${CurrencyFormatter.format(totalSpent)} / ${CurrencyFormatter.format(targetSpent)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: tierProgress,
                      minHeight: 6,
                      backgroundColor: Colors.black12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Voucher Store Section (Đổi điểm)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Đổi voucher ưu đãi', style: AppTextStyles.headlineMedium),
                Text('Có sẵn: $points điểm', style: const TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            loyalty.isLoadingData
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                : Column(
                    children: loyalty.vouchers.where((v) => v.pointsRequired > 0).map((voucher) {
                      final canRedeem = points >= voucher.pointsRequired;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.brewGreen.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
                              ),
                              child: const Icon(Icons.confirmation_num_outlined, color: AppColors.primaryGold, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(voucher.code, style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(voucher.title, style: AppTextStyles.bodyMedium),
                                  const SizedBox(height: 4),
                                  Text(
                                    'HSD: ${DateFormatter.formatDate(voucher.expiredAt)}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${voucher.pointsRequired} điểm',
                                  style: const TextStyle(
                                    color: AppColors.primaryGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: canRedeem ? () => _onRedeem(context, voucher, loyalty, auth) : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.brewGreen,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(
                                      'Đổi ngay',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: canRedeem ? Colors.white : Colors.white38,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 24),

            // 3. Points History / Loyalty Logs
            const Text('Lịch sử tích lũy điểm', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 12),
            ...loyalty.logs.map((log) {
              final isPositive = log.pointsChanged > 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isPositive ? AppColors.brewGreen.withOpacity(0.3) : AppColors.cardDark,
                        shape: BoxShape.circle,
                        border: Border.all(color: isPositive ? AppColors.success : AppColors.error),
                      ),
                      child: Icon(
                        isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
                        color: isPositive ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.description, style: AppTextStyles.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            DateFormatter.formatDateTime(log.createdAt),
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isPositive ? '+' : ''}${log.pointsChanged} điểm',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? AppColors.success : AppColors.error,
                          ),
                        ),
                        Text(
                          'Số dư: ${log.balanceAfter}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
