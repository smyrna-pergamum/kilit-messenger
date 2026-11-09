import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';

/// The stickers Kilit draws (`assets/stickers/<name>.png`, made by
/// `scripts/stickers.py`). A sticker travels as its name only.
const stickers = [
  'kilit-hello',
  'kilit-love',
  'kilit-laugh',
  'kilit-ok',
  'kilit-party',
  'kilit-cool',
  'kilit-wow',
  'kilit-think',
  'kilit-sad',
  'kilit-angry',
  'kilit-sleepy',
  'kilit-shh',
];

/// A sticker by name. One this version does not have (a newer phone may
/// send it) shows as its name.
class StickerImage extends StatelessWidget {
  const StickerImage(this.name, {super.key, this.size = 140});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox(
      width: size,
      height: size,
      child: stickers.contains(name)
          ? Image.asset(
              'assets/stickers/$name.png',
              key: ValueKey('sticker-$name'),
              filterQuality: FilterQuality.medium,
            )
          : Center(
              child: Text(
                ':$name:',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.textMuted),
              ),
            ),
    );
  }
}

/// The emoji, a tab each. The phone's own emoji font draws them; nothing is
/// fetched.
const _emoji = <(IconData, String)>[
  (
    Icons.emoji_emotions_outlined,
    '😀 😃 😄 😁 😆 😅 😂 🤣 🙂 🙃 😉 😊 😇 🥰 😍 🤩 😘 😗 😚 😋 😛 😜 🤪 😝 '
        '🤗 🤭 🤫 🤔 🤐 🤨 😐 😑 😶 😏 😒 🙄 😬 😌 😔 😪 😴 😷 🤒 🤕 🤢 🥵 '
        '🥶 😵 🤯 🥳 😎 🤓 🧐 😕 😟 🙁 😮 😯 😲 😳 🥺 😦 😧 😨 😰 😥 😢 😭 '
        '😱 😖 😣 😞 😓 😩 😫 🥱 😤 😡 😠 🤬 😈 💀 👻 🤖',
  ),
  (
    Icons.back_hand_outlined,
    '👍 👎 👌 ✌️ 🤞 🤟 🤘 🤙 👈 👉 👆 👇 ☝️ ✋ 🤚 🖐️ 🖖 👋 👏 🙌 👐 🤲 🤝 🙏 '
        '✍️ 💪 🫶 👀 🧠 🫂 👶 👧 🧒 👦 👩 🧑 👨 👵 🧓 👴 🙋 🙆 🙅 🤷 🤦 💃 🕺',
  ),
  (
    Icons.favorite_border,
    '❤️ 🧡 💛 💚 💙 💜 🤎 🖤 🤍 💔 ❣️ 💕 💞 💓 💗 💖 💘 💝 💟 ✨ ⭐ 🌟 💫 🔥 '
        '💯 ✅ ❌ ❓ ❗ 💬 💭 🎉 🎊 🎈 🎁 🏆 🥇 🔔 🔒 🔓 🔑 🗝️',
  ),
  (
    Icons.pets_outlined,
    '🐶 🐱 🐭 🐹 🐰 🦊 🐻 🐼 🐨 🐯 🦁 🐮 🐷 🐸 🐵 🐔 🐧 🐦 🦆 🦉 🐺 🐴 🦄 🐝 '
        '🦋 🐌 🐞 🐢 🐍 🐙 🐬 🐳 🐟 🌸 🌹 🌻 🌷 🌱 🌲 🍀 🍁 🌍 🌙 ☀️ ⛅ 🌧️ ❄️ 🌈',
  ),
  (
    Icons.restaurant_outlined,
    '🍏 🍎 🍐 🍊 🍋 🍌 🍉 🍇 🍓 🍒 🍑 🥭 🍍 🥥 🥝 🍅 🥑 🥦 🥕 🌽 🥔 🍞 🧀 🥚 '
        '🍳 🥞 🍔 🍟 🍕 🌭 🥪 🌮 🍝 🍜 🍲 🍣 🍰 🎂 🍪 🍫 🍩 🍿 ☕ 🍵 🥤 🍺 🍷 🥂',
  ),
  (
    Icons.directions_car_outlined,
    '⚽ 🏀 🏈 ⚾ 🎾 🏐 🎱 🏓 🏸 🥊 🚴 🏃 🧘 🎮 🎲 🎯 🎨 🎬 🎤 🎧 🎵 🎸 📚 ✏️ '
        '💻 📱 📷 💡 🔧 🧳 🚗 🚕 🚌 🚲 ✈️ 🚀 🚢 🏠 🏡 🏫 🏥 ⛺ 🏖️ 🗺️ ⏰ 📅 📍',
  ),
];

/// Emoji and stickers, in place of the keyboard under a message box.
class EmojiPanel extends StatelessWidget {
  const EmojiPanel({super.key, required this.onEmoji, required this.onSticker});

  /// Puts an emoji into the message being written.
  final ValueChanged<String> onEmoji;

  /// Sends a sticker at once.
  final ValueChanged<String> onSticker;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return DefaultTabController(
      length: _emoji.length + 1,
      child: Container(
        key: const ValueKey('emoji-panel'),
        height: 300,
        color: t.surface,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(
                  key: const ValueKey('tab-stickers'),
                  icon: Tooltip(
                    message: l.stickers,
                    child: const Icon(Icons.lock_outline),
                  ),
                ),
                for (final (icon, _) in _emoji) Tab(icon: Icon(icon)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  GridView.count(
                    padding: const EdgeInsets.all(8),
                    crossAxisCount: 4,
                    children: [
                      for (final s in stickers)
                        InkWell(
                          key: ValueKey('pick-sticker-$s'),
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => onSticker(s),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: StickerImage(s, size: 72),
                          ),
                        ),
                    ],
                  ),
                  for (final (_, list) in _emoji)
                    GridView.extent(
                      padding: const EdgeInsets.all(6),
                      maxCrossAxisExtent: 44,
                      children: [
                        for (final e in list.split(' '))
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => onEmoji(e),
                            child: Center(
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 26),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Puts [text] into [c] where the cursor is, replacing any selection.
void insertAtCursor(TextEditingController c, String text) {
  final v = c.value;
  final sel = v.selection.isValid
      ? v.selection
      : TextSelection.collapsed(offset: v.text.length);
  final next = v.text.replaceRange(sel.start, sel.end, text);
  c.value = TextEditingValue(
    text: next,
    selection: TextSelection.collapsed(offset: sel.start + text.length),
  );
}
