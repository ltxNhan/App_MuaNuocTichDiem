import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/custom_toast.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../loyalty/presentation/dynamic_qr_modal.dart';
import '../../menu/models/product_model.dart';
import '../../menu/presentation/widgets/customization_bottom_sheet.dart';
import '../../menu/providers/menu_provider.dart';
import '../../cart_checkout/presentation/order_review_sheet.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final menu = Provider.of<MenuProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Profile Row
              _buildTopHeader(context, user),
              const SizedBox(height: 18),

              // 2. Luxury Gold Member Card
              _buildGoldMemberCard(context, user),
              const SizedBox(height: 20),

              // 3. Quick Actions Row
              _buildQuickActions(context),
              const SizedBox(height: 20),

              // 3.5. Delivered Order Review Card
              _buildDeliveredReviewBanner(context),
              const SizedBox(height: 24),

              // 4. Promo Banner Carousel
              _buildPromotionBanner(),
              const SizedBox(height: 24),

              // 5. Best Sellers Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Món bán chạy nhất', style: AppTextStyles.headlineLarge),
                  TextButton(
                    onPressed: () => onTabChange(1), // Go to Menu tab
                    child: const Text('Xem tất cả', style: TextStyle(color: AppColors.primaryGold, fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildBestsellerList(context, menu.bestsellers),
              const SizedBox(height: 24),

              // 6. Category Highlights
              const Text('Khám phá đồ uống', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 12),
              _buildCategoryHighlights(context, menu),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _showAccountMenu(context, user),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGold, width: 1.5),
                  color: AppColors.cardDark,
                ),
                child: ClipOval(
                  child: Image.network(
                    user?.avatarUrl ??
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryGold,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Xin chào,', style: AppTextStyles.bodySmall),
                  Row(
                    children: [
                      Text(
                        user?.fullName ?? 'Khách hàng',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: AppColors.primaryGold, size: 20),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryGold, size: 24),
              tooltip: 'Mã QR tích điểm',
              onPressed: () => DynamicQrModal.show(context),
            ),
            // Nút Tài khoản Khách hàng
            InkWell(
              onTap: () => _showAccountMenu(context, user),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.6)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_outline_rounded, color: AppColors.primaryGold, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Tài khoản',
                      style: TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAccountMenu(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.cardDark,
                      child: const Icon(Icons.person_rounded, color: AppColors.primaryGold, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Khách vãng lai',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user != null
                                ? 'SĐT: ${user.phone} • Hạng ${user.membershipTier}'
                                : 'Chưa đăng nhập tài khoản',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 10),

                // Tiện ích khách hàng
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.qr_code_2_rounded, color: AppColors.primaryGold),
                  title: const Text('Mã QR tích điểm & Đổi thưởng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: const Text('Quét mã tại quầy để tích 10% điểm cho mỗi ly', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 13),
                  onTap: () {
                    Navigator.pop(ctx);
                    DynamicQrModal.show(context);
                  },
                ),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.card_membership_rounded, color: AppColors.tierGold),
                  title: const Text('Đặc quyền thành viên & Thăng hạng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: Text('Hạng hiện tại: ${user?.membershipTier ?? "Thành viên"} • ${user?.points ?? 0} Điểm', style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 13),
                  onTap: () {
                    Navigator.pop(ctx);
                    onTabChange(3); // Go to Loyalty tab
                  },
                ),

                const Divider(color: AppColors.divider),

                // Đăng nhập tài khoản khác
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.switch_account_rounded, color: AppColors.primaryGold),
                  title: const Text('Đổi tài khoản / Đăng nhập quyền khác', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: const Text('Đăng nhập bằng tài khoản Khách, Nhân viên hoặc Quản trị', style: TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 13),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen(initialTabIndex: 0)),
                    );
                  },
                ),

                if (user != null) ...[
                  const Divider(color: AppColors.divider),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    title: const Text('Đăng xuất tài khoản', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 13.5)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      await auth.logout();
                      if (context.mounted) {
                        CustomToast.showSuccess(context, 'Đã đăng xuất tài khoản thành công');
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoldMemberCard(BuildContext context, dynamic user) {
    final points = user?.points ?? 350;
    final tier = user?.membershipTier ?? 'Gold';
    final totalSpent = user?.totalSpent ?? 4200000.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.luxuryCardGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.brewGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.stars_rounded, color: AppColors.primaryGold, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$tier Membership'.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => onTabChange(3), // Loyalty Tab
                child: const Row(
                  children: [
                    Text('Quyền lợi', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Điểm tích lũy hiện có', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$points',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('điểm', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  Text(
                    'Đã chi tiêu: ${CurrencyFormatter.format(totalSpent)}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => DynamicQrModal.show(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brewGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.primaryGold),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                icon: const Icon(Icons.qr_code_2_rounded, size: 18, color: AppColors.primaryGold),
                label: const Text(
                  'TÍCH ĐIỂM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _buildActionItem(
          icon: Icons.storefront_rounded,
          label: 'Tự đến lấy\n(Pick-up)',
          color: AppColors.brewGreen,
          onTap: () => onTabChange(1),
        ),
        _buildActionItem(
          icon: Icons.moped_rounded,
          label: 'Giao tận nơi\n(In-house)',
          color: AppColors.brewGreenDark,
          onTap: () => onTabChange(1),
        ),
        _buildActionItem(
          icon: Icons.card_giftcard_rounded,
          label: 'Đổi điểm\n(Vouchers)',
          color: const Color(0xFF332A1C),
          onTap: () => onTabChange(3),
        ),
        _buildActionItem(
          icon: Icons.qr_code_rounded,
          label: 'Quét tại quầy\n(Dynamic QR)',
          color: const Color(0xFF28231D),
          onTap: () => DynamicQrModal.show(context),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionBanner() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.cardDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.greenGradient,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('ƯU ĐÃI ĐỘC QUYỀN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'TẶNG 50 ĐIỂM THƯỞNG\nKHI ĐẶT ĐƠN ĐẦU TIÊN',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  const Text('Nhập mã GIAM20 để giảm thêm 20%', style: TextStyle(color: AppColors.goldLight, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestsellerList(BuildContext context, List<ProductModel> items) {
    if (items.isEmpty) {
      return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: AppColors.primaryGold)));
    }

    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = items[index];
          final isAvailable = product.isAvailable;

          return GestureDetector(
            onTap: () {
              if (!isAvailable) {
                CustomToast.showError(
                  context,
                  'Món "${product.name}" đã bán hết hẹn bạn vào hôm sau nhé!',
                );
                return;
              }
              CustomizationBottomSheet.show(context, product);
            },
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isAvailable ? AppColors.divider : Colors.redAccent.withOpacity(0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          product.imageUrl,
                          width: 160,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 160,
                            height: 120,
                            color: AppColors.surfaceDark,
                            child: const Icon(Icons.local_cafe, color: AppColors.primaryGold),
                          ),
                        ),
                      ),
                      if (!isAvailable)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.68),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ĐÃ BÁN HẾT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isAvailable ? Colors.white : Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (!isAvailable)
                          const Text(
                            'Đã bán hết hẹn bạn vào hôm sau',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CurrencyFormatter.format(product.basePrice),
                              style: isAvailable
                                  ? AppTextStyles.price
                                  : AppTextStyles.price.copyWith(color: AppColors.textMuted),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isAvailable ? AppColors.brewGreen : Colors.white10,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isAvailable ? Icons.add : Icons.block_rounded,
                                color: isAvailable ? AppColors.primaryGold : Colors.redAccent.withOpacity(0.7),
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryHighlights(BuildContext context, MenuProvider menu) {
    return Row(
      children: [
        _buildHighlightTile(
          title: 'Trà Sữa',
          subtitle: 'Ceylon & Matcha',
          imageUrl: 'https://images.unsplash.com/photo-1558857563-b37cf5a7c2a7?auto=format&fit=crop&w=400&q=80',
          onTap: () {
            menu.selectCategory(2);
            onTabChange(1);
          },
        ),
        const SizedBox(width: 12),
        _buildHighlightTile(
          title: 'Cà Phê',
          subtitle: 'Muối & Cold Brew',
          imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=400&q=80',
          onTap: () {
            menu.selectCategory(3);
            onTabChange(1);
          },
        ),
      ],
    );
  }

  Widget _buildHighlightTile({
    required String title,
    required String subtitle,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.cardDark,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceDark,
                      child: const Center(
                        child: Icon(Icons.local_cafe_rounded, color: AppColors.primaryGold, size: 28),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                        Text(subtitle, style: const TextStyle(color: AppColors.primaryGold, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveredReviewBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'GIAO THÀNH CÔNG',
                      style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text('+10 Điểm thưởng', style: TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Bạn cảm thấy chất lượng món ăn thế nào?',
            style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Đơn hàng #BP-20261024-001 • Hãy gửi bình luận và chọn icon chất lượng để tích điểm nhé!',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🤩', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 6),
                  Text('😊', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 6),
                  Text('😐', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 6),
                  Text('😕', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 6),
                  Text('😡', style: TextStyle(fontSize: 22)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  OrderReviewSheet.show(context, orderCode: 'BP-20261024-001');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.star_rounded, size: 16, color: Colors.black),
                label: const Text('Đánh giá ngay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
