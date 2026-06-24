import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom [TextField] wrapper that manually handles standard keyboard shortcuts
/// (Backspace, Delete, Copy, Paste, Cut, Select All) on desktop platforms.
/// This acts as a robust workaround for known Flutter Windows engine bugs where
/// non-character keys and shortcuts fail to work when using non-English IMEs (e.g., Lao).
class DesktopTextField extends StatefulWidget {
  final TextEditingController? controller;
  final InputDecoration decoration;
  final bool obscureText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextSelectionControls? selectionControls;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;

  const DesktopTextField({
    super.key,
    this.controller,
    this.decoration = const InputDecoration(),
    this.obscureText = false,
    this.focusNode,
    this.onChanged,
    this.keyboardType,
    this.selectionControls,
    this.onSubmitted,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  State<DesktopTextField> createState() => _DesktopTextFieldState();
}

class _DesktopTextFieldState extends State<DesktopTextField> {
  FocusNode? _internalFocusNode;
  TextEditingController? _internalController;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());
  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    // Set up low-level key event listener
    _focusNode.onKeyEvent = _handleKeyEvent;
  }

  @override
  void didUpdateWidget(DesktopTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.onKeyEvent = null;
      _focusNode.onKeyEvent = _handleKeyEvent;
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final isControlPressed = HardwareKeyboard.instance.isControlPressed;
    final isMetaPressed =
        HardwareKeyboard.instance.isMetaPressed; // Command key on macOS
    final isShortcutModifier = isControlPressed || isMetaPressed;

    // 1. Backspace
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      final text = _controller.text;
      final selection = _controller.selection;
      if (!selection.isValid) return KeyEventResult.ignored;

      final start = selection.start;
      final end = selection.end;

      if (start != end) {
        final newText = text.replaceRange(start, end, '');
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: start),
        );
        if (widget.onChanged != null) widget.onChanged!(newText);
        return KeyEventResult.handled;
      } else {
        final offset = selection.baseOffset;
        if (offset > 0) {
          final newText =
              text.substring(0, offset - 1) + text.substring(offset);
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: offset - 1),
          );
          if (widget.onChanged != null) widget.onChanged!(newText);
          return KeyEventResult.handled;
        }
      }
    }

    // 2. Delete
    if (event.logicalKey == LogicalKeyboardKey.delete) {
      final text = _controller.text;
      final selection = _controller.selection;
      if (!selection.isValid) return KeyEventResult.ignored;

      final start = selection.start;
      final end = selection.end;

      if (start != end) {
        final newText = text.replaceRange(start, end, '');
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: start),
        );
        if (widget.onChanged != null) widget.onChanged!(newText);
        return KeyEventResult.handled;
      } else {
        final offset = selection.baseOffset;
        if (offset < text.length) {
          final newText =
              text.substring(0, offset) + text.substring(offset + 1);
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: offset),
          );
          if (widget.onChanged != null) widget.onChanged!(newText);
          return KeyEventResult.handled;
        }
      }
    }

    // 3. Paste (Ctrl + V / Cmd + V)
    if (isShortcutModifier && event.logicalKey == LogicalKeyboardKey.keyV) {
      Clipboard.getData(Clipboard.kTextPlain).then((data) {
        if (data != null && data.text != null) {
          final pasteText = data.text!;
          final text = _controller.text;
          final selection = _controller.selection;
          if (!selection.isValid) return;

          final start = selection.start;
          final end = selection.end;
          final newText = text.replaceRange(start, end, pasteText);
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(
              offset: start + pasteText.length,
            ),
          );
          if (widget.onChanged != null) widget.onChanged!(newText);
        }
      });
      return KeyEventResult.handled;
    }

    // 4. Copy (Ctrl + C / Cmd + C)
    if (isShortcutModifier && event.logicalKey == LogicalKeyboardKey.keyC) {
      final text = _controller.text;
      final selection = _controller.selection;
      if (selection.isValid && selection.start != selection.end) {
        final selectedText = text.substring(selection.start, selection.end);
        Clipboard.setData(ClipboardData(text: selectedText));
      }
      return KeyEventResult.handled;
    }

    // 5. Cut (Ctrl + X / Cmd + X)
    if (isShortcutModifier && event.logicalKey == LogicalKeyboardKey.keyX) {
      final text = _controller.text;
      final selection = _controller.selection;
      if (selection.isValid && selection.start != selection.end) {
        final start = selection.start;
        final end = selection.end;
        final selectedText = text.substring(start, end);
        Clipboard.setData(ClipboardData(text: selectedText));
        final newText = text.replaceRange(start, end, '');
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: start),
        );
        if (widget.onChanged != null) widget.onChanged!(newText);
      }
      return KeyEventResult.handled;
    }

    // 6. Select All (Ctrl + A / Cmd + A)
    if (isShortcutModifier && event.logicalKey == LogicalKeyboardKey.keyA) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: widget.decoration,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      selectionControls: widget.selectionControls,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
    );
  }
}

