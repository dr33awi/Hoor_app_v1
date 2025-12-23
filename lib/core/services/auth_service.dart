// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../features/auth/models/user_model.dart';
import 'base_service.dart';
import 'logger_service.dart';

class AuthService extends BaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  static const String _usersCollection = 'users';

  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;

  // Getters
  User? get firebaseUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  UserModel? get currentUser => _currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isAuthenticated => _auth.currentUser != null;

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
  }

  Future<ServiceResult<UserCredential>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      AppLogger.i('🔐 Signing in with email...');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        if (userData['isActive'] == false) {
          await _auth.signOut();
          return ServiceResult.failure('هذا الحساب معطل');
        }
        if (userData['status'] == 'pending') {
          await _auth.signOut();
          return ServiceResult.failure('حسابك قيد المراجعة');
        }
        if (userData['status'] == 'rejected') {
          await _auth.signOut();
          return ServiceResult.failure('تم رفض حسابك');
        }

        await _firestore
            .collection(_usersCollection)
            .doc(credential.user!.uid)
            .update({'lastLoginAt': FieldValue.serverTimestamp()});

        _currentUser = UserModel.fromFirestore(userDoc);
      }

      AppLogger.i('✅ Email sign in successful');
      return ServiceResult.success(credential);
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<UserCredential>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return ServiceResult.failure('تم إلغاء تسجيل الدخول');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _createOrUpdateGoogleUser(userCredential.user!);

      return ServiceResult.success(userCredential);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<UserCredential>> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user!.updateDisplayName(name);

      final user = UserModel(
        id: credential.user!.uid,
        email: email.trim(),
        name: name.trim(),
        role: 'employee',
        status: 'pending',
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_usersCollection)
          .doc(credential.user!.uid)
          .set(user.toMap());

      _currentUser = user;
      return ServiceResult.success(credential);
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentUser = null;
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return ServiceResult.success();
    } on FirebaseAuthException catch (e) {
      return ServiceResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<UserModel>> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      if (!doc.exists) {
        return ServiceResult.failure('المستخدم غير موجود');
      }
      return ServiceResult.success(UserModel.fromFirestore(doc));
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> createOrUpdateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<void> _createOrUpdateGoogleUser(User firebaseUser) async {
    final docRef = _firestore
        .collection(_usersCollection)
        .doc(firebaseUser.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      final user = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'مستخدم',
        photoUrl: firebaseUser.photoURL,
        role: 'employee',
        status: 'approved',
        isActive: true,
        isGoogleUser: true,
        createdAt: DateTime.now(),
      );
      await docRef.set(user.toMap());
      _currentUser = user;
    } else {
      await docRef.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'photoUrl': firebaseUser.photoURL,
      });
      _currentUser = UserModel.fromFirestore(doc);
    }
  }

  Future<ServiceResult<List<UserModel>>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .orderBy('createdAt', descending: true)
          .get();
      final users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      return ServiceResult.success(users);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> approveUser(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'status': 'approved',
        'isActive': true,
        'approvedAt': FieldValue.serverTimestamp(),
      });
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  /// رفض مستخدم - المعامل الثاني اختياري
  Future<ServiceResult<void>> rejectUser(String uid, [String? reason]) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'status': 'rejected',
        'isActive': false,
        'rejectionReason': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
      });
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> activateUser(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'isActive': true,
        'status': 'approved',
      });
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> deactivateUser(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'isActive': false,
      });
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'role': role,
      });
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> toggleUserStatus(
    String uid,
    bool isActive,
  ) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'isActive': isActive,
      });
      return ServiceResult.success();
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<void>> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return ServiceResult.success();
      }
      return ServiceResult.failure('لا يوجد مستخدم');
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  Future<ServiceResult<bool>> checkVerificationAndLogin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return ServiceResult.failure('لا يوجد مستخدم');
      }

      await user.reload();
      final refreshedUser = _auth.currentUser;

      if (refreshedUser?.emailVerified == true) {
        return ServiceResult.success(true);
      }
      return ServiceResult.success(false);
    } catch (e) {
      return ServiceResult.failure(handleError(e));
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'user-disabled':
        return 'هذا الحساب معطل';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً. حاول لاحقاً';
      case 'invalid-credential':
        return 'بيانات الدخول غير صحيحة';
      default:
        return 'حدث خطأ أثناء المصادقة';
    }
  }
}
