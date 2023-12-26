import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatssap_web/provider/conversa_provider.dart';
import 'package:whatssap_web/routes.dart';
import 'package:whatssap_web/utils/paleta_cores.dart';
import 'screens/login.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final ThemeData themeData = ThemeData(
  appBarTheme: AppBarTheme(
    backgroundColor: PaletaCores.corPrimaria,
    titleTextStyle: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  )
);

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(
      ChangeNotifierProvider(
          create: (context) => ConversaProvider(),
          child: MaterialApp(
              onGenerateRoute: Routes.generatedRoutes,
              initialRoute: '/',
              theme: themeData,
              title: 'WhatsWeb',
              debugShowCheckedModeBanner: false,
              home: Login(),
      )
  ));
}