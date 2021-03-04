import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:flutter_firebase_dersleri/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class LoginIslemleri extends StatefulWidget {
  @override
  _LoginIslemleriState createState() => _LoginIslemleriState();
}

class _LoginIslemleriState extends State<LoginIslemleri> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth.authStateChanges().listen((User user) {
      if (user == null) {
        print('Kullanıcı oturumunu kapattı');
      } else {
        if (user.emailVerified) {
          print('Kullanıcı giriş yaptı ve emaili onaylı');
        } else {
          print('Kullanıcı giriş yaptı ve emaili onaylı degil');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Login İşlemleri"),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              RaisedButton(
                color: Colors.blue,
                child: Text("E-mail/Password User Create"),
                onPressed: _emailPasswordKullaniciOlustur,
              ),
              RaisedButton(
                color: Colors.green,
                child: Text("E-mail/Password User Login"),
                onPressed: _emailPasswordKullaniciGirisYap,
              ),
              RaisedButton(
                color: Colors.yellow,
                child: Text("Login Out"),
                onPressed: _cikisYap,
              ),
              RaisedButton(
                color: Colors.yellow,
                child: Text("reset Password"),
                onPressed: _resetPassword,
              ),
              RaisedButton(
                color: Colors.red,
                child: Text("Update Password"),
                onPressed: _updatePassword,
              ),
              RaisedButton(
                color: Colors.blueAccent,
                child: Text("Google İle giriş Yap"),
                onPressed: signInWithGoogle,
              ),
              RaisedButton(
                color: Colors.blueAccent,
                child: Text("Telefon Numarasi ile Giriş"),
                onPressed: _telefonNumarasi,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _emailPasswordKullaniciOlustur() async {
    String _email = "cuneytaykac2@gmail.com";
    var _sifre = "password";
    try {
      UserCredential _credential = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _sifre);
      User _yeniKayit = _credential.user;

      await _yeniKayit.sendEmailVerification();
      if (_auth.currentUser != null) {
        debugPrint("Size bir Mail attık lütfen onaylayın");
        await _auth.signOut();
        debugPrint("Kullanıcı Sistemden atıldı");
      }
      debugPrint(_yeniKayit.toString());
    } catch (e) {
      debugPrint("***************Hata Oluştu****************");
      debugPrint("$e");
    }
  }

  void _emailPasswordKullaniciGirisYap() async {
    try {
      if (_auth.currentUser == null) {
        String _email = "cuneytaykac2@gmail.com";
        var _sifre = "password";
        User _oturumdakiKullanici = (await _auth.signInWithEmailAndPassword(
                email: _email, password: _sifre))
            .user;

        if (_oturumdakiKullanici.emailVerified) {
          print("Mail onaylı giriş yapabilirsiniz");
        } else {
          print("Mailinize gelen linke tıklayınız ve tekrar giriş yapınız");
          _auth.signOut();
        }
      } else {
        print("Oturum'da kullanıcı bulunmakta");
      }
    } catch (e) {
      print("Hata" + e.toString());
    }
  }

  void _cikisYap() async {
    if (_auth.currentUser != null) {
      _auth.signOut();
    } else {
      print("Kullanıcı bulunmamaktadır.");
    }
  }

  void _resetPassword() async {
    String _email = "cuneytaykac2@gmail.com";
    try {
      await _auth.sendPasswordResetEmail(email: _email);
      debugPrint("Resetleme Maili gonderildi");
    } catch (e) {
      print("Hata oluştu" + e.toString());
    }
  }

  void _updatePassword() async {
    try {
      await _auth.currentUser.updatePassword("password");
      debugPrint("Şifreniz başarıyla güncellendi");
    } catch (e) {
      try {
        //kullanıcıdan eski oturum bilgileri girmesi istenir
        String email = 'cuneytaykac2@gmail.com';
        String password = 'password';

        EmailAuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);
        await FirebaseAuth.instance.currentUser
            .reauthenticateWithCredential(credential);

        //güncel email ve şifre bilgisi dogruysa eski şifresi yenisiyle güncellenir.
        debugPrint("Girilen eski email şifre bilgisi dogru");
        await _auth.currentUser.updatePassword("password");
        debugPrint("Auth yeniden saglandı, şifre de güncellendi");
      } catch (e) {
        debugPrint("hata çıktı $e");
      }
      debugPrint("ŞifreGüncellenirken bir hata oluştu $e");
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Gmail ile girşte problem yaşandı $e");
    }
  }

  void _telefonNumarasi() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+90 545 326 03 56',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Hata : $e");
        },
        codeSent: (String verificationId, int resendToken) async {
          print("Kod yollandı");
          // Update the UI - wait for the user to enter the SMS code
          String smsCode = '123456789';

          // Create a PhoneAuthCredential with the code
          PhoneAuthCredential phoneAuthCredential =
              PhoneAuthProvider.credential(
                  verificationId: verificationId, smsCode: smsCode);

          // Sign the user in (or link) with the credential
          await _auth.signInWithCredential(phoneAuthCredential);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("timeoutta düştü");
        },
      );
    } catch (e) {
      print("Telefon numarasına mesaj göderilirken bir hata oluştu $e");
    }
  }
}
