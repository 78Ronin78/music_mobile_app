import 'package:flutter/material.dart';
import 'package:music_mobile_app/screen/concert.dart';
import 'package:music_mobile_app/screen/home.dart';
import 'package:music_mobile_app/screen/play_list.dart';
import 'package:music_mobile_app/screen/player.dart';
import 'package:music_mobile_app/screen/city_picker.dart';
import 'helpers/route_arguments.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/home':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/playList':
        return MaterialPageRoute(builder: (_) => PlayListPage(routeArgument: args as RouteArgument));
      case '/player':
        return MaterialPageRoute(builder: (_) => PlayerPage(routeArgument: args as RouteArgument));
      case '/concert':
        return MaterialPageRoute(builder: (_) => ConcertPage(routeArgument: args as RouteArgument));
      case '/cityPicker':
        return MaterialPageRoute(builder: (_) => CityPicker());
      default:
        return MaterialPageRoute(builder: (_) => Scaffold(body: SafeArea(child: Text('Route Error')))); 
    }
  }
}
