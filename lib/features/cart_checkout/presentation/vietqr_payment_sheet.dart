import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_toast.dart';
import '../models/order_model.dart';
import 'order_tracking_sheet.dart';

class VietQrPaymentSheet extends StatelessWidget {
  final OrderModel order;
  final VietQrModel? vietqr;

  const VietQrPaymentSheet({
    super.key,
    required this.order,
    this.vietqr,
  });

  static void show(BuildContext context, {required OrderModel order, VietQrModel? vietqr}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => VietQrPaymentSheet(order: order, vietqr: vietqr),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrData = vietqr != null
        ? 'vietqr://pay?bank=${vietqr!.bankId}&acc=${vietqr!.accountNumber}&amt=${vietqr!.amount}&memo=${vietqr!.memo}'
        : 'brewpoint://${order.orderCode}/${order.finalAmount}';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 54),
                  const SizedBox(height: 12),
                  const Text('ĐẶT HÀNG THÀNH CÔNG!', style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 6),
                  Text(
                    'Mã đơn hàng: #${order.orderCode}',
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // VietQR Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // VietQR Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF003B70),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('VietQR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            const SizedBox(width: 8),
                            const Text('NAPAS 247', style: TextStyle(color: Color(0xFFE51A24), fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Dynamic QR Code Rendering
                        QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 210.0,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          'Quét bằng ứng dụng ngân hàng bất kỳ để thanh toán',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Transfer details card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        _buildTransferRow(
                          context,
                          label: 'Ngân hàng',
                          value: vietqr?.bankName ?? 'MBBank Quân Đội',
                        ),
                        const Divider(color: AppColors.divider, height: 20),
                        _buildTransferRow(
                          context,
                          label: 'Số tài khoản',
                          value: vietqr?.accountNumber ?? '090123456789',
                          isCopyable: true,
                        ),
                        const Divider(color: AppColors.divider, height: 20),
                        _buildTransferRow(
                          context,
                          label: 'Chủ tài khoản',
                          value: vietqr?.accountName ?? 'BREWPOINT VIETNAM',
                        ),
                        const Divider(color: AppColors.divider, height: 20),
                        _buildTransferRow(
                          context,
                          label: 'Số tiền',
                          value: CurrencyFormatter.format(order.finalAmount),
                          highlightColor: AppColors.primaryGold,
                          isCopyable: true,
                          copyValue: order.finalAmount.toInt().toString(),
                        ),
                        const Divider(color: AppColors.divider, height: 20),
                        _buildTransferRow(
                          context,
                          label: 'Nội dung chuyển khoản',
                          value: order.orderCode,
                          highlightColor: AppColors.primaryGold,
                          isCopyable: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Action Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.cardDark,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              child: CustomButton(
                text: 'HOÀN TẤT & THEO DÕI ĐƠN HÀNG',
                onPressed: () {
                  Navigator.of(context).pop();
                  OrderTrackingSheet.show(context, order: order);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? highlightColor,
    bool isCopyable = false,
    String? copyValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: highlightColor ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
            if (isCopyable) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: copyValue ?? value));
                  CustomToast.showSuccess(context, 'Đã sao chép $label');
                },
                child: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primaryGold),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
