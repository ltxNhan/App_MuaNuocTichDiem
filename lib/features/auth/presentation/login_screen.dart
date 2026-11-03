import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_toast.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final int initialTabIndex;
  const LoginScreen({super.key, this.initialTabIndex = 0});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // CẤU HÌNH HIỂN THỊ NÚT ĐĂNG NHẬP NHANH (Đặt false khi muốn ẩn hoàn toàn)
  static bool enableQuickRoleButtons = true;

  // Login Controllers
  final _loginPhoneController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;

  // Register Controllers (Đơn giản: Tên người dùng + SĐT + Mật khẩu)
  final _regNameController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regPasswordController = TextEditingController();
  bool _regObscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regPhoneController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final phone = _loginPhoneController.text.trim();
    final password = _loginPasswordController.text.trim();

    if (phone.isEmpty) {
      CustomToast.showError(context, 'Vui lòng nhập số điện thoại');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(phone, password);

    if (!mounted) return;

    if (success) {
      CustomToast.showSuccess(
        context,
        'Chào mừng ${authProvider.currentUser?.fullName}!',
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      CustomToast.showError(
        context,
        authProvider.errorMessage ?? 'Đăng nhập thất bại',
      );
    }
  }

  void _quickLogin(String role) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (role == 'admin') {
      _loginPhoneController.text = '0814534594';
      _loginPasswordController.text = '123123123';
      authProvider.switchDemoRole('admin');
      CustomToast.showSuccess(context, 'Đăng nhập thành công: Quyền Quản trị viên (Admin)');
    } else if (role == 'staff') {
      _loginPhoneController.text = '0983408021';
      _loginPasswordController.text = '098765';
      authProvider.switchDemoRole('staff');
      CustomToast.showSuccess(context, 'Đăng nhập thành công: Quyền Nhân viên (Staff/KDS)');
    } else {
      _loginPhoneController.text = '0901234567';
      _loginPasswordController.text = '123456';
      authProvider.switchDemoRole('customer');
      CustomToast.showSuccess(context, 'Đăng nhập thành công: Quyền Khách hàng VIP');
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _onRegister() async {
    final name = _regNameController.text.trim();
    final phone = _regPhoneController.text.trim();
    final password = _regPasswordController.text.trim();

    if (name.isEmpty) {
      CustomToast.showError(context, 'Vui lòng nhập tên người dùng');
      return;
    }
    if (phone.isEmpty) {
      CustomToast.showError(context, 'Vui lòng nhập số điện thoại');
      return;
    }
    if (password.length < 6) {
      CustomToast.showError(context, 'Mật khẩu phải từ 6 ký tự trở lên');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      phone,
      name,
      password,
    );

    if (!mounted) return;

    if (success) {
      CustomToast.showSuccess(
        context,
        'Đăng ký thành công! Chào mừng $name 🎉',
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      CustomToast.showError(
        context,
        authProvider.errorMessage ?? 'Đăng ký không thành công',
      );
    }
  }

  void _onGoogleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.loginWithGoogle();

    if (!mounted) return;

    if (success) {
      CustomToast.showSuccess(
        context,
        'Đăng nhập thành công! Bạn nhận được 50 điểm thưởng chào mừng 🎉',
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      CustomToast.showError(
        context,
        authProvider.errorMessage ?? 'Đăng nhập Google thất bại',
      );
    }
  }

  void _showForgotPasswordDialog() {
    final phoneCtrl = TextEditingController(
      text: _loginPhoneController.text.trim(),
    );
    final otpCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    int currentStep = 1; // 1: Nhập SĐT, 2: Nhập OTP & mật khẩu mới
    bool obscureNewPass = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primaryGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Khôi phục mật khẩu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentStep == 1) ...[
                  const Text(
                    'Nhập số điện thoại đã đăng ký để nhận mã xác thực OTP khôi phục mật khẩu:',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Số điện thoại',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: 0901234567',
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.phone_iphone_rounded,
                        color: AppColors.primaryGold,
                        size: 18,
                      ),
                      filled: true,
                      fillColor: AppColors.cardDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brewGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.brewGreen.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.mark_email_read_rounded,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Mã OTP gửi đến ${phoneCtrl.text} (Mã thử nghiệm: 686868)',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Mã xác thực OTP (6 chữ số) *',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: otpCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                    decoration: InputDecoration(
                      hintText: '686868',
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                      filled: true,
                      fillColor: AppColors.cardDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Mật khẩu mới *',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: obscureNewPass,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Tối thiểu 6 ký tự',
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: AppColors.cardDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNewPass
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        onPressed: () => setModalState(
                          () => obscureNewPass = !obscureNewPass,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Xác nhận mật khẩu mới *',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: obscureNewPass,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Nhập lại mật khẩu mới',
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: AppColors.cardDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text(
                'Hủy',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            if (currentStep == 1)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final phone = phoneCtrl.text.trim();
                  if (phone.isEmpty) {
                    CustomToast.showError(
                      modalCtx,
                      'Vui lòng nhập số điện thoại',
                    );
                    return;
                  }
                  otpCtrl.text = '686868';
                  setModalState(() => currentStep = 2);
                  CustomToast.showSuccess(
                    modalCtx,
                    'Đã gửi mã OTP đến số $phone!',
                  );
                },
                child: const Text(
                  'Gửi mã OTP',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final otp = otpCtrl.text.trim();
                  final newPass = newPassCtrl.text.trim();
                  final confirm = confirmPassCtrl.text.trim();

                  if (otp.isEmpty) {
                    CustomToast.showError(modalCtx, 'Vui lòng nhập mã OTP');
                    return;
                  }
                  if (newPass.length < 6) {
                    CustomToast.showError(
                      modalCtx,
                      'Mật khẩu mới phải từ 6 ký tự',
                    );
                    return;
                  }
                  if (newPass != confirm) {
                    CustomToast.showError(
                      modalCtx,
                      'Mật khẩu xác nhận không trùng khớp',
                    );
                    return;
                  }

                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final success = await auth.resetPassword(
                    phoneCtrl.text.trim(),
                    newPass,
                  );
                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);

                  if (!mounted) return;

                  if (success) {
                    setState(() {
                      _loginPhoneController.text = phoneCtrl.text.trim();
                      _loginPasswordController.text = newPass;
                    });
                    CustomToast.showSuccess(
                      context,
                      'Đặt lại mật khẩu thành công! Bạn có thể đăng nhập ngay.',
                    );
                  } else {
                    CustomToast.showError(
                      context,
                      'Khôi phục mật khẩu thất bại. Vui lòng thử lại.',
                    );
                  }
                },
                child: const Text(
                  'Đổi mật khẩu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleLogo() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFF34A853),
                  Color(0xFFFBBC05),
                  Color(0xFFEA4335),
                ],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 20.0, 20.0)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0C0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text(
          'BrewPoint Coffee',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                backgroundColor: Colors.white.withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withOpacity(0.12)),
                ),
              ),
              onPressed: () {
                authProvider.continueAsGuest();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Bỏ qua',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.65),
            radius: 1.3,
            colors: [
              Color(0xFF281E16), // Roasted amber ambient glow
              Color(0xFF141211), // Deep espresso
              Color(0xFF0D0C0B), // Midnight backdrop
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Luxury Emblem
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B2919), Color(0xFF1D140C)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: AppColors.primaryGold.withOpacity(0.85),
                            width: 2.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGold.withOpacity(0.35),
                              blurRadius: 28,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryGold.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.local_cafe_rounded,
                              color: AppColors.primaryGold,
                              size: 36,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFFDF9E),
                            Color(0xFFD4A056),
                            Color(0xFFB8822B),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'BREWPOINT',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryGold.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'PREMIUM COFFEE & TEA • LOYALTY CLUB',
                          style: TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Sleek Capsule Tab Switcher
                Container(
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1917),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE5B869), Color(0xFFB8822B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGold.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      letterSpacing: 0.3,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                    tabs: const [
                      Tab(text: 'Đăng nhập'),
                      Tab(text: 'Đăng ký mới'),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Tab Content
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return _tabController.index == 0
                        ? _buildLoginTab(authProvider)
                        : _buildRegisterTab(authProvider);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primaryGold),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF191715),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withOpacity(0.09),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            autocorrect: false,
            enableSuggestions: false,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 13,
              ),
              prefixIcon: Icon(
                icon,
                color: AppColors.primaryGold.withOpacity(0.85),
                size: 19,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5B869), Color(0xFFB8822B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A056).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.black,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildField(
          label: 'Số điện thoại',
          hint: 'Nhập số điện thoại (ví dụ: 0901234567)',
          controller: _loginPhoneController,
          icon: Icons.phone_iphone_rounded,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        _buildField(
          label: 'Mật khẩu',
          hint: 'Nhập mật khẩu',
          controller: _loginPasswordController,
          icon: Icons.lock_outline_rounded,
          obscureText: _loginObscurePassword,
          keyboardType: TextInputType.visiblePassword,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_loginPasswordController.text.isNotEmpty)
                IconButton(
                  tooltip: 'Xoá để nhập lại',
                  icon: const Icon(
                    Icons.cancel_rounded,
                    color: Colors.white38,
                    size: 18,
                  ),
                  onPressed: () => setState(() {
                    _loginPasswordController.clear();
                  }),
                ),
              IconButton(
                tooltip: _loginObscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                icon: Icon(
                  _loginObscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primaryGold.withOpacity(0.85),
                  size: 19,
                ),
                onPressed: () => setState(
                  () => _loginObscurePassword = !_loginObscurePassword,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Nút Quên mật khẩu
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _showForgotPasswordDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Quên mật khẩu?',
              style: TextStyle(
                color: AppColors.primaryGold,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Login Button
        _buildSubmitButton(
          text: 'ĐĂNG NHẬP NGAY',
          isLoading: authProvider.isLoading,
          onPressed: _onLogin,
        ),
        const SizedBox(height: 16),

        // Chuyển sang Đăng ký
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chưa có tài khoản? ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: const Text(
                'Đăng ký ngay',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        // 3 Nút Đăng nhập nhanh theo vai trò (Admin / Nhân viên / Khách hàng)
        _buildQuickRoleButtons(),
        const SizedBox(height: 22),

        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.white.withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'HOẶC TIẾP TỤC VỚI',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.white.withOpacity(0.1)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Nút Đăng nhập nhanh với Google
        InkWell(
          onTap: authProvider.isLoading ? null : _onGoogleLogin,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1917),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGoogleLogo(),
                const SizedBox(width: 10),
                const Text(
                  'Đăng nhập với Google',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        Center(
          child: TextButton.icon(
            onPressed: () {
              authProvider.continueAsGuest();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(
              Icons.storefront_rounded,
              color: AppColors.primaryGold,
              size: 17,
            ),
            label: const Text(
              'Tiếp tục với tư cách Khách vãng lai',
              style: TextStyle(
                color: AppColors.primaryGold,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickRoleButtons() {
    if (!enableQuickRoleButtons) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF181614),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flash_on_rounded,
                color: AppColors.primaryGold,
                size: 15,
              ),
              const SizedBox(width: 6),
              const Text(
                'ĐĂNG NHẬP NHANH (3 VAI TRÒ)',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'DEV MODE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 1. Khách hàng
              Expanded(
                child: _buildRoleCard(
                  title: 'Khách hàng',
                  subtitle: 'VIP Member',
                  icon: Icons.person_rounded,
                  color: AppColors.primaryGold,
                  onTap: () => _quickLogin('customer'),
                ),
              ),
              const SizedBox(width: 8),
              // 2. Nhân viên
              Expanded(
                child: _buildRoleCard(
                  title: 'Nhân viên',
                  subtitle: 'Barista KDS',
                  icon: Icons.coffee_maker_rounded,
                  color: const Color(0xFF2ECC71),
                  onTap: () => _quickLogin('staff'),
                ),
              ),
              const SizedBox(width: 8),
              // 3. Quản trị
              Expanded(
                child: _buildRoleCard(
                  title: 'Quản trị',
                  subtitle: 'Admin Portal',
                  icon: Icons.admin_panel_settings_rounded,
                  color: const Color(0xFFE74C3C),
                  onTap: () => _quickLogin('admin'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterTab(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome bonus banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A3528), Color(0xFF10221A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ĐẶC QUYỀN THÀNH VIÊN MỚI',
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Tặng ngay 50 điểm thưởng khởi đầu vào tài khoản 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Tên người dùng Input
        _buildField(
          label: 'Tên người dùng',
          hint: 'Nhập họ và tên (ví dụ: Nguyễn Văn An)',
          controller: _regNameController,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),

        // Số điện thoại Input
        _buildField(
          label: 'Số điện thoại',
          hint: 'Nhập số điện thoại (ví dụ: 0901234567)',
          controller: _regPhoneController,
          icon: Icons.phone_iphone_rounded,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 14),

        // Mật khẩu Input
        _buildField(
          label: 'Mật khẩu',
          hint: 'Tối thiểu 6 ký tự',
          controller: _regPasswordController,
          icon: Icons.lock_outline_rounded,
          obscureText: _regObscurePassword,
          keyboardType: TextInputType.visiblePassword,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_regPasswordController.text.isNotEmpty)
                IconButton(
                  tooltip: 'Xoá để nhập lại',
                  icon: const Icon(
                    Icons.cancel_rounded,
                    color: Colors.white38,
                    size: 18,
                  ),
                  onPressed: () => setState(() {
                    _regPasswordController.clear();
                  }),
                ),
              IconButton(
                tooltip: _regObscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                icon: Icon(
                  _regObscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primaryGold.withOpacity(0.85),
                  size: 19,
                ),
                onPressed: () =>
                    setState(() => _regObscurePassword = !_regObscurePassword),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Register Button
        _buildSubmitButton(
          text: 'ĐĂNG KÝ TÀI KHOẢN 🎉',
          isLoading: authProvider.isLoading,
          onPressed: _onRegister,
        ),
        const SizedBox(height: 16),

        // Chuyển sang Đăng nhập
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Đã có tài khoản? ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: const Text(
                'Đăng nhập ngay',
                style: TextStyle(
                  color: AppColors.primaryGold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
