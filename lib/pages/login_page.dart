import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    form.save();

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // simula request
    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login simulado com sucesso')),
    );
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final spacing = 12.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Informe seu email';
                    if (!s.contains('@')) return 'Email inválido';
                    return null;
                  },
                  onSaved: (v) => _email = (v ?? '').trim(),
                ),
                SizedBox(height: spacing),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.length < 4) return 'Mínimo de 4 caracteres';
                    return null;
                  },
                  onSaved: (v) => _password = (v ?? '').trim(),
                ),
                SizedBox(height: spacing * 2),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Entrar'),
                  ),
                ),
                SizedBox(height: spacing),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/signup'),
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                  child: const Text('Continuar sem login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
