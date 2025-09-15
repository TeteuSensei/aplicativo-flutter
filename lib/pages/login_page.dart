import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final pass = TextEditingController();
  bool show = false;
  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
  final isValid = form.currentState?.validate() ?? false; // <- null-safe
  if (!isValid) return;

  setState(() => loading = true);
  final ok = await AuthService.I.login(email.text.trim(), pass.text);
  setState(() => loading = false);
  if (!mounted) return;

  if (ok) {
    Navigator.of(context).pushReplacementNamed('/home');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credenciais inválidas')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, size: 56, color: cs.primary),
                const SizedBox(height: 12),
                Text(
                  'Consultoria',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                            validator: (v) => (v == null || !v.contains('@')) ? 'Informe um e-mail válido' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: pass,
                            obscureText: !show,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => show = !show),
                                icon: Icon(show ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 4) ? 'Mínimo 4 caracteres' : null,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text('Recuperação em breve'))),
                              child: const Text('Esqueci minha senha'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: loading ? null : _submit,
                              child: loading
                                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Text('Entrar'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Não tem conta?'),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/register'),
                                child: const Text('Criar conta'),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}
