import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/ui/formatters.dart';
import '../../core/ui/widgets.dart';
import '../../data/api/api_exception.dart';
import '../../data/auth/session.dart';
import '../../data/providers.dart';
import 'onboarding_widgets.dart';

/// Step 1: create an account or sign in.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final session = ref.read(sessionProvider.notifier);
      if (_register) {
        await session.register(_email.text.trim(), _password.text);
      } else {
        await session.login(_email.text.trim(), _password.text);
      }
    } on ApiException catch (e) {
      setState(() => _error = switch (e.code) {
            'invalid_credentials' => l10n.wrongCredentials,
            'email_taken' => l10n.emailTaken,
            'network' => l10n.networkError,
            _ => e.fieldErrors.values.expand((v) => v).firstOrNull ?? l10n.somethingWrong(e.message),
          });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editServer() async {
    final config = ref.read(appConfigProvider);
    final controller = TextEditingController(text: config.baseUrl);
    final l10n = context.l10n;
    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.server),
        content: TextField(controller: controller, keyboardType: TextInputType.url, decoration: InputDecoration(hintText: l10n.serverHint)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: Text(l10n.save)),
        ],
      ),
    );
    controller.dispose();
    if (url == null) return;
    await config.setBaseUrl(url);
    ref.invalidate(tokenManagerProvider);
    ref.invalidate(apiClientProvider);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), children: [
              const BanknotesIllustration(),
              if (_register) ...[const StepDots(step: 1), const SizedBox(height: 20)],
              RiseIn(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.welcomeTitle, style: text.headlineMedium?.copyWith(height: 1.2)),
                  const SizedBox(height: 8),
                  Text(l10n.welcomeSubtitle, style: text.bodyMedium?.copyWith(color: c.textSecondary, height: 1.5, fontSize: 15)),
                ]),
              ),
              const SizedBox(height: 20),
              RiseIn(
                index: 1,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  FieldLabel(l10n.email),
                  TextFormField(
                    key: const Key('email'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(hintText: l10n.emailHint),
                    validator: (v) => v == null || !v.contains('@') ? l10n.invalidEmail : null,
                  ),
                  const SizedBox(height: 14),
                  FieldLabel(l10n.password),
                  TextFormField(
                    key: const Key('password'),
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(hintText: l10n.passwordHint),
                    validator: (v) => v == null || v.length < 8 ? l10n.shortPassword : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ]),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: c.danger)),
              ],
              const SizedBox(height: 24),
              PrimaryButton(label: _register ? l10n.createAccount : l10n.signIn, busy: _busy, onPressed: _submit),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() {
                  _register = !_register;
                  _error = null;
                }),
                child: Text(_register ? l10n.haveAccount : l10n.noAccount, style: TextStyle(color: c.accentText)),
              ),
              TextButton(
                onPressed: _editServer,
                child: Text('${l10n.server}: ${Uri.tryParse(ref.watch(appConfigProvider).baseUrl)?.authority ?? ''}',
                    style: TextStyle(color: c.textSecondary, fontSize: 12)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
