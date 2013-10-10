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

    inputStrings = ["x + 2",
                    "x * 2^2.5 * log(10,100)",
                    "log(10,100)",
                    "0 - 1",
                    "(0 - 1)",
                    "nrt(5,10-1)",
                    //"(-1)"
                    ];
    
    tokenStreams = new List(inputStrings.length);
    rpnTokenStreams = new List(inputStrings.length);

    tokenStreams[0] = [new Token("x", TokenType.VAR),
                       new Token("+", TokenType.PLUS),
                       new Token("2", TokenType.VAL)];
    
    rpnTokenStreams[0] = [new Token("x", TokenType.VAR),
                          new Token("2", TokenType.VAL),
                          new Token("+", TokenType.PLUS)];

    tokenStreams[1] = [new Token("x", TokenType.VAR),
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
                      new Token(")", TokenType.RBRACE)];

    rpnTokenStreams[1] = [new Token("x", TokenType.VAR),
                          new Token("2", TokenType.VAL),
                          new Token("2.5", TokenType.VAL),
                          new Token("^", TokenType.POW),
                          new Token("*", TokenType.TIMES),
                          new Token("10", TokenType.VAL),
                          new Token("100", TokenType.VAL),
                          new Token("log", TokenType.LOG),
                          new Token("*", TokenType.TIMES)];

    tokenStreams[2] = [new Token("log", TokenType.LOG),
                    new Token("(", TokenType.LBRACE),
                    new Token("10", TokenType.VAL),
                    new Token(",", TokenType.SEPAR),
                    new Token("100", TokenType.VAL),
                    new Token(")", TokenType.RBRACE)];
    
    rpnTokenStreams[2] = [new Token("10", TokenType.VAL),
                          new Token("100", TokenType.VAL),
                          new Token("log", TokenType.LOG)];
    
    tokenStreams[3] = [new Token("0", TokenType.VAL),
                       new Token("-", TokenType.MINUS),
                        new Token("1", TokenType.VAL)];
    
    rpnTokenStreams[3] = [new Token("0", TokenType.VAL),
                          new Token("1", TokenType.VAL),
                          new Token("-", TokenType.MINUS)];
    
    tokenStreams[4] = [new Token("(", TokenType.LBRACE),
                       new Token("0", TokenType.VAL),
                       new Token("-", TokenType.MINUS),
                       new Token("1", TokenType.VAL),
                       new Token(")", TokenType.RBRACE)];
    
    rpnTokenStreams[4] = [new Token("0", TokenType.VAL),
                          new Token("1", TokenType.VAL),
                          new Token("-", TokenType.MINUS)];
    
    tokenStreams[5] = [new Token("nrt", TokenType.ROOT),
                       new Token("(", TokenType.LBRACE),
                       new Token("5", TokenType.VAL),
                       new Token(",", TokenType.SEPAR),
                       new Token("10", TokenType.VAL),
                       new Token("-", TokenType.MINUS),
                       new Token("1", TokenType.VAL),
                       new Token(")", TokenType.RBRACE)];
    
    rpnTokenStreams[5] = [new Token("5", TokenType.VAL),
                          new Token("10", TokenType.VAL),
                          new Token("1", TokenType.VAL),
                          new Token("-", TokenType.MINUS),
                          new Token("nrt", TokenType.ROOT)];
    
//    tokenStreams[6] = [new Token("-", TokenType.MINUS),
//                       new Token("1", TokenType.VAL)];
//    
//    rpnTokenStreams[6] = [new Token("1", TokenType.VAL),
//                          new Token("-", TokenType.UNMINUS)];
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
//                        'log(,1)': throws,
//                        'log(1,)': throws,
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