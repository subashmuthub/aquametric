import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

    Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔥 STEP 1: Starting signup for email: $email');
      
      // Create user account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      print('🔥 STEP 2: User created successfully! UID: ${user?.uid}');

      // Create user document in Firestore
      if (user != null) {
        print('🔥 STEP 3: Creating Firestore document...');
        
        Map<String, dynamic> userData = {
          'name': name,
          'email': email,
          'points': 0,
          'totalUsage': 0.0,
          'totalCost': 0.0,
          'achievements': ['first_day'],
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        print('🔥 STEP 4: User data prepared: $userData');
        
        await _firestore.collection('users').doc(user.uid).set(userData);
        
        print('🔥 STEP 5: Firestore document created successfully!');

        // Update display name
        await user.updateDisplayName(name);
        print('🔥 STEP 6: Display name updated. Signup complete!');
      }

      return null; // Success
      
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'weak-password') {
        return 'The password is too weak. Use at least 6 characters.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is invalid.';
      } else if (e.code == 'network-request-failed') {
        return 'Network error. Check your internet connection.';
      } else {
        return 'Auth error: ${e.message}';
      }
    } on FirebaseException catch (e) {
      print('❌ FirebaseException (Firestore): ${e.code} - ${e.message}');
      return 'Database error: ${e.message}';
    } catch (e) {
      print('❌ General error: $e');
      return 'Error: $e';
    }
  }
    Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔥 STEP 1: Starting login for email: $email');
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('🔥 STEP 2: Login successful!');
      return null; // Success
      
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        return 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is invalid.';
      } else if (e.code == 'user-disabled') {
        return 'This account has been disabled.';
      } else if (e.code == 'network-request-failed') {
        return 'Network error. Check your internet connection.';
      } else {
        return 'Login error: ${e.message}';
      }
    } catch (e) {
      print('❌ General login error: $e');
      return 'Error: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is signed in
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}