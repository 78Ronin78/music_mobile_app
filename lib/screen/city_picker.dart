import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:music_mobile_app/helpers/preferences_helper.dart';
import 'package:music_mobile_app/repo/user_repo.dart';

class ItemData {
  ItemData(this.title, this.key);
  final String title;
  final Key key;
}

class Item extends StatelessWidget {
  Item({this.data, this.isFirst, this.isLast, this.delFromFavorites});
  final ItemData data;
  final bool isFirst;
  final bool isLast;
  final delFromFavorites;

  Widget _buildChild(BuildContext context, ReorderableItemState state) {
    Widget dragHandle = ReorderableListener(
      child: Container(
        padding: EdgeInsets.only(right: 18.0, left: 18.0),
        child: Center(
          child: Icon(
            Icons.menu,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );

    return Container(
      child: SafeArea(
        top: false,
        bottom: false,
        child: Opacity(
          opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: [
                      dragHandle,
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 0.0),
                        child: Text(
                          data.title,
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.red,
                          size: 23,
                        ),
                        onPressed: delFromFavorites,
                      ),
                      SizedBox(
                        width: 22,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(key: data.key, childBuilder: _buildChild);
  }
}

class CityPicker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CityPickerState();
  }
}

class CityPickerState extends State<CityPicker> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController editController = TextEditingController();
  List<String> history = [];
  List<ItemData> _items = [];

  int _indexOfKey(Key key) {
    return _items.indexWhere((ItemData d) => d.key == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    int draggingIndex = _indexOfKey(item);
    int newPositionIndex = _indexOfKey(newPosition);
    final draggedItem = _items[draggingIndex];
    setState(() {
      _items.removeAt(draggingIndex);
      _items.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  void _reorderDone(Key item) {
    List<String> list = [];
    _items.forEach((element) {
      list.add(element.title);
    });
    PreferencesHelper.setStringList('favorites', list);
  }

  addToFavorites(String element) async {
    if (_items.length >= 5) {
      scaffoldKey?.currentState?.showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Достигнут максимум городов', style: TextStyle(color: Colors.white)),
          action: SnackBarAction(
            textColor: Colors.white,
            label: 'Скрыть',
            onPressed: () {},
          ),
        ),
      );
    } else {
      List<String> list = [];
      _items.add(ItemData(element, ValueKey(_items.length)));
      _items.forEach(
        (element) {
          list.add(element.title);
        },
      );
      PreferencesHelper.setStringList('favorites', list).then(
        (value) {
          history.remove(element);
          PreferencesHelper.setStringList('history', history).then(
            (value2) {
              setState(
                () {
                  editController.text = '';
                },
              );
            },
          );
        },
      );
    }
  }

  delFromFavorites(String value) {
    _items.removeWhere((element) => element.title == value);
    List<String> list = [];
    _items.forEach((element) {
      list.add(element.title);
    });
    _items = [];
    for (int i = 0; i < list.length; ++i) {
      String label = list[i];
      _items.add(
        ItemData(
          label,
          ValueKey(i),
        ),
      );
    }
    PreferencesHelper.setStringList('favorites', list).then(
      (value2) {
        history.insert(0, value);
        if (history.length > 5) {
          history.removeAt(5);
        }
        PreferencesHelper.setStringList('history', history).then(
          (value) {
            editController.text = '';
            setState(() {});
          },
        );
      },
    );
  }

  getSearchList() {
    List<String> result = [];
    userRepo.allCitiesStringList.forEach(
      (element) {
        if (element.toLowerCase().contains(editController.text.toLowerCase())) {
          result.add(element);
        }
      },
    );
    return getList(list: result);
  }

  getFavoritesList(BuildContext context) {
    return ReorderableList(
      onReorder: this._reorderCallback,
      onReorderDone: this._reorderDone,
      child: CustomScrollView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          editController.text = _items[index].title;
                        });
                      },
                      child: Item(
                        data: _items[index],
                        isFirst: index == 0,
                        isLast: index == _items.length - 1,
                        delFromFavorites: () {
                          delFromFavorites(_items[index].title);
                        },
                      ),
                    );
                  },
                  childCount: _items.length,
                ),
              )),
        ],
      ),
    );
  }

  getList({List list, bool history = false}) {
    List<Widget> _places = [];
    for (int i = 0; i < list.length; i++) {
      bool favor = false;
      _items.forEach((value) {
        if (value.title == list[i]) favor = true;
      });
      _places.add(
        InkWell(
          onTap: () {
            if (history) {
              setState(() {
                editController.text = list[i];
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(25, history == false ? 0 : 15, 25, history == false ? 0 : 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  list[i],
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                history
                    ? Container()
                    : favor
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              delFromFavorites(list[i]);
                            },
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.add,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              addToFavorites(list[i]);
                            },
                          )
              ],
            ),
          ),
        ),
      );
    }
    return Column(
      children: _places,
    );
  }

  Widget historyAndFavorites(BuildContext context) {
    return Column(
      children: [
        customRow('История'),
        getList(list: history, history: true),
        customRow('Избранное'),
        getFavoritesList(context),
      ],
    );
  }

  Widget customRow(String label) {
    return Padding(
      padding: EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'HelveticaNeue',
              color: Color(0xFF3C3C3C),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Divider(
              height: 1,
              color: Color(0xFF3C3C3C),
            ),
          )
        ],
      ),
    );
  }

  Widget customTextForm() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            iconSize: 20,
            onPressed: () {
              if (editController.text.isNotEmpty) {
                editController.clear();
                setState(() {});
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: Image.asset(
              'assets/icons/arrow_back.png',
              width: 20,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: TextField(
              controller: editController,
              style: TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Поиск местоположения",
                border: InputBorder.none,
                focusColor: Colors.white,
                fillColor: Colors.white,
                hoverColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Icon(Icons.search),
          SizedBox(
            width: 8,
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(45),
        color: Colors.black,
      ),
    );
  }

  Widget searchResult() {
    return Column(
      children: [
        customRow('Поиск'),
        getSearchList(),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    PreferencesHelper.getStringList('favorites').then(
      (value) {
        for (int i = 0; i < value.length; ++i) {
          String label = value[i];
          _items.add(ItemData(label, ValueKey(i)));
        }
        PreferencesHelper.getStringList('history').then(
          (value2) {
            if (value2.length != 0) {
              history = value2;
            }
            setState(() {});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [
              0.1,
              0.8,
            ],
            colors: [
              Color(0xFF282828),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListView(
            children: [
              customTextForm(),
              editController.text.isNotEmpty ? searchResult() : historyAndFavorites(context),
            ],
          ),
        ),
      ),
    );
  }
}
