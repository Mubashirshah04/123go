import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      try {
                        if (_isLogin) {
                          await ref.read(authServiceProvider).signInWithEmail(_emailController.text, _passwordController.text);
                        } else {
                          await ref.read(authServiceProvider).signUpWithEmail(_emailController.text, _passwordController.text);
                        }
                        if (mounted) Navigator.of(context).pop();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auth error: $e')));
                        }
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
              child: Text(_isLogin ? 'Login' : 'Create Account'),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin ? 'Need an account? Sign Up' : 'Have an account? Login'),
            ),
            const Divider(),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Continue with Google'),
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      try {
                        await ref.read(authServiceProvider).signInWithGoogle();
                        if (mounted) Navigator.of(context).pop();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auth error: $e')));
                        }
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}