import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class deneme extends StatefulWidget {
  @override
  _denemeState createState() => _denemeState();
}

class _denemeState extends State<deneme> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  var _key = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth.authStateChanges().listen((User user) {
      if (user == null) {
        print('Kullanıcı Bulunmamakta!');
      } else {
        print('Kullanıcı giriş Yaptı!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Deneme"),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller1,
                decoration: InputDecoration(
                    labelText: "E Mail ",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller2,
                decoration: InputDecoration(
                    labelText: "Şifre ",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ),
            FlatButton(onPressed: _kayitOl, child: Text("Kayıt Ol")),
            FlatButton(onPressed: () {}, child: Text("Giriş Yap"))
          ],
        ),
      ),
    );
  }

  void _kayitOl() async {
    var _email = controller1.text;
    var _sifre = controller2.text;

    try {
      UserCredential _credential = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _sifre);
      User _yeniKayit = _credential.user;
      print(_yeniKayit.toString());
      _yeniKayit.sendEmailVerification();
      if (_auth.currentUser != null) {
        setState(() {
          _key.currentState.showSnackBar(
            SnackBar(content: Text("Size bir Mail attık lütfen onaylayın"),duration: Duration(seconds: 2),));
        });
        //debugPrint("Size bir Mail attık lütfen onaylayın");
        await _auth.signOut();
        debugPrint("Kullanıcı Sistemden atıldı");
      }
    } catch (e) {
      print("*******HATA*******");
      print("Oluşan Hata : $e");
    }
  }
}
