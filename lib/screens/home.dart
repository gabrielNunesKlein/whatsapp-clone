import 'package:flutter/material.dart';
import 'package:whatssap_web/screens/home_mobile.dart';
import 'package:whatssap_web/screens/home_web.dart';
import 'package:whatssap_web/utils/responsive.dart';

class Home extends StatelessWidget {
  const Home({Key? key});

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: HomeMobile(),
      tablet: HomeWeb(),
      web: HomeWeb(),
    );
  }
}
