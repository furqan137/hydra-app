import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> appNavigatorKey =
GlobalKey<NavigatorState>();

BuildContext get navContext => appNavigatorKey.currentContext!;
