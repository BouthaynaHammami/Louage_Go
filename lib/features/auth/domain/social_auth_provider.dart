import '../../../models/app_user.dart';

abstract interface class SocialAuthProvider {
  Future<AppUser> signInWithGoogle();
}
