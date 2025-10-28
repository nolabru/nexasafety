import 'package:flutter/material.dart';
import 'package:nexasafety/core/services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  String _name = '';
  String _email = '';
  String _password = '';
  String _phone = '';
  bool _loading = false;

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    form.save();

    setState(() => _loading = true);
    try {
      await AuthService().register(
        email: _email,
        password: _password,
        nome: _name,
        telefone: _phone,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado. Faça login.')),
      );
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = 12.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Informe seu nome';
                    return null;
                  },
                  onSaved: (v) => _name = (v ?? '').trim(),
                ),
                SizedBox(height: spacing),
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
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    hintText: 'Ex.: 71999999999',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Informe seu telefone';
                    return null;
                  },
                  onSaved: (v) => _phone = (v ?? '').trim(),
                ),
                SizedBox(height: spacing),
                TextFormField(
                  controller: _passwordController,
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
                        : const Text('Cadastrar'),
                  ),
                ),
                SizedBox(height: spacing),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).pushReplacementNamed('/login'),
                  child: const Text('Já tem conta? Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
