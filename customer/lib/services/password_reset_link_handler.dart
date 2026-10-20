import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../views/reset_password_screen.dart';

/// Routes Firebase email-action links to the in-app password form.
class PasswordResetLinkHandler extends StatefulWidget {
  const PasswordResetLinkHandler({super.key, required this.child, required this.navigatorKey});
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  @override
  State<PasswordResetLinkHandler> createState() => _PasswordResetLinkHandlerState();
}

class _PasswordResetLinkHandlerState extends State<PasswordResetLinkHandler> {
  final _links = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _opening = false;
  String? _lastCode;

  @override
  void initState() {
    super.initState();
    _subscription = _links.uriLinkStream.listen(_handle);
    _links.getInitialLink().then((url) {
      if (url != null) _handle(url);
    }).catchError((Object _) {});
  }

  String? _codeFrom(Uri uri, [int depth = 0]) {
    if (depth > 3) return null;
    final q = uri.queryParameters;
    if (q['mode'] == 'resetPassword' && (q['oobCode']?.isNotEmpty ?? false)) {
      return q['oobCode'];
    }
    for (final field in ['link', 'deep_link_id', 'continueUrl']) {
      final nested = q[field];
      if (nested == null) continue;
      final inner = Uri.tryParse(nested);
      if (inner != null) {
        final code = _codeFrom(inner, depth + 1);
        if (code != null) return code;
      }
    }
    return null;
  }

  void _handle(Uri link) {
    final code = _codeFrom(link);
    if (code == null || _opening || code == _lastCode) return;
    _opening = true;
    _lastCode = code;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) { _opening = false; return; }
      final navigator = widget.navigatorKey.currentState;
      if (navigator == null) { _opening = false; _lastCode = null; return; }
      await navigator.push(MaterialPageRoute<void>(
        builder: (_) => ResetPasswordScreen(code: code),
      ));
      _opening = false;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
