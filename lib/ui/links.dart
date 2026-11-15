import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../copy/strings.dart';

/// Opens a phone number or web page. If the phone can't (tablet, desktop,
/// simulator), the number or address stays readable in a snack bar.
Future<void> openLink(BuildContext context, Uri uri, {String? shown}) async {
  var ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (ok || !context.mounted) return;
  final prefix = uri.scheme == 'tel' ? S.callFailed : S.linkFailed;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 8),
        content: SelectableText('$prefix ${shown ?? uri.toString()}'),
      ),
    );
}
