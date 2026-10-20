import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A [TextFormField] with "clear on typing + validate on blur" behaviour.
///
/// * While the user types, any red error (text and border) is removed
///   immediately. No "invalid format" message appears mid-typing.
/// * When the field loses focus, the normal [validator] runs again and the red
///   error comes back if the value is still invalid.
/// * `Form.validate()` (the Submit button) still runs the normal [validator],
///   so submitting an invalid form always shows the errors again.
///
/// The validation rules themselves are untouched: pass the same [validator]
/// you would give to a [TextFormField].
class BlurTextFormField extends StatefulWidget {
  const BlurTextFormField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled,
    this.readOnly = false,
    this.style,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final bool obscureText;
  final bool? enabled;
  final bool readOnly;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final GestureTapCallback? onTap;

  @override
  State<BlurTextFormField> createState() => _BlurTextFormFieldState();
}

class _BlurTextFormFieldState extends State<BlurTextFormField> {
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  FocusNode? _ownNode;
  bool _clearing = false;

  FocusNode get _node => widget.focusNode ?? (_ownNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant BlurTextFormField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownNode)?.removeListener(_onFocusChange);
      _node.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _node.removeListener(_onFocusChange);
    _ownNode?.dispose();
    super.dispose();
  }

  // Validate on blur.
  void _onFocusChange() {
    if (_node.hasFocus) return;
    if (widget.validator == null) return;
    _fieldKey.currentState?.validate();
  }

  // Clear on typing: re-run validation with a validator that always passes,
  // which removes the error text and resets the border.
  void _clearError() {
    final state = _fieldKey.currentState;
    if (state == null || !state.hasError) return;
    _clearing = true;
    state.validate();
    _clearing = false;
  }

  @override
  Widget build(BuildContext context) {
    final validator = widget.validator;
    return TextFormField(
      key: _fieldKey,
      controller: widget.controller,
      focusNode: _node,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textDirection: widget.textDirection,
      textAlign: widget.textAlign,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      style: widget.style,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      autovalidateMode: AutovalidateMode.disabled,
      validator: validator == null
          ? null
          : (value) => _clearing ? null : validator(value),
      onChanged: (value) {
        _clearError();
        widget.onChanged?.call(value);
      },
    );
  }
}
