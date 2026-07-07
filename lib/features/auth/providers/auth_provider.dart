import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { initial, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final User? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({AuthStatus? status, String? errorMessage, User? user}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : _supabase = Supabase.instance.client,
        super(AuthState(user: Supabase.instance.client.auth.currentUser)) {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;

      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.success,
          errorMessage: null,
          user: user,
        );
        return;
      }

      if (data.event == AuthChangeEvent.signedOut) {
        state = const AuthState();
      }
    });
  }

  final SupabaseClient _supabase;
  late final StreamSubscription<dynamic> _authSubscription;

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName ?? ''},
      );

      if (res.session == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Registrasi berhasil. Cek email untuk konfirmasi akun.',
          user: res.user,
        );
        return;
      }

      state = state.copyWith(status: AuthStatus.success, user: res.user);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Terjadi kesalahan saat registrasi',
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Login gagal. Coba lagi.',
        );
        return;
      }
      state = state.copyWith(status: AuthStatus.success, user: res.user);
    } on AuthException catch (e) {
      String msg = e.message;
      if (msg.toLowerCase().contains('invalid')) {
        msg = 'Email atau password salah';
      }
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg);
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Terjadi kesalahan saat login',
      );
    }
  }

  // âœ… TAMBAHAN: Google Sign-In via Supabase OAuth
  Future<void> loginWithGoogle() async {
    const mobileRedirectUrl = 'tarnews://login-callback/';

    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    try {
      final didLaunch = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? '${Uri.base.origin}/' : mobileRedirectUrl,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      if (!didLaunch) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Halaman login Google tidak dapat dibuka.',
        );
        return;
      }

      state = state.copyWith(status: AuthStatus.initial);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Gagal login dengan Google.',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      state = const AuthState();
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Gagal logout',
      );
    }
  }

  void reset() {
    state = state.copyWith(status: AuthStatus.initial, errorMessage: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});
