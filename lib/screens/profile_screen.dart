import 'package:flutter/material.dart';
import '../core/app_controller.dart';
import '../theme/vertice_theme.dart';
import '../widgets/vertice_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final VerticeAppController controller;

  const ProfileScreen({super.key, required this.controller});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.controller.preferences.guestName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final prefs = ctrl.preferences;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      children: [
        const Text(
          'Perfil Visitante',
          style: TextStyle(
            color: VerticeColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: VerticeColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: VerticeColors.border),
          ),
          child: Row(
            children: [
              const VerticeLogoMark(size: 58, showText: false),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prefs.guestName,
                      style: const TextStyle(
                        color: VerticeColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Modo Visitante ativo • Sem login ou senha',
                      style: TextStyle(color: VerticeColors.purpleLight, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Preferências Locais',
          style: TextStyle(color: VerticeColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VerticeColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: VerticeColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nome de exibição', style: TextStyle(color: VerticeColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(hintText: 'Seu nome de visitante'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VerticeColors.purpleNeon,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      ctrl.updatePreferences(
                        prefs.copyWith(guestName: _nameCtrl.text.trim().isEmpty ? 'Visitante Vértice' : _nameCtrl.text.trim()),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Preferências salvas localmente.')),
                      );
                    },
                    child: const Text('Salvar', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Volume padrão', style: TextStyle(color: VerticeColors.textPrimary)),
                  Text(
                    '${(prefs.defaultVolume * 100).round()}%',
                    style: const TextStyle(color: VerticeColors.purpleLight, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Slider(
                min: 0,
                max: 1,
                activeColor: VerticeColors.purpleNeon,
                inactiveColor: VerticeColors.border,
                value: prefs.defaultVolume,
                onChanged: (val) => ctrl.updatePreferences(prefs.copyWith(defaultVolume: val)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: VerticeColors.purpleNeon,
                title: const Text('Aviso de qualidade de streaming', style: TextStyle(color: VerticeColors.textPrimary, fontSize: 14)),
                subtitle: const Text('Streaming online via fontes abertas/licenciadas', style: TextStyle(color: VerticeColors.textSecondary, fontSize: 12)),
                value: prefs.highQualityStreamNotice,
                onChanged: (val) => ctrl.updatePreferences(prefs.copyWith(highQualityStreamNotice: val)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Sobre o VÉRTICE MUSIC',
          style: TextStyle(color: VerticeColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: VerticeColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: VerticeColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VÉRTICE MUSIC v1.0.0',
                style: TextStyle(color: VerticeColors.textPrimary, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Streaming online com gravações reais do Internet Archive. Cada faixa precisa ter licença pública ou Creative Commons compatível e arquivo MP3 identificado nos metadados.',
                style: TextStyle(color: VerticeColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 10),
              ...ctrl.providers.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '• ${p.displayName}: ${p.licenseSummary}',
                    style: const TextStyle(color: VerticeColors.textMuted, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
