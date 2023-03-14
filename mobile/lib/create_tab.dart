import 'package:flutter/cupertino.dart';

class CreateTab extends StatefulWidget {
  const CreateTab({super.key});

  @override
  State<CreateTab> createState() {
    return _CreateTabState();
  }
}

class _CreateTabState extends State<CreateTab> {
  TextEditingController titleController = TextEditingController();
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CupertinoFormSection(
                    margin: EdgeInsets.only(left:12,right:12,top:0,bottom:12),
                    children: [
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          textInputAction: TextInputAction.next,
                          placeholder: 'Title',
                        ),
                      ),
                      CupertinoFormRow(
                        child: CupertinoTextFormFieldRow(
                          textInputAction: TextInputAction.next,
                          placeholder: 'Location description',
                        ),
                      ),
                    ]
                  )
                ],
              )
            )
          ))

      ],
    );
  }
}