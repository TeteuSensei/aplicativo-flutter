import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final pass2 = TextEditingController();
  bool show = false;
  bool loading = false;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    pass.dispose();
    pass2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = form.currentState?.validate() ?? false; // <- null-safe
    if (!isValid) return;

    setState(() => loading = true);
    final ok = await AuthService.I.register(
      name: name.text.trim(),
      email: email.text.trim(),
      password: pass.text,
    );
    setState(() => loading = false);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Conta criada! Faça login.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Falha ao cadastrar')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Nome completo',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
                      ),
                      const SizedBox(height: 12),
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
                          labelText: 'Senha (min. 6)',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => show = !show),
                            icon: Icon(show ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: pass2,
                        obscureText: !show,
                        decoration: const InputDecoration(
                          labelText: 'Confirmar senha',
                          prefixIcon: Icon(Icons.lock_reset),
                        ),
                        validator: (v) => (v != pass.text) ? 'As senhas não coincidem' : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading ? null : _submit,
                          child: loading
                              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Criar conta'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
