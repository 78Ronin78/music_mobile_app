import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:music_mobile_app/repo/user_repo.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class GetToken extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 3 / 5,
                child: Text(
                  'Dont worry, we take info from Spotify',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  SpotifySdk.getAuthenticationToken(
                    scope: "playlist-modify-public playlist-modify-private",
                    clientId: DotEnv().env['CLIENT_ID'].toString(),
                    redirectUrl: DotEnv().env['REDIRECT_URL'].toString(),
                  ).then(
                    (value) {
                      userRepo.tokenUpdateTime = DateTime.now();
                      userRepo.authenticationToken = value;
                      Navigator.of(context).pop();
                    },
                  );
                },
                child: Container(
                  color: Colors.blue,
                  width: MediaQuery.of(context).size.width * 4 / 5,
                  height: 70,
                  child: Center(
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
