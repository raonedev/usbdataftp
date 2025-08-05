import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Recordingscreen extends StatefulWidget {
  const Recordingscreen({super.key});

  @override
  State<Recordingscreen> createState() => _RecordingscreenState();
}

class _RecordingscreenState extends State<Recordingscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recordings"),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(left: 8,right: 8,bottom: 8,top: index==0?8:0),
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(16),
              child: CupertinoListTile(
                padding: EdgeInsets.zero,
                title: Text("Recording_${index+1}_08_2025"),
                subtitle: Text("2025-08-02 17:19:48"),
                backgroundColor: Colors.white,
                leadingSize: 80,
                leading: Card(
                  child: Padding(padding: EdgeInsetsGeometry.all(3),
                  child: Container(
                    width: 60,
                    height: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                    color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("thumb",style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),),
                  ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}