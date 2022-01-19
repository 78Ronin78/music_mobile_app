import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:music_mobile_app/components/city_carusel.dart';
import 'package:music_mobile_app/components/drawer_element.dart';
import 'package:music_mobile_app/components/mainappbar.dart';
import 'package:music_mobile_app/helpers/api_router.dart';
import 'package:music_mobile_app/helpers/preferences_helper.dart';
import 'package:music_mobile_app/helpers/route_arguments.dart';
import 'package:music_mobile_app/repo/banner_repo.dart';
import 'package:music_mobile_app/repo/playlist_repo.dart';
import 'package:music_mobile_app/repo/spotify_repo.dart';
import 'package:music_mobile_app/repo/user_repo.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

import 'getSpotifyToken.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    if (userRepo.cities.value.isNotEmpty)
      updateBanners(
        int.parse(
          userRepo.getCityId(
            userRepo.cities.value[userRepo.cityIdForHome]["name"],
          ),
        ),
      );
    super.initState();
  }

  updateBanners(int id) async {
    await bannerRepo.updateBanners(id);
    setState(() {});
  }

  List<Widget> _imageSliders() {
    return bannerRepo.banners
        .map(
          (item) => Container(
            child: InkWell(
              onTap: () async {
                if (DateTime.now().difference(userRepo.tokenUpdateTime).inMinutes > 55) {
                  if (Platform.isAndroid) {
                    userRepo.authenticationToken = "";
                    await SpotifySdk.getAuthenticationToken(
                      scope: "playlist-modify-public playlist-modify-private",
                      clientId: DotEnv().env['CLIENT_ID'].toString(),
                      redirectUrl: DotEnv().env['REDIRECT_URL'].toString(),
                    ).then(
                      (value) {
                        userRepo.tokenUpdateTime = DateTime.now();
                        userRepo.authenticationToken = value;
                      },
                    );
                  }
                  if (Platform.isIOS)
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => GetToken(),
                      ),
                    );
                }
                Navigator.of(context)
                    .pushNamed(
                  '/playList',
                  arguments: RouteArgument(
                    title: "Рекламный плэйлист",
                    subtitle: "",
                    plate: 1,
                    date: '',
                    period: "",
                    bannerItem: item,
                  ),
                )
                    .then(
                  (value) async {
                    if (userRepo.cityListForCarusel.value.isNotEmpty) {
                      if (DateTime.now().difference(userRepo.tokenUpdateTime).inMinutes > 55) {
                        if (Platform.isAndroid) {
                          userRepo.authenticationToken = "";
                          await SpotifySdk.getAuthenticationToken(
                            scope: "playlist-modify-public playlist-modify-private",
                            clientId: DotEnv().env['CLIENT_ID'].toString(),
                            redirectUrl: DotEnv().env['REDIRECT_URL'].toString(),
                          ).then(
                            (value) {
                              userRepo.tokenUpdateTime = DateTime.now();
                              userRepo.authenticationToken = value;
                            },
                          );
                        }
                        if (Platform.isIOS)
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => GetToken(),
                            ),
                          );
                        setState(
                          () {
                            playListRepo.delPlaylist("");
                            userRepo.cityIdForHome = userRepo.cityIdForPlaylist;
                            userRepo.buttonCarouselControllerForHome.jumpToPage(userRepo.cityIdForPlaylist);
                            setState(() {});
                          },
                        );
                      }
                    }
                  },
                );
              },
              child: Container(
                margin: EdgeInsets.all(0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.network(
                        item.image,
                        fit: BoxFit.contain,
                        width: 1000.0,
                        height: 132,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  final CarouselController _controllerSlider = CarouselController();
  int _current = 0;
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        key: scaffoldKey,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        backgroundColor: Color(0xFF101010),
        appBar: MainAppBar(),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.symmetric(horizontal: 10),
                shrinkWrap: true,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  CityCarusel(
                    'home',
                    cityId: userRepo.cityIdForHome,
                    controller: userRepo.buttonCarouselControllerForHome,
                    onChange: () {
                      userRepo.changeTiles(
                        userRepo.cities.value[userRepo.cityIdForHome]["name"],
                      );
                      updateBanners(
                        int.parse(
                          userRepo.getCityId(
                            userRepo.cities.value[userRepo.cityIdForHome]["name"],
                          ),
                        ),
                      );
                    },
                    refactor: () {
                      updateBanners(
                        int.parse(
                          userRepo.getCityId(
                            userRepo.cities.value[userRepo.cityIdForHome]["name"],
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  SingleChildScrollView(
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        bannerRepo.banners.isNotEmpty
                            ? CarouselSlider(
                                items: _imageSliders(),
                                options: CarouselOptions(
                                  viewportFraction: 1.0,
                                  enlargeCenterPage: false,
                                  height: 132,
                                  onPageChanged: (index, reason) {
                                    setState(
                                      () {
                                        _current = index;
                                      },
                                    );
                                  },
                                ),
                                carouselController: _controllerSlider,
                              )
                            : Container(),
                        bannerRepo.banners.isNotEmpty
                            ? Positioned(
                                bottom: 10,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: bannerRepo.banners.map(
                                    (url) {
                                      int index = bannerRepo.banners.indexOf(url);
                                      return Container(
                                        width: 8.0,
                                        height: 8.0,
                                        margin: EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                          border: Border.all(),
                                          shape: BoxShape.circle,
                                          color: _current == index ? Color.fromRGBO(0, 0, 0, 0.9) : Colors.transparent,
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              )
                            : Container(),
                        bannerRepo.banners.isNotEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    child: IconButton(
                                      onPressed: () => _controllerSlider.previousPage(),
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: IconButton(
                                      onPressed: () => _controllerSlider.nextPage(),
                                      icon: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container()
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Row(
                      children: [
                        Text(
                          'Плейлисты',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            width: double.infinity,
                            height: 1,
                            color: Color(0xFF262626),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: userRepo.playlist,
                    builder: (BuildContext context, List playlist, Widget child) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.15,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: playlist.length,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () async {
                              if (playlist[i]["tracks"]) {
                                if (DateTime.now().difference(userRepo.tokenUpdateTime).inMinutes > 55) {
                                  if (Platform.isAndroid) {
                                    userRepo.authenticationToken = "";
                                    await SpotifySdk.getAuthenticationToken(
                                            scope: "playlist-modify-public playlist-modify-private",
                                            clientId: DotEnv().env['CLIENT_ID'].toString(),
                                            redirectUrl: DotEnv().env['REDIRECT_URL'].toString())
                                        .then(
                                      (value) {
                                        userRepo.tokenUpdateTime = DateTime.now();
                                        userRepo.authenticationToken = value;
                                      },
                                    );
                                  }
                                  if (Platform.isIOS)
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => GetToken(),
                                      ),
                                    );
                                }
                                await Navigator.of(context).pushNamed(
                                  '/playList',
                                  arguments: RouteArgument(
                                    title: playlist[i]['title'],
                                    subtitle: playlist[i]['subtitle'],
                                    plate: i,
                                    date:
                                        '${playlist[i]['firstDate']} ${(playlist[i]['secondDate'] != null) ? "- ${playlist[i]['secondDate']}" : ''}',
                                    period: playlist[i]["dateTime"],
                                  ),
                                );

                                if (userRepo.cityListForCarusel.value.isNotEmpty) {
                                  if (DateTime.now().difference(userRepo.tokenUpdateTime).inMinutes > 55) {
                                    if (Platform.isAndroid) {
                                      userRepo.authenticationToken = "";
                                      await SpotifySdk.getAuthenticationToken(
                                              scope: "playlist-modify-public playlist-modify-private",
                                              clientId: DotEnv().env['CLIENT_ID'].toString(),
                                              redirectUrl: DotEnv().env['REDIRECT_URL'].toString())
                                          .then(
                                        (value) {
                                          userRepo.tokenUpdateTime = DateTime.now();
                                          userRepo.authenticationToken = value;
                                        },
                                      );
                                    }
                                    if (Platform.isIOS)
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => GetToken(),
                                        ),
                                      );
                                  }
                                  userRepo.cityIdForHome = userRepo.cityIdForPlaylist;
                                  playListRepo.delPlaylist(playlist[i]["dateTime"]);
                                  userRepo.buttonCarouselControllerForHome.jumpToPage(userRepo.cityIdForPlaylist);
                                  setState(() {});
                                }
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    image: DecorationImage(
                                      image: playlist[i]["tracks"]
                                          ? AssetImage("assets/images/plate_${i + 1}.png")
                                          : AssetImage("assets/images/plate_11.png"),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                  child: SizedBox(),
                                ),
                                Positioned(
                                  bottom: 33,
                                  left: 10,
                                  child: Text(
                                    playlist[i]['subtitle'] != null ? playlist[i]['subtitle'] : '',
                                    // style: Theme.of(context).textTheme.subtitle1,
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Text(
                                    playlist[i]['title'],
                                    // style: Theme.of(context).textTheme.bodyText1,
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Text(
                                    '${playlist[i]['firstDate']} ${(playlist[i]['secondDate'] != null) ? "- ${playlist[i]['secondDate']}" : ''}',
                                    // style: Theme.of(context).textTheme.subtitle1,
                                    style: TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 16,
                                      fontFamily: 'Golroy',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
              (userRepo.firstOpen)
                  ? Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0, 1],
                            colors: [
                              Color(0xFF000000),
                              Color(0x66000000),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                width: MediaQuery.of(context).size.width - 60,
                                height: 65,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF112F7D),
                                      Color(0xFF3B6CEB),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: FlatButton(
                                  onPressed: () {
                                    launch("https://play.google.com/store/apps/details?id=com.spotify.music&hl=en");
                                  },
                                  child: Text(
                                    'Загрузите Spotify',
                                    style: TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                height: 65,
                                width: MediaQuery.of(context).size.width - 60,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFFFFF),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xFF3B6CEB),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: FlatButton(
                                  onPressed: () {
                                    spotyRepo.connectToSpotifyRemote().then(
                                      (value) async {
                                        if (value) {
                                          PreferencesHelper.setString("firstOpen", "false");
                                          userRepo.firstOpen = false;
                                          setState(() {});
                                          String token = await spotyRepo.getAuthenticationToken();
                                          String auth = await ApiRouter.sendRequest(
                                            method: 'post',
                                            path: 'api/user',
                                            requestBody: {"token": token},
                                          );
                                          if (userRepo.cities.value.isNotEmpty)
                                            updateBanners(
                                              int.parse(
                                                userRepo.getCityId(
                                                  userRepo.cities.value[userRepo.cityIdForHome]["name"],
                                                ),
                                              ),
                                            );
                                          userRepo.clientId = (json.decode(auth)["user"]["client_id"]);
                                          await userRepo.getPlaylistFromLocal().then(
                                            (value) {
                                              if (userRepo.cities.value.isNotEmpty)
                                                userRepo
                                                    .changeTiles(userRepo.cities.value[userRepo.cityIdForHome]["name"]);
                                            },
                                          );
                                        }
                                      },
                                      onError: (e) {
                                        final snackBar = SnackBar(
                                          content: Text('Oops, something went wrong'),
                                          action: SnackBarAction(
                                            label: 'Ok',
                                            onPressed: () {
                                              print('error: $e');
                                            },
                                          ),
                                        );
                                        scaffoldMessengerKey.currentState.showSnackBar(snackBar);
                                      },
                                    );
                                  },
                                  child: Text(
                                    'У меня есть Spotify',
                                    style: TextStyle(
                                      fontFamily: 'Gilroy',
                                      fontSize: 16,
                                      color: Color(0xFF3B6CEB),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
        ),
        endDrawer: DrawerElement(),
      ),
    );
  }
}
