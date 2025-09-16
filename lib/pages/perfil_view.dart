// lib/pages/perfil_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import '../services/auth_service.dart';

/// Página de Perfil (Material 3)
/// - Header com avatar, nome e botões de ação
/// - Seções de Conta, Preferências, Privacidade/Sobre
/// - Botão Sair
/// TODO (integração com API):
///   - Carregar nome/username/bio/foto reais do usuário autenticado
///   - Implementar update de perfil (PUT /perfil)
///   - Alterar/Resetar senha
///   - Upload da foto de perfil
class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  // Estados locais (placeholders até integrar com API)
  String nome = 'Seu nome';
  String username = '@usuario';
  String bio = 'Sem bio no momento.';
  bool notificacoes = true;
  bool salvarHistorico = true;
  bool twoFA = false;

  // Token apenas para exibição/cópia (NUNCA logue isso em produção)
  String? get token => AuthService.I.token;

  // Formata o token pra mostrar só início/fim
  String _maskToken(String? t) {
    if (t == null || t.isEmpty) return '-';
    if (t.length <= 12) return t;
    return '${t.substring(0, 6)}…${t.substring(t.length - 6)}';
  }

  void _copiarToken() async {
    final t = token ?? '';
    if (t.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: t));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token copiado para a área de transferência')),
    );
  }

  void _abrirEditarPerfil() async {
    // Abre um bottom sheet para editar nome/username/bio (somente UI por enquanto)
    final result = await showModalBottomSheet<_PerfilEdicaoResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => _EditarPerfilSheet(
        nomeInicial: nome,
        usernameInicial: username,
        bioInicial: bio,
      ),
    );
    if (result != null && mounted) {
      // TODO: chamar API (PUT /perfil) e depois setar o retorno real
      setState(() {
        nome = result.nome;
        username = result.username;
        bio = result.bio;
      });
    }
  }

  void _trocarFoto() async {
    // Apenas UI – integração com câmera/galeria depois (image_picker)
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abrir câmera (TODO)')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abrir galeria (TODO)')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _alterarSenha() {
    // TODO: navegar para página de alterar senha ou abrir modal (depende da sua rota)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alterar senha (TODO)')),
    );
  }

  void _baixarDados() {
    // TODO: endpoint para exportação LGPD/GDPR
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solicitar download dos dados (TODO)')),
    );
  }

  void _deletarConta() async {
    // Confirmação "forte"
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _ConfirmarExclusaoDialog(),
    );
    if (ok == true && mounted) {
      // TODO: chamar DELETE /conta
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta solicitada para exclusão (TODO)')),
      );
    }
  }

  void _sair() {
    AuthService.I.logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          // ===== Header do Perfil =====
          _PerfilHeader(
            nome: nome,
            username: username,
            bio: bio,
            onEditar: _abrirEditarPerfil,
            onTrocarFoto: _trocarFoto,
          ),
          const SizedBox(height: 16),

          // ===== Seção: Conta =====
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Nome'),
                  subtitle: Text(nome),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: _abrirEditarPerfil,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Username'),
                  subtitle: Text(username),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: _abrirEditarPerfil,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.vpn_key_outlined),
                  title: const Text('Token'),
                  subtitle: Text(_maskToken(token)),
                  trailing: IconButton(
                    tooltip: 'Copiar token',
                    onPressed: _copiarToken,
                    icon: const Icon(Icons.copy_all_outlined),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_reset_outlined),
                  title: const Text('Alterar senha'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _alterarSenha,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ===== Seção: Preferências =====
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Notificações'),
                  value: notificacoes,
                  onChanged: (v) => setState(() => notificacoes = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.bookmark_outline),
                  title: const Text('Salvar histórico de treinos'),
                  value: salvarHistorico,
                  onChanged: (v) => setState(() => salvarHistorico = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.verified_user_outlined),
                  title: const Text('Autenticação em 2 etapas'),
                  value: twoFA,
                  onChanged: (v) => setState(() => twoFA = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ===== Seção: Privacidade / Sobre =====
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacidade e termos'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    // TODO: abrir webview/página com os termos
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abrir termos (TODO)')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Baixar meus dados'),
                  onTap: _baixarDados,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Sobre o app'),
                  subtitle: const Text('Consultoria • v1.0.0 (dev)'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: cs.error),
                  title: Text('Excluir conta', style: TextStyle(color: cs.error)),
                  onTap: _deletarConta,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ===== Sair =====
          FilledButton.tonalIcon(
            onPressed: _sair,
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// =======================  COMPONENTES UI  ===========================
// ===================================================================

/// Header do perfil com avatar grande, nome, @username e botões de ação
class _PerfilHeader extends StatelessWidget {
  final String nome;
  final String username;
  final String bio;
  final VoidCallback onEditar;
  final VoidCallback onTrocarFoto;

  const _PerfilHeader({
    required this.nome,
    required this.username,
    required this.bio,
    required this.onEditar,
    required this.onTrocarFoto,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Usa surfaceVariant para um visual levemente destacado
        color: cs.surfaceVariant.withOpacity(.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(.4)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: onTrocarFoto,
                  borderRadius: BorderRadius.circular(24),
                  child: Ink(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.outlineVariant.withOpacity(.5)),
                    ),
                    child: Icon(Icons.camera_alt, size: 18, color: cs.onPrimaryContainer),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            nome,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(username, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(
            bio,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar perfil'),
              ),
              FilledButton.tonalIcon(
                onPressed: onTrocarFoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Trocar foto'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===== Bottom sheet de edição de perfil =====
class _EditarPerfilSheet extends StatefulWidget {
  final String nomeInicial;
  final String usernameInicial;
  final String bioInicial;
  const _EditarPerfilSheet({
    required this.nomeInicial,
    required this.usernameInicial,
    required this.bioInicial,
  });

  @override
  State<_EditarPerfilSheet> createState() => _EditarPerfilSheetState();
}

class _EditarPerfilSheetState extends State<_EditarPerfilSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _userCtrl;
  late final TextEditingController _bioCtrl;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.nomeInicial);
    _userCtrl = TextEditingController(text: widget.usernameInicial);
    _bioCtrl = TextEditingController(text: widget.bioInicial);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _userCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    // Apenas devolve os dados — a integração com API fica no caller
    Navigator.of(context).pop(
      _PerfilEdicaoResult(
        nome: _nomeCtrl.text.trim(),
        username: _userCtrl.text.trim(),
        bio: _bioCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, viewInsets + 16),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_outlined),
                const SizedBox(width: 8),
                Text(
                  'Editar perfil',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu nome' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _userCtrl,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: '@usuario',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu username' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _bioCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Conte um pouco sobre você',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.check),
              label: const Text('Salvar alterações'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerfilEdicaoResult {
  final String nome;
  final String username;
  final String bio;
  _PerfilEdicaoResult({required this.nome, required this.username, required this.bio});
}

// ===== Diálogo de exclusão de conta (confirmação forte) =====
class _ConfirmarExclusaoDialog extends StatefulWidget {
  const _ConfirmarExclusaoDialog();

  @override
  State<_ConfirmarExclusaoDialog> createState() => _ConfirmarExclusaoDialogState();
}

class _ConfirmarExclusaoDialogState extends State<_ConfirmarExclusaoDialog> {
  final _ctrl = TextEditingController();
  bool get _habilita => _ctrl.text.toUpperCase() == 'DELETAR';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir conta'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Essa ação é irreversível. Para confirmar, digite:\n\nDELETAR',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            textCapitalization: TextCapitalization.characters,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'DELETAR',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(
          onPressed: _habilita ? () => Navigator.pop(context, true) : null,
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
          child: const Text('Excluir'),
        ),
      ],
    );
  }
}
