import 'package:flutter/material.dart';
import 'package:music_mobile_app/components/expandedsection.dart';
import 'buttons/custom_switch.dart';

class DrawerElement extends StatefulWidget {
  DrawerElement({Key key}) : super(key: key);

  @override
  _DrawerElementState createState() => _DrawerElementState();
}

class _DrawerElementState extends State<DrawerElement> {
  bool _settings = false;
  bool _expanded = false;
  bool _expandedNotify = false;
  List<bool> isSwitched = [false, false, false];

  Widget _divider() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(20, 15, 20, 15),
      height: 1,
      color: Color(0xFF212121),
    );
  }

  countryEncoder(String country) {
    switch (country) {
      case 'USA':
        return '🇺🇸';
        break;
      case 'Russia':
        return '🇷🇺';
        break;
      case 'Great Britain':
        return '🇬🇧';
        break;
      case 'Spain':
        return '🇪🇸';
        break;
      case 'Azerbaydzhan':
        return '🇦🇿';
        break;
      default:
        return null;
        break;
    }
  }

  Widget _langeItem(String country, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${countryEncoder(country)}    $country',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Container(
              width: 13,
              height: 13,
              margin: EdgeInsets.fromLTRB(0, 0, 6, 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: Color(0xFFFFFFFF),
                ),
              ),
              child: (isActive)
                  ? Container(
                      width: 9,
                      height: 9,
                      margin: EdgeInsets.fromLTRB(1, 1, 1, 1),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B6CEB),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _langSelect() {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${countryEncoder('Russia')}    Язык: Русский',
                        style: TextStyle(fontSize: 16)),
                  ),
                  Container(
                    child: Icon(
                        (_expanded) ? Icons.expand_less : Icons.expand_more),
                  )
                ],
              ),
            ),
          ),
          ExpandedSection(
            expand: _expanded,
            child: Column(
              children: [
                _divider(),
                _langeItem('USA', false),
                _divider(),
                _langeItem('Russia', true),
                _divider(),
                _langeItem('Great Britain', false),
                _divider(),
                _langeItem('Spain', false),
                _divider(),
                _langeItem('Azerbaydzhan', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notifySelectItem(int index) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(20, 15, 20, 15),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Все оповещения',
              style: TextStyle(fontSize: 16),
            ),
          ),
          CustomSwitch(
            value: isSwitched[index],
            onChanged: (value) {
              setState(() {
                isSwitched[index] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _notifySelect() {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedNotify = !_expandedNotify;
              });
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: Row(
                children: [
                  Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 12, 0),
                      child: Icon(Icons.notifications)),
                  Expanded(
                    child: Text('Оповещения', style: TextStyle(fontSize: 16)),
                  ),
                  Container(
                    child: Icon((_expandedNotify)
                        ? Icons.expand_less
                        : Icons.expand_more),
                  )
                ],
              ),
            ),
          ),
          ExpandedSection(
            expand: _expandedNotify,
            child: Column(
              children: [
                _divider(),
                _notifySelectItem(0),
                _notifySelectItem(1),
                _notifySelectItem(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (_settings)
        ? Container(
            width: 270,
            color: Color(0xFF101010),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _settings = false;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(20, 10, 25, 10),
                          child: Icon(
                            Icons.arrow_back,
                            size: 30,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(25, 10, 15, 10),
                          child: Icon(
                            Icons.close,
                            size: 30,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      child: ListView(
                        children: [
                          _divider(),
                          _langSelect(),
                          _divider(),
                          _notifySelect()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container(
            width: 270,
            color: Color(0xFF101010),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(25, 10, 15, 10),
                          child: Icon(
                            Icons.close,
                            size: 30,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _divider(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _settings = true;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 20, 4),
                            width: 20,
                            child: Icon(
                              Icons.settings,
                              color: Color(0xFFFFFFFF),
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Настройки',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _divider(),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            margin: EdgeInsets.fromLTRB(0, 0, 20, 4),
                            child: Icon(
                              Icons.info_rounded,
                              color: Color(0xFFFFFFFF),
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'О приложении',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _divider(),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            margin: EdgeInsets.fromLTRB(0, 0, 20, 4),
                            child: Icon(
                              Icons.campaign,
                              color: Color(0xFFFFFFFF),
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Рекламодателям',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _divider(),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 20, 4),
                            child: Icon(
                              Icons.message,
                              color: Color(0xFFFFFFFF),
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Обратная связь',
                              style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text(
                        'Политика конфиденциальности',
                        style:
                            TextStyle(color: Color(0xFF8E8E8E), fontSize: 14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadiusDirectional.circular(4),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            stops: [0, 1],
                            colors: [Color(0xFF3B6CEB), Color(0xFF112F7D)],
                          ),
                        ),
                        child: Text(
                          'Поделиться приложением',
                          style: TextStyle(
                              fontSize: 16,
                              height: 2.4,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
