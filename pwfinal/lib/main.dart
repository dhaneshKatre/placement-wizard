import 'package:flutter/material.dart';
import 'package:pwfinal/screens/home.dart';
import 'package:pwfinal/screens/login.dart';
import 'package:pwfinal/screens/splash.dart';
import 'package:pwfinal/state_widget.dart';
import 'package:pwfinal/design/colors.dart';
import 'package:pwfinal/model/state.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

void main() => runApp(StateWidget(child: PlacementWizard()));

TextTheme _buildAppTextTheme(TextTheme base, Brightness brightness) {
  return base
      .copyWith(
        headline: base.headline.copyWith(
          fontWeight: FontWeight.w500,
        ),
        title: base.title.copyWith(fontSize: 18.0),
        caption: base.caption.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
      )
      .apply(
        fontFamily: 'Lato',
        displayColor: brightness == Brightness.light
            ? kShrineBrown900
            : kShrineSurfaceWhite,
        bodyColor: brightness == Brightness.light
            ? kShrineBrown900
            : kShrineSurfaceWhite,
      );
}

ThemeData _buildAppTheme(Brightness brightness) {
  if (brightness == Brightness.light) {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      accentColor: kShrineBrown900,
      primaryColor: kShrinePink100,
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: kShrinePink100,
        textTheme: ButtonTextTheme.normal,
      ),
      scaffoldBackgroundColor: kShrineBackgroundWhite,
      cardColor: kShrineBackgroundWhite,
      textSelectionColor: kShrinePink100,
      errorColor: kShrineErrorRed,
      textTheme: _buildAppTextTheme(base.textTheme, brightness),
      primaryTextTheme: _buildAppTextTheme(base.primaryTextTheme, brightness),
      accentTextTheme: _buildAppTextTheme(base.accentTextTheme, brightness),
      primaryIconTheme: base.iconTheme.copyWith(color: kShrineBrown900),
    );
  } else {
    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      accentColor: kShrineAltYellow,
      primaryColor: kShrineAltDarkGrey,
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: kShrineAltYellow,
        textTheme: ButtonTextTheme.normal,
      ),
      scaffoldBackgroundColor: kShrineAltDarkGrey,
      cardColor: kShrineAltDarkGrey,
      textSelectionColor: kShrinePink100,
      errorColor: kShrineErrorRed,
      textTheme: _buildAppTextTheme(base.textTheme, brightness),
      primaryTextTheme: _buildAppTextTheme(base.primaryTextTheme, brightness),
      accentTextTheme: _buildAppTextTheme(base.accentTextTheme, brightness),
      primaryIconTheme: base.iconTheme.copyWith(color: kShrineAltYellow),
    );
  }
}

class PlacementWizard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StateModel appState = StateWidget.of(context).state;

    Widget _buildContent() {
      if (appState.isLoading) {
        return SplashScreen();
      } else if (!appState.isLoading && appState.user == null) {
        return new LoginScreen();
      } else {
        return Backdrop();
      }
    }

    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => _buildAppTheme(brightness),
      themedWidgetBuilder: (context, theme) => MaterialApp(
            title: 'Placement Wizard',
            theme: theme,
            debugShowCheckedModeBanner: false,
            home: _buildContent(),
          ),
    );
  }
}
