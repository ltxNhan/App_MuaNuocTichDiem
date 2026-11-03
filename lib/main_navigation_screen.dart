import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'features/cart_checkout/presentation/cart_screen.dart';
import 'features/cart_checkout/providers/cart_provider.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/loyalty/presentation/loyalty_screen.dart';
import 'features/menu/presentation/menu_screen.dart';
import 'features/admin_dashboard/presentation/admin_dashboard_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/staff/presentation/staff_dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    // PHÂN QUYỀN TRUY CẬP (ROLE-BASED ACCESS CONTROL - RBAC)
    // 1. Nếu chưa đăng nhập -> Hiển thị Màn hình Đăng nhập theo vai trò
    if (user == null) {
      return const LoginScreen();
    }

    // 2. Nếu là tài khoản NHÂN VIÊN (Staff) -> Vào thẳng hệ thống Nhân viên (KDS Barista & POS)
    if (user.isStaff) {
      return const StaffDashboardScreen();
    }

    // 3. Nếu là tài khoản QUẢN TRỊ VIÊN (Admin) -> Vào Cổng Quản trị Kinh doanh (Owner Portal)
    if (user.isAdmin) {
      return const AdminDashboardScreen();
    }

    // 4. Mặc định tài khoản KHÁCH HÀNG -> Chỉ có 4 tab của khách (Home, Menu, Giỏ hàng, Thành viên)
    final cart = Provider.of<CartProvider>(context);

    final pages = [
      HomeScreen(onTabChange: _onTabTapped),
      const MenuScreen(),
      const CartScreen(),
      LoyaltyScreen(onTabChange: _onTabTapped),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primaryGold,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'Thực đơn',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: cart.itemCount > 0,
                backgroundColor: AppColors.primaryGold,
                textColor: Colors.black,
                label: Text(
                  '${cart.itemCount}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: cart.itemCount > 0,
                backgroundColor: AppColors.primaryGold,
                textColor: Colors.black,
                label: Text(
                  '${cart.itemCount}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                ),
                child: const Icon(Icons.shopping_bag_rounded),
              ),
              label: 'Giỏ hàng',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.card_membership_outlined),
              activeIcon: Icon(Icons.card_membership_rounded),
              label: 'Thành viên',
            ),
          ],
        ),
      ),
    );
  }
}
