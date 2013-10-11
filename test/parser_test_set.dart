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
    
    inputStrings.add("x + 2");
    tokenStreams.add([new Token("x", TokenType.VAR),
                      new Token("+", TokenType.PLUS),
                      new Token("2", TokenType.VAL)]);
    rpnTokenStreams.add([new Token("x", TokenType.VAR),
                         new Token("2", TokenType.VAL),
                         new Token("+", TokenType.PLUS)]);
    
    inputStrings.add("log(10,100)");
    tokenStreams.add([new Token("log", TokenType.LOG),
                    new Token("(", TokenType.LBRACE),
                    new Token("10", TokenType.VAL),
                    new Token(",", TokenType.SEPAR),
                    new Token("100", TokenType.VAL),
                    new Token(")", TokenType.RBRACE)]);
    rpnTokenStreams.add([new Token("10", TokenType.VAL),
                          new Token("100", TokenType.VAL),
                          new Token("log", TokenType.LOG)]);
    
    inputStrings.add("x * 2^2.5 * log(10,100)");
    tokenStreams.add([new Token("x", TokenType.VAR),
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
                      new Token(")", TokenType.RBRACE)]);
    rpnTokenStreams.add([new Token("x", TokenType.VAR),
                         new Token("2", TokenType.VAL),
                         new Token("2.5", TokenType.VAL),
                         new Token("^", TokenType.POW),
                         new Token("*", TokenType.TIMES),
                         new Token("10", TokenType.VAL),
                         new Token("100", TokenType.VAL),
                         new Token("log", TokenType.LOG),
                         new Token("*", TokenType.TIMES)]);
    
    inputStrings.add("0 - 1");
    tokenStreams.add([new Token("0", TokenType.VAL),
                      new Token("-", TokenType.MINUS),
                      new Token("1", TokenType.VAL)]);
    rpnTokenStreams.add([new Token("0", TokenType.VAL),
                         new Token("1", TokenType.VAL),
                         new Token("-", TokenType.MINUS)]);
    
    inputStrings.add("(0 - 1)");
    tokenStreams.add([new Token("(", TokenType.LBRACE),
                      new Token("0", TokenType.VAL),
                      new Token("-", TokenType.MINUS),
                      new Token("1", TokenType.VAL),
                      new Token(")", TokenType.RBRACE)]);
    rpnTokenStreams.add([new Token("0", TokenType.VAL),
                         new Token("1", TokenType.VAL),
                         new Token("-", TokenType.MINUS)]);
    
    inputStrings.add("nrt(5,10-1)");
    tokenStreams.add([new Token("nrt", TokenType.ROOT),
                      new Token("(", TokenType.LBRACE),
                      new Token("5", TokenType.VAL),
                      new Token(",", TokenType.SEPAR),
                      new Token("10", TokenType.VAL),
                      new Token("-", TokenType.MINUS),
                      new Token("1", TokenType.VAL),
                      new Token(")", TokenType.RBRACE)]);
    rpnTokenStreams.add([new Token("5", TokenType.VAL),
                         new Token("10", TokenType.VAL),
                         new Token("1", TokenType.VAL),
                         new Token("-", TokenType.MINUS),
                         new Token("nrt", TokenType.ROOT)]);
    
    inputStrings.add("1^1^1");
    tokenStreams.add([new Token("1", TokenType.VAL),
                      new Token("^", TokenType.POW),
                      new Token("1", TokenType.VAL),
                      new Token("^", TokenType.POW),
                      new Token("1", TokenType.VAL)]);
    rpnTokenStreams.add([new Token("1", TokenType.VAL),
                         new Token("1", TokenType.VAL),
                         new Token("1", TokenType.VAL),
                         new Token("^", TokenType.POW),
                         new Token("^", TokenType.POW)]);
    
    inputStrings.add("_1");
    tokenStreams.add([new Token("_", TokenType.UNMINUS),
                      new Token("1", TokenType.VAL)]);
    rpnTokenStreams.add([new Token("1", TokenType.VAL),
                         new Token("_", TokenType.UNMINUS)]);
    
    inputStrings.add("(_1)");
    tokenStreams.add([new Token("(", TokenType.LBRACE),
                      new Token("_", TokenType.UNMINUS),
                      new Token("1", TokenType.VAL),
                      new Token(")", TokenType.RBRACE)]);
    rpnTokenStreams.add([new Token("1", TokenType.VAL),
                         new Token("_", TokenType.UNMINUS)]);
    
    inputStrings.add("_(1)");
    tokenStreams.add([new Token("_", TokenType.UNMINUS),
                      new Token("(", TokenType.LBRACE),
                      new Token("1", TokenType.VAL),
                      new Token(")", TokenType.RBRACE)]);
    rpnTokenStreams.add([new Token("1", TokenType.VAL),
                         new Token("_", TokenType.UNMINUS)]);
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