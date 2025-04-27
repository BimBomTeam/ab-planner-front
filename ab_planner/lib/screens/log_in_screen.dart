import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ab_planner/screens/main_screen.dart';
import 'package:ab_planner/screens/sign_up_screen.dart';
import 'package:ab_planner/services/auth_service.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();
  bool _isLoading = false;
  bool _isResetLoading = false;

  Future<void> _logIn(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Proszę wypełnić wszystkie pola');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.login(email, password);

      if (!mounted) return;
      _showSuccess('Zalogowano pomyślnie!');
    } catch (e) {
      _showError(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = _resetEmailController.text.trim();

    if (email.isEmpty) {
      _showError('Proszę podać adres email');
      return;
    }

    setState(() {
      _isResetLoading = true;
    });

    try {
      await AuthService.resetPassword(email);
      if (!mounted) return;
      Navigator.of(context).pop(); // zamyka modal
      _showSuccess('Link do resetu hasła został wysłany na email.');
    } catch (e) {
      _showError(e.toString().replaceAll('Exception:', '').trim());
    } finally {
      setState(() {
        _isResetLoading = false;
      });
    }
  }

  void _showResetPasswordModal() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Resetuj hasło'),
          content: TextField(
            controller: _resetEmailController,
            decoration: const InputDecoration(
              labelText: 'Podaj email',
              prefixIcon: Icon(Icons.email),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              onPressed: _isResetLoading ? null : _resetPassword,
              child: _isResetLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Wyślij'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Błąd'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sukces'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Container(
          width: 350,
          height: 550,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1F38), Color(0xFF3A0CA3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(35.0),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Log In', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: 'Email ID',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showResetPasswordModal,
                        child: const Text(
                          'Zapomniałeś hasło?',
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _logIn(context),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Log In'),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            'Nie masz konta?',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpScreen()),
                            );
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
