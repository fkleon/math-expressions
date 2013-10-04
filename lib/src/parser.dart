part of math_expressions;

//TODO documentation
class Parser {
  Lexer lex;

  Parser(): lex = new Lexer();

  Expression parse(String inputString) {
    List<Expression> expressionStack = new List<Expression>();
    List<Token> inputStream;

    lex.createUPNStream(inputString);
    inputStream = lex.tokenStream;

    for (var i = 0; i < inputStream.length; i++){
      Token currentToken = inputStream[i];

      if(currentToken.type == TokenType.VAL) {
        Expression currentExpression = new Number(double.parse(currentToken.text));
        expressionStack.add(currentExpression);
        continue;
      }

      if(currentToken.type == TokenType.VAR) {
        Expression currentExpression = new Variable(currentToken.text);
        expressionStack.add(currentExpression);
        continue;
      }

      if(currentToken.type == TokenType.PLUS) {
        Expression rightOperand = expressionStack.last;
        expressionStack.removeLast();
        Expression leftOperand = expressionStack.last;
        expressionStack.removeLast();
        Expression currentExpression = leftOperand + rightOperand;
        expressionStack.add(currentExpression);
        continue;
      }

      if(currentToken.type == TokenType.MINUS) {
        Expression rightOperand = expressionStack.last;
        expressionStack.removeLast();
        Expression leftOperand = expressionStack.last;
        expressionStack.removeLast();
        Expression currentExpression = leftOperand - rightOperand;
        expressionStack.add(currentExpression);
        continue;
      }

      if(currentToken.type == TokenType.TIMES) {
        Expression rightOperand = expressionStack.last;
        expressionStack.removeLast();
        Expression leftOperand = expressionStack.last;
        expressionStack.removeLast();
        Expression currentExpression = leftOperand * rightOperand;
        expressionStack.add(currentExpression);
        continue;
      }

      if(currentToken.type == TokenType.DIV) {
        Expression rightOperand = expressionStack.last;
        expressionStack.removeLast();
        Expression leftOperand = expressionStack.last;
        expressionStack.removeLast();
        Expression currentExpression = leftOperand / rightOperand;
        expressionStack.add(currentExpression);
        continue;
      }

      if(currentToken.type == TokenType.POW) {
        Expression rightOperand = expressionStack.last;
        expressionStack.removeLast();
        Expression leftOperand = expressionStack.last;
        expressionStack.removeLast();
        Expression currentExpression = leftOperand ^ rightOperand;
        expressionStack.add(currentExpression);
        continue;
      }

      if(currentToken.type == TokenType.UNMINUS) {
        Expression operand = expressionStack.last;
        expressionStack.removeLast();
        Expression currentExpression = - operand;
        expressionStack.add(currentExpression);
        continue;
      }

      if(currentToken.type == TokenType.LOG) {
        Expression rightOperand = expressionStack.last;
        expressionStack.removeLast();
        Expression leftOperand = expressionStack.last;
        expressionStack.removeLast();
        Expression currentExpression = new Log(leftOperand, rightOperand);
        expressionStack.add(currentExpression);
        continue;
      }

      if(currentToken.type == TokenType.LN) {
        Expression operand = expressionStack.last;
        expressionStack.removeLast();
        Expression currentExpression = new Ln(operand);
        expressionStack.add(currentExpression);
        continue;
      }

      if(currentToken.type == TokenType.SQRT) {
        Expression operand = expressionStack.last;
        expressionStack.removeLast();
        Expression currentExpression = new Sqrt(operand);
        expressionStack.add(currentExpression);
        continue;
      }
    }

    if(expressionStack.length > 1){
      throw new StateError("The input String is not a correct expression");
    }

    return expressionStack.last;
  }
}

class Lexer {
  var keywords = new Map<String, TokenType>();
  List<Token> _tokenStream;
  String intBuffer = "";
  String varBuffer = "";

