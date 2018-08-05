part of math_expressions_test;

/**
 * Contains a test set for testing the parser and lexer
 */
class ParserTests extends TestSet {
  get name => 'Parser Tests';

  get testFunctions => {
        'Lexer Tokenize (Infix + Postfix)': lexerTokenTest,
        'Lexer Tokenize Invalid': lexerTokenTestInvalid,
        'Parser Expression Creation': parserExpressionTest,
        'Parser Expression Creation Invalid': parserExpressionTestInvalid
      };

  void initTests() {
    pars = new Parser();
    lex = new Lexer();

    inputStrings = new List();
    tokenStreams = new List();
    rpnTokenStreams = new List();

    /*
     *  Operations
     */
    // Plus
    inputStrings.add("x + 2");
    tokenStreams.add([
      new Token("x", TokenType.VAR),
      new Token("+", TokenType.PLUS),
      new Token("2", TokenType.VAL)
    ]);
    rpnTokenStreams.add([
      new Token("x", TokenType.VAR),
      new Token("2", TokenType.VAL),
      new Token("+", TokenType.PLUS)
    ]);

    // Minus
    inputStrings.add("x - 2");
    tokenStreams.add([
      new Token("x", TokenType.VAR),
      new Token("-", TokenType.MINUS),
      new Token("2", TokenType.VAL)
    ]);
    rpnTokenStreams.add([
      new Token("x", TokenType.VAR),
      new Token("2", TokenType.VAL),
      new Token("-", TokenType.MINUS)
    ]);

    inputStrings.add("0 - 1");
    tokenStreams.add([
      new Token("0", TokenType.VAL),
      new Token("-", TokenType.MINUS),
      new Token("1", TokenType.VAL)
    ]);
    rpnTokenStreams.add([
      new Token("0", TokenType.VAL),
      new Token("1", TokenType.VAL),
      new Token("-", TokenType.MINUS)
    ]);

    inputStrings.add("(0 - 1)");
    tokenStreams.add([
      new Token("(", TokenType.LBRACE),
      new Token("0", TokenType.VAL),
      new Token("-", TokenType.MINUS),
      new Token("1", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams.add([
      new Token("0", TokenType.VAL),
      new Token("1", TokenType.VAL),
      new Token("-", TokenType.MINUS)
    ]);

    // Multiplication
    inputStrings.add("0 * 1");
    tokenStreams.add([
      new Token("0", TokenType.VAL),
      new Token("*", TokenType.TIMES),
      new Token("1", TokenType.VAL)
    ]);
    rpnTokenStreams.add([
      new Token("0", TokenType.VAL),
      new Token("1", TokenType.VAL),
      new Token("*", TokenType.TIMES)
    ]);

    // Division
    inputStrings.add("0 / 1");
    tokenStreams.add([
      new Token("0", TokenType.VAL),
      new Token("/", TokenType.DIV),
      new Token("1", TokenType.VAL)
    ]);
    rpnTokenStreams.add([
      new Token("0", TokenType.VAL),
      new Token("1", TokenType.VAL),
      new Token("/", TokenType.DIV)
    ]);

    // Unary Minus
    // underscoe syntax
    inputStrings.add("_1");
    tokenStreams.add(
        [new Token("_", TokenType.UNMINUS), new Token("1", TokenType.VAL)]);
    rpnTokenStreams.add(
        [new Token("1", TokenType.VAL), new Token("_", TokenType.UNMINUS)]);

    inputStrings.add("(_1)");
    tokenStreams.add([
      new Token("(", TokenType.LBRACE),
      new Token("_", TokenType.UNMINUS),
      new Token("1", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams.add(
        [new Token("1", TokenType.VAL), new Token("_", TokenType.UNMINUS)]);

    inputStrings.add("_(1)");
    tokenStreams.add([
      new Token("_", TokenType.UNMINUS),
      new Token("(", TokenType.LBRACE),
      new Token("1", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams.add(
        [new Token("1", TokenType.VAL), new Token("_", TokenType.UNMINUS)]);

    // standard syntax
    inputStrings.add("-1");
    tokenStreams
        .add([new Token("-", TokenType.MINUS), new Token("1", TokenType.VAL)]);
    rpnTokenStreams.add(
        [new Token("1", TokenType.VAL), new Token("-", TokenType.UNMINUS)]);

    inputStrings.add("(-1)");
    tokenStreams.add([
      new Token("(", TokenType.LBRACE),
      new Token("-", TokenType.MINUS),
      new Token("1", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams.add(
        [new Token("1", TokenType.VAL), new Token("-", TokenType.UNMINUS)]);

    inputStrings.add("-(1)");
    tokenStreams.add([
      new Token("-", TokenType.MINUS),
      new Token("(", TokenType.LBRACE),
      new Token("1", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams.add(
        [new Token("1", TokenType.VAL), new Token("-", TokenType.UNMINUS)]);

    // Power
    inputStrings.add("1^1^1");
    tokenStreams.add([
      new Token("1", TokenType.VAL),
      new Token("^", TokenType.POW),
      new Token("1", TokenType.VAL),
      new Token("^", TokenType.POW),
      new Token("1", TokenType.VAL)
    ]);
    rpnTokenStreams.add([
      new Token("1", TokenType.VAL),
      new Token("1", TokenType.VAL),
      new Token("1", TokenType.VAL),
      new Token("^", TokenType.POW),
      new Token("^", TokenType.POW)
    ]);

    /*
     *  Functions
     */
    // Log
    inputStrings.add("log(10,100)");
    tokenStreams.add([
      new Token("log", TokenType.LOG),
      new Token("(", TokenType.LBRACE),
      new Token("10", TokenType.VAL),
      new Token(",", TokenType.SEPAR),
      new Token("100", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams.add([
      new Token("10", TokenType.VAL),
      new Token("100", TokenType.VAL),
      new Token("log", TokenType.LOG)
    ]);

    // Ln
    inputStrings.add("ln(10)");
    tokenStreams.add([
      new Token("ln", TokenType.LN),
      new Token("(", TokenType.LBRACE),
      new Token("10", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([new Token("10", TokenType.VAL), new Token("ln", TokenType.LN)]);

    // Sqrt
    inputStrings.add("sqrt(10)");
    tokenStreams.add([
      new Token("sqrt", TokenType.SQRT),
      new Token("(", TokenType.LBRACE),
      new Token("10", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams.add(
        [new Token("10", TokenType.VAL), new Token("sqrt", TokenType.SQRT)]);

    // Cos
    inputStrings.add("cos(10)");
    tokenStreams.add([
      new Token("cos", TokenType.COS),
      new Token("(", TokenType.LBRACE),
      new Token("10", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([new Token("10", TokenType.VAL), new Token("cos", TokenType.COS)]);

    // Sin
    inputStrings.add("sin(10)");
    tokenStreams.add([
      new Token("sin", TokenType.SIN),
      new Token("(", TokenType.LBRACE),
      new Token("10", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([new Token("10", TokenType.VAL), new Token("sin", TokenType.SIN)]);

    // Tan
    inputStrings.add("tan(10)");
    tokenStreams.add([
      new Token("tan", TokenType.TAN),
      new Token("(", TokenType.LBRACE),
      new Token("10", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([new Token("10", TokenType.VAL), new Token("tan", TokenType.TAN)]);

    // Abs
    inputStrings.add("abs(10)");
    tokenStreams.add([
      new Token("abs", TokenType.ABS),
      new Token("(", TokenType.LBRACE),
      new Token("10", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([new Token("10", TokenType.VAL), new Token("abs", TokenType.ABS)]);
    // Sgn
    inputStrings.add("sgn(10)");
    tokenStreams.add([
      new Token("sgn", TokenType.SGN),
      new Token("(", TokenType.LBRACE),
      new Token("10", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams
        .add([new Token("10", TokenType.VAL), new Token("sgn", TokenType.SGN)]);

    // n-th root
    inputStrings.add("nrt(2,10)");
    tokenStreams.add([
      new Token("nrt", TokenType.ROOT),
      new Token("(", TokenType.LBRACE),
      new Token("2", TokenType.VAL),
      new Token(",", TokenType.SEPAR),
      new Token("10", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams.add([
      new Token("2", TokenType.VAL),
      new Token("10", TokenType.VAL),
      new Token("nrt", TokenType.ROOT)
    ]);

    inputStrings.add("nrt(5,10-1)");
    tokenStreams.add([
      new Token("nrt", TokenType.ROOT),
      new Token("(", TokenType.LBRACE),
      new Token("5", TokenType.VAL),
      new Token(",", TokenType.SEPAR),
      new Token("10", TokenType.VAL),
      new Token("-", TokenType.MINUS),
      new Token("1", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams.add([
      new Token("5", TokenType.VAL),
      new Token("10", TokenType.VAL),
      new Token("1", TokenType.VAL),
      new Token("-", TokenType.MINUS),
      new Token("nrt", TokenType.ROOT)
    ]);

    // Exp
    // function syntax
    inputStrings.add("e(x)");
    tokenStreams.add([
      new Token("e", TokenType.EFUNC),
      new Token("(", TokenType.LBRACE),
      new Token("x", TokenType.VAR),
      new Token(")", TokenType.RBRACE),
    ]);
    rpnTokenStreams
        .add([new Token("x", TokenType.VAR), new Token("e", TokenType.EFUNC)]);

    // power syntax
    inputStrings.add("e^x");
    tokenStreams
        .add([new Token("e", TokenType.EFUNC), new Token("x", TokenType.VAR)]);
    rpnTokenStreams
        .add([new Token("x", TokenType.VAR), new Token("e", TokenType.EFUNC)]);

    inputStrings.add("e^(x+2)");
    tokenStreams.add([
      new Token("e", TokenType.EFUNC),
      new Token("(", TokenType.LBRACE),
      new Token("x", TokenType.VAR),
      new Token("+", TokenType.PLUS),
      new Token("2", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams.add([
      new Token("x", TokenType.VAR),
      new Token("2", TokenType.VAL),
      new Token("+", TokenType.PLUS),
      new Token("e", TokenType.EFUNC)
    ]);

    // Complex expressions
    inputStrings.add("x * 2^2.5 * log(10,100)");
    tokenStreams.add([
      new Token("x", TokenType.VAR),
      new Token("*", TokenType.TIMES),
      new Token("2", TokenType.VAL),
      new Token("^", TokenType.POW),
      new Token("2.5", TokenType.VAL),
      new Token("*", TokenType.TIMES),
      new Token("log", TokenType.LOG),
      new Token("(", TokenType.LBRACE),
      new Token("10", TokenType.VAL),
      new Token(",", TokenType.SEPAR),
      new Token("100", TokenType.VAL),
      new Token(")", TokenType.RBRACE)
    ]);
    rpnTokenStreams.add([
      new Token("x", TokenType.VAR),
      new Token("2", TokenType.VAL),
      new Token("2.5", TokenType.VAL),
      new Token("^", TokenType.POW),
      new Token("*", TokenType.TIMES),
      new Token("10", TokenType.VAL),
      new Token("100", TokenType.VAL),
      new Token("log", TokenType.LOG),
      new Token("*", TokenType.TIMES)
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
    Map invalidCases = {
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
    Map invalidCases = {
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
