import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:music_mobile_app/helpers/route_arguments.dart';
import 'package:music_mobile_app/repo/playlist_repo.dart';
import 'package:music_mobile_app/repo/user_repo.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyRepo extends ChangeNotifier {
  final Logger _logger = Logger();

  Future<bool> connectToSpotifyRemote() async {
    try {
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: DotEnv().env['CLIENT_ID'].toString(), redirectUrl: DotEnv().env['REDIRECT_URL'].toString());
      setStatus(result ? 'connect to spotify successful' : 'connect to spotify failed');
      return result;
    } catch (e) {
      if (Platform.isAndroid) launch("https://play.google.com/store/apps/details?id=com.spotify.music&hl=en");
      if (Platform.isIOS) launch("https://apps.apple.com/ru/app/spotify-слушай-музыку/id324684580");
      // TODO: make exception logging
      rethrow;
    }
  }

  Future<String> getAuthenticationToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAuthenticationToken(
          clientId: DotEnv().env['CLIENT_ID'].toString(),
          redirectUrl: DotEnv().env['REDIRECT_URL'].toString(),
          scope: 'app-remote-control, '
              'user-modify-playback-state, '
              'playlist-read-private, '
              'playlist-modify-public,user-read-currently-playing');
      userRepo.tokenUpdateTime = DateTime.now();
      userRepo.authenticationToken = authenticationToken;
      setStatus('Got a token: $authenticationToken');
      return authenticationToken;
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      setStatus('not implemented');
      return Future.error('not implemented');
    }
  }

  void setStatus(String code, {String message = ''}) {
    var text = message.isEmpty ? '' : ' : $message';
    _logger.d('$code$text');
  }

  Future<void> addNextTracks(RouteArgument routeArgument) async {
    var i = routeArgument.trackNumber + 1;
    while (playListRepo.listPlaylist
            .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][routeArgument.period].tracks.length >
        i) {
      try {
        await Future.delayed(new Duration(seconds: 5));
        await SpotifySdk.queue(
            spotifyUri: playListRepo
                .listPlaylist
                .value[userRepo.cities.value[userRepo.cityIdForPlaylist]["name"]][routeArgument.period]
                .tracks[i]
                .track["url"]
                .toString());
      } catch (e) {}
      i++;
    }
  }

  Future<void> play(String url) async {
    try {
      await SpotifySdk.play(spotifyUri: url, asRadio: false);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> resume() async {
    try {
      await SpotifySdk.resume();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }
}

SpotifyRepo spotyRepo = SpotifyRepo();
