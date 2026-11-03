import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/loyalty_provider.dart';

class DynamicQrModal extends StatefulWidget {
  const DynamicQrModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DynamicQrModal(),
    );
  }

  @override
  State<DynamicQrModal> createState() => _DynamicQrModalState();
}

class _DynamicQrModalState extends State<DynamicQrModal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loyalty = Provider.of<LoyaltyProvider>(context, listen: false);
      loyalty.fetchNewDynamicQr();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final loyalty = Provider.of<LoyaltyProvider>(context);
    final user = auth.currentUser;

    final progress = loyalty.secondsRemaining / 60.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  const Text('MÃ TÍCH ĐIỂM TẠI QUẦY', style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 6),
                  const Text(
                    'Đưa mã này cho nhân viên thu ngân quét để tích lũy điểm ngay',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 20),

                  // Member Badge Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.luxuryCardGradient,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.fullName ?? 'Khách hàng', style: AppTextStyles.titleMedium),
                            const SizedBox(height: 2),
                            Text(user?.phone ?? '0901234567', style: AppTextStyles.bodySmall),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.brewGreen,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryGold),
                          ),
                          child: Text(
                            '${user?.membershipTier.toUpperCase()} MEMBER',
                            style: const TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dynamic QR Container
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withOpacity(0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: loyalty.isLoadingQr || loyalty.dynamicQrToken == null
                        ? const SizedBox(
                            width: 220,
                            height: 220,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryGold,
                              ),
                            ),
                          )
                        : QrImageView(
                            data: loyalty.dynamicQrToken!,
                            version: QrVersions.auto,
                            size: 220.0,
                            backgroundColor: Colors.white,
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Animated 60s countdown timer
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 2.8,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              loyalty.secondsRemaining <= 10 ? AppColors.error : AppColors.primaryGold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Mã tự làm mới sau: ${loyalty.secondsRemaining}s',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: loyalty.secondsRemaining <= 10 ? AppColors.error : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Manual refresh button
                  TextButton.icon(
                    onPressed: loyalty.isLoadingQr ? null : () => loyalty.fetchNewDynamicQr(),
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold, size: 18),
                    label: const Text(
                      'Làm mới mã ngay',
                      style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
