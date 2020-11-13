import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:numeric_keyboard/numeric_keyboard.dart';

void main() {
  // ステータスバーとナビゲーションバーを非表示にする場合
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);

  runApp(MyApp());
}

const Color MAIN_COLOR = Color.fromRGBO(0x2a, 0x47, 0x43, 1);
const Color ACCCENT_COLOR = Color.fromRGBO(0xb1, 0x99, 0x62, 1);
const Color SUB_COLOR = Color.fromRGBO(0x7c, 0x2e, 0x1e, 1);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: MAIN_COLOR,
        backgroundColor: MAIN_COLOR,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Go To トラベル 計算機'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String NOT_TARGET = "8泊以上はGOTO対象外";
  final formatter = NumberFormat("#,###");

  String _price = '';
  int _person = 1;
  int _stay = 0;

  int _support = 0;
  int _minus = 0;
  int _coupon = 0;
  int _pay = 0;

  bool _tomin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "東京都民割",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: CupertinoSwitch(
                        value: _tomin,
                        onChanged: (bool value) {
                          setState(
                            () {
                              _tomin = value;
                              _calc();
                            },
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "人数",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: DropdownButton(
                        value: _person,
                        style: Theme.of(context).textTheme.headline5,
                        items: <DropdownMenuItem<int>>[
                          DropdownMenuItem<int>(child: Text("1名"), value: 1),
                          DropdownMenuItem<int>(child: Text("2名"), value: 2),
                          DropdownMenuItem<int>(child: Text("3名"), value: 3),
                          DropdownMenuItem<int>(child: Text("4名"), value: 4),
                          DropdownMenuItem<int>(child: Text("5名"), value: 5),
                          DropdownMenuItem<int>(child: Text("6名"), value: 6),
                          DropdownMenuItem<int>(child: Text("7名"), value: 7),
                          DropdownMenuItem<int>(child: Text("8名"), value: 8),
                          DropdownMenuItem<int>(child: Text("9名"), value: 9),
                          DropdownMenuItem<int>(child: Text("10名"), value: 10),
                        ],
                        onChanged: (value) => setState(() {
                          _person = value;
                          _calc();
                        }),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "宿泊日数",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: DropdownButton(
                        value: _stay,
                        style: Theme.of(context).textTheme.headline5,
                        items: <DropdownMenuItem<int>>[
                          DropdownMenuItem<int>(child: Text("日帰り"), value: 0),
                          DropdownMenuItem<int>(child: Text("1泊2日"), value: 1),
                          DropdownMenuItem<int>(child: Text("2泊3日"), value: 2),
                          DropdownMenuItem<int>(child: Text("3泊4日"), value: 3),
                          DropdownMenuItem<int>(child: Text("4泊5日"), value: 4),
                          DropdownMenuItem<int>(child: Text("5泊6日"), value: 5),
                          DropdownMenuItem<int>(child: Text("6泊7日"), value: 6),
                          DropdownMenuItem<int>(child: Text("7泊8日"), value: 7),
                          DropdownMenuItem<int>(child: Text("8泊以上"), value: 10),
                        ],
                        onChanged: (value) => setState(() {
                          _stay = value;
                          _calc();
                        }),
                      ),
                    ),
                  )
                ],
              ),
              NumericKeyboard(
                onKeyboardTap: _onKeyboardTap,
                textColor: SUB_COLOR,
                rightButtonFn: () {
                  setState(() {
                    if (_price.length == 0) {
                      return;
                    }
                    _price = _price.substring(0, _price.length - 1);
                    if (0 < _price.length) {
                      _calc();
                    } else {
                      _coupon = 0;
                      _minus = 0;
                      _pay = 0;
                    }
                  });
                },
                rightIcon: Icon(
                  Icons.backspace,
                  color: ACCCENT_COLOR,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Expanded(
                    child: Text(
                      "旅行代金",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${_price.length == 0 ? "" : formatter.format(int.parse(_price))}',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Expanded(
                    child: Text(
                      "割引額",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${_stay == 10 ? NOT_TARGET : _minus == 0 ? "" : formatter.format(_minus)}',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Expanded(
                    child: Text(
                      "支払額",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${_pay == 0 ? "" : formatter.format(_pay)}',
                        textAlign: TextAlign.right,
                        style: Theme.of(context)
                            .textTheme
                            .headline4
                            .copyWith(color: ACCCENT_COLOR),
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  Expanded(
                    child: Text(
                      "クーポン",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${_stay == 10 ? NOT_TARGET : _coupon == 0 ? "" : formatter.format(_coupon)}',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _onKeyboardTap(String value) async {
    if (_price.length == 7) {
      return;
    }

    setState(() {
      _price = _price + value;
      _calc();
    });
  }

  _calc() {
    if (_price.length == 0) {
      return;
    }

    int price = int.parse(_price);

    int max = (_stay == 10
            ? 0
            : _stay == 0
                ? 10000
                : 20000 * _stay) *
        _person;

    int half = (price / 2).toInt();

    bool isExpensive = half > max;
    _minus = (isExpensive ? max * 0.7 : price * 0.35).toInt();
    _coupon = ((isExpensive ? max * 0.3 : price * 0.15) / 1000).round() * 1000;
    _pay = price - _minus;

    if (_tomin) {
      if ((_stay == 0 && 4500 * _person <= price) || 9000 * _person <= price) {
        int value =
            5000 * _person * _stay < _pay ? 5000 * _person * _stay : _pay;
        if (_stay == 0) {
          value = 2500 * _person < _pay ? 2500 * _person : _pay;
        }
        _pay -= value;
        _minus += value;
      }
    }
  }
}
