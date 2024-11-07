import 'package:flutter/material.dart';
import 'package:habit_tracker/theme/light_mode.dart';
import 'package:habit_tracker/theme/dark_mode.dart';


class ThemeProvider extends ChangeNotifier{
  //initially light mode
  ThemeData _themeData = lightmode;

  //get curren theme
  ThemeData get themedata =>  _themeData;

  //is dark mode
  bool get isDarkMode => _themeData == darkmode;

  //set theme
  set themedata(ThemeData themedata){
    _themeData = themedata;
    notifyListeners();
  }

  //toggle theme
  void toggleTheme(){
    if(_themeData == lightmode){
      themedata = darkmode;
    }else{
      themedata = lightmode;
    }
  }
}