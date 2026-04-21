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

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    User? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(AuthState(
          user: Supabase.instance.client.auth.currentUser,
        ));

  final _supabase = Supabase.instance.client;

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
      state = state.copyWith(status: AuthStatus.success, user: res.user);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Terjadi kesalahan saat registrasi');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
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
          errorMessage: 'Terjadi kesalahan saat login');
    }
  }

  // ✅ TAMBAHAN: Google Sign-In via Supabase OAuth
  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:8080', // untuk web dev; ganti sesuai platform
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
      // Supabase akan redirect browser ke Google lalu kembali ke app
      // Status sukses akan ditangani oleh onAuthStateChange di app_router
      state = state.copyWith(status: AuthStatus.initial);
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Gagal login dengan Google');
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      state = const AuthState();
    } catch (_) {
      state =
          state.copyWith(status: AuthStatus.error, errorMessage: 'Gagal logout');
    }
  }

  void reset() {
    state = state.copyWith(status: AuthStatus.initial, errorMessage: null);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});