import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();

BuildContext get navContext => navigatorKey.currentContext!;
