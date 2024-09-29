import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:window_manager/window_manager.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.setAlwaysOnTop(true);

  windowManager.setSize(Size(314.4, 263.2));
  // windowManager.setMaximumSize(Size(314.4, 249.6));
  // windowManager.setMinimumSize(Size(314.4, 249.6));
  windowManager.setResizable(false);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Wisp - Mini Translator App',
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'PretendardVariable',
        ),
        home: const MyHomePage(),
      );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class FontSystem {
  static const pretendardRegular = <FontVariation>[FontVariation.weight(400)];
  static const pretendardMedium = <FontVariation>[FontVariation.weight(500)];
  static const pretendardSemiBold = <FontVariation>[FontVariation.weight(600)];
}

class ColorSystem {
  static final ColorSystem instance = ColorSystem._internal();
  factory ColorSystem() => instance;
  ColorSystem._internal();

  // Mode
  bool isLight = true;

  // Border Color
  Color defaultBorderColor = Color(0xFFDBDBDB);
  Color focusedBorderColor = Color(0xFF353535);

  // Surface Color
  Color backgroundColor = Colors.white;
  Color surfaceColor = Color(0xFFF4F5F6);
  Color buttonSurfaceColor = Color(0xFF5F4AFF);

  // Text Color
  Color primaryTextColor = Color(0xFF353535);
  Color secondaryTextColor = Color(0xFFA7A7A7);
  Color buttonTextColor = Colors.white;

  void toggleMode() {
    isLight = !isLight;
    chooseColor(isLight);
  }

  void chooseColor(bool isLight) {
    if(isLight) {
      defaultBorderColor = Color(0xFFDBDBDB);
      focusedBorderColor = Color(0xFF353535);

      backgroundColor = Colors.white;
      surfaceColor = Color(0xFFF4F5F6);
      buttonSurfaceColor = Color(0xFF5F4AFF);

      primaryTextColor = Color(0xFF353535);
      secondaryTextColor = Color(0xFFA7A7A7);
      buttonTextColor = Colors.white;
    } else {
      defaultBorderColor = Color(0xFF505050);
      focusedBorderColor = Color(0xFFA8A8A8);

      backgroundColor = Color(0xFF353535);
      surfaceColor = Color(0xFF484848);
      buttonSurfaceColor = Color(0xFF5F4AFF);

      primaryTextColor = Colors.white;
      secondaryTextColor = Color(0xFF636363);
      buttonTextColor = Colors.white;
    }
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();

  final _apiKey = 'YOUR_API_KEY';

  final _korean = 'KOREAN';
  final _english = 'ENGLISH';

  String _translatedText = '';
  late String _translateFrom;
  late String _translateTo;

  bool isLight = true;
  ColorSystem colorSystem = ColorSystem();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _translateFrom = _english;
    _translateTo = _korean;
    _translateText(myController.text, _translateTo);
  }

