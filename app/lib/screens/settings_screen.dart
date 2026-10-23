import 'package:flutter/material.dart';

import '../state/session.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final core = session.core;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Güvenlik numaran',
                  style: TextStyle(color: t.text, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bir kişiyi doğrularken iki telefonda da aynı olmalı.',
                  style: TextStyle(color: t.textMuted),
                ),
                const SizedBox(height: 12),
                FutureBuilder<String>(
                  future: core.myFingerprint(),
                  builder: (context, snap) => SelectableText(
                    snap.data ?? '…',
                    key: const ValueKey('fingerprint'),
                    style: TextStyle(
                      fontFamily: monoFamily,
                      fontSize: 16,
                      color: t.text,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(
              core.isHardwareBacked
                  ? Icons.verified_user_outlined
                  : Icons.warning_amber_rounded,
              color: core.isHardwareBacked ? t.safe : t.danger,
            ),
            title: Text('PIN koruması: ${core.pinProtection}'),
            subtitle: Text(
              core.isHardwareBacked
                  ? 'PIN bu cihazın donanım anahtarına bağlı. Kasa dosyası kopyalansa bile başka bir cihazda denenemez.'
                  : 'Donanım anahtarı yok: kasa dosyası kopyalanırsa PIN başka bir cihazda tahmin edilebilir.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: session.lock,
          icon: const Icon(Icons.lock_outline),
          label: const Text('Şimdi kilitle'),
        ),
      ],
    );
  }
}
