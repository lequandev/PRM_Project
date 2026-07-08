import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../util/colors.dart';
import '../widgets/custom_text_field.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final bool isDarkMode;
  const RegisterScreen({super.key, this.isDarkMode = true});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreeTerms = true;
  bool _isSubmitting = false;
  bool _registerSuccess = false;
  String _errorMessage = '';

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _selectedBirthday;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2004, 2, 3),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() => _selectedBirthday = pickedDate);
    }
  }

  void _handleRegister() async {
    if (_nameController.text.trim().isEmpty ||
        _selectedBirthday == null ||
        _passwordController.text.isEmpty) {
      setState(
        () => _errorMessage = 'Please fill in all mandatory profile values.',
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Confirm passkey does not match.');
      return;
    }

    setState(() {
      _errorMessage = '';
      _isSubmitting = true;
    });

    try {
      final user = await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullname: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        birthday: _selectedBirthday,
      );

      if (user != null) {
        setState(() => _registerSuccess = true);
      }
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? LuxeColors.bgDark
          : LuxeColors.bgLight,
      body: SafeArea(
        child: _registerSuccess ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: LuxeColors.goldPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome to Luxe Reserve',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LuxeColors.goldPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'ENTER LUXE LOUNGE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              const Text(
                'Register Membership',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_errorMessage.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
          CustomTextField(
            label: 'FULL NAME',
            controller: _nameController,
            icon: Icons.person_outline,
            hint: 'Nguyen Le Quan',
            isDarkMode: widget.isDarkMode,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'PREMIUM EMAIL',
                  controller: _emailController,
                  icon: Icons.mail_outline,
                  hint: 'alex@luxe.com',
                  keyboardType: TextInputType.emailAddress,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'MOBILE PHONE',
                  controller: _phoneController,
                  icon: Icons.phone_android,
                  hint: '0375523715',
                  keyboardType: TextInputType.phone,
                  isDarkMode: widget.isDarkMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'DATE OF BIRTH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _presentDatePicker,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? LuxeColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cake_outlined, size: 18, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    _selectedBirthday == null
                        ? 'Select your birthday'
                        : DateFormat('yyyy-MM-dd').format(_selectedBirthday!),
                    style: TextStyle(
                      color: _selectedBirthday == null
                          ? Colors.grey
                          : (widget.isDarkMode ? Colors.white : Colors.black),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'CREATE SECURE PASSKEY',
            controller: _passwordController,
            icon: Icons.lock_outline,
            hint: 'Password',
            obscureText: !_showPassword,
            isDarkMode: widget.isDarkMode,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
                size: 16,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'CONFIRM SECURE PASSKEY',
            controller: _confirmPasswordController,
            icon: Icons.lock_outline,
            hint: 'Confirm Password',
            obscureText: !_showConfirmPassword,
            isDarkMode: widget.isDarkMode,
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                size: 16,
              ),
              onPressed: () =>
                  setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LuxeColors.goldPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSubmitting ? null : _handleRegister,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'REQUEST PREMIUM MEMBERSHIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
