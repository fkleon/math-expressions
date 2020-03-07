part of math_expressions_test;

/**
 * Contains a test set for testing the parser and lexer
 */
class ParserTests extends TestSet {
  @override
  String get name => 'Parser Tests';

  @override
  get testFunctions => {
        'Lexer Tokenize (Infix + Postfix)': lexerTokenTest,
        'Lexer Tokenize Invalid': lexerTokenTestInvalid,
        'Parser Expression Creation': parserExpressionTest,
        'Parser Expression Creation Invalid': parserExpressionTestInvalid
      };

  @override
  void initTests() {
    pars = Parser();
    lex = Lexer();

    inputStrings = [];
    tokenStreams = [];
    rpnTokenStreams = [];

    /*
     *  Operations
     */
    // Plus
    inputStrings.add('x + 2');
    tokenStreams.add([
      Token('x', TokenType.VAR),
      Token('+', TokenType.PLUS),
      Token('2', TokenType.VAL)
    ]);
    rpnTokenStreams.add([
      Token('x', TokenType.VAR),
      Token('2', TokenType.VAL),
      Token('+', TokenType.PLUS)
    ]);

    // Minus
    inputStrings.add('x - 2');
    tokenStreams.add([
      Token('x', TokenType.VAR),
      Token('-', TokenType.MINUS),
      Token('2', TokenType.VAL)
    ]);
    rpnTokenStreams.add([
      Token('x', TokenType.VAR),
      Token('2', TokenType.VAL),
      Token('-', TokenType.MINUS)
    ]);

    inputStrings.add('0 - 1');
    tokenStreams.add([
      Token('0', TokenType.VAL),
      Token('-', TokenType.MINUS),
      Token('1', TokenType.VAL)
    ]);
    rpnTokenStreams.add([
      Token('0', TokenType.VAL),
      Token('1', TokenType.VAL),
      Token('-', TokenType.MINUS)
    ]);

    inputStrings.add('(0 - 1)');
    tokenStreams.add([
      Token('(', TokenType.LBRACE),
      Token('0', TokenType.VAL),
      Token('-', TokenType.MINUS),
      Token('1', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams.add([
      Token('0', TokenType.VAL),
      Token('1', TokenType.VAL),
      Token('-', TokenType.MINUS)
    ]);

    // Multiplication
    inputStrings.add('0 * 1');
    tokenStreams.add([
      Token('0', TokenType.VAL),
      Token('*', TokenType.TIMES),
      Token('1', TokenType.VAL)
    ]);
    rpnTokenStreams.add([
      Token('0', TokenType.VAL),
      Token('1', TokenType.VAL),
      Token('*', TokenType.TIMES)
    ]);

    // Division
    inputStrings.add('0 / 1');
    tokenStreams.add([
      Token('0', TokenType.VAL),
      Token('/', TokenType.DIV),
      Token('1', TokenType.VAL)
    ]);
    rpnTokenStreams.add([
      Token('0', TokenType.VAL),
      Token('1', TokenType.VAL),
      Token('/', TokenType.DIV)
    ]);

    // Unary Minus
    // underscoe syntax
    inputStrings.add('_1');
    tokenStreams
        .add([Token('_', TokenType.UNMINUS), Token('1', TokenType.VAL)]);
    rpnTokenStreams
        .add([Token('1', TokenType.VAL), Token('_', TokenType.UNMINUS)]);

    inputStrings.add('(_1)');
    tokenStreams.add([
      Token('(', TokenType.LBRACE),
      Token('_', TokenType.UNMINUS),
      Token('1', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('1', TokenType.VAL), Token('_', TokenType.UNMINUS)]);

    inputStrings.add('_(1)');
    tokenStreams.add([
      Token('_', TokenType.UNMINUS),
      Token('(', TokenType.LBRACE),
      Token('1', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('1', TokenType.VAL), Token('_', TokenType.UNMINUS)]);

    // standard syntax
    inputStrings.add('-1');
    tokenStreams.add([Token('-', TokenType.MINUS), Token('1', TokenType.VAL)]);
    rpnTokenStreams
        .add([Token('1', TokenType.VAL), Token('-', TokenType.UNMINUS)]);

    inputStrings.add('(-1)');
    tokenStreams.add([
      Token('(', TokenType.LBRACE),
      Token('-', TokenType.MINUS),
      Token('1', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('1', TokenType.VAL), Token('-', TokenType.UNMINUS)]);

    inputStrings.add('-(1)');
    tokenStreams.add([
      Token('-', TokenType.MINUS),
      Token('(', TokenType.LBRACE),
      Token('1', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('1', TokenType.VAL), Token('-', TokenType.UNMINUS)]);

    // Power
    inputStrings.add('1^1^1');
    tokenStreams.add([
      Token('1', TokenType.VAL),
      Token('^', TokenType.POW),
      Token('1', TokenType.VAL),
      Token('^', TokenType.POW),
      Token('1', TokenType.VAL)
    ]);
    rpnTokenStreams.add([
      Token('1', TokenType.VAL),
      Token('1', TokenType.VAL),
      Token('1', TokenType.VAL),
      Token('^', TokenType.POW),
      Token('^', TokenType.POW)
    ]);

    /*
     *  Functions
     */
    // Log
    inputStrings.add('log(10,100)');
    tokenStreams.add([
      Token('log', TokenType.LOG),
      Token('(', TokenType.LBRACE),
      Token('10', TokenType.VAL),
      Token(',', TokenType.SEPAR),
      Token('100', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams.add([
      Token('10', TokenType.VAL),
      Token('100', TokenType.VAL),
      Token('log', TokenType.LOG)
    ]);

    // Ln
    inputStrings.add('ln(10)');
    tokenStreams.add([
      Token('ln', TokenType.LN),
      Token('(', TokenType.LBRACE),
      Token('10', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('10', TokenType.VAL), Token('ln', TokenType.LN)]);

    // Sqrt
    inputStrings.add('sqrt(10)');
    tokenStreams.add([
      Token('sqrt', TokenType.SQRT),
      Token('(', TokenType.LBRACE),
      Token('10', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('10', TokenType.VAL), Token('sqrt', TokenType.SQRT)]);

    // Cos
    inputStrings.add('cos(10)');
    tokenStreams.add([
      Token('cos', TokenType.COS),
      Token('(', TokenType.LBRACE),
      Token('10', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('10', TokenType.VAL), Token('cos', TokenType.COS)]);

    // Sin
    inputStrings.add('sin(10)');
    tokenStreams.add([
      Token('sin', TokenType.SIN),
      Token('(', TokenType.LBRACE),
      Token('10', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('10', TokenType.VAL), Token('sin', TokenType.SIN)]);

    // Tan
    inputStrings.add('tan(10)');
    tokenStreams.add([
      Token('tan', TokenType.TAN),
      Token('(', TokenType.LBRACE),
      Token('10', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('10', TokenType.VAL), Token('tan', TokenType.TAN)]);

    // Arccos
    inputStrings.add('arccos(10)');
    tokenStreams.add([
      Token('arccos', TokenType.ACOS),
      Token('(', TokenType.LBRACE),
      Token('10', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('10', TokenType.VAL), Token('arccos', TokenType.ACOS)]);

    // Arcsin
    inputStrings.add('arcsin(10)');
    tokenStreams.add([
      Token('arcsin', TokenType.ASIN),
      Token('(', TokenType.LBRACE),
      Token('10', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('10', TokenType.VAL), Token('arcsin', TokenType.ASIN)]);

    // Arctan
    inputStrings.add('arctan(10)');
    tokenStreams.add([
      Token('arctan', TokenType.ATAN),
      Token('(', TokenType.LBRACE),
      Token('10', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('10', TokenType.VAL), Token('arctan', TokenType.ATAN)]);

    // Abs
    inputStrings.add('abs(10)');
    tokenStreams.add([
      Token('abs', TokenType.ABS),
      Token('(', TokenType.LBRACE),
      Token('10', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('10', TokenType.VAL), Token('abs', TokenType.ABS)]);
    // Sgn
    inputStrings.add('sgn(10)');
    tokenStreams.add([
      Token('sgn', TokenType.SGN),
      Token('(', TokenType.LBRACE),
      Token('10', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([Token('10', TokenType.VAL), Token('sgn', TokenType.SGN)]);

    // n-th root
    inputStrings.add('nrt(2,10)');
    tokenStreams.add([
      Token('nrt', TokenType.ROOT),
      Token('(', TokenType.LBRACE),
      Token('2', TokenType.VAL),
      Token(',', TokenType.SEPAR),
      Token('10', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams.add([
      Token('2', TokenType.VAL),
      Token('10', TokenType.VAL),
      Token('nrt', TokenType.ROOT)
    ]);

    inputStrings.add('nrt(5,10-1)');
    tokenStreams.add([
      Token('nrt', TokenType.ROOT),
      Token('(', TokenType.LBRACE),
      Token('5', TokenType.VAL),
      Token(',', TokenType.SEPAR),
      Token('10', TokenType.VAL),
      Token('-', TokenType.MINUS),
      Token('1', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams.add([
      Token('5', TokenType.VAL),
      Token('10', TokenType.VAL),
      Token('1', TokenType.VAL),
      Token('-', TokenType.MINUS),
      Token('nrt', TokenType.ROOT)
    ]);

    // Exp
    // function syntax
    inputStrings.add('e(x)');
    tokenStreams.add([
      Token('e', TokenType.EFUNC),
      Token('(', TokenType.LBRACE),
      Token('x', TokenType.VAR),
      Token(')', TokenType.RBRACE),
    ]);
    rpnTokenStreams
        .add([Token('x', TokenType.VAR), Token('e', TokenType.EFUNC)]);

    // power syntax
    inputStrings.add('e^x');
    tokenStreams.add([Token('e', TokenType.EFUNC), Token('x', TokenType.VAR)]);
    rpnTokenStreams
        .add([Token('x', TokenType.VAR), Token('e', TokenType.EFUNC)]);

    inputStrings.add('e^(x+2)');
    tokenStreams.add([
      Token('e', TokenType.EFUNC),
      Token('(', TokenType.LBRACE),
      Token('x', TokenType.VAR),
      Token('+', TokenType.PLUS),
      Token('2', TokenType.VAL),
      Token(')', TokenType.RBRACE)
    ]);
    rpnTokenStreams.add([
      Token('x', TokenType.VAR),
      Token('2', TokenType.VAL),
      Token('+', TokenType.PLUS),
      Token('e', TokenType.EFUNC)
    ]);

    // Complex expressions
    inputStrings.add('x * 2^2.5 * log(10,100)');
    tokenStreams.add([
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
    ]);
    rpnTokenStreams.add([
      Token('x', TokenType.VAR),
      Token('2', TokenType.VAL),
      Token('2.5', TokenType.VAL),
      Token('^', TokenType.POW),
      Token('*', TokenType.TIMES),
      Token('10', TokenType.VAL),
      Token('100', TokenType.VAL),
      Token('log', TokenType.LOG),
      Token('*', TokenType.TIMES)
    ]);
  }

  /*
   *  Tests and variables.
   */
  Parser pars;
  Lexer lex;
  List<String> inputStrings;

  List<List<Token>> tokenStreams;
  List<List<Token>> rpnTokenStreams;

  void lexerTokenTest() {
    for (int i = 0; i < inputStrings.length; i++) {
      String input = inputStrings[i];

      // Test infix streams
      List<Token> infixStream = lex.tokenize(input);
      expect(infixStream, orderedEquals(tokenStreams[i]));

      // Test RPN streams
      List<Token> rpnStream = lex.shuntingYard(infixStream);
      expect(rpnStream, orderedEquals(rpnTokenStreams[i]));
    }
  }

  void lexerTokenTestInvalid() {
    Map<String, Matcher> invalidCases = {
      '(': throwsStateError,
      ')': throwsStateError,
      '1+1)': throwsStateError,
      '(1+1': throwsStateError,
      'log(1,': throwsStateError,
    };

    for (String expr in invalidCases.keys) {
      expect(() => lex.tokenizeToRPN(expr), invalidCases[expr]);
    }
  }

  void parserExpressionTest() {
    for (String inputString in inputStrings) {
      Expression exp = pars.parse(inputString);
      // TODO Don't just test for no exceptions,
      // also test for expression content.
    }
  }

  void parserExpressionTestInvalid() {
    Map<String, Matcher> invalidCases = {
      '': throwsArgumentError,
      '(': throwsStateError,
      ')': throwsStateError,
      '1+1)': throwsStateError,
      '(1+1': throwsStateError,
      'log(,1)': throwsRangeError,
      'log(1,)': throwsRangeError,
    };

    for (String expr in invalidCases.keys) {
      expect(() => pars.parse(expr), invalidCases[expr]);
    }
  }
}
