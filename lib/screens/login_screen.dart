import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoiso/constants.dart';
import 'package:invoiso/providers/repositories.dart';
import 'package:invoiso/screens/change_password_screen.dart';

import '../providers/app_config_provider.dart';
import 'dashboard_screen.dart';

// Login Screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(AppEditionConfig cfg) async {
    // for cloud the username will be email
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final usernameText = cfg.isCloud ? "Email" : "Username";

    if (username.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter $usernameText and password')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    final user =
        await ref.read(authRepositoryProvider).getUser(username, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid credentials')),
      );
      return;
    }

    if (cfg.isCloud) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(user)),
      );
    } else if (!user.passwordChanged && !cfg.isCloud) {
      // Force password change on first login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasswordScreen(user: user, forced: true),
        ),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen(user)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = ref.watch(appEditionConfigProvider);
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Card(
          elevation: 8,
          color: Colors.white,
          child: Container(
            width: MediaQuery.sizeOf(context).width * 0.25,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/celltek_logo.png',
                  width: 230,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                AppSpacing.hXlarge,
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: cfg.isCloud ? 'Email' : 'Username',
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: cfg.isCloud
                      ? TextInputType.emailAddress
                      : TextInputType.text,
                ),
                AppSpacing.hMedium,
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onSubmitted: (_) => _login(cfg),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                if (!cfg.isCloud) ...[
                  AppSpacing.hMedium,
                  Text(
                    'Default login: username admin / password admin.\nYou will be prompted to set a new password after first login.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
                AppSpacing.hXlarge,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _login(cfg),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
                AppSpacing.hLarge,
                Text(
                  AppConfig.version,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
