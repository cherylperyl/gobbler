import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/edit_post.dart';
import 'package:mobile/login_page.dart';
import 'package:mobile/model/post.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/model/app_state_model.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class IndividualPost extends StatefulWidget {
  const IndividualPost({
    super.key,
    required this.post
    });
  final Post post;

  @override
  State<IndividualPost> createState() => _IndividualPostState();
}

class _IndividualPostState extends State<IndividualPost> {
  bool isLoading = false;
  num availableReservations = 0;
  final formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController servingsController = TextEditingController();
  DateTime dateTime = DateTime.now();
  String? selectedTime;
  String? formattedTime;
  bool timeErrorMsg = false;
  bool imageErrorMsg = false;
  bool loading = false;
  XFile? image;

  @override
  void initState() {  
    isLoading = false;
    availableReservations = widget.post.availableReservations;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        // final userId = model.getUser()?.userId;
        const userId = 22;
        final userRegisteredPosts = model.getUserRegisteredPostsIds();
        return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text("Gobble Snack"),
          trailing: userId == widget.post.userId 
          ? CupertinoButton(
            child: Icon(
              CupertinoIcons.pen), 
            onPressed: (){
              Navigator.push(
                context, 
                CupertinoPageRoute(
                  builder: (context) => EditPost(
                    post: widget.post
                  )
                )
              );
            })
          : null
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  widget.post.title, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20),)),
              Container(
                height: MediaQuery.of(context).size.height * 0.36,
                width: double.infinity,
                child: Image.network(widget.post.imageUrl,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 14),
                child: Container(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [const Icon(CupertinoIcons.placemark),const Text(" Location", style: const TextStyle(fontWeight: FontWeight.bold),)]),
                          Padding(padding: EdgeInsets.symmetric(horizontal:6, vertical: 2.0),child: Text(widget.post.locationDescription)),
                          const SizedBox(height: 12),
                          Row(children: [const Icon(CupertinoIcons.calendar),Text(" Posted at", style: TextStyle(fontWeight: FontWeight.bold),)]),
                          Padding(padding: EdgeInsets.symmetric(horizontal:6, vertical: 2.0), child: Text("Today "+DateFormat.jm().format(widget.post.createdAt)),),
                          const SizedBox(height: 12),
                          Row(children: [
                            const Icon(CupertinoIcons.clear_circled),
                            Text(" Expires in: ", style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(getExpiryTime())
                            ]),
                          const SizedBox(height: 12),
                          Row(children: [
                            const Icon(CupertinoIcons.number_square),
                            Text(" Servings left: ", style: TextStyle(fontWeight: FontWeight.bold),), 
                            Text(availableReservations.toString())
                            ]),
                        ],
                      ),
                    ),
                  ),
                ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 18),
                  width: double.infinity,
                  child: userId == widget.post.userId
                  ? CupertinoButton(
                    color: CupertinoColors.systemRed,
                    child: Text("Delete your post"),
                    onPressed: () {},
                    
                  )
                  : userRegisteredPosts.contains(widget.post.postId)
                    ? CupertinoButton.filled(
                      child: Text("Registered"), 
                      onPressed: null,
                      disabledColor: CupertinoColors.systemGrey,
                    )
                    : CupertinoButton.filled(
                      child: Text("Chope!"), 
                      onPressed: () {
                        handleReservationPressed(context);
                      }),
                )
            ],),
        )
        );
      }
    );
  }

  String getExpiryTime() {
    Duration timeBetween = widget.post.timeEnd.difference(DateTime.now());
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(timeBetween.inMinutes.remainder(60));
    return "${twoDigits(timeBetween.inHours)} hours $twoDigitMinutes minutes";
  }
  void handleReservationPressed(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? bearer = prefs.getString('bearerToken');
    if (bearer == null) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => LoginPage()
            )
          );
    } else {
      _showAlertDialog(context);
    }
  }
  void _showAlertDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Are you sure you want to reserve one serving?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              
              setState(() { isLoading = true; });
              // call to make reservation
              setState(() { availableReservations -= 1;});

              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}