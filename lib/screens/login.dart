import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:whatssap_web/models/usuario.dart';
import 'package:whatssap_web/utils/paleta_cores.dart';

class Login extends StatefulWidget {
  const Login({Key? key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
/*
  TextEditingController _controllerName = TextEditingController(text: 'Gabriel Klein');
  TextEditingController _controllerEmail = TextEditingController(text: 'Gabriel.klein@gmail.com');
  TextEditingController _controllerSenha = TextEditingController(text: '1234567');*/

  TextEditingController _controllerName = TextEditingController(text: '');
  TextEditingController _controllerEmail = TextEditingController(text: '');
  TextEditingController _controllerSenha = TextEditingController(text: '');

  bool _cadastroUsuario = false;
  String _textButton = "Login";
  Uint8List? _selectedFile;

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<UserCredential> _loginFacebook() async {


    final UserCredential userCredential;

    if(kIsWeb) {
      FacebookAuthProvider facebookProvider = FacebookAuthProvider();

      facebookProvider.addScope('email');
      facebookProvider.setCustomParameters({
        'display': 'popup',
      });

      // Once signed in, return the UserCredential
      userCredential = await FirebaseAuth.instance
          .signInWithPopup(facebookProvider);
    } else {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      print(loginResult);

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.token);

      // Once signed in, return the UserCredential
      userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      print(userCredential);
    }

    Usuario usuario = Usuario(userCredential!.user!.uid,
        userCredential.user!.displayName.toString(),
        userCredential.user!.email.toString(),
      urlImagem: userCredential.user!.photoURL.toString()
    );


    final usuarioRef = _firestore.collection("usuarios");
    usuarioRef.doc(usuario.idUsuario)
        .set(usuario.toMap())
        .then((value) {
      Navigator.pushReplacementNamed(context, "/home");
    });

    return userCredential;

  }

  _verifyUserLogin() async {

    User? userLoged = await _auth.currentUser;

    if(userLoged != null){
      Navigator.pushReplacementNamed(context, "/home");
    }

  }

  _selectedPhoto() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image
    );

    setState(() {
      _selectedFile = result?.files.single.bytes;
    });
  }

  _uploadImage(Usuario usuario){
    Reference imagePerfil = _storage.ref("imagens/perfil/${usuario.idUsuario}.jpg");
    UploadTask uploadTask = imagePerfil.putData(_selectedFile!);

    uploadTask.whenComplete(() async {
      String link = await uploadTask.snapshot.ref.getDownloadURL();
      usuario.urlImagem = link;
      final usuarioRef = _firestore.collection("usuarios");

      await _auth.currentUser?.updateDisplayName(usuario.nome);
      await _auth.currentUser?.updatePhotoURL(usuario.urlImagem);

      usuarioRef.doc(usuario.idUsuario)
      .set(usuario.toMap())
      .then((value) {
        Navigator.pushReplacementNamed(context, "/home");
      });
    });

  }

  _validationFields() async {

    String nome = _controllerName.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(email.isNotEmpty && email.contains("@")){
      if(senha.isNotEmpty && senha.length > 6){

        if(_cadastroUsuario) {

          if(_selectedFile != null){
            if(nome.isNotEmpty && nome.length > 3){
              await _auth.createUserWithEmailAndPassword(
                  email: email,
                  password: senha
              ).then((auth) {
                String? idUsuario = auth.user?.uid;
                Usuario usuario = Usuario(idUsuario!, nome, email);
                _uploadImage(usuario);
                //print('Usuári ${idUser}');
              });
            } else {
              print("Nome invalido");
            }

          }else {
            print('Selecione uma imagem');
          }
        } else {
          await _auth.signInWithEmailAndPassword(
              email: email,
              password: senha
          ).then((auth) {
            String? email = auth.user?.email;
            print('Usuatio ${email}');

            Navigator.pushReplacementNamed(context, "/home");

          });
        }


      } else {
        print('Senha invalida');
      }

    } else {
      print('E-mail invalido');
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verifyUserLogin();
  }

  @override
  Widget build(BuildContext context) {

    double alturaTela = MediaQuery.of(context).size.height;
    double larguraTela = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        color: PaletaCores.corFundo,
        width: larguraTela,
        height: alturaTela,
        child: Stack(
          children: [
            Positioned(
              child: Container(
                width: larguraTela,
                height: alturaTela * 0.5,
                color: PaletaCores.corPrimaria,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10)
                      )
                    ),
                    child: Container(
                      width: 500,
                      //height: 400,
                      padding: EdgeInsets.all(40),
                      child: Column(

                        children: [

                          Visibility(
                            visible: _cadastroUsuario,
                            child: ClipOval(
                              child:
                              _selectedFile != null ? Image.memory(_selectedFile!, width: 120, height: 120) :
                              Image.asset('imagens/perfil.png', width: 120, height: 120, fit: BoxFit.cover,),
                            ),
                          ),

                          SizedBox(height: 8,),

                          Visibility(
                            visible: _cadastroUsuario,
                            child: OutlinedButton(
                                onPressed: _selectedPhoto,
                                child: Text('Adicionar Foto')
                            ),
                          ),

                          SizedBox(height: 8,),

                          Visibility(
                            visible: _cadastroUsuario,
                              child: TextField(
                                keyboardType: TextInputType.text,
                                controller: _controllerName,
                                decoration: InputDecoration(
                                    hintText: 'Nome',
                                    labelText: 'Nome',
                                    suffixIcon: Icon(
                                        Icons.person_outline
                                    )
                                ),
                              ),

                          ),

                          TextField(
                            keyboardType: TextInputType.emailAddress,
                            controller: _controllerEmail,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              labelText: 'Email',
                              suffixIcon: Icon(
                                Icons.mail_outline
                              )
                            ),
                          ),

                          TextField(
                            keyboardType: TextInputType.text,
                            controller: _controllerSenha,
                            obscureText: true,
                            decoration: InputDecoration(
                                hintText: 'Senha',
                                labelText: 'Senha',
                                suffixIcon: Icon(
                                    Icons.lock_outlined
                                )
                            ),
                          ),

                          SizedBox(height: 20,),

                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: _validationFields,
                                style: ElevatedButton.styleFrom(
                                  primary: PaletaCores.corPrimaria
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(_textButton, style: TextStyle(color: Colors.white, fontSize: 18),),
                                )
                            ),
                          ),

                          SizedBox(height: 8,),

                          Container(
                            width: double.infinity,
                            child: OutlinedButton(
                                onPressed: () {
                                  _loginFacebook();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.facebook_outlined),
                                      SizedBox(width: 5,),
                                      Text("Login com facebook", style: TextStyle(color: PaletaCores.corPrimaria, fontSize: 18),),
                                    ],
                                  ),
                                )
                            ),
                          ),

                          SizedBox(height: 20,),

                          Row(
                            children: [
                              Text("Login"),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Switch(
                                    value: _cadastroUsuario,
                                    onChanged: (bool value){
                                      setState(() {
                                        _cadastroUsuario = value;

                                        if(_cadastroUsuario){
                                          _textButton = "Cadastrar";
                                        } else {
                                          _textButton = "Login";
                                        }

                                      });
                                    }
                                ),
                              ),
                              Text("Cadastro"),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

