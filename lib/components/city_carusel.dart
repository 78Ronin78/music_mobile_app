import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_mobile_app/repo/user_repo.dart';
import 'package:music_mobile_app/screen/city_picker.dart';

class CityCarusel extends StatefulWidget {
  int cityId;
  final String page;
  final CarouselController controller;
  final Function onChange;
  final Function refactor;
  CityCarusel(this.page, {this.controller, this.cityId, this.onChange, this.refactor});

  @override
  _CityCaruselState createState() => _CityCaruselState();
}

class _CityCaruselState extends State<CityCarusel> {
  Widget _cityCarousel() {
    return ValueListenableBuilder(
      valueListenable: userRepo.cityListForCarusel,
      builder: (BuildContext context, List cities, Widget child) {
        return (cities.length > 0)
            ? Container(
                margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: CarouselSlider(
                  key: PageStorageKey(widget.page),
                  carouselController: widget.controller,
                  options: CarouselOptions(
                      aspectRatio: 10.0,
                      viewportFraction: 0.45,
                      onPageChanged: (index, reason) {
                        setState(() {
                          widget.cityId = index;
                          if (widget.page == 'home') {
                            userRepo.cityIdForHome = index;
                          } else
                            userRepo.cityIdForPlaylist = index;
                        });
                        if (widget.onChange != null) widget.onChange();
                      }),
                  items: cities.map((i) {
                    List<String> name = i['name'].split(' , ');
                    int index = cities.indexOf(i);
                    return Builder(
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Padding(
                            padding: EdgeInsets.all(0),
                            child: Container(
                              decoration: index == widget.cityId
                                  ? BoxDecoration(
                                      border: Border(bottom: BorderSide(width: 1)),
                                    )
                                  : BoxDecoration(),
                              child: GestureDetector(
                                onTap: () async {
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) => CityPicker(),
                                    ),
                                  )
                                      .then(
                                    (value) {
                                      userRepo
                                          .refactorFavotites()
                                          .then((value) => {if (widget.refactor != null) widget.refactor()});
                                    },
                                  );
                                },
                                child: Text(
                                    (index == widget.cityId)
                                        ? i['name'].toString().toUpperCase()
                                        : name[0].toString().toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: index == widget.cityId
                                        ? TextStyle(
                                            color: Color(0xFF3B6CEB),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            fontFamily: 'HelveticaNeue',
                                          )
                                        : TextStyle(color: Colors.grey, fontSize: 14)),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              )
            : Column(
                children: [
                  Center(
                    child: InkWell(
                      onTap: () async {
                        await Navigator.of(context)
                            .push(
                          MaterialPageRoute(
                            builder: (context) => CityPicker(),
                          ),
                        )
                            .then((value) {
                          userRepo
                              .refactorFavotites()
                              .then((value) => {if (widget.refactor != null) widget.refactor()});
                        });
                      },
                      child: Text(
                        'Choose city',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _cityCarousel();
  }
}