/// A custom [TextFormField] wrapper that manually handles standard keyboard shortcuts
/// on desktop platforms. This behaves identically to [DesktopTextField] but integrates
/// directly with [Form] validation.
class DesktopTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final InputDecoration decoration;
  final bool obscureText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final TextInputType? keyboardType;
  final TextSelectionControls? selectionControls;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;

  const DesktopTextFormField({
    super.key,
    this.controller,
    this.decoration = const InputDecoration(),
    this.obscureText = false,
    this.focusNode,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.keyboardType,
    this.selectionControls,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  State<DesktopTextFormField> createState() => _DesktopTextFormFieldState();
}

class _DesktopTextFormFieldState extends State<DesktopTextFormField> {
  FocusNode? _internalFocusNode;
  TextEditingController? _internalController;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());
  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _focusNode.onKeyEvent = _handleKeyEvent;
  }

  @override
  void didUpdateWidget(DesktopTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.onKeyEvent = null;
      _focusNode.onKeyEvent = _handleKeyEvent;
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final isControlPressed = HardwareKeyboard.instance.isControlPressed;
    final isMetaPressed = HardwareKeyboard.instance.isMetaPressed;
    final isShortcutModifier = isControlPressed || isMetaPressed;

    // 1. Backspace
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      final text = _controller.text;
      final selection = _controller.selection;
      if (!selection.isValid) return KeyEventResult.ignored;

      final start = selection.start;
      final end = selection.end;

      if (start != end) {
        final newText = text.replaceRange(start, end, '');
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: start),
        );
        if (widget.onChanged != null) widget.onChanged!(newText);
        return KeyEventResult.handled;
      } else {
        final offset = selection.baseOffset;
        if (offset > 0) {
          final newText =
              text.substring(0, offset - 1) + text.substring(offset);
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: offset - 1),
          );
          if (widget.onChanged != null) widget.onChanged!(newText);
          return KeyEventResult.handled;
        }
      }
    }

    // 2. Delete
    if (event.logicalKey == LogicalKeyboardKey.delete) {
      final text = _controller.text;
      final selection = _controller.selection;
      if (!selection.isValid) return KeyEventResult.ignored;

      final start = selection.start;
      final end = selection.end;

      if (start != end) {
        final newText = text.replaceRange(start, end, '');
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: start),
        );
        if (widget.onChanged != null) widget.onChanged!(newText);
        return KeyEventResult.handled;
      } else {
        final offset = selection.baseOffset;
        if (offset < text.length) {
          final newText =
              text.substring(0, offset) + text.substring(offset + 1);
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: offset),
          );
          if (widget.onChanged != null) widget.onChanged!(newText);
          return KeyEventResult.handled;
        }
      }
    }

    // 3. Paste (Ctrl + V / Cmd + V)
    if (isShortcutModifier && event.logicalKey == LogicalKeyboardKey.keyV) {
      Clipboard.getData(Clipboard.kTextPlain).then((data) {
        if (data != null && data.text != null) {
          final pasteText = data.text!;
          final text = _controller.text;
          final selection = _controller.selection;
          if (!selection.isValid) return;

          final start = selection.start;
          final end = selection.end;
          final newText = text.replaceRange(start, end, pasteText);
          _controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(
              offset: start + pasteText.length,
            ),
          );
          if (widget.onChanged != null) widget.onChanged!(newText);
        }
      });
      return KeyEventResult.handled;
    }

    // 4. Copy (Ctrl + C / Cmd + C)
    if (isShortcutModifier && event.logicalKey == LogicalKeyboardKey.keyC) {
      final text = _controller.text;
      final selection = _controller.selection;
      if (selection.isValid && selection.start != selection.end) {
        final selectedText = text.substring(selection.start, selection.end);
        Clipboard.setData(ClipboardData(text: selectedText));
      }
      return KeyEventResult.handled;
    }

    // 5. Cut (Ctrl + X / Cmd + X)
    if (isShortcutModifier && event.logicalKey == LogicalKeyboardKey.keyX) {
      final text = _controller.text;
      final selection = _controller.selection;
      if (selection.isValid && selection.start != selection.end) {
        final start = selection.start;
        final end = selection.end;
        final selectedText = text.substring(start, end);
        Clipboard.setData(ClipboardData(text: selectedText));
        final newText = text.replaceRange(start, end, '');
        _controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: start),
        );
        if (widget.onChanged != null) widget.onChanged!(newText);
      }
      return KeyEventResult.handled;
    }

    // 6. Select All (Ctrl + A / Cmd + A)
    if (isShortcutModifier && event.logicalKey == LogicalKeyboardKey.keyA) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: widget.decoration,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onFieldSubmitted: widget.onFieldSubmitted,
      selectionControls: widget.selectionControls,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
    );
  }
}
