import '../../loyalty/providers/loyalty_provider.dart';
import '../../loyalty/models/voucher_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../auth/providers/auth_provider.dart';
import '../../menu/models/topping_model.dart';
import '../../staff/models/staff_order_model.dart';
import '../../staff/providers/staff_provider.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../providers/cart_provider.dart';
import 'order_review_sheet.dart';
import 'order_tracking_sheet.dart';
import 'vietqr_payment_sheet.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _currentTab = 0; // 0: Giỏ hàng hiện tại, 1: Đơn hàng của tôi
  int _orderFilterStatus = 0; // 0: Tất cả, 1: Đang thực hiện, 2: Đã hoàn thành
  final TextEditingController _voucherController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cart = Provider.of<CartProvider>(context, listen: false);
    _addressController.text = cart.deliveryAddress;
  }

  @override
  void dispose() {
    _voucherController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onApplyVoucher(CartProvider cart, LoyaltyProvider loyalty) {
    final code = _voucherController.text.trim().toUpperCase();
    if (code.isEmpty) {
      CustomToast.showError(context, 'Vui lòng nhập mã giảm giá');
      return;
    }

    if (code == 'FREESHIP') {
      if (cart.orderType != 'delivery') {
        CustomToast.showError(
          context,
          'Mã FREESHIP chỉ áp dụng cho hình thức Giao hàng tận nơi. Đơn tự đến lấy tại quán của bạn đã không tốn phí ship rồi nhé!',
        );
        return;
      }
      cart.applyVoucher('FREESHIP', cart.shippingFee);
      CustomToast.showSuccess(context, 'Áp dụng mã FREESHIP thành công: Miễn phí giao hàng 18.000đ!');
      return;
    }

    // Tìm voucher trong kho voucher của user hoặc danh sách hệ thống
    final allVouchers = [...loyalty.myVouchers, ...loyalty.vouchers];
    final voucher = allVouchers.firstWhere(
      (v) => v.code.toUpperCase() == code,
      orElse: () => VoucherModel(
        id: 999,
        code: code,
        title: 'Mã giảm giá $code',
        discountType: 'fixed',
        discountValue: 20000,
        minOrderValue: 50000,
        pointsRequired: 0,
        quantity: 100,
        expiredAt: '2026-12-31',
      ),
    );

    if (cart.subtotal < voucher.minOrderValue) {
      CustomToast.showError(
        context,
        'Đơn hàng chưa đạt mức tối thiểu ${CurrencyFormatter.format(voucher.minOrderValue)} để áp dụng mã này.',
      );
      return;
    }

    cart.applyVoucherModel(voucher);
    CustomToast.showSuccess(
      context,
      'Áp dụng mã $code thành công: -${CurrencyFormatter.format(cart.voucherDiscount)}',
    );
  }

  // BOTTOM SHEET KHO VOUCHER KHẢ DỤNG CHO NGƯỜI DÙNG
  void _showVoucherPickerModal(BuildContext context, CartProvider cart, LoyaltyProvider loyalty) {
    // Gộp và dedup danh sách voucher khả dụng
    final allVouchers = <VoucherModel>[];
    final seenCodes = <String>{};

    for (final v in [...loyalty.myVouchers, ...loyalty.vouchers]) {
      if (!seenCodes.contains(v.code.toUpperCase())) {
        seenCodes.add(v.code.toUpperCase());
        allVouchers.add(v);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.confirmation_number_rounded, color: AppColors.primaryGold, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KHO MÃ GIẢM GIÁ & ƯU ĐÃI',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Có ${allVouchers.length} mã ưu đãi khả dụng cho bạn',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: allVouchers.isEmpty
                  ? const Center(
                      child: Text('Chưa có mã giảm giá nào', style: TextStyle(color: AppColors.textMuted)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: allVouchers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final v = allVouchers[index];
                        final isApplied = cart.appliedVoucherCode?.toUpperCase() == v.code.toUpperCase();
                        final isFreeship = v.code.toUpperCase() == 'FREESHIP';
                        final isEligible = cart.subtotal >= v.minOrderValue;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isApplied ? AppColors.primaryGold : AppColors.divider,
                              width: isApplied ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: (isApplied ? AppColors.primaryGold : AppColors.brewGreen).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: (isApplied ? AppColors.primaryGold : AppColors.brewGreen).withOpacity(0.4),
                                  ),
                                ),
                                child: Icon(
                                  isFreeship ? Icons.local_shipping_rounded : Icons.local_offer_rounded,
                                  color: isApplied ? AppColors.primaryGold : AppColors.brewGreen,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          v.code,
                                          style: const TextStyle(
                                            color: AppColors.primaryGold,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        if (isFreeship) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.brewGreen.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Free Ship',
                                              style: TextStyle(color: AppColors.success, fontSize: 9.5, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      v.title,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Đơn tối thiểu: ${CurrencyFormatter.format(v.minOrderValue)} • HSD: ${v.expiredAt}',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isApplied)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGold.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.primaryGold),
                                  ),
                                  child: const Text(
                                    'Đang dùng',
                                    style: TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                )
                              else
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isEligible ? AppColors.brewGreen : Colors.white12,
                                    foregroundColor: isEligible ? Colors.white : Colors.white38,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  onPressed: isEligible
                                      ? () {
                                          Navigator.pop(ctx);
                                          if (isFreeship && cart.orderType != 'delivery') {
                                            cart.setOrderType('delivery');
                                            CustomToast.showSuccess(
                                              context,
                                              'Đã chuyển sang hình thức Giao hàng và áp dụng FREESHIP!',
                                            );
                                          }
                                          cart.applyVoucherModel(v);
                                          _voucherController.text = v.code;
                                          CustomToast.showSuccess(
                                            context,
                                            'Đã áp dụng mã ${v.code} (-${CurrencyFormatter.format(cart.voucherDiscount)})',
                                          );
                                        }
                                      : () {
                                          final needed = v.minOrderValue - cart.subtotal;
                                          CustomToast.showError(
                                            context,
                                            'Cần mua thêm ${CurrencyFormatter.format(needed)} để dùng mã này',
                                          );
                                        },
                                  child: Text(
                                    isEligible ? 'Áp dụng' : 'Chưa đủ',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _onCheckout(CartProvider cart, AuthProvider auth) async {
    if (cart.items.isEmpty) {
      CustomToast.showError(context, 'Giỏ hàng đang trống');
      return;
    }

    if (cart.orderType == 'delivery' && _addressController.text.trim().isEmpty) {
      CustomToast.showError(context, 'Vui lòng nhập địa chỉ giao hàng');
      return;
    }

    cart.setDeliveryAddress(_addressController.text.trim());

    final success = await cart.checkout(auth);
    if (!mounted) return;

    if (success && cart.lastCreatedOrder != null) {
      VietQrPaymentSheet.show(
        context,
        order: cart.lastCreatedOrder!,
        vietqr: cart.lastVietQr,
      );
    } else {
      CustomToast.showError(context, 'Không thể tạo đơn hàng. Vui lòng thử lại.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final loyalty = Provider.of<LoyaltyProvider>(context);
    final staff = Provider.of<StaffProvider>(context);
    final userPoints = auth.currentUser?.points ?? 0;

    // Lấy các đơn hàng thuộc về khách hàng hiện tại
    final phone = auth.currentUser?.phone ?? '';
    final myOrders = staff.orders.where((o) {
      if (phone.isNotEmpty && o.customerPhone == phone) return true;
      return o.customerPhone == '0901234567' || o.id.startsWith('ord_');
    }).toList();

    final activeOrdersCount = myOrders.where((o) =>
      o.orderStatus == 'pending' ||
      o.orderStatus == 'processing' ||
      o.orderStatus == 'ready_for_pickup' ||
      o.orderStatus == 'delivering'
    ).length;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        title: Text(
          _currentTab == 0 ? 'Giỏ hàng & Đặt món' : 'Đơn hàng của tôi',
          style: AppTextStyles.headlineMedium,
        ),
        actions: [
          if (_currentTab == 0 && cart.items.isNotEmpty)
            TextButton(
              onPressed: () => cart.clearCart(),
              child: const Text('Xóa tất cả', style: TextStyle(color: AppColors.error, fontSize: 13)),
            ),
        ],
      ),
      body: Column(
        children: [
          // BỘ CHUYỂN TAB: "Giỏ hàng hiện tại" ⇄ "Đơn hàng của tôi"
          _buildMainTabSwitcher(cart.itemCount, activeOrdersCount),
          Expanded(
            child: _currentTab == 0
                ? (cart.items.isEmpty
                    ? _buildEmptyCart()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Order Type Toggle (Pickup vs Delivery)
                            _buildOrderTypeSelector(cart),
                            const SizedBox(height: 16),

                            // 2. Pickup Time or Delivery Address Section
                            if (cart.orderType == 'pickup')
                              _buildPickupTimeSection(cart)
                            else
                              _buildDeliveryAddressSection(cart),
                            const SizedBox(height: 20),

                            // 3. Cart Items List
                            const Text('Món đã chọn', style: AppTextStyles.headlineMedium),
                            const SizedBox(height: 10),
                            ...List.generate(cart.items.length, (index) {
                              final item = cart.items[index];
                              return _buildCartItemCard(cart, item, index);
                            }),
                            const SizedBox(height: 18),

                            // 4. Voucher & Points Section
                            _buildLoyaltyAndVoucherSection(cart, userPoints, loyalty),
                            const SizedBox(height: 20),

                            // 5. Payment Method Selector
                            _buildPaymentMethodSection(cart),
                            const SizedBox(height: 20),

                            // 6. Order Summary Calculation Card
                            _buildOrderSummaryCard(cart),
                            const SizedBox(height: 100), // spacing for bottom bar
                          ],
                        ),
                      ))
                : _buildMyOrdersView(myOrders, cart),
          ),
        ],
      ),
      bottomSheet: (_currentTab == 0 && cart.items.isNotEmpty)
          ? _buildBottomCheckoutBar(cart, auth)
          : null,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(Icons.shopping_bag_outlined, size: 48, color: AppColors.primaryGold),
          ),
          const SizedBox(height: 20),
          const Text('Giỏ hàng chưa có món nào', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          const Text(
            'Hãy dạo menu và chọn cho mình ly nước yêu thích nhé!',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryGold),
              foregroundColor: AppColors.primaryGold,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.receipt_long_rounded, size: 18),
            label: const Text('Xem đơn hàng đã đặt', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => setState(() => _currentTab = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTabSwitcher(int cartCount, int activeCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCapsuleTab(
              title: 'Giỏ hàng hiện tại',
              badgeCount: cartCount,
              badgeColor: AppColors.primaryGold,
              icon: Icons.shopping_bag_outlined,
              isSelected: _currentTab == 0,
              onTap: () => setState(() => _currentTab = 0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildCapsuleTab(
              title: 'Đơn hàng của tôi',
              badgeCount: activeCount,
              badgeColor: const Color(0xFF2ECC71),
              icon: Icons.receipt_long_rounded,
              isSelected: _currentTab == 1,
              onTap: () => setState(() => _currentTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapsuleTab({
    required String title,
    required int badgeCount,
    required Color badgeColor,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryGold : Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMyOrdersView(List<StaffOrder> orders, CartProvider cart) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: AppColors.primaryGold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có đơn hàng nào',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Các đơn bạn đã đặt sẽ hiển thị đầy đủ tiến độ tại đây.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'ĐẶT MÓN NGAY',
              width: 180,
              onPressed: () => setState(() => _currentTab = 0),
            ),
          ],
        ),
      );
    }

    final activeOrders = orders.where((o) =>
      o.orderStatus == 'pending' ||
      o.orderStatus == 'processing' ||
      o.orderStatus == 'ready_for_pickup' ||
      o.orderStatus == 'delivering'
    ).toList();

    final completedOrders = orders.where((o) =>
      o.orderStatus == 'completed' ||
      o.orderStatus == 'delivered'
    ).toList();

    List<StaffOrder> displayedOrders;
    if (_orderFilterStatus == 1) {
      displayedOrders = activeOrders;
    } else if (_orderFilterStatus == 2) {
      displayedOrders = completedOrders;
    } else {
      displayedOrders = orders;
    }

    return Column(
      children: [
        // Filter Sub-tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('Tất cả (${orders.length})', 0),
              const SizedBox(width: 8),
              _buildFilterChip('Đang thực hiện (${activeOrders.length})', 1),
              const SizedBox(width: 8),
              _buildFilterChip('Đã hoàn thành (${completedOrders.length})', 2),
            ],
          ),
        ),
        Expanded(
          child: displayedOrders.isEmpty
              ? Center(
                  child: Text(
                    _orderFilterStatus == 1
                        ? 'Không có đơn nào đang thực hiện'
                        : 'Chưa có đơn nào hoàn thành',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: displayedOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (ctx, index) {
                    final order = displayedOrders[index];
                    return _buildOrderCard(order, cart);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _orderFilterStatus == index;
    return GestureDetector(
      onTap: () => setState(() => _orderFilterStatus = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold.withOpacity(0.18) : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryGold : AppColors.textMuted,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(StaffOrder order, CartProvider cart) {
    final isPickup = order.orderType == 'pickup';
    final isActive = order.orderStatus == 'pending' ||
        order.orderStatus == 'processing' ||
        order.orderStatus == 'ready_for_pickup' ||
        order.orderStatus == 'delivering';

    // Status details
    String statusLabel;
    Color statusColor;
    IconData statusIcon;
    String statusDescription;

    switch (order.orderStatus) {
      case 'pending':
        statusLabel = 'Chờ xác nhận';
        statusColor = const Color(0xFFF39C12);
        statusIcon = Icons.hourglass_top_rounded;
        statusDescription = 'Quán đã nhận đơn và đang xếp hàng chờ làm';
        break;
      case 'processing':
        statusLabel = 'Đang pha chế';
        statusColor = const Color(0xFF3498DB);
        statusIcon = Icons.coffee_maker_rounded;
        statusDescription = 'Barista đang pha chế các ly nước thơm ngon';
        break;
      case 'ready_for_pickup':
        statusLabel = 'Sẵn sàng lấy món';
        statusColor = const Color(0xFF2ECC71);
        statusIcon = Icons.storefront_rounded;
        statusDescription = 'Món đã pha xong! Mời bạn tới quầy nhận nước';
        break;
      case 'delivering':
        statusLabel = 'Đang giao hàng';
        statusColor = const Color(0xFF2ECC71);
        statusIcon = Icons.delivery_dining_rounded;
        statusDescription = 'Tài xế đang giao đơn nước mát lạnh tới bạn';
        break;
      case 'completed':
      case 'delivered':
        statusLabel = 'Hoàn thành';
        statusColor = AppColors.textMuted;
        statusIcon = Icons.check_circle_rounded;
        statusDescription = 'Đơn hàng đã giao thành công';
        break;
      default:
        statusLabel = 'Đã hủy';
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_rounded;
        statusDescription = 'Đơn hàng đã bị hủy';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primaryGold.withOpacity(0.4) : AppColors.divider,
          width: isActive ? 1.4 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#${order.orderCode}',
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    Icon(
                      isPickup ? Icons.storefront_rounded : Icons.delivery_dining_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPickup ? 'Tự lấy tại quầy' : 'Giao tận nơi',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                    ),
                  ],
                ),
                const Spacer(),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Status message banner if active
          if (isActive)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: statusColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusDescription,
                      style: TextStyle(color: statusColor, fontSize: 11.5),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(color: AppColors.divider, height: 16),

          // 3. Items List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: order.items.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.local_cafe_rounded, size: 16, color: AppColors.primaryGold),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.quantity}x ${item.productName}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Size ${item.sizeName} • ${item.sugarLevel} đường • ${item.iceLevel} đá${item.toppings.isNotEmpty ? " • ${item.toppings.join(", ")}" : ""}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.unitPrice * item.quantity),
                        style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(color: AppColors.divider, height: 16),

          // 4. Footer & Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng thanh toán', style: TextStyle(color: AppColors.textMuted, fontSize: 10.5)),
                    Text(
                      CurrencyFormatter.format(order.totalAmount),
                      style: const TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (isActive)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.timeline_rounded, size: 16),
                    label: const Text(
                      'Theo dõi tiến độ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    onPressed: () {
                      OrderTrackingSheet.show(
                        context,
                        order: _toOrderModel(order),
                      );
                    },
                  )
                else ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.divider),
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.star_outline_rounded, size: 14, color: AppColors.primaryGold),
                    label: const Text('Đánh giá', style: TextStyle(fontSize: 11.5)),
                    onPressed: () {
                      OrderReviewSheet.show(context, orderCode: order.orderCode);
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.replay_rounded, size: 14),
                    label: const Text(
                      'Đặt lại đơn',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                    onPressed: () => _reorder(order, cart),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  OrderModel _toOrderModel(StaffOrder o) {
    return OrderModel(
      id: o.id,
      orderCode: o.orderCode,
      orderType: o.orderType,
      pickupTime: o.pickupTime,
      deliveryAddress: o.deliveryAddress,
      recipientPhone: o.customerPhone,
      recipientName: o.customerName,
      subtotalAmount: o.totalAmount,
      shippingFee: o.orderType == 'delivery' ? 18000 : 0,
      discountAmount: 0,
      finalAmount: o.totalAmount,
      pointsEarned: (o.totalAmount / 10000).floor(),
      pointsUsed: 0,
      paymentMethod: o.paymentMethod,
      paymentStatus: o.paymentStatus,
      orderStatus: o.orderStatus,
      note: o.note,
      createdAt: o.createdAt.toIso8601String(),
    );
  }

  void _reorder(StaffOrder order, CartProvider cart) {
    for (final item in order.items) {
      cart.addItem(
        CartItemModel(
          productId: 1,
          productName: item.productName,
          imageUrl: 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?auto=format&fit=crop&w=400&q=80',
          sizeName: item.sizeName,
          sugarLevel: item.sugarLevel,
          iceLevel: item.iceLevel,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          selectedToppings: item.toppings.map((t) => ToppingModel(id: 1, name: t, price: 10000, isAvailable: true)).toList(),
          itemNote: item.note,
        ),
      );
    }
    CustomToast.showSuccess(context, 'Đã thêm các món vào giỏ hàng!');
    setState(() => _currentTab = 0);
  }

  Widget _buildOrderTypeSelector(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => cart.setOrderType('pickup'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: cart.orderType == 'pickup' ? AppColors.brewGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 18,
                      color: cart.orderType == 'pickup' ? AppColors.primaryGold : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tự đến lấy (Pick-up)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: cart.orderType == 'pickup' ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => cart.setOrderType('delivery'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: cart.orderType == 'delivery' ? AppColors.brewGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.moped_rounded,
                      size: 18,
                      color: cart.orderType == 'delivery' ? AppColors.primaryGold : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Giao tận nơi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: cart.orderType == 'delivery' ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupTimeSection(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time_filled_rounded, color: AppColors.primaryGold, size: 20),
              SizedBox(width: 8),
              Text('Hẹn giờ đến lấy nước', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTimeChip(cart, '15 phút nữa', 15),
              const SizedBox(width: 8),
              _buildTimeChip(cart, '30 phút nữa', 30),
              const SizedBox(width: 8),
              _buildTimeChip(cart, '45 phút nữa', 45),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Dự kiến pha xong lúc: ${DateFormatter.formatTime(cart.pickupTime)} hôm nay',
            style: const TextStyle(fontSize: 12, color: AppColors.primaryGold, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(CartProvider cart, String label, int minutes) {
    final targetTime = DateTime.now().add(Duration(minutes: minutes));
    final isSelected = cart.pickupTime.difference(DateTime.now()).inMinutes >= (minutes - 5) &&
        cart.pickupTime.difference(DateTime.now()).inMinutes <= (minutes + 5);

    return Expanded(
      child: InkWell(
        onTap: () => cart.setPickupTime(targetTime),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brewGreen : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppColors.primaryGold : AppColors.divider),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressSection(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_rounded, color: AppColors.primaryGold, size: 20),
              SizedBox(width: 8),
              Text('Địa chỉ nhận hàng', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _addressController,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Nhập địa chỉ chi tiết (Số nhà, tên đường, tòa nhà...)',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              filled: true,
              fillColor: AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartProvider cart, dynamic item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 70,
                height: 70,
                color: AppColors.surfaceDark,
                child: const Icon(Icons.local_cafe, color: AppColors.primaryGold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => cart.removeItem(index),
                      child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.customizationSummary,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                if (item.itemNote != null && item.itemNote!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Ghi chú: ${item.itemNote}',
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyFormatter.format(item.totalPrice),
                      style: AppTextStyles.price,
                    ),
                    // Quantity stepper
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 14, color: Colors.white),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28),
                            onPressed: () => cart.updateQuantity(index, item.quantity - 1),
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 14, color: AppColors.primaryGold),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28),
                            onPressed: () => cart.updateQuantity(index, item.quantity + 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyAndVoucherSection(CartProvider cart, int userPoints, LoyaltyProvider loyalty) {
    final myVoucherCount = loyalty.myVouchers.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề & Nút chọn voucher
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Khuyến mãi & Mã giảm giá', style: AppTextStyles.titleMedium),
              InkWell(
                onTap: () => _showVoucherPickerModal(context, cart, loyalty),
                child: const Row(
                  children: [
                    Text('Xem tất cả', style: TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryGold, size: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Thanh chọn nhanh voucher khả dụng của khách
          InkWell(
            onTap: () => _showVoucherPickerModal(context, cart, loyalty),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cart.appliedVoucherCode != null ? AppColors.primaryGold : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.confirmation_number_rounded,
                    color: cart.appliedVoucherCode != null ? AppColors.primaryGold : Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cart.appliedVoucherCode != null
                              ? 'Đang dùng mã: ${cart.appliedVoucherCode}'
                              : 'Chọn mã ưu đãi có sẵn của bạn',
                          style: TextStyle(
                            color: cart.appliedVoucherCode != null ? AppColors.primaryGold : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                        Text(
                          cart.appliedVoucherCode != null
                              ? 'Đã giảm: -${CurrencyFormatter.format(cart.voucherDiscount)}'
                              : 'Bạn có $myVoucherCount mã giảm giá trong ví (Bấm để chọn)',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_right_rounded, color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Ô nhập mã thủ công
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: TextField(
                    controller: _voucherController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Hoặc nhập mã (GIAM20, FREESHIP...)',
                      hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () => _onApplyVoucher(cart, loyalty),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brewGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Áp dụng', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          if (cart.appliedVoucherCode != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Text(
                  'Đã áp dụng mã: ${cart.appliedVoucherCode} (-${CurrencyFormatter.format(cart.voucherDiscount)})',
                  style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => cart.removeVoucher(),
                  child: const Text('Gỡ', style: TextStyle(color: AppColors.error, fontSize: 12)),
                ),
              ],
            ),
          ],

          const Divider(color: AppColors.divider, height: 24),

          // Loyalty points usage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.stars_rounded, color: AppColors.primaryGold, size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dùng điểm tích lũy', style: AppTextStyles.titleMedium),
                      Text('Bạn có $userPoints điểm khả dụng (1 điểm = 1.000đ)', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
              Switch(
                value: cart.usePoints,
                activeColor: AppColors.primaryGold,
                activeTrackColor: AppColors.brewGreen,
                onChanged: userPoints > 0 ? (val) => cart.toggleUsePoints(val, userPoints) : null,
              ),
            ],
          ),

          if (cart.usePoints && userPoints > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: cart.pointsToUse.toDouble(),
                    min: 0,
                    max: userPoints.toDouble(),
                    divisions: userPoints > 0 ? userPoints : 1,
                    activeColor: AppColors.primaryGold,
                    inactiveColor: AppColors.surfaceDark,
                    onChanged: (val) => cart.setPointsToUse(val.toInt(), userPoints),
                  ),
                ),
                Text(
                  '${cart.pointsToUse} điểm\n(-${CurrencyFormatter.format(cart.pointsDiscount)})',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12, color: AppColors.primaryGold, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phương thức thanh toán', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          _buildPaymentOption(
            cart,
            id: 'vietqr',
            title: 'Chuyển khoản VietQR (Khuyên dùng)',
            subtitle: 'Quét mã QR tự động điền tiền và nội dung',
            icon: Icons.qr_code_scanner_rounded,
          ),
          _buildPaymentOption(
            cart,
            id: 'cash',
            title: 'Tiền mặt khi nhận hàng',
            subtitle: 'Thanh toán trực tiếp tại quầy hoặc cho shipper',
            icon: Icons.payments_outlined,
          ),
          _buildPaymentOption(
            cart,
            id: 'wallet',
            title: 'Ví BrewPoint Pay',
            subtitle: 'Thanh toán nhanh từ số dư ví',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    CartProvider cart, {
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = cart.paymentMethod == id;
    return GestureDetector(
      onTap: () => cart.setPaymentMethod(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brewGreen.withOpacity(0.25) : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryGold : AppColors.textMuted, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primaryGold, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Tạm tính (${cart.itemCount} món)', CurrencyFormatter.format(cart.subtotal)),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Phí giao hàng',
            cart.orderType == 'pickup'
                ? '0đ (Tự đến lấy quán)'
                : (cart.appliedVoucherCode?.toUpperCase() == 'FREESHIP'
                    ? '18.000đ (Miễn phí freeship)'
                    : CurrencyFormatter.format(cart.shippingFee)),
            color: (cart.orderType == 'delivery' && cart.appliedVoucherCode?.toUpperCase() == 'FREESHIP')
                ? AppColors.success
                : null,
          ),
          if (cart.voucherDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              cart.appliedVoucherCode?.toUpperCase() == 'FREESHIP'
                  ? 'Ưu đãi Miễn phí vận chuyển'
                  : 'Giảm giá Voucher (${cart.appliedVoucherCode})',
              '-${CurrencyFormatter.format(cart.voucherDiscount)}',
              color: AppColors.success,
            ),
          ],
          if (cart.pointsDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Giảm giá điểm', '-${CurrencyFormatter.format(cart.pointsDiscount)}', color: AppColors.success),
          ],
          const Divider(color: AppColors.divider, height: 20),
          _buildSummaryRow(
            'Tổng thanh toán',
            CurrencyFormatter.format(cart.finalAmount),
            style: AppTextStyles.priceLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tích lũy sau đơn này:', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text('+${cart.estimatedPointsEarned} điểm', style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {TextStyle? style, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          value,
          style: style ?? TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color ?? Colors.white),
        ),
      ],
    );
  }

  Widget _buildBottomCheckoutBar(CartProvider cart, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tổng thanh toán', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                Text(
                  CurrencyFormatter.format(cart.finalAmount),
                  style: AppTextStyles.priceLarge,
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: CustomButton(
                text: 'THANH TOÁN',
                isLoading: cart.isCheckingOut,
                onPressed: () => _onCheckout(cart, auth),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
