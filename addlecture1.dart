import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class AddLecture1 extends StatefulWidget {
  final String courseId;

  const AddLecture1({super.key , required this.courseId});

  @override
  State<AddLecture1> createState() => _AddLecture1State();
}
class _AddLecture1State extends State<AddLecture1> {
  
  final  CourseNameController = TextEditingController();
  final  TitleController= TextEditingController();
  final  CreatedByController =TextEditingController();

  File? file;
  ImagePicker image = ImagePicker();
  String pdfurl = "";
  String imageurl="";
  var name;
  var color1 = Colors.redAccent[700];
 
  late DatabaseReference dbRef;
 
  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Students').child(widget.courseId);
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                 
                  const Text(
                    'Create New Course',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SingleChildScrollView(
                    child: TextField(
                      controller: CourseNameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30))
                        ),
                        labelText: 'Course Name',
                        hintText: 'Enter Course Name ',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: TitleController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30))
                      ),
                      labelText: 'Title',
                      hintText: 'Enter Title',
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    controller: CreatedByController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30))
                      ),
                      labelText: 'Created By',
                      hintText: 'Enter Your Name',
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  MaterialButton(
                    shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                    ),
                    onPressed: () {
                      Map<String, String> lecturedata = {
                        'Course': CourseNameController.text,
                        'Title': TitleController.text,
                        'CreatedBy': CreatedByController.text,
                        'file':pdfurl,
                        'image':imageurl,
                        
                        
                      };

                        print('Lecture data saved for courseId: ${widget.courseId}');

         
                     dbRef.child(widget.courseId).push().set(lecturedata);


                    },
                    color: const Color.fromARGB(255, 3, 141, 88),
                    textColor: Colors.white,
                    minWidth: 300,
                    height: 35,
                    child: const Text('Create Course'),
                    
                    
                  ),
        
                  const SizedBox(height: 10,),
        
                  MaterialButton(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  elevation: 5.0,
                  height: 40,
                  minWidth: 200,
                  onPressed: () {
                    getfile();
                  },
                  color: const Color.fromARGB(255, 7, 135, 158),
                  child: const Text(
                    "Upload Lecture file",
                    style: TextStyle(color: Colors.white,
                      fontSize: 15,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                /*MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    elevation: 5.0,
                    height: 40,
                    minWidth: 200,
                    onPressed: () {
                      getImage();
                    },
                    child: Text(
                      "Choose Image",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    color: Color.fromARGB(255, 7, 135, 158),
                  ),
                  */
                ],                
              ),
            ),
          ),
        ),
      ),
    );
  }

getfile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc'],
    );

    if (result != null) {
      File c = File(result.files.single.path.toString());
      setState(() {
        file = c;
        name = result.names.toString();
      });
      uploadFile();
    }
  }

  getImage() async {
    var img = await image.pickImage(source: ImageSource.gallery);
    setState(() {
      file = File(img!.path);
    });
    if (file != null) {
      uploadimage();
    }
  }

  uploadFile() async {
    try {
      var imagefile =
          FirebaseStorage.instance.ref().child('Students').child("/$name");
      UploadTask task = imagefile.putFile(file!);
      TaskSnapshot snapshot = await task;
      pdfurl = await snapshot.ref.getDownloadURL();

      print(pdfurl);
      if (file != null) {
        Fluttertoast.showToast(
          msg: "Done Uploaded",
          textColor: Colors.red,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Something went wrong",
          textColor: Colors.red,
        );
      }
    } on Exception catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        textColor: Colors.red,
      );
    }
  }

  uploadimage() async {
    try {
      var imagefile =
          FirebaseStorage.instance.ref().child("Images").child("/$name");
      UploadTask task = imagefile.putFile(file!);
      TaskSnapshot snapshot = await task;
      imageurl = await snapshot.ref.getDownloadURL();

      print(imageurl);
      if (file != null) {
        Fluttertoast.showToast(
          msg: "Done Uploaded",
          textColor: Colors.red,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Something went wrong",
          textColor: Colors.red,
        );
      }
    } on Exception catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        textColor: Colors.red,
      );
    }
  }
  
}