  Future<void> _translateText(String text, String targetLanguage) async {
    final url = 'https://translation.googleapis.com/language/translate/v2?key=$_apiKey';

    final tl = targetLanguage == _korean ? 'ko' : 'en';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'q': text,
        'target': tl,
      }),
    );

    if(response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _translatedText = responseData['data']['translations'][0]['translatedText'];
      });
    } else {
      setState(() {
        _translatedText = '번역 중 오류가 발생했습니다.';
      });
    }
  }

  void _toggleLanguage() {
    if(_translateFrom == _english) {
      setState(() {
        _translateFrom = _korean;
        _translateTo = _english;
      });
    } else if(_translateFrom == _korean) {
      setState(() {
        _translateFrom = _english;
        _translateTo = _korean;
      });
    } 
  }

  void _toggleThemeMode() {
    setState(() {
      colorSystem.toggleMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyT, control: true): () {
          setState(() {
            _toggleThemeMode();
          });
        }
      },
      child: Scaffold(
        backgroundColor: colorSystem.backgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          child: Column(
            children: [
              Container(
                height: 52,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorSystem.focusedBorderColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 9,
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 10,
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            _translateFrom,
                            style: TextStyle(
                              fontVariations: FontSystem.pretendardSemiBold,
                              fontSize: 10,
                              height: 0.1,
                              letterSpacing: -0.30,
                              color: colorSystem.secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                        child: Focus(
                          onFocusChange: (hasFocus) {
                            // if(hasFocus) print('hi');
                            // else print('bye');
                          },
                          child: TextField(
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              
                              hintText: '번역할 내용을 입력하세요.',
                              hintStyle: TextStyle(
                                fontVariations: FontSystem.pretendardRegular,
                                fontSize: 14,
                                height: 0.1,
                                letterSpacing: -0.42,
                                color: colorSystem.secondaryTextColor,
                              ),
                            ),
                            style: TextStyle(
                              fontVariations: FontSystem.pretendardRegular,
                              fontSize: 14,
                              letterSpacing: -0.42,
                              color: colorSystem.primaryTextColor,
                            ),
                                        
                            cursorHeight: 18,
                            cursorWidth: 1.0,
                                
                            controller: myController,
                            onEditingComplete: () {
                              _translateText(myController.text, _translateTo);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8,),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: _toggleLanguage, 
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    backgroundColor: colorSystem.buttonSurfaceColor,
                  ),
                  
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                      
                    children: [
                      Icon(
                        Icons.swap_vert,
                        color: colorSystem.buttonTextColor,
                      ),
                      SizedBox(width: 4,),
                      Text(
                        'Swap',
                        style: TextStyle(
                          fontVariations: FontSystem.pretendardMedium,
                          fontSize: 14,
                          letterSpacing: -0.42,
                          color: colorSystem.buttonTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8,),
              Container(
                height: 93,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorSystem.defaultBorderColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: colorSystem.surfaceColor,
                ),
      
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 9, 
                    horizontal: 15
                  ),
      
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 10,
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            _translateTo,
                            style: TextStyle(
                              fontVariations: FontSystem.pretendardSemiBold,
                              fontSize: 10,
                              height: 0.1,
                              letterSpacing: -0.30,
                              color: colorSystem.secondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 268, height: 2,),
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SelectableText(
                            _translatedText,
                            style: TextStyle(
                              fontVariations: FontSystem.pretendardRegular,
                              fontSize: 14,
                              letterSpacing: -0.42,
                              color: colorSystem.primaryTextColor,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    

    // return Scaffold(
    //   body: Padding(
    //     padding: const EdgeInsets.symmetric(
    //       vertical: 12,
    //       horizontal: 16,
    //     ),
    //     child: Column(
    //       children: [
    //         // Input Box
    //         Container(
    //           height: 52,
    //           decoration: BoxDecoration(
    //             border: Border.all(
    //               color: Color(0xFFA7A7A7),
    //             ),
    //             borderRadius: BorderRadius.all(Radius.circular(4)),
    //           ),
    //           child: Padding(
    //             padding: const EdgeInsets.symmetric(
    //               vertical: 9,
    //               horizontal: 15,
    //             ),
    //             // Input Box - Inner
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 // Input Box - Inner - Label
    //                 SizedBox(
    //                   height: 10,
    //                   child: Center(
    //                     widthFactor: 1,
    //                     child: Text(
    //                       _translateFrom,
    //                       style: TextStyle(
    //                         // Input Box - Inner - Label - Font Setting
    //                         fontVariations: _pretendardSemiBold,
    //                         fontSize: 10,
    //                         // Input Box - Inner - Label - Font Color
    //                         color: Color(0xFFA7A7A7),
    //                         // Input Box - Inner - Label - Font Letters
    //                         height: 0.10,
    //                         letterSpacing: -0.30,
    //                         ),
    //                     ),
    //                   ),
    //                 ),
    //                 SizedBox(
    //                   height: 20,
    //                   child: TextField(
    //                     controller: myController,
    //                     // textAlignVertical: TextAlignVertical.bottom,
    //                     // maxLines: 1,
    //                     decoration: InputDecoration(
    //                       // contentPadding: EdgeInsets.zero,
    //                       // isDense: true,
    //                       border: InputBorder.none,
    //                       // isCollapsed: true,
    //                       hintText: '번역할 내용을 입력하세요.',
    //                       hintStyle: TextStyle(
    //                         color: Color(0xFFC0C0C0),
    //                         // fontWeight: FontWeight.w200,
    //                         fontSize: MediaQuery.of(context).textScaler.clamp().scale(14),
    //                         fontVariations: _pretendardRegular,
    //                         // height: 0.10,
    //                         letterSpacing: -0.42,
    //                       ),
    //                     ),
    //                     cursorColor: Color(0xFF353535),
    //                     cursorHeight: 18,
    //                     cursorWidth: 1.0,
    //                     style: TextStyle(
    //                       fontSize: 14,
    //                       // fontWeight: FontWeight.w200,
    //                       fontVariations: _pretendardRegular,
    //                       // height: 0.10,
    //                       letterSpacing: -0.42,
    //                     ),
    //                     onSubmitted: (value) {
    //                       _translateText(myController.text, _translateTo);
    //                     },
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //         const SizedBox(height: 8,),
    //         SizedBox(
    //           width: 268,
    //           height: 40,
    //           child: ElevatedButton(
    //             onPressed: () {
    //               toggleLanguage();
    //               // print(MediaQuery.of(context).);
    //             }, 
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Color.fromARGB(255, 95, 74, 255),
    //               iconColor: Colors.white,
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.all(Radius.circular(8)),
    //               )
    //             ),
                
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: [
    //                 Icon(Icons.swap_vert),
    //                 SizedBox(width: 4,),
    //                 Text(
    //                   'Swap',
    //                   style: TextStyle(
    //                     color: Colors.white,
    //                     // fontWeight: FontWeight.w300,
    //                     fontVariations: _pretendardMedium,
    //                     height: 0.10,
    //                     letterSpacing: -0.42,
    //                   ),
    //                 )
    //               ],
    //             ),
    //           ),
    //         ),
    //         SizedBox(height: 8,),
    //         // Expanded(
    //         //   // height: 93,
    //         //   child: TextField(
    //         //     maxLines: null,
    //         //     expands: true,
    //         //     keyboardType: TextInputType.multiline,
    //         //     readOnly: true,
    //         //     decoration: InputDecoration(
    //         //       enabledBorder: OutlineInputBorder(
    //         //         borderSide: BorderSide(color: Color(0xFFC0C0C0))
    //         //       ),
    //         //       focusedBorder: OutlineInputBorder(
    //         //         borderSide: BorderSide(color: Color(0xFFC0C0C0))
    //         //       ),
    //         //       hintText: _translatedText,
    //         //       hintStyle: TextStyle(
    //         //         fontSize: 14,
    //         //         fontWeight: FontWeight.w200,
    //         //         height: 0.10,
    //         //         letterSpacing: -0.42,
    //         //       ),
    //         //       labelText: _translateTo,
    //         //       labelStyle: TextStyle(
    //         //         color: Color(0xFFC0C0C0),
    //         //         fontWeight: FontWeight.w400,
    //         //         height: 0.10,
    //         //         letterSpacing: -0.30,
    //         //       ),
    //         //       floatingLabelBehavior: FloatingLabelBehavior.always,
    //         //     ),
    //         //   ),
    //         // ),
    //         Row(
    //           children: [
    //             Text(
    //               // '긴문장긴문장 긴문장긴문장 긴문장긴문장 긴문장긴문장',
    //               _translatedText,
    //               style: TextStyle(
    //                 fontSize: 14,
    //                 // fontWeight: FontWeight.w200,
    //               fontVariations: _pretendardRegular,
    //                 height: 0.10,
    //                 letterSpacing: -0.42,
    //                 overflow: TextOverflow.clip,
    //               ),
    //               // overflow: TextOverflow.clip,
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
