import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../../companies/controllers/companies_controller.dart';
import '../../investors/controllers/investors_controller.dart';
import '../../members/controllers/members_controller.dart';
import '../../packages/controllers/packages_controller.dart';
import '../../../widgets/desktop_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'InvesTrack Admin Login',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  DesktopTextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Username or Email',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) =>
                        _performLogin(context, context.read<AuthController>()),
                  ),
                  const SizedBox(height: 16),
                  DesktopTextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) =>
                        _performLogin(context, context.read<AuthController>()),
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthController>(
                    builder: (context, authController, child) {
                      return ElevatedButton(
                        onPressed: authController.isLoading
                          ? null
                          : () => _performLogin(context, authController),
                        child: authController.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Login'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performLogin(
    BuildContext context,
    AuthController authController,
  ) async {
    if (authController.isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username/email and password'),
        ),
      );
      return;
    }

    bool success = await authController.login(email, password);
    if (success && context.mounted) {
      // Fetch fresh data after successful login
      Provider.of<CompaniesController>(context, listen: false).loadCompanies();
      Provider.of<InvestorsController>(context, listen: false).loadInvestors();
      Provider.of<MembersController>(context, listen: false).loadMembers();
      Provider.of<PackagesController>(context, listen: false).loadPackages();

      context.go('/dashboard');
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authController.errorMessage ?? 'Login failed')),
      );
    }
  }
}
