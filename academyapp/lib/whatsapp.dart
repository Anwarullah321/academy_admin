import 'package:academyapp/utils/nexasoft_license_generator.dart';
import 'package:academyapp/utils/shuffling_and_masking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_drawer.dart';
import 'constants/my_keys.dart';
import 'models/StudentModel.dart';

class StudentRequestPage extends StatefulWidget {
  const StudentRequestPage({
    super.key,
  });

  @override
  State<StudentRequestPage> createState() => _StudentRequestPageState();
}

class _StudentRequestPageState extends State<StudentRequestPage> {
  List<String> subjects = [
    "Biology",
    "Maths",
    "Physics",
    "Chemistry",
    "English",
    "Pakistan Studies",
    "Islamiyat",
    "Urdu",
    "Mutalae Quran"
  ];
  List<String> selectedSubjects = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController phoneNoController = TextEditingController();
  TextEditingController classController = TextEditingController();
  TextEditingController fnController = TextEditingController();
  bool isEditing = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    phoneNoController.dispose();
    classController.dispose();
    fnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child:
                      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        TextFormField(
                          controller: nameController,
                          validator: (String? v) {
                            if (v == null || v.isEmpty) {
                              return "Required";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              label: Text("Name"),
                              hintText: "Name"),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: fnController,
                          validator: (String? v) {
                            if (v == null || v.isEmpty) {
                              return "Required";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_4_sharp),
                              label: Text("Father Name"),
                              hintText: "Father Name"),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: dobController,
                          validator: (String? v) {
                            if (v == null || v.isEmpty) {
                              return "Required";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  onPressed: () async {
                                    DateTime now = DateTime.now();
                                    DateTime dob = await showDatePicker(
                                        builder: (context, child) {
                                          return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: const ColorScheme.light(
                                                  primary: Colors.black,
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.black,
                                                ),
                                                textButtonTheme: TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              child: child!);
                                        },
                                        currentDate: DateTime.now(),
                                        barrierColor:
                                        const Color.fromARGB(123, 0, 0, 0),
                                        context: context,
                                        firstDate: DateTime(1970),
                                        lastDate: now) ??
                                        DateTime.now();

                                    dobController.text =
                                    "${dob.day}-${dob.month}-${dob.year}";
                                  },
                                  icon: const Icon(Icons.calendar_month)),
                              prefixIcon: const Icon(Icons.calendar_view_day),
                              label: const Text("Date of Birth"),
                              hintText: "Date of Birth"),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: phoneNoController,
                          keyboardType: const TextInputType.numberWithOptions(),
                          validator: (String? v) {
                            if (v == null || v.isEmpty) {
                              return "Required";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              prefixIcon: Padding(padding: EdgeInsets.all(6), child: Image(image: AssetImage("assets/images/whatsapp.png",),width: 14,height: 14,), ),
                              label: Text("Your WhatsApp Number"),
                              hintText: "92 320 43975479"),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        DropdownMenu(
                            leadingIcon: const Icon(Icons.school),
                            controller: classController,
                            width: MediaQuery.sizeOf(context).width - 40,
                            hintText: "Class 9",
                            dropdownMenuEntries: const [
                              DropdownMenuEntry(value: "Class 9", label: "Class 9"),
                              DropdownMenuEntry(value: "Class 10", label: "Class 10"),
                              DropdownMenuEntry(value: "Class 11", label: "Class 11"),
                              DropdownMenuEntry(value: "Class 12", label: "Class 12"),
                              DropdownMenuEntry(value: "ETEA", label: "ETEA")
                            ]),
                        const SizedBox(
                          height: 15,
                        ),
                        DropdownButton<String>(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          icon: const Icon(Icons.keyboard_double_arrow_down_sharp),
                          hint: const Text("Select a Subject"),
                          items: (subjects.toSet().difference(selectedSubjects.toSet()))
                              .toList()
                              .map((sub) {
                            return DropdownMenuItem<String>(
                              value: sub,
                              child: Text(sub),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null && !selectedSubjects.contains(newValue)) {
                              setState(() {
                                selectedSubjects.add(newValue);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        selectedSubjects.isEmpty
                            ? const SizedBox()
                            : const Text(
                          "Selected Subjects:",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 35,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedSubjects.length,
                            itemBuilder: (context, index) {
                              final subject = selectedSubjects[index];
                              return Center(
                                child: SubjectContainer(
                                  subject: subject,
                                  onTap: () {
                                    setState(() {
                                      selectedSubjects.removeAt(index);
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            style: ButtonStyle(
                                fixedSize: const WidgetStatePropertyAll(Size(250, 50)),
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15))),
                                backgroundColor: const WidgetStatePropertyAll<Color>(
                                    Color.fromARGB(255, 236, 236, 236)),
                                side: const WidgetStatePropertyAll<BorderSide>(
                                    BorderSide(width: 5, color: Color(0xffFEB80B)))),
                            child: const Text(
                              "Create License",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            onPressed: () async {
                              String rollNo = await getNextDocId();
                              String publicKey =
                              MaskingAndShuffling.decryptUnmaskAndUnshuffleKey(
                                  MyKey.encPublicKey, "public");

                              if (_formKey.currentState!.validate()) {
                                StudentModel model = StudentModel(studentData: {
                                  'name': nameController.text,
                                  'rollNo': rollNo,
                                  'class': classController.text,
                                  'dob': dobController.text,
                                  'subjects': selectedSubjects,
                                  'f/n': fnController.text,
                                  'whatsapp':
                                  "+${phoneNoController.text.replaceAll(" ", "")}",
                                });

                                String encrypted =
                                await NexaSoftLicenseGenrator.encryptString(
                                    data: model.toJson(), publicKey: publicKey);
                                final String encodedEncrypted =
                                Uri.encodeComponent(encrypted);
                                final Uri whatsappUri = Uri.parse(
                                    "https://wa.me/+923079374165?text=$encodedEncrypted");
                                _launchUrl(whatsappUri);
                                // if (context.mounted) {
                                //   showDialog(
                                //       context: context,
                                //       builder: (context) => AlertDialog(
                                //             title: Row(
                                //               mainAxisAlignment:
                                //                   MainAxisAlignment.spaceBetween,
                                //               children: [
                                //                 Text(
                                //                   "${nameController.text}'s License",
                                //                   style: const TextStyle(
                                //                       fontSize: 14,
                                //                       fontWeight: FontWeight.bold),
                                //                 ),
                                //                 IconButton(
                                //                     onPressed: () {
                                //                       Clipboard.setData(
                                //                           ClipboardData(text: encrypted));
                                //                       ScaffoldMessenger.of(context)
                                //                           .showSnackBar(const SnackBar(
                                //                               content: Text("Copied!!")));
                                //                     },
                                //                     icon: const Icon(Icons.copy))
                                //               ],
                                //             ),
                                //             content: SizedBox(
                                //               height: 400,
                                //               child: SingleChildScrollView(
                                //                 child: SelectableText(encrypted),
                                //               ),
                                //             ),
                                //           ));
                                // }
                                // }
                              }
                            }),
                      ]),
                    ),
                  ))),
        ));
  }

  Future<void> _launchUrl(Uri uri) async {
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  Future<String> getNextDocId() async {
    CollectionReference collection =
    FirebaseFirestore.instance.collection('student_licenses');

    QuerySnapshot querySnapshot = await collection.get();

    List<int> extNumbers = [];
    for (var doc in querySnapshot.docs) {
      String docId = doc.id;
      if (docId.startsWith('ext-')) {
        String numberPart = docId.substring(4);
        if (int.tryParse(numberPart) != null) {
          extNumbers.add(int.parse(numberPart));
        }
      }
    }

    extNumbers.sort();

    int nextId = 1;
    for (int number in extNumbers) {
      if (number != nextId) {
        break;
      }
      nextId++;
    }

    return 'ext-$nextId';
  }
}