  Lexer() {
    keywords["+"] = TokenType.PLUS;
    keywords["-"] = TokenType.MINUS;
    keywords["*"] = TokenType.TIMES;
    keywords["/"] = TokenType.DIV;
    keywords["^"] = TokenType.POW;
    keywords["sqrt"] = TokenType.SQRT;
    keywords["log"] = TokenType.LOG;
    keywords["ln"] = TokenType.LN;
    keywords["e"] = TokenType.EFUNC;
    keywords["("] = TokenType.LBRACE;
    keywords[")"] = TokenType.RBRACE;
    _tokenStream = new List<Token>();
  }

  List<Token> get tokenStream =>  _tokenStream;

  /**
   * creates a list of tokens from the given string.
   */
  List<Token> createTokenStream(String inputString) {
    List<Token> tempTokenStream = new List<Token>();

    String clearedString = inputString.replaceAll(" ", "");

    RuneIterator iter = clearedString.runes.iterator;
    int siInt;

    while (iter.moveNext()) {
      String si = iter.currentAsString;

      /* check if the current Character is a keyword. If it is a keyword, check if the intBuffer is not empty and add
       * a Value Token for the intBuffer and the corresponding Token for the keyword.
       */
      if(keywords.containsKey(si)) {
        // check and or do intBuffer and varBuffer
        if(intBuffer.length > 0) {
          doIntBuffer(tempTokenStream);
        }
        if(varBuffer.length > 0) {
          doVarBuffer(tempTokenStream);
        }
        tempTokenStream.add(new Token(si, keywords[si]));
      } else {
        // check if the current string is a Number. If it's the case add the string to the intBuffer.
        StringBuffer sb = new StringBuffer(intBuffer);
        try {
          siInt = int.parse(si);
          // the current string is a number and it is added to the intBuffer.
          sb.write(si);
          intBuffer = sb.toString();
          if(varBuffer.length > 0) {
            doVarBuffer(tempTokenStream);
          }
        } on FormatException {
          // check if the current string is part of a floating point input
          if(si=="."){
            sb.write(si);
            intBuffer = sb.toString();
            continue;
          }

          // the current string is not a number and not a simple keyword, so it has to be a variable or log or ln.
          sb = new StringBuffer(varBuffer);
          if(intBuffer.length > 0) {
            /* the intBuffer contains a string and the current string is a variable or part of a complex keyword, so the value is added to the tokenstream
             * and the current string is added to the var buffer.
             */
            doIntBuffer(tempTokenStream);
            sb.write(si);
            varBuffer = sb.toString();
            //reset the intBuffer.
            intBuffer ="";
            //  print("was in text and do int case");
          } else {
            // the intBuffer contains no string and the current string is a variable, so both Tokens are added to the tokenStream.
            // print("was in text case");
            sb.write(si);
            varBuffer = sb.toString();
          }
        }
      }
    }

    if(intBuffer.length > 0) {
      // There are no more symbols in the input string but there is still an int in the intBuffer
      doIntBuffer(tempTokenStream);
      intBuffer ="";
    }
    if(varBuffer.length > 0) {
      // There are no more symbols in the input string but there is still a variable or keyword in the varBuffer
      doVarBuffer(tempTokenStream);
      varBuffer ="";
    }
    return tempTokenStream;
  }

  /**
   * Checks if the intBuffer contains a number and adds it to the tokenStream.
   */
  void doIntBuffer(List<Token> stream){
    stream.add(new Token(intBuffer,TokenType.VAL));
    intBuffer = "";
  }

  /**
   * Checks if the varBuffer contains a keyword or a variable and adds them to the tokenStream.
   */
  void doVarBuffer(List<Token> stream) {
    if(keywords.containsKey(varBuffer)) {
      stream.add(new Token(varBuffer, keywords[varBuffer]));
    } else {
      stream.add(new Token(varBuffer, TokenType.VAR));
    }
    varBuffer = "";
  }

