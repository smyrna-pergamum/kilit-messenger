import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// Where preferences are kept. They are not secret (a theme, a language,
/// one switch) and are needed before the vault opens, so they live in a
/// small JSON file beside the vault rather than inside it.
abstract interface class PrefsStore {
  Future<Map<String, Object?>> read();
  Future<void> write(Map<String, Object?> values);
}

class FilePrefsStore implements PrefsStore {
  FilePrefsStore(this.file);
  final File file;

  @override
  Future<Map<String, Object?>> read() async {
    try {
      final v = jsonDecode(await file.readAsString());
      return v is Map<String, Object?> ? v : {};
    } on Object {
      return {}; // missing or damaged: start from the defaults
    }
  }

  @override
  Future<void> write(Map<String, Object?> values) async {
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode(values), flush: true);
    await tmp.rename(file.path);
  }
}

class MemoryPrefsStore implements PrefsStore {
  MemoryPrefsStore([Map<String, Object?>? initial]) : values = {...?initial};
  Map<String, Object?> values;

  @override
  Future<Map<String, Object?>> read() async => {...values};

  @override
  Future<void> write(Map<String, Object?> v) async => values = {...v};
}

/// The languages Kilit ships, by code. English is the main language: the
/// default for new installs and the fallback for any other system language.
/// Each language is named in itself, so it can be found by someone who
/// does not read the language currently on screen.
const supportedLanguages = {
  'en': 'English',
  'ar': 'العربية',
  'de': 'Deutsch',
  'es': 'Español',
  'fa': 'فارسی',
  'fr': 'Français',
  'id': 'Bahasa Indonesia',
  'it': 'Italiano',
  'ja': '日本語',
  'pt': 'Português',
  'ru': 'Русский',
  'tr': 'Türkçe',
  'uk': 'Українська',
  'vi': 'Tiếng Việt',
  'zh': '中文（简体）',
};

const defaultLanguage = 'en';

class Prefs extends ChangeNotifier {
  Prefs._(this._store, this._theme, this._language, this._clipboardHint);

  static Future<Prefs> load(PrefsStore store) async {
    final v = await store.read();
    final theme =
        ThemeMode.values.where((m) => m.name == v['theme']).firstOrNull ??
        ThemeMode.system;
    // absent: a new install, English; "system": follow the device
    final lang = v.containsKey('language') ? v['language'] : defaultLanguage;
    return Prefs._(
      store,
      theme,
      lang is String && supportedLanguages.containsKey(lang) ? lang : null,
      v['clipboardHint'] == true,
    );
  }

  final PrefsStore _store;
  ThemeMode _theme;
  String? _language;
  bool _clipboardHint;

  ThemeMode get themeMode => _theme;

  /// A code from [supportedLanguages], or null to follow the system.
  String? get language => _language;

  /// Whether the vault offers to open a KLT1: message found on the clipboard.
  bool get clipboardHint => _clipboardHint;

  Locale? get locale => _language == null ? null : Locale(_language!);

  /// Settings sections the user has open. Kept for as long as the app
  /// runs, not saved.
  final Set<String> openSections = {'protections'};

  Future<void> _save() async {
    notifyListeners();
    await _store.write({
      'theme': _theme.name,
      'language': _language,
      'clipboardHint': _clipboardHint,
    });
  }

  Future<void> setThemeMode(ThemeMode m) {
    _theme = m;
    return _save();
  }

  Future<void> setLanguage(String? code) {
    _language = code;
    return _save();
  }

  Future<void> setClipboardHint(bool on) {
    _clipboardHint = on;
    return _save();
  }
}
