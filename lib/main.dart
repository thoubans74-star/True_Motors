import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:true_motors/login_module/splash_screen.dart';
import 'package:true_motors/provider/profile_update_provider.dart';
import 'package:true_motors/provider/used_vehicle_provider.dart';
import 'package:true_motors/provider/subscription_provider.dart';
import 'package:true_motors/provider/terms_provider.dart';
import 'package:true_motors/provider/sell_vehicle_provider.dart';
import 'package:true_motors/provider/common_dropdown_provider.dart';
import 'package:true_motors/provider/rto_location_provider.dart';
import 'package:true_motors/provider/seller_insert_step_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsedVehicleProvider()),
        ChangeNotifierProvider(create: (_) => ProfileUpdateProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => TermsProvider()),
        ChangeNotifierProvider(create: (_) => SellVehicleProvider()),
        ChangeNotifierProvider(create: (_) => CommonDropdownProvider()),
        ChangeNotifierProvider(create: (_) => RtoLocationProvider()),
        ChangeNotifierProvider(create: (_) => SellerInsertStepProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Poppins',
          ),
          builder: (context, child) {
            return Container(
              color: Colors.white,
              child: child!,
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}