  /**
   * Transforms the lexers token stream into UPN.
   */
  List<Token> shuntingYard(List<Token> stream) {
    if(stream.isEmpty) {
      throw new Exception("tokenStream was empty");
    }

    List<Token> outputStream = new List<Token>();
    List<Token> operatorBuffer = new List<Token>();

    for(int i = 0; i < stream.length; i++) {
      Token tempToken = stream[i];

      //if the current Token is a value or a variable, put them into the outputstream.
      if(tempToken.type == TokenType.VAL || tempToken.type == TokenType.VAR) {
        outputStream.add(tempToken);
        continue;
      }

      //if the current Token is a left brace, put it on the operator buffer.
      if(tempToken.type == TokenType.LBRACE) {
        operatorBuffer.add(tempToken);
        continue;
      }

      //if the current Token is a right brace, empty the operator buffer until you find a left brace.
      if(tempToken.type == TokenType.RBRACE) {
        while(operatorBuffer.last.type != TokenType.LBRACE) {
          outputStream.add(operatorBuffer.last);
          operatorBuffer.removeLast();
        }
        operatorBuffer.removeLast();
        continue;
      }
      /*
       * if there is no other operator in the operatorBuffer, than the current operator token ist added to the
       * operatorBuffer.
       */
      if(operatorBuffer.isEmpty){
        operatorBuffer.add(tempToken);
        continue;
      }

      /* if the current Tokens type is MINUS and the last Token in the operator buffer is of type LBRACE
       * the current Token is an unary minus, so the tokentype has to be changed.
       */
      if(tempToken.type == TokenType.MINUS && operatorBuffer.last.type == TokenType.LBRACE) {
        Token newToken = new Token(tempToken.text, TokenType.UNMINUS);
        operatorBuffer.add(newToken);
        continue;
      }
      /* if the current token is an operator and it's priority is lower than the priority of the last
       * operator in the operator buffer, than put the operators from the operator buffer into the output
       * stream until you find an operator with a priority lower or equal as the current tokens.
       * Then add the current Token to the operator buffer.
       */
      if(tempToken.type.priority < operatorBuffer.last.type.priority) {
        while(operatorBuffer.length > 0 && operatorBuffer.last.type.priority > tempToken.type.priority) {
          outputStream.add(operatorBuffer.last);
          operatorBuffer.removeLast();
        }
        operatorBuffer.add(tempToken);
        continue;
      } else {
        operatorBuffer.add(tempToken);
        continue;
      }
    }
    /*
     * when the algorithm reached the end of the input stream, then we add the tokens in the
     * operatorBuffer to the outputStream.
     */
    while(!operatorBuffer.isEmpty) {
      outputStream.add(operatorBuffer.last);
      operatorBuffer.removeLast();
    }

    return outputStream;
  }

  /**
   * This method invokes the createTokenStream methode to create an infix token stream and then invokes the shunting
   * yards method to transform this stream into an UPN token stream.
   *
   * Returns  List<Token>.
   */
  createUPNStream(String inputString) {
    List<Token> infixStream = createTokenStream(inputString);
    _tokenStream = shuntingYard(infixStream);
  }
}

class Token {
  //TODO
  var text;
  final TokenType type;

  bool operator==(Token token) => (token.text == this.text) && (token.type == this.type);

  Token(var this.text, TokenType this.type);

  String toString(){
    return "( $type , $text )";
  }
}

class TokenType {
  static final TokenType VAR = const TokenType("VAR",10);
  static final TokenType VAL = const TokenType("VAL",10);

  //Braces
  static final TokenType LBRACE = const TokenType("LBRACE",-1);
  static final TokenType RBRACE = const TokenType("RBRACE",-1);

  //Simple Operators
  static final TokenType PLUS = const TokenType("PLUS",1);
  static final TokenType MINUS = const TokenType("MINUS",1);
  static final TokenType UNMINUS = const TokenType("UNMINUS",1);
  static final TokenType TIMES = const TokenType("TIMES",2);
  static final TokenType DIV = const TokenType("DIV",2);

  //Complex Operators
  static final TokenType POW = const TokenType("POW",3);
  static final TokenType SQRT = const TokenType("SQRT",3);
  static final TokenType LOG = const TokenType("LOG",3);
  static final TokenType LN = const TokenType("LN",3);
  static final TokenType EFUNC = const TokenType("EFUNC",3);

  final String value;
  final int priority;

  const TokenType(String this.value, int this.priority);

  String toString() {
    return value;
  }
}

