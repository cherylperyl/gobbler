import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  DateTime dateTime = DateTime.now();
  String? selectedTime;
  String? formattedTime;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        const CupertinoSliverNavigationBar(
          largeTitle: Text('Create post'),
        ),
        SliverSafeArea(
          top: false,
          minimum: const EdgeInsets.only(top:0),
          sliver: SliverToBoxAdapter(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CupertinoFormSection(
                    margin: EdgeInsets.only(left:18,right:18,top:0,bottom:12),
                    children: [
                      CupertinoFormRow(
                        prefix: const Text("Title"),
                        child: CupertinoTextFormFieldRow(
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
                          textInputAction: TextInputAction.next,
                          placeholder: 'SMU Campus Green',
                          validator: (desc) {
                            if (desc == null || desc == '') {
                              return "Please enter a description of the location";
                            } else if (desc.length > 30) {
                              return "Please keep it under 30 characters";
                            } else {
                              return null;
                            }
                          }
                        ),
                      ),
                    ]
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CupertinoButton.filled(
                        child: formattedTime == null 
                        ? Text('Show picker')
                        : Text(formattedTime!),
                        onPressed: () => showSheet(
                          context, 
                          child: buildDatePicker(), 
                          onClicked: (){
                            setState(() => this.selectedTime = dateTime.toIso8601String());
                            setState(() => this.formattedTime = DateFormat('MMM d hh:m').format(dateTime));
                          }
                          )
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity, 
                    margin: EdgeInsets.symmetric(horizontal: 18),
                    child: CupertinoButton.filled(
                      child: Text('Create'),
                      onPressed: (){
                        final form = formKey.currentState!;
                        if (form.validate()) {
                          print('form valid');
                          Fluttertoast.showToast(
                            msg: "Post created successfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 2,
                            backgroundColor: CupertinoColors.activeGreen,
                            textColor: Colors.white,
                            fontSize: 16.0
                      );
                        }
                      },
                    )
                  ),
                ],
              )
            )
          ))

      ],
    );
  }
  Widget buildDatePicker() => Container(
    height: 180,
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: CupertinoDatePicker(
      initialDateTime: dateTime,
      mode: CupertinoDatePickerMode.time,
      onDateTimeChanged: (dateTime) => {
        setState(() => this.dateTime = dateTime),
      },
    ),
  );

  static void showSheet(
    BuildContext context, {
      required Widget child,
      required VoidCallback onClicked,
  }) => showCupertinoModalPopup(
    context: context, 
    builder: (context) => CupertinoActionSheet(
      actions: [
        child,
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: onClicked,
        child: Text('Done')
        )
    )
  );
}