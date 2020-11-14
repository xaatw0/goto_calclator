import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:io';

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
  final _isIOS = Platform.isIOS;

  final _lstPerson = List<Text>.generate(
    10,
    (i) => Text("${i + 1}名"),
  );

  final _lstStay = <Text>[
    Text("日帰り"),
    ...List.generate(
      7,
      (index) => Text("${index + 1}泊${index + 2}日"),
    ),
    Text("8泊以上")
  ];

  String _price = '';
  int _person = 1;
  int _stay = 0;

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
                      "都民割",
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
                      child: _isIOS ? _createPersonIos() : _createPerson(),
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
                      child: _isIOS ? _createStayIos() : _createStay(),
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

  void _calc() {
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

    if (_stay == 10) {
      _pay = price;
    }

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

  Widget _createPerson() {
    return DropdownButton(
      value: _person,
      style: Theme.of(context).textTheme.headline5,
      items: List.generate(10,
          (i) => DropdownMenuItem<int>(child: Text("${i + 1}名"), value: i + 1)),
      onChanged: (value) => setState(() {
        _person = value;
        _calc();
      }),
    );
  }

  Widget _createPersonIos() {
    return CupertinoButton(
      child: _lstPerson[_person - 1],
      onPressed: () {
        showCupertinoModalPopup<String>(
          context: context,
          builder: (context) {
            return _buildBottomPicker(
              CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (value) {
                  setState(() {
                    _person = value + 1;
                    _calc();
                  });
                },
                children: _lstPerson,
                scrollController: FixedExtentScrollController(
                  initialItem: _person - 1,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _createStay() {
    return DropdownButton(
      value: _stay,
      style: Theme.of(context).textTheme.headline5,
      items: <DropdownMenuItem<int>>[
        DropdownMenuItem<int>(child: Text("日帰り"), value: 0),
        ...List.generate(
          7,
          (index) => DropdownMenuItem<int>(
              child: Text("${index + 1}泊${index + 2}日"), value: index + 1),
        ),
        DropdownMenuItem<int>(child: Text("8泊以上"), value: 10),
      ],
      onChanged: (value) => setState(() {
        _stay = value;
        _calc();
      }),
    );
  }

  Widget _createStayIos() {
    return CupertinoButton(
      child: _lstStay[_stay == 10 ? _lstStay.length - 1 : _stay],
      onPressed: () {
        showCupertinoModalPopup<String>(
          context: context,
          builder: (context) {
            return _buildBottomPicker(
              CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (value) {
                  setState(() {
                    _stay = value == _lstStay.length - 1 ? 10 : value;
                    _calc();
                  });
                },
                children: _lstStay,
                scrollController: FixedExtentScrollController(
                  initialItem: _stay,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: 216,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }
}
