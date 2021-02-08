import 'package:flutter/material.dart';
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
  new GlobalKey<NavigatorState>();
  Future<dynamic> navigateToAnyadForce(var route){
    if(navigatorKey.currentState==null)
      return null;
    return navigatorKey.currentState.pushAndRemoveUntil(route, (r) => false);
  }
  Future<dynamic> navigateToAnyad(var route){
    if(navigatorKey.currentState==null)
      return null;
    return navigatorKey.currentState.push(route);
  }
  Future<dynamic> navigateTo(String routeName) {
    if(navigatorKey.currentState==null)
      return null;
    return navigatorKey.currentState.pushNamed(routeName);
  }
}