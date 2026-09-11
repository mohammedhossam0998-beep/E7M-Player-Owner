import 'package:flutter/material.dart';
import 'package:e7m/core/theme/app_spacing.dart';

extension ContextExtensions on BuildContext {
  // استخدام sizeOf يمنع الـ Widget من إعادة البناء عند تغير خصائص أخرى في MediaQuery
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;

  void hideKeyboard() => FocusScope.of(this).unfocus();
}

extension PaddingExtension on Widget {
  Widget withPadding([double value = AppSpacing.sm]) {
    return Padding(padding: EdgeInsets.all(value), child: this);
  }
}