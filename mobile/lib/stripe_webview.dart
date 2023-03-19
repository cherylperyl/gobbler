import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mobile/model/app_state_model.dart';


class StripeWebView extends StatefulWidget {
  const StripeWebView({super.key});

  @override
  State<StripeWebView> createState() => _StripeWebViewState();
}

class _StripeWebViewState extends State<StripeWebView> {
  late final WebViewController controller;
  bool showWebView = true;
  late AppStateModel appStateModel;

  @override
  void initState() {
    super.initState();

    showWebView = true; 
    

    controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest:(request) async {
            if (request.url.startsWith("http://localhost:5000/users")) {
              appStateModel = Provider.of<AppStateModel>(context, listen:false);
              setState(() { showWebView = false; });
              await Future.delayed(const Duration());
              appStateModel.getUpdatedUserDetails();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        )
      )
      ..loadRequest(
        Uri.parse(
          'http://${dotenv.env['BASE_API_URL']!}:5000/create-checkout-session'
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Subscribe to premium Gobbler'),
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
                      child: const Text(
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
                ? WebViewWidget(
                  controller: controller,
                )
                : SizedBox()
              ],
            ),
          ),
        );
  }
}