part of math_expressions_test;

/**
 * Contains a test set for testing the parser and lexer
 */
class ParserTests extends TestSet {

  get name => 'Parser Tests';

  get testFunctions => {
    'Lexer Token Creation (Infix + Postfix)': lexerTokenTest,
    'Parser Expression Creation': parserExpressionTest
  };

  void initTests() {
    pars = new Parser();
    lex = new Lexer();

    inputStrings = ["x + 2",
                    "x * 2^2.5 * log(10)(100)",
                    "log(10)(100)"];
    
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
                      new Token(")", TokenType.RBRACE),
                      new Token("(", TokenType.LBRACE),
                      new Token("100", TokenType.VAL),
                      new Token(")", TokenType.RBRACE)];

    rpnTokenStreams[1] = [new Token("x", TokenType.VAR),
                          new Token("2", TokenType.VAL),
                          new Token("2.5", TokenType.VAL),
                          new Token("^", TokenType.POW),
                          new Token("10", TokenType.VAL),
                          new Token("100", TokenType.VAL),
                          new Token("log", TokenType.LOG),
                          new Token("*", TokenType.TIMES),
                          new Token("*", TokenType.TIMES)];

    tokenStreams[2] = [new Token("log", TokenType.LOG),
                    new Token("(", TokenType.LBRACE),
                    new Token("10", TokenType.VAL),
                    new Token(")", TokenType.RBRACE),
                    new Token("(", TokenType.LBRACE),
                    new Token("100", TokenType.VAL),
                    new Token(")", TokenType.RBRACE)];
    
    rpnTokenStreams[2] = [new Token("10", TokenType.VAL),
                          new Token("100", TokenType.VAL),
                          new Token("log", TokenType.LOG)];
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
      List<Token> infixStream = lex.createTokenStream(input);
      expect(infixStream, orderedEquals(tokenStreams[i]));
      
      // Test RPN streams
      List<Token> rpnStream = lex.shuntingYard(infixStream);
      expect(rpnStream, orderedEquals(rpnTokenStreams[i]));
    }
  }

  void parserExpressionTest() {
    for (String inputString in inputStrings) {
      Expression exp = pars.parse(inputString);
      // TODO Don't just test for no exceptions,
      // also test for expression content.
    }
  }
}