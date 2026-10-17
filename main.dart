import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculatrice Flutter',
      theme: ThemeData.dark(),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String expression = '0';
  String result = '0';
  String? history;

  bool hasError = false;
  bool resultDisplayed = false;

  static const Color backgroundColor = Colors.black;
  static const Color numberColor = Color(0xFF333333);
  static const Color operatorColor = Color(0xFF505050);
  static const Color equalColor = Color(0xFFFF9500);

  void clear() {
    setState(() {
      expression = '0';
      result = '0';
      history = null;
      hasError = false;
      resultDisplayed = false;
    });
  }

  void addNumber(String value) {
    setState(() {
      if (hasError) {
        expression = '0';
        result = '0';
        history = null;
        hasError = false;
      }
      if (resultDisplayed) {
        if (value == '.') {
          expression = '0.';
        } else {
          expression = value;
        }

        resultDisplayed = false;
        history = null;
        result = expression;
        return;
      }
      if (expression == '0' && value != '.') {
        expression = value;
      } else if (expression == '0' && value == '.') {
        expression = '0.';
      } else {
        if (value == '.') {
          final currentNumber = expression.split(RegExp(r'[+\-×÷%]')).last;

          if (currentNumber.contains('.')) {
            return;
          }
        }

        expression += value;
      }

      updatePreview();
    });
  }

  void addOperator(String operator) {
    setState(() {
      if (hasError) {
        clear();
      }
      if (resultDisplayed) {
        expression = result;
        resultDisplayed = false;
        history = null;
      }
      if (expression == '0' && operator != '-') {
        return;
      }

      if (expression == '0' && operator == '-') {
        expression = '-';
        return;
      }
      final lastChar = expression[expression.length - 1];

      if ('+×÷%'.contains(lastChar) ||
          (lastChar == '-' && expression.length > 1)) {
        expression = expression.substring(0, expression.length - 1);
      }

      expression += operator;
      updatePreview();
    });
  }

  void updatePreview() {
    try {
      final value = ExpressionParser(expression).parse();

      if (value.isFinite) {
        result = formatNumber(value);
      }
    } catch (_) {}
  }

  void calculate() {
    try {
      final value = ExpressionParser(expression).parse();

      setState(() {
        history = '$expression =';
        result = formatNumber(value);
        expression = result;
        resultDisplayed = true;
        hasError = false;
      });
    } catch (_) {
      setState(() {
        history = 'Expression invalide';
        result = 'Erreur';
        expression = 'Erreur';
        hasError = true;
        resultDisplayed = false;
      });
    }
  }

  String formatNumber(double value) {
    if (!value.isFinite) {
      return 'Erreur';
    }

    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  Widget buildButton(
    String label, {
    Color color = numberColor,
    Color textColor = Colors.white,
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox.expand(
          child: ElevatedButton(
            onPressed: () {
              switch (label) {
                case 'C':
                  clear();
                  break;

                case '=':
                  calculate();
                  break;

                case '+':
                case '-':
                case '×':
                case '÷':
                case '%':
                  addOperator(label);
                  break;

                default:
                  addNumber(label);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: textColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(List<Widget> buttons) {
    return Expanded(child: Row(children: buttons));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              // Zone d'affichage.
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Historique du calcul.
                      if (history != null)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            history!,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white54,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Résultat affiché en grand.
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          hasError ? 'Erreur' : result,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Expression saisie en plus petit.
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          resultDisplayed ? '' : expression,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    buildRow([
                      buildButton('C', color: operatorColor),
                      buildButton('%', color: operatorColor),
                      buildButton('÷', color: operatorColor),
                      buildButton('×', color: operatorColor),
                    ]),

                    buildRow([
                      buildButton('7'),
                      buildButton('8'),
                      buildButton('9'),
                      buildButton('-', color: operatorColor),
                    ]),

                    buildRow([
                      buildButton('4'),
                      buildButton('5'),
                      buildButton('6'),
                      buildButton('+', color: operatorColor),
                    ]),

                    buildRow([
                      buildButton('1'),
                      buildButton('2'),
                      buildButton('3'),
                      buildButton('=', color: equalColor),
                    ]),

                    buildRow([
                      buildButton('0', flex: 2),
                      buildButton('.'),
                      buildButton('C', color: operatorColor),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpressionParser {
  final String input;
  int position = 0;

  ExpressionParser(this.input);

  double parse() {
    if (input.isEmpty) {
      throw const FormatException('Expression vide');
    }

    final value = parseExpression();

    if (position != input.length) {
      throw const FormatException('Expression invalide');
    }

    if (!value.isFinite) {
      throw const FormatException('Résultat non valide');
    }

    return value;
  }

  double parseExpression() {
    double value = parseTerm();

    while (position < input.length) {
      final operator = input[position];

      if (operator != '+' && operator != '-') {
        break;
      }

      position++;
      final next = parseTerm();

      if (operator == '+') {
        value += next;
      } else {
        value -= next;
      }
    }

    return value;
  }

  double parseTerm() {
    double value = parseFactor();

    while (position < input.length) {
      final operator = input[position];

      if (!'×÷%'.contains(operator)) {
        break;
      }

      position++;
      final next = parseFactor();

      switch (operator) {
        case '×':
          value *= next;
          break;

        case '÷':
          if (next == 0) {
            throw const FormatException('Division par zéro');
          }

          value /= next;
          break;

        case '%':
          if (next == 0) {
            throw const FormatException('Modulo par zéro');
          }

          value %= next;
          break;
      }
    }

    return value;
  }

  double parseFactor() {
    if (position < input.length && input[position] == '-') {
      position++;
      return -parseFactor();
    }

    if (position < input.length && input[position] == '+') {
      position++;
      return parseFactor();
    }

    return parseNumber();
  }

  double parseNumber() {
    final start = position;
    bool hasDecimalPoint = false;

    while (position < input.length) {
      final char = input[position];

      if (char == '.') {
        if (hasDecimalPoint) {
          throw const FormatException('Nombre décimal invalide');
        }

        hasDecimalPoint = true;
        position++;
      } else if ('0123456789'.contains(char)) {
        position++;
      } else {
        break;
      }
    }

    if (start == position) {
      throw const FormatException('Nombre attendu');
    }

    return double.parse(input.substring(start, position));
  }
}
