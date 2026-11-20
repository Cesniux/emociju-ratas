import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../copy/strings.dart';

/// Opens a web page. If the phone can't, the address stays readable in a
/// snack bar.
Future<void> openLink(BuildContext context, Uri uri, {String? shown}) async {
  var ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (ok || !context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 8),
        content: SelectableText('${S.linkFailed} ${shown ?? uri.toString()}'),
      ),
    );
}
