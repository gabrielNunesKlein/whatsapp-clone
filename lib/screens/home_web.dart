import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatssap_web/components/list_conversas.dart';
import 'package:whatssap_web/components/list_mensagens.dart';
import 'package:whatssap_web/models/usuario.dart';
import 'package:whatssap_web/provider/conversa_provider.dart';
import 'package:whatssap_web/utils/paleta_cores.dart';
import 'package:whatssap_web/utils/responsive.dart';

class HomeWeb extends StatefulWidget {
  const HomeWeb({Key? key});

  @override
  State<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  Usuario? usuario;

  @override
  void initState() {
    _getUser();
    // TODO: implement initState
    super.initState();
  }

  _getUser(){
    User? user = _auth.currentUser;
    if(user != null) {
      String? idUser = user?.uid;
      String? nome = user?.displayName ?? "";
      String? email = user?.email ?? "";
      String? imageUrl = user?.photoURL ?? "";

      usuario = Usuario(idUser!, nome, email, urlImagem: imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final heigth = MediaQuery.of(context).size.height;

    final isWeb = Responsive.isWeb(context);

    return Scaffold(
      body: Container(
        color: PaletaCores.corFundo,
        child: Stack(
          children: [
            Positioned(
                top: 0,
                child:
              Container(
                width: width,
                height: heigth * 0.2,
                color: PaletaCores.corPrimaria,
              )
            ),

            Positioned(
                top: isWeb ? heigth * 0.05 : 0,
                bottom: isWeb ? heigth * 0.05 : 0,
                left: isWeb ? width * 0.05 : 0,
                right: isWeb ? width * 0.05 : 0,
                child:
                Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: AreaConversas(usuario: usuario!)
                    ),

                    Expanded(
                        flex: 10,
                        child: AreaMensagens(usuarioLogin: usuario!)
                    )
                ],
              )
            )
          ],
        ),
      )
    );
  }
}

class AreaMensagens extends StatelessWidget {


  final Usuario usuarioLogin;

  const AreaMensagens({Key? key, required this.usuarioLogin});

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final heigth = MediaQuery.of(context).size.height;
    Usuario? usuario = context.watch<ConversaProvider>().usuario;

    return usuario != null

        ? Column(
          children: [
            Container(
              color: PaletaCores.corFundoBarra,
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    backgroundImage:  CachedNetworkImageProvider(usuario.urlImagem),
                  ),
                  SizedBox(width: 8,),
                  Text(usuario.nome, style: TextStyle(
                    fontSize: 16
                  ),),
                  Spacer(),
                  IconButton(onPressed: (){}, icon: Icon(Icons.search)),
                  IconButton(onPressed: (){}, icon: Icon(Icons.more_vert)),
                ],
              ),
            ),

            Expanded(child: ListMensagens(
              usuarioRemetente: usuarioLogin,
              usuarioDestinatario: usuario,
            ))
          ],
        )

        : Container(
          color: PaletaCores.corFundoBarraClaro,
          width: width,
          height: heigth,
          child: Center(child: Text("Usuário não foi selecionado")
      ),
    );
  }
}

class AreaConversas extends StatelessWidget {

  final Usuario usuario;

  const AreaConversas({
    Key? key,
    required this.usuario
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PaletaCores.corFundoBarraClaro,
        border: Border(
          right: BorderSide(
            color: PaletaCores.corFundo,
            width: 1
          )
        )
      ),

      child: Column(
        children: [
          Container(
            color: PaletaCores.corFundoBarra,
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  backgroundImage:  CachedNetworkImageProvider(usuario.urlImagem),
                ),

                Spacer(),
                IconButton(onPressed: (){}, icon: Icon(Icons.message)),
                IconButton(onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamed(context, "/login");
                }, icon: Icon(Icons.logout))
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100)
            ),
            child: Row(
              children: [
                IconButton(onPressed: (){}, icon: Icon(Icons.search)),
                Expanded(
                    child: TextField(
                      decoration: InputDecoration.collapsed(hintText: "Pesquise uma conversa"),
                    )
                )
              ],
            ),

          ),

          Expanded(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ListConversas(),
              )
          )
        ],
      ),
    );
  }
}


