import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

const publicInviteBaseUrl = 'https://issuedinventory.com/invite';

class InviteLinkService {
  InviteLinkService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  static const _pendingInviteTokenKey = 'issued.pending_invite_token';

  final AppLinks _appLinks;
  final StreamController<String> _tokenController =
      StreamController<String>.broadcast();
  StreamSubscription<Uri>? _linkSubscription;
  String? _pendingInviteToken;

  Stream<String> get tokenStream => _tokenController.stream;
  String? get pendingInviteToken => _pendingInviteToken;
  bool get hasPendingInvite => _pendingInviteToken?.isNotEmpty == true;

  Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    _pendingInviteToken = preferences.getString(_pendingInviteTokenKey);

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      await handleUri(initialUri);
    }

    _linkSubscription ??= _appLinks.uriLinkStream.listen((uri) {
      unawaited(handleUri(uri));
    });
  }

  Future<void> dispose() async {
    await _linkSubscription?.cancel();
    await _tokenController.close();
  }

  Future<bool> handleUri(Uri uri) async {
    final token = _tokenFromUri(uri);
    if (token == null) {
      return false;
    }
    await setPendingInviteToken(token);
    _tokenController.add(token);
    return true;
  }

  Future<String?> getPendingInviteToken() async {
    if (_pendingInviteToken?.isNotEmpty == true) {
      return _pendingInviteToken;
    }
    final preferences = await SharedPreferences.getInstance();
    _pendingInviteToken = preferences.getString(_pendingInviteTokenKey);
    return _pendingInviteToken;
  }

  Future<void> setPendingInviteToken(String token) async {
    final cleanToken = token.trim();
    if (cleanToken.isEmpty) {
      return;
    }
    _pendingInviteToken = cleanToken;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pendingInviteTokenKey, cleanToken);
  }

  Future<void> clearPendingInviteToken() async {
    _pendingInviteToken = null;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_pendingInviteTokenKey);
  }

  String? _tokenFromUri(Uri uri) {
    final isHttpsInvite =
        uri.scheme == 'https' &&
        uri.host.toLowerCase() == 'issuedinventory.com' &&
        (uri.path == '/invite' || uri.path.startsWith('/invite/'));
    final isCustomInvite =
        uri.scheme == 'issued' && uri.host.toLowerCase() == 'invite';
    if (!isHttpsInvite && !isCustomInvite) {
      return null;
    }
    final token = uri.queryParameters['token']?.trim();
    return token == null || token.isEmpty ? null : token;
  }
}
