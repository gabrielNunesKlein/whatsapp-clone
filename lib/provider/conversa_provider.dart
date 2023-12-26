

import 'package:flutter/cupertino.dart';
import 'package:whatssap_web/models/usuario.dart';

class ConversaProvider with ChangeNotifier {

  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  set usuario(Usuario? value) {
    _usuario = value;
    notifyListeners();
  }
}