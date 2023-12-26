import 'package:flutter/material.dart';
import 'package:whatssap_web/models/usuario.dart';
import 'package:whatssap_web/screens/home.dart';
import 'package:whatssap_web/screens/login.dart';
import 'package:whatssap_web/screens/mensagens.dart';

class Routes {

  static Route<dynamic> generatedRoutes(RouteSettings settings){


    final args = settings.arguments;

    switch(settings.name){
      case "/":
        return MaterialPageRoute(
            builder: (_) => Login()
        );

      case "/login":
        return MaterialPageRoute(
            builder: (_) => Login()
        );

      case "/home":
        return MaterialPageRoute(
            builder: (_) => Home()
        );

      case "/mensagens":
        return MaterialPageRoute(
            builder: (_) => Mensagens(args as Usuario)
        );
    }

    return _errorRoute();

  }

  static Route<dynamic> _errorRoute(){
    return MaterialPageRoute(builder: (_){
      return Scaffold(
        appBar: AppBar(
          title: Text('Error tela não encontrada'),
        ),
        body: Center(
          child: Text('Tela não encontrada'),
        ),
      );
    });
  }

}