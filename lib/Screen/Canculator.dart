import 'package:flutter/material.dart';
import 'package:flutter_uploadimage_to_firebase/Widget/button.dart';
import 'package:flutter_uploadimage_to_firebase/screen/ListImage.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Calculator extends StatefulWidget {
  const Calculator({Key? key}) : super(key: key);

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  var userInput = '';
  var answer = '0';
  // ignore: prefer_final_fields
  late TextEditingController _calculatorController = TextEditingController();
  final List<String> buttons = [
    'C',
    '%',
    'DEL',
    '/',
    '7',
    '8',
    '9',
    'x',
    '4',
    '5',
    '6',
    '-',
    '1',
    '2',
    '3',
    '+',
    '0',
    '.',
    '=',
  ];
  // @override
  // void initState() {
  //   super.initState();
  //   _calculatorController = TextEditingController();
  // }

  // @override
  // void dispose() {
  //   _calculatorController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xff1F1D2B),
        appBar: AppBar(
          title: const Text('Calculator'),
        ),
        body: Column(children: [
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(right: 20, top: 20, left: 20),
                    alignment: Alignment.centerRight,
                    child: Text(
                      userInput,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 15, left: 20),
                    alignment: Alignment.centerRight,
                    child: Text(
                      // answer.length > 10
                      //     ? answer.substring(0, 10) + '...'
                      //     : answer,
                      answer,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 50,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                itemCount: buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemBuilder: (BuildContext context, int index) {
                  // Clear Button
                  if (index == 0) {
                    return MyButton(
                      buttontapped: () {
                        setState(() {
                          userInput = '';
                          answer = '0';
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.blue[50],
                      textColor: Colors.black,
                    );
                  }

                  // % button
                  else if (index == 1) {
                    return MyButton(
                      buttontapped: () {
                        setState(() {
                          userInput += buttons[index];
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.blue[50],
                      textColor: Colors.black,
                    );
                  }

                  // Delete Button
                  else if (index == 2) {
                    return MyButton(
                      buttontapped: () {
                        setState(() {
                          print('userInput' + userInput);
                          if (userInput != null || userInput != "")
                            userInput =
                                userInput.substring(0, userInput.length - 1);
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.blue[50],
                      textColor: Colors.black,
                    );
                  }

                  // Equal_to Button
                  else if (index == 18) {
                    return MyButton(
                      buttontapped: () {
                        setState(() {
                          equalPressed();
                        });
                      },
                      buttonText: buttons[index],
                      color: Colors.orange[700],
                      textColor: Colors.white,
                    );
                  }

                  // other buttons
                  else {
                    return MyButton(
                      buttontapped: () {
                        setState(() {
                          userInput += buttons[index];
                        });
                      },
                      buttonText: buttons[index],
                      color: isOperator(buttons[index])
                          ? Colors.blueAccent
                          : Colors.white,
                      textColor: isOperator(buttons[index])
                          ? Colors.white
                          : Colors.black,
                    );
                  }
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  //dung library tinh toan
  Future<void> equalPressed() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final password = preferences.getInt('calculatorPass');
    //userInput = int.parse(userInput);
    //password = String
    print('calculatorPass' + password.toString());
    print(password.runtimeType);
    print('userInput' + userInput.toString());
    print(userInput.runtimeType);
    if (password.toString() == userInput) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ListImage()));
    } else {
      String finaluserinput = userInput;
      finaluserinput = userInput.replaceAll('x', '*');

      Parser p = Parser();
      Expression exp = p.parse(finaluserinput);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      answer = eval.toString();
    }
  }

  //check toan tu
  bool isOperator(String o) {
    if (o == '/' || o == 'x' || o == '-' || o == '+' || o == '=') {
      return true;
    }

    return false;
  }
}
