import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// دعم الترجمة العربية
class AppLocalizations {
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
