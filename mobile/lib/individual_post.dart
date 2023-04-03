import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  late bool isAvailable;

  @override
  void initState() {  
    isLoading = false;
    availableReservations = widget.post.availableReservations;
    isAvailable = widget.post.isAvailable;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        final userId = model.getUser()?.userId;
        
        final userRegisteredPosts = model.getUserRegisteredPosts();
        final userRegisteredPostsIds = model.getUserRegisteredPostsIds();
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
                          Padding(padding: EdgeInsets.symmetric(horizontal:6, vertical: 2.0), child: Text("Today "+DateFormat.jm().format(widget.post.createdAt.add(Duration(hours:8)))),),
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
                  ? isAvailable
                    ? CupertinoButton(
                      color: CupertinoColors.systemRed,
                      child: Text("Hide your post"),
                      onPressed: () {
                        print('widget.post.postId ${widget.post.postId}');
                        handleDeletePressed(context, model, widget.post.postId, userId!);
                      },
                    )
                    : widget.post.timeEnd.compareTo(DateTime.now()) > 0
                      ? CupertinoButton.filled(
                        disabledColor: CupertinoColors.systemGrey,
                        child: Text("Post hidden"),
                        onPressed: null,
                      )
                      : CupertinoButton.filled(
                        disabledColor: CupertinoColors.systemGrey,
                        child: Text("Post expired"),
                        onPressed: null,
                      )
                  : userRegisteredPostsIds.containsKey(widget.post.postId)
                    ? CupertinoButton(
                      child: Text("Cancel registration"), 
                      onPressed: () {
                        handleCancelPressed(context, model, userRegisteredPostsIds[widget.post.postId]!);
                      },
                      color: CupertinoColors.systemRed
                    )
                    : CupertinoButton.filled(
                      child: Text("Chope!"), 
                      onPressed: () {
                        handleReservationPressed(context, model, widget.post.postId, userId);
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
    if (timeBetween.inMinutes < 0) {
      return "Ended ${DateFormat().format(widget.post.timeEnd)}";
    }
    // String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = timeBetween.inMinutes.remainder(60).toString();
    if (timeBetween.inHours > 1) {
      return "${timeBetween.inHours} hours $twoDigitMinutes minutes";    
    } else if (timeBetween.inHours == 0) {
      return "$twoDigitMinutes minutes";  
    }
    return "${timeBetween.inHours} hour $twoDigitMinutes minutes";
  }
  void handleReservationPressed(BuildContext context, AppStateModel model, num postId, int? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => LoginPage()
            )
          );
    } else {
      _showAlertDialog(context, model, postId, userId!);
    }
  }
  
  void _showAlertDialog(BuildContext context, AppStateModel model, num postId, int userId) {
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
            onPressed: () async {
              setState(() { isLoading = true; });
              bool success = await model.reservePost(postId, userId);
              if (success) {
                setState(() { availableReservations -= 1;});
                Fluttertoast.showToast(
                  msg: "Food reserved successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 2,
                  backgroundColor: CupertinoColors.activeGreen,
                  textColor: Colors.white,
                  fontSize: 16.0
                );
              } else {
                Fluttertoast.showToast(
                  msg: "Could not reserve food",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 2,
                  backgroundColor: CupertinoColors.systemRed,
                  textColor: Colors.white,
                  fontSize: 16.0
                );
              }
              
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void handleCancelPressed(BuildContext context, AppStateModel model, int reservationId) async {
    _showCancelDialog(context, model, reservationId);
  }

  void _showCancelDialog(BuildContext context, AppStateModel model, int reservationId) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Are you sure you want to cancel your reservation?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              setState(() { isLoading = true; });
              bool success = await model.cancelReservation(reservationId);
              if (success) {
                setState(() { availableReservations += 1;});
                Fluttertoast.showToast(
                  msg: "Cancelled reservation successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 2,
                  backgroundColor: CupertinoColors.activeGreen,
                  textColor: Colors.white,
                  fontSize: 16.0
                );
              } else {
                Fluttertoast.showToast(
                  msg: "Could not cancel reservation",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 2,
                  backgroundColor: CupertinoColors.systemRed,
                  textColor: Colors.white,
                  fontSize: 16.0
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
  }

  void handleDeletePressed(BuildContext context, AppStateModel model, num postId, int userId) async {
    _showDeleteDialog(context, model, postId, userId);
  }

  void _showDeleteDialog(BuildContext context, AppStateModel model, num postId, int userId) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Confirmation'),
        content: const Text("Are you sure you want to hide your post? Users won't be able to see it anymore."),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              setState(() { isLoading = true; });
              Post? res = await model.hidePost(postId, userId);
              if (res != null) {
                print(res);
                setState((){ isAvailable = false; });
                Fluttertoast.showToast(
                  msg: "Post hidden successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 2,
                  backgroundColor: CupertinoColors.activeGreen,
                  textColor: Colors.white,
                  fontSize: 16.0
                );
              } else {
                Fluttertoast.showToast(
                  msg: "Could not hide post",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 2,
                  backgroundColor: CupertinoColors.systemRed,
                  textColor: Colors.white,
                  fontSize: 16.0
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Yes, hide it'),
          ),
        ],
      ),
    );
  }
}