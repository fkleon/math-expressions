part of math_expressions_test;

/**
 * Contains a test set for testing the parser and lexer
 */
class ParserTests extends TestSet {

  get name => 'Parser Tests';

  get testFunctions => {
    'Parser Token test': parserTokenTest,
  };

  void initTests() {
    pars = new Parser();
    lex = new Lexer();

    inputString1 = "x + 2";
    inputString2 = "x * 2^2.5 * log(10)(100)";
    inputString3 = "log(10)(100)";

    tokenStream1 = [new Token("x", TokenType.VAR),
                    new Token("+", TokenType.PLUS),
                    new Token("2", TokenType.VAL)];

    tokenStream2 = [new Token("x", TokenType.VAR),
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

    upnTokenStream2 = [new Token("x", TokenType.VAR),
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

    tokenStream3 = [new Token("log", TokenType.LOG),
                    new Token("(", TokenType.LBRACE),
                    new Token("10", TokenType.VAL),
                    new Token(")", TokenType.RBRACE),
                    new Token("(", TokenType.LBRACE),
                    new Token("100", TokenType.VAL),
                    new Token(")", TokenType.RBRACE)];
  }

  /*
   *  Tests and variables.
   */
  Parser pars;
  Lexer lex;
  String inputString1;
  String inputString2;
  String inputString3;

  List<Token> tokenStream1;
  List<Token> tokenStream2;
  List<Token> tokenStream3;

  List<Token> upnTokenStream1;
  List<Token> upnTokenStream2;


  void parserTokenTest() {
    List<Token> stream1 = lex.createTokenStream(inputString1);
    List<Token> stream2 = lex.createTokenStream(inputString2);
    List<Token> stream3 = lex.createTokenStream(inputString3);

    List<Token> upnStream1 = lex.shuntingYard(stream1);
    List<Token> upnStream2 = lex.shuntingYard(stream2);

    expect(stream1, orderedEquals(tokenStream1));
    expect(stream1, isNot(orderedEquals(tokenStream2)));
    expect(stream2, orderedEquals(tokenStream2));
    expect(stream2, isNot(orderedEquals(tokenStream1)));
    expect(stream3, orderedEquals(tokenStream3));
  }

  void parserExpressionTest() {
    throw new UnimplementedError();
  }


}