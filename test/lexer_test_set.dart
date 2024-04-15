part of 'math_expressions_test.dart';

/// Contains a test set for testing the lexer
class LexerTests extends TestSet {
  @override
  String get name => 'Lexer Tests';

  @override
  String get tags => 'lexer';

  @override
  Map<String, Function> get testGroups => {
        // Literals
        'Value': tokenizeValue,
        'Variable': tokenizeVariable,
        'Parenthesis': tokenizeParenthesis,

        // Operators
        'Unary Minus': tokenizeUnaryMinus,
        'Unary Plus': tokenizeUnaryPlus,
        'Power': tokenizePower,
        'Modulo': tokenizeModulo,
        'Multiplication': tokenizeMultiplication,
        'Division': tokenizeDivision,
        'Plus': tokenizePlus,
        'Minus': tokenizeMinus,

        // Functions
        'Functions': tokenizeFunctions,
        'Algorithmic functions': tokenizeAlgorithmicFunctions,

        // Expressions
        'Complex expression': tokenizeComplexExpression,

        // Negative test cases
        'Invalid': lexerTokenTestInvalid,
      };

  @override
  void initTests() {}

  Lexer lex = Lexer();

  // Test RPN
  void parameterizedRpn(Map<String, List<Token>> cases) {
    cases.forEach((expression, rpn) {
      test('$expression -> $rpn',
          () => expect(lex.tokenizeToRPN(expression), orderedEquals(rpn)));
    });
  }

  /// Test infix and RPN
  void parameterized(Map<String, (List<Token>, List<Token>)> cases) {
    cases.forEach((expression, value) {
      var (infix, rpn) = value;
      test('$expression -> $infix -> $rpn', () {
        var infixStream = lex.tokenize(expression);
        expect(infixStream, orderedEquals(infix));
        var rpnStream = lex.shuntingYard(infixStream);
        expect(rpnStream, orderedEquals(rpn));
      });
    });
  }

  void tokenizeValue() {
    var cases = {
      '0': [Token('0', TokenType.VAL)],
      '1': [Token('1', TokenType.VAL)],
      '0.0': [Token('0.0', TokenType.VAL)],
      '1.0': [Token('1.0', TokenType.VAL)],
      math.pi.toStringAsFixed(11): [Token('3.14159265359', TokenType.VAL)],
    };

    parameterizedRpn(cases);
  }

  void tokenizeVariable() {
    var cases = {
      'x': [Token('x', TokenType.VAR)],
      ' x': [Token('x', TokenType.VAR)],
      'y': [Token('y', TokenType.VAR)],
      '(y )': [Token('y', TokenType.VAR)],
      //'var2': [Token('var2', TokenType.VAR)], // Does not support numbers in variable names
      'longname': [Token('longname', TokenType.VAR)],
    };
    parameterizedRpn(cases);
  }

  void tokenizeUnaryMinus() {
    var cases = {
      '-0': (
        [Token('-', TokenType.MINUS), Token('0', TokenType.VAL)],
        [Token('0', TokenType.VAL), Token('-', TokenType.UNMINUS)]
      ),
      '-1.0': (
        [Token('-', TokenType.MINUS), Token('1.0', TokenType.VAL)],
        [Token('1.0', TokenType.VAL), Token('-', TokenType.UNMINUS)]
      ),
      '(-1)': (
        [
          Token('(', TokenType.LBRACE),
          Token('-', TokenType.MINUS),
          Token('1', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('1', TokenType.VAL), Token('-', TokenType.UNMINUS)]
      ),
      '-(1)': (
        [
          Token('-', TokenType.MINUS),
          Token('(', TokenType.LBRACE),
          Token('1', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('1', TokenType.VAL), Token('-', TokenType.UNMINUS)]
      ),
    };
    parameterized(cases);
  }

  void tokenizeUnaryPlus() {
    var cases = {
      '+1': (
        [Token('+', TokenType.PLUS), Token('1', TokenType.VAL)],
        [Token('1', TokenType.VAL), Token('+', TokenType.UNPLUS)]
      ),
      '(+1)': (
        [
          Token('(', TokenType.LBRACE),
          Token('+', TokenType.PLUS),
          Token('1', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('1', TokenType.VAL), Token('+', TokenType.UNPLUS)]
      ),
      '+(1)': (
        [
          Token('+', TokenType.PLUS),
          Token('(', TokenType.LBRACE),
          Token('1', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('1', TokenType.VAL), Token('+', TokenType.UNPLUS)]
      ),
    };
    parameterized(cases);
  }

  void tokenizePower() {
    var cases = {
      '1^1': (
        [
          Token('1', TokenType.VAL),
          Token('^', TokenType.POW),
          Token('1', TokenType.VAL)
        ],
        [
          Token('1', TokenType.VAL),
          Token('1', TokenType.VAL),
          Token('^', TokenType.POW),
        ]
      ),
      '1^1^1': (
        [
          Token('1', TokenType.VAL),
          Token('^', TokenType.POW),
          Token('1', TokenType.VAL),
          Token('^', TokenType.POW),
          Token('1', TokenType.VAL)
        ],
        [
          Token('1', TokenType.VAL),
          Token('1', TokenType.VAL),
          Token('1', TokenType.VAL),
          Token('^', TokenType.POW),
          Token('^', TokenType.POW)
        ]
      )
    };
    parameterized(cases);
  }

  void tokenizeModulo() {
    var cases = {
      '1%1': (
        [
          Token('1', TokenType.VAL),
          Token('%', TokenType.MOD),
          Token('1', TokenType.VAL),
        ],
        [
          Token('1', TokenType.VAL),
          Token('1', TokenType.VAL),
          Token('%', TokenType.MOD),
        ]
      ),
    };
    parameterized(cases);
  }

  void tokenizeMultiplication() {
    var cases = {
      '0 * 1': (
        [
          Token('0', TokenType.VAL),
          Token('*', TokenType.TIMES),
          Token('1', TokenType.VAL)
        ],
        [
          Token('0', TokenType.VAL),
          Token('1', TokenType.VAL),
          Token('*', TokenType.TIMES)
        ]
      ),
    };
    parameterized(cases);
  }

  void tokenizeDivision() {
    var cases = {
      '0 / 1': (
        [
          Token('0', TokenType.VAL),
          Token('/', TokenType.DIV),
          Token('1', TokenType.VAL)
        ],
        [
          Token('0', TokenType.VAL),
          Token('1', TokenType.VAL),
          Token('/', TokenType.DIV)
        ]
      ),
    };
    parameterized(cases);
  }

  void tokenizePlus() {
    var cases = {
      'x + 2': (
        [
          Token('x', TokenType.VAR),
          Token('+', TokenType.PLUS),
          Token('2', TokenType.VAL)
        ],
        [
          Token('x', TokenType.VAR),
          Token('2', TokenType.VAL),
          Token('+', TokenType.PLUS)
        ]
      ),
    };
    parameterized(cases);
  }

  void tokenizeMinus() {
    var cases = {
      'x - 2': (
        [
          Token('x', TokenType.VAR),
          Token('-', TokenType.MINUS),
          Token('2', TokenType.VAL)
        ],
        [
          Token('x', TokenType.VAR),
          Token('2', TokenType.VAL),
          Token('-', TokenType.MINUS)
        ]
      ),
    };
    parameterized(cases);
  }

  void tokenizeParenthesis() {
    Map<String, (List<Token>, List<Token>)> cases = {
      '()': ([Token('(', TokenType.LBRACE), Token(')', TokenType.RBRACE)], []),
    };
    parameterized(cases);
  }

  void tokenizeFunctions() {
    var cases = {
      'log(10,100)': (
        [
          Token('log', TokenType.LOG),
          Token('(', TokenType.LBRACE),
          Token('10', TokenType.VAL),
          Token(',', TokenType.SEPAR),
          Token('100', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [
          Token('10', TokenType.VAL),
          Token('100', TokenType.VAL),
          Token('log', TokenType.LOG)
        ]
      ),
      'ln(2)': (
        [
          Token('ln', TokenType.LN),
          Token('(', TokenType.LBRACE),
          Token('2', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('2', TokenType.VAL), Token('ln', TokenType.LN)]
      ),
      'sqrt(10)': (
        [
          Token('sqrt', TokenType.SQRT),
          Token('(', TokenType.LBRACE),
          Token('10', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('10', TokenType.VAL), Token('sqrt', TokenType.SQRT)]
      ),
      // n-th root
      'nrt(2,10)': (
        [
          Token('nrt', TokenType.ROOT),
          Token('(', TokenType.LBRACE),
          Token('2', TokenType.VAL),
          Token(',', TokenType.SEPAR),
          Token('10', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [
          Token('2', TokenType.VAL),
          Token('10', TokenType.VAL),
          Token('nrt', TokenType.ROOT)
        ]
      ),
      'nrt(5,10-1)': (
        [
          Token('nrt', TokenType.ROOT),
          Token('(', TokenType.LBRACE),
          Token('5', TokenType.VAL),
          Token(',', TokenType.SEPAR),
          Token('10', TokenType.VAL),
          Token('-', TokenType.MINUS),
          Token('1', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [
          Token('5', TokenType.VAL),
          Token('10', TokenType.VAL),
          Token('1', TokenType.VAL),
          Token('-', TokenType.MINUS),
          Token('nrt', TokenType.ROOT)
        ]
      ),
      'cos(10)': (
        [
          Token('cos', TokenType.COS),
          Token('(', TokenType.LBRACE),
          Token('10', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('10', TokenType.VAL), Token('cos', TokenType.COS)]
      ),
      'sin(10)': (
        [
          Token('sin', TokenType.SIN),
          Token('(', TokenType.LBRACE),
          Token('10', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('10', TokenType.VAL), Token('sin', TokenType.SIN)]
      ),
      'tan(10)': (
        [
          Token('tan', TokenType.TAN),
          Token('(', TokenType.LBRACE),
          Token('10', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('10', TokenType.VAL), Token('tan', TokenType.TAN)]
      ),
      'arccos(1)': (
        [
          Token('arccos', TokenType.ACOS),
          Token('(', TokenType.LBRACE),
          Token('1', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('1', TokenType.VAL), Token('arccos', TokenType.ACOS)]
      ),
      'arcsin(1)': (
        [
          Token('arcsin', TokenType.ASIN),
          Token('(', TokenType.LBRACE),
          Token('1', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('1', TokenType.VAL), Token('arcsin', TokenType.ASIN)]
      ),
      'arctan(10)': (
        [
          Token('arctan', TokenType.ATAN),
          Token('(', TokenType.LBRACE),
          Token('10', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('10', TokenType.VAL), Token('arctan', TokenType.ATAN)]
      ),
      'abs(10)': (
        [
          Token('abs', TokenType.ABS),
          Token('(', TokenType.LBRACE),
          Token('10', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('10', TokenType.VAL), Token('abs', TokenType.ABS)]
      ),
      'sgn(10)': (
        [
          Token('sgn', TokenType.SGN),
          Token('(', TokenType.LBRACE),
          Token('10', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('10', TokenType.VAL), Token('sgn', TokenType.SGN)]
      ),
      // Exponential - function syntax
      'e(x)': (
        [
          Token('e', TokenType.EFUNC),
          Token('(', TokenType.LBRACE),
          Token('x', TokenType.VAR),
          Token(')', TokenType.RBRACE),
        ],
        [Token('x', TokenType.VAR), Token('e', TokenType.EFUNC)]
      ),
      // Exponential - power syntax
      'e^x': (
        [Token('e', TokenType.EFUNC), Token('x', TokenType.VAR)],
        [Token('x', TokenType.VAR), Token('e', TokenType.EFUNC)]
      ),
      'e^(x+2)': (
        [
          Token('e', TokenType.EFUNC),
          Token('(', TokenType.LBRACE),
          Token('x', TokenType.VAR),
          Token('+', TokenType.PLUS),
          Token('2', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [
          Token('x', TokenType.VAR),
          Token('2', TokenType.VAL),
          Token('+', TokenType.PLUS),
          Token('e', TokenType.EFUNC)
        ]
      ),
      'ceil(9.5)': (
        [
          Token('ceil', TokenType.CEIL),
          Token('(', TokenType.LBRACE),
          Token('9.5', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('9.5', TokenType.VAL), Token('ceil', TokenType.CEIL)]
      ),
      'floor(9.5)': (
        [
          Token('floor', TokenType.FLOOR),
          Token('(', TokenType.LBRACE),
          Token('9.5', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [Token('9.5', TokenType.VAL), Token('floor', TokenType.FLOOR)]
      ),
      '10!': (
        [Token('10', TokenType.VAL), Token('!', TokenType.FACTORIAL)],
        [Token('10', TokenType.VAL), Token('!', TokenType.FACTORIAL)]
      ),
    };
    parameterized(cases);
  }

  void tokenizeAlgorithmicFunctions() {
    var cases = {
      'myAlgorithmicFunction(1.0)': (
        [
          Token('myAlgorithmicFunction', TokenType.FUNC),
          Token('(', TokenType.LBRACE),
          Token('1.0', TokenType.VAL),
          Token(')', TokenType.RBRACE),
        ],
        [
          Token('1.0', TokenType.VAL),
          Token('myAlgorithmicFunction', TokenType.FUNC),
        ]
      ),
      'my_min(1,x,-2)': (
        [
          Token('my_min', TokenType.FUNC),
          Token('(', TokenType.LBRACE),
          Token('1', TokenType.VAL),
          Token(',', TokenType.SEPAR),
          Token('x', TokenType.VAR),
          Token(',', TokenType.SEPAR),
          Token('-', TokenType.MINUS),
          Token('2', TokenType.VAL),
          Token(')', TokenType.RBRACE),
        ],
        [
          Token('1', TokenType.VAL),
          Token('x', TokenType.VAR),
          Token('2', TokenType.VAL),
          Token('-', TokenType.UNMINUS),
          Token('my_min', TokenType.FUNC),
        ]
      ),
    };

    lex.keywords['myAlgorithmicFunction'] = TokenType.FUNC;
    lex.keywords['my_min'] = TokenType.FUNC;

    parameterized(cases);
  }

  void tokenizeComplexExpression() {
    var cases = {
      'x * 2^2.5 * log(10,100)': (
        [
          Token('x', TokenType.VAR),
          Token('*', TokenType.TIMES),
          Token('2', TokenType.VAL),
          Token('^', TokenType.POW),
          Token('2.5', TokenType.VAL),
          Token('*', TokenType.TIMES),
          Token('log', TokenType.LOG),
          Token('(', TokenType.LBRACE),
          Token('10', TokenType.VAL),
          Token(',', TokenType.SEPAR),
          Token('100', TokenType.VAL),
          Token(')', TokenType.RBRACE)
        ],
        [
          Token('x', TokenType.VAR),
          Token('2', TokenType.VAL),
          Token('2.5', TokenType.VAL),
          Token('^', TokenType.POW),
          Token('*', TokenType.TIMES),
          Token('10', TokenType.VAL),
          Token('100', TokenType.VAL),
          Token('log', TokenType.LOG),
          Token('*', TokenType.TIMES)
        ]
      ),
    };
    parameterized(cases);
  }

  void lexerTokenTestInvalid() {
    Map<String, Matcher> invalidCases = {
      '(': throwsFormatException,
      ')': throwsFormatException,
      '1+1)': throwsFormatException,
      '(1+1': throwsFormatException,
      'log(1,': throwsFormatException,
    };

    for (String expr in invalidCases.keys) {
      test(expr,
          () => expect(() => lex.tokenizeToRPN(expr), invalidCases[expr]));
    }
  }
}
