import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:mobile/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mobile/model/app_state_model.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


class StripeWebView extends StatefulWidget {
  const StripeWebView({
    super.key,
    required this.user,
  });
  final User user;
  @override
  State<StripeWebView> createState() => _StripeWebViewState();
}

class _StripeWebViewState extends State<StripeWebView> {
  // WebViewController? controller;
  InAppWebViewController? webView;
  bool showWebView = true;
  late AppStateModel appStateModel;

  Future<void> userData() async {
    // final prefs = await SharedPreferences.getInstance();
    // String? prefsBearer = prefs.getString('bearerToken');
    // print("web view controller $prefsBearer");

    // var url = Uri.http("${dotenv.env['BASE_API_URL']!}",'/user/subscribe');
    // var response = await http.post(url, 
    //   headers: {
    //     'Authorization': '$prefsBearer', 
    //     'Content-Type': 'application/json'
    //   },
    //   body: jsonEncode(
    //     {
    //       "userId" : '${widget.user.userId}',
    //       "success_url": "http://www.google.com"
    //     }
    //   )
    // );
    // print(response.body);


    // controller = WebViewController()
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onNavigationRequest:(request) async {
    //         print('request Url ${request.url}');
    //         if (request.url.startsWith("http://google.com")) {
    //           appStateModel = Provider.of<AppStateModel>(context, listen:false);
    //           setState(() { showWebView = false; });
    //           await Future.delayed(const Duration());
    //           appStateModel.setUserToPremium();
    //           return NavigationDecision.prevent;
    //         }
    //         return NavigationDecision.navigate;
    //       },
    //     )
    //   )
      
    //   ..loadRequest(
    //     Uri.http(
    //       '${dotenv.env['BASE_API_URL']!}','/user/subscribe',
    //     ),
    //     method: LoadRequestMethod.post,
    //     body: Uint8List.fromList(utf8.encode(jsonEncode({
    //       "userId": '${widget.user.userId}',
    //       "success_url": "http://www.google.com"
    //     }))),
    //     headers: { "Authorization": "Bearer abcd",  "Content-Type": "text/plain"}
    // );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await userData();
      setState(() {});
    });
    
    if(widget.user.isPremium) {
        showWebView = false; 
      }
  }

  @override
  Widget build(BuildContext context) {
    print(Uint8List.fromList(utf8.encode("userId=${widget.user.userId}&success_url=http%3A%2F%2Fwww.google.com")));
    return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('new to premium Gobbler'),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                ListView(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 18),
                      alignment: Alignment.center,
                      child: const Text(
                        'Thank you!',
                        style: TextStyle(
                            color: CupertinoColors.activeBlue,
                            fontWeight: FontWeight.w500,
                            fontSize: 30),
                      )
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
                      child: widget.user.isPremium 
                      ? const Text("Already a premium Gobbler omnomnom!\nNo unsubscribing 😂😂😂", textAlign: TextAlign.center,)
                      : const Text(
                        'Successfully subscribed to Gobbler Premium omnomnom!',
                        style: TextStyle(fontSize: 20),
                      )
                      
                    ),
                    Image(
                      image: AssetImage('assets/success.webp')
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(26),
                      child: const Text(
                        'You may now return to the app',
                        style: TextStyle(fontSize: 20),
                      )
                    ),
                  ],
                ),
                showWebView 
                ? InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: Uri.http(
                      '${dotenv.env['BASE_API_URL']!}','/user/subscribe',
                    ),
                    method: "POST",
                    body: Uint8List.fromList(utf8.encode("userId=${widget.user.userId}&success_url=http%3A%2F%2Fwww.google.com")
                    ),
                    headers: {"Content-Type" : "application/json",}
                  ),
                )
                : SizedBox()
              ],
            ),
          ),
        );
  }
}