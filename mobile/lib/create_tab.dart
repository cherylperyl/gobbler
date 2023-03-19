import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile/model/app_state_model.dart';
import 'package:mobile/model/post.dart';
import 'package:mobile/individual_post.dart';
import 'package:location/location.dart';
import 'package:mobile/login_page.dart';

class CreateTab extends StatefulWidget {
  const CreateTab({super.key});

  @override
  State<CreateTab> createState() {
    return _CreateTabState();
  }
}

class _CreateTabState extends State<CreateTab> {
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

  final ImagePicker _picker = ImagePicker();
  @override
  initState() {
    super.initState();
    timeErrorMsg = false;
    imageErrorMsg = false;
    image = null;
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, model, child) {
        final userId = model.getUser()?.userId;
        final location = model.getLoc();
        return CustomScrollView(
          slivers: <Widget>[
            const CupertinoSliverNavigationBar(
              largeTitle: Text('Create post'),
            ),
            SliverSafeArea(
              top: false,
              minimum: const EdgeInsets.only(top:0),
              sliver: SliverToBoxAdapter(
                child: 
                userId != null 
                ? buildForm(model, userId, location!)
                : Column(
                  children: [
                    SizedBox(height: 30),
                    Center(
                      child: Text("Please log in to create a post")
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      child: CupertinoButton.filled(
                        child: const Text("Log in"), 
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => LoginPage()
                            )
                          );
                          setState(() {});
                        }),
                    )
                  ],
                )
              ))
      
          ],
        );
      }
    );
  }
  Widget buildDatePicker() => Container(
    height: 180,
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: CupertinoDatePicker(
      initialDateTime: dateTime,
      minimumDate: DateTime.now(),
      mode: CupertinoDatePickerMode.time,
      onDateTimeChanged: (dateTime) => {
        setState(() => this.dateTime = dateTime),
      },
    ),
  );

  void buildImagePicker(context) => showCupertinoModalPopup(
    context: context, 
    builder: (context) => CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () async {
            XFile? uploadImage = await _picker.pickImage(source: ImageSource.camera);
            if (uploadImage != null) {
              setState((){image = uploadImage;});
            }
            Navigator.of(context).pop();
          }, 
          child: Text("Camera")
        ),
        CupertinoActionSheetAction(
          onPressed: () async {
            XFile? uploadImage = await _picker.pickImage(source: ImageSource.gallery);
            if (uploadImage != null) {
              setState((){image = uploadImage;});
            }
            Navigator.of(context).pop();
            // final bytes = await image?.readAsBytes();
          }, 
          child: Text("Photo Library"),
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: (){
          Navigator.of(context).pop();
        },
        child: Text("Cancel")
      ),
    )
  );

  void showSheet(
    BuildContext context, {
      required Widget child,
  }) => showCupertinoModalPopup(
    context: context, 
    builder: (context) => CupertinoActionSheet(
      actions: [
        child,
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: (){
          setState(() => selectedTime = DateFormat('y-MM-d HH:mm:ss').format(dateTime));
          setState(() => formattedTime = DateFormat('MMM d h:mma').format(dateTime));
          Navigator.pop(context);
        },
        child: Text('Done')
      ),
    )
  );
  Widget buildForm(AppStateModel model, int userId, LocationData location) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CupertinoFormSection(
            margin: EdgeInsets.only(left:18,right:18,top:0,bottom:22),
            children: [
              CupertinoFormRow(
                prefix: const Text("Title"),
                child: CupertinoTextFormFieldRow(
                  controller: titleController,
                  textAlign: TextAlign.end,
                  textInputAction: TextInputAction.next,
                  placeholder: 'Chicken rice',
                  validator: (title) {
                    if (title == null || title == '') {
                      return "Please enter a title";
                    } else if (title.length > 30) {
                      return "Please keep it under 30 characters";
                    } else {
                      return null;
                    }
                  }
                  ,
                ),
              ),
              CupertinoFormRow(
                prefix: const Text("Location"),
                helper: Text('Provide a description so others know exactly where to go',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 12,
                  ),),
                child: CupertinoTextFormFieldRow(
                  controller: locationController,
                  maxLines: 2,
                  textAlign: TextAlign.end,
                  textInputAction: TextInputAction.next,
                  placeholder: 'SMU Campus Green',
                  validator: (desc) {
                    if (desc == null || desc == '') {
                      return "Please enter a location";
                    } else if (desc.length > 30) {
                      return "Please keep it under 30 characters";
                    } else {
                      return null;
                    }
                  }
                ),
              ),
              CupertinoFormRow(
                prefix: const Text("Servings"),
                helper: Text('The number of servings available',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 12,
                  ),
                ),
                child: CupertinoTextFormFieldRow(
                  controller: servingsController,
                  textInputAction: TextInputAction.next,
                  textAlign: TextAlign.end,
                  placeholder: '10',
                  validator: (servings) {
                    if (servings == null || servings == '') {
                      return "Please enter a number";
                    } else if (int.tryParse(servings) == null) {
                      return "Please enter a whole number";
                    } else {
                      return null;
                    }
                  }
                ),
              ),
              CupertinoFormRow(
                prefix: const Text("Expiry time"),
                child: CupertinoButton(
                  child: formattedTime == null 
                  ? Text('Select time')
                  : Text(formattedTime!),
                  onPressed: () => showSheet(
                    context, 
                    child: buildDatePicker(), 
                  )
                ),
                
                error: timeErrorMsg 
                ? Padding(
                  padding: const EdgeInsets.only(left: 102.0),
                  child: Text("Please select a time")
                )
                : SizedBox()
              ),
              CupertinoFormRow(
                prefix: const Text("Upload image"),
                child:  CupertinoButton(
                  onPressed: () => buildImagePicker(context),
                  child: image == null 
                  ? const Icon(CupertinoIcons.cloud_upload) 
                  : Text(image!.name)
                ),
                error: imageErrorMsg
                ? Padding(
                  padding: const EdgeInsets.only(left: 120),
                  child: Text("Please upload an image")
                )
                : SizedBox()
              ),
            ]
          ),

          Container(
            width: double.infinity, 
            margin: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: CupertinoButton.filled(
              disabledColor: CupertinoColors.systemGrey3,
              child: loading 
              ? const CupertinoActivityIndicator(
                color: CupertinoColors.black,
              )
              : Text('Create'),
              onPressed: loading
              ? null
              : () async {
                final form = formKey.currentState!;
                bool valid = form.validate();
                if (selectedTime == null) {
                  valid = false; 
                  setState(() { timeErrorMsg = true; });
                } else {
                  setState((){ timeErrorMsg = false; });
                }

                if (image == null) {
                  valid = false;
                  setState(() { imageErrorMsg = true; });
                } else {
                  setState(() { imageErrorMsg = false; });
                }

                if (valid) {  
                  setState((){loading = true;});
                  Post? post = await model.uploadPost(
                    titleController.text, 
                    locationController.text, 
                    servingsController.text, 
                    selectedTime!, 
                    userId, 
                    image!, 
                    location!
                  );

                  if (post != null) {
                    titleController.clear();
                    locationController.clear();
                    servingsController.clear();
                    setState((){selectedTime = null;});
                    setState((){formattedTime = null;});
                    setState((){image = null;});
                    setState((){loading = false;});
                    Fluttertoast.showToast(
                      msg: "Post created successfully",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      timeInSecForIosWeb: 2,
                      backgroundColor: CupertinoColors.activeGreen,
                      textColor: Colors.white,
                      fontSize: 16.0
                    );

                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => IndividualPost(post: post))
                    );
                  } else {

                  }
                } 
              },
            )
          ),
        ],
      )
    );
  }
}