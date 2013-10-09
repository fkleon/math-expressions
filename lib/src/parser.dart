part of math_expressions;

/**
 * The Parser creates a mathematical [Expression] from an input string.
 * 
 * It uses a [Lexer] to create a RPN token stream and then builds the
 * expression.
 */
class Parser {
  Lexer lex;

  /**
   * Creates a new parser.
   */
  Parser(): lex = new Lexer();

  /**
   * Parses the given input string into an [Expression]. Throws a [StateError]
   * if the token stream is invalid. Returns a valid [Expression].
   */
  Expression parse(String inputString) {
    List<Expression> expressionStack = new List<Expression>();
    List<Token> inputStream = lex.tokenizeToRPN(inputString);

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
      
      if(currentToken.type == TokenType.COS) {
        Expression operand = expressionStack.last;
        expressionStack.removeLast();
        Expression currentExpression = new Cos(operand);
        expressionStack.add(currentExpression);
        continue;
      }
      
      if(currentToken.type == TokenType.SIN) {
        Expression operand = expressionStack.last;
        expressionStack.removeLast();
        Expression currentExpression = new Sin(operand);
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

/**
 * The lexer creates tokens (see [TokenType] and [Token]) from an input string.
 * The input string is expected to be in
 * [infix notation form](https://en.wikipedia.org/wiki/Infix_notation).
 * The lexer can convert an infix stream into a
 * [postfix stream](https://en.wikipedia.org/wiki/Reverse_Polish_notation)
 * (Reverse Polish Notation) for further processing by a [Parser].
 */
class Lexer {
  final Map keywords = new Map<String, TokenType>();
  String intBuffer = "";
  String varBuffer = "";

  /**
   * Creates a new lexer.
   */
  Lexer() {
    keywords["+"] = TokenType.PLUS;
    keywords["-"] = TokenType.MINUS;
    keywords["*"] = TokenType.TIMES;
    keywords["/"] = TokenType.DIV;
    keywords["^"] = TokenType.POW;
    keywords["sqrt"] = TokenType.SQRT;
    keywords["log"] = TokenType.LOG;
    keywords["cos"] = TokenType.COS;
    keywords["sin"] = TokenType.SIN;
    keywords["ln"] = TokenType.LN;
    keywords["e"] = TokenType.EFUNC;
    keywords["("] = TokenType.LBRACE;
    keywords[")"] = TokenType.RBRACE;
    keywords["{"] = TokenType.LBRACE;
    keywords["}"] = TokenType.RBRACE;
  }

  /**
   * Tokenizes a given input string.
   * Returns a list of [Token] in infix notation.
   */
  List<Token> tokenize(String inputString) {
    List<Token> tempTokenStream = new List<Token>();

    String clearedString = inputString.replaceAll(" ", "");

    RuneIterator iter = clearedString.runes.iterator;
    int siInt;

    while (iter.moveNext()) {
      String si = iter.currentAsString;

      /* 
       * Check if the current Character is a keyword. If it is a keyword, check if the intBuffer is not empty and add
       * a Value Token for the intBuffer and the corresponding Token for the keyword.
       */
      if(keywords.containsKey(si)) {
        // check and or do intBuffer and varBuffer
        if(intBuffer.length > 0) {
          _doIntBuffer(tempTokenStream);
        }
        if(varBuffer.length > 0) {
          _doVarBuffer(tempTokenStream);
        }
        tempTokenStream.add(new Token(si, keywords[si]));
      } else {
        // Check if the current string is a Number. If it's the case add the string to the intBuffer.
        StringBuffer sb = new StringBuffer(intBuffer);
        try {
          siInt = int.parse(si);
          // The current string is a number and it is added to the intBuffer.
          sb.write(si);
          intBuffer = sb.toString();
          if(varBuffer.length > 0) {
            _doVarBuffer(tempTokenStream);
          }
        } on FormatException {
          // Check if the current string is part of a floating point input
          if(si=="."){
            sb.write(si);
            intBuffer = sb.toString();
            continue;
          }

          // The current string is not a number and not a simple keyword, so it has to be a variable or log or ln.
          sb = new StringBuffer(varBuffer);
          if(intBuffer.length > 0) {
            /* 
             * The intBuffer contains a string and the current string is a
             * variable or part of a complex keyword, so the value is added
             * to the token stream and the current string is added to the
             * var buffer.
             */
            _doIntBuffer(tempTokenStream);
            sb.write(si);
            varBuffer = sb.toString();
          } else {
            // intBuffer contains no string and the current string is a variable, so both Tokens are added to the tokenStream.
            sb.write(si);
            varBuffer = sb.toString();
          }
        }
      }
    }

    if(intBuffer.length > 0) {
      // There are no more symbols in the input string but there is still an int in the intBuffer
      _doIntBuffer(tempTokenStream);
    }
    if(varBuffer.length > 0) {
      // There are no more symbols in the input string but there is still a variable or keyword in the varBuffer
      _doVarBuffer(tempTokenStream);
    }
    return tempTokenStream;
  }

  /**
   * Checks if the intBuffer contains a number and adds it to the tokenStream.
   * Then clears the intBuffer.
   */
  void _doIntBuffer(List<Token> stream){
    stream.add(new Token(intBuffer,TokenType.VAL));
    intBuffer = "";
  }

  /**
   * Checks if the varBuffer contains a keyword or a variable and adds them to the tokenStream.
   * Then clears the varBuffer.
   */
  void _doVarBuffer(List<Token> stream) {
    if(keywords.containsKey(varBuffer)) {
      stream.add(new Token(varBuffer, keywords[varBuffer]));
    } else {
      stream.add(new Token(varBuffer, TokenType.VAR));
    }
    varBuffer = "";
  }

  /**
   * Transforms the lexer's token stream into RPN using the Shunting-yard
   * algorithm. Returns a list of [Token] in RPN form.
   */
  List<Token> shuntingYard(List<Token> stream) {
    if(stream.isEmpty) {
      throw new Exception("tokenStream was empty");
    }

    List<Token> outputStream = new List<Token>();
    List<Token> operatorBuffer = new List<Token>();

    for(int i = 0; i < stream.length; i++) {
      Token tempToken = stream[i];

      // If the current Token is a value or a variable, put them into the output stream.
      if(tempToken.type == TokenType.VAL || tempToken.type == TokenType.VAR) {
        outputStream.add(tempToken);
        continue;
      }

      // If the current Token is a left brace, put it on the operator buffer.
      if(tempToken.type == TokenType.LBRACE) {
        operatorBuffer.add(tempToken);
        continue;
      }

      // If the current Token is a right brace, empty the operator buffer until you find a left brace.
      if(tempToken.type == TokenType.RBRACE) {
        while(operatorBuffer.last.type != TokenType.LBRACE) {
          outputStream.add(operatorBuffer.last);
          operatorBuffer.removeLast();
        }
        operatorBuffer.removeLast();
        continue;
      }
      /*
       * If there is no other operator in the operator buffer, the current
       * operator token is added to the operator buffer.
       */
      if(operatorBuffer.isEmpty){
        operatorBuffer.add(tempToken);
        continue;
      }

      /* 
       * If the current Tokens type is MINUS and the last Token in the operator
       * buffer is of type LBRACE, the current Token is an unary minus, so the
       * token type has to be changed.
       */
//      if(tempToken.type == TokenType.MINUS && operatorBuffer.last.type == TokenType.LBRACE) {
//        //TODO This is buggy. Handly unary minus as right-associated operator of higher prcedence.
//        //TODO Or check if _isInfixOperator(last).
//        Token newToken = new Token(tempToken.text, TokenType.UNMINUS);
//        operatorBuffer.add(newToken);
//        continue;
//      }
      
      /* 
       * If the current token is an operator and it's priority is lower than the priority of the last
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
     * When the algorithm reaches the end of the input stream, we add the
     * tokens in the operatorBuffer to the outputStream.
     */
    while(!operatorBuffer.isEmpty) {
      outputStream.add(operatorBuffer.last);
      operatorBuffer.removeLast();
    }

    return outputStream;
  }

  /**
   * This method invokes the createTokenStream methode to create an infix token
   * stream and then invokes the shunting yard method to transform this stream
   * into a RPN (reverse polish notation) token stream.
   */
  List<Token> tokenizeToRPN(String inputString) {
    List<Token> infixStream = tokenize(inputString);
    return shuntingYard(infixStream);
  }
}

/**
 * A Token consists of text and has a [TokenType].
 */
class Token {
  /// The test of this token.
  String text;
  
  /// The type of this token.
  final TokenType type;

  /// Tokens equal, if they have equal text and types.
  bool operator==(Token token) => (token.text == this.text)
      && (token.type == this.type);

  int get hashCode {
    int result = 17;
    result = 37 * result + text.hashCode;
    result = 37 * result + type.hashCode;
    return result;
  }
  
  /// Creates a new Token with the given text and type.
  Token(String this.text, TokenType this.type);

  String toString() {
    return "($type,$text)";
  }
}

/**
 * A token type. Access token types via the static final fields.
 * 
 * For example, to access the token type PLUS:
 *     plusType = TokenType.PLUS;
 */
class TokenType {
  static final TokenType VAR = const TokenType._internal("VAR",10);
  static final TokenType VAL = const TokenType._internal("VAL",10);

  // Braces
  static final TokenType LBRACE = const TokenType._internal("LBRACE",-1);
  static final TokenType RBRACE = const TokenType._internal("RBRACE",-1);

  // Simple Operators
  static final TokenType PLUS = const TokenType._internal("PLUS",1);
  static final TokenType MINUS = const TokenType._internal("MINUS",1);
  static final TokenType UNMINUS = const TokenType._internal("UNMINUS",5);
  static final TokenType TIMES = const TokenType._internal("TIMES",2);
  static final TokenType DIV = const TokenType._internal("DIV",2);

  // Complex Operators
  static final TokenType POW = const TokenType._internal("POW",4);
  static final TokenType SQRT = const TokenType._internal("SQRT",3);
  static final TokenType LOG = const TokenType._internal("LOG",3);
  static final TokenType LN = const TokenType._internal("LN",3);
  static final TokenType COS = const TokenType._internal("COS",3);
  static final TokenType SIN = const TokenType._internal("SIN",3);
  static final TokenType EFUNC = const TokenType._internal("EFUNC",3);

  /// The string value of this token type.
  final String value;
  
  /// The priority of this token type.
  final int priority;

  /**
   * Internal constructor for a [TokenType].
   * To retrieve a token type, directly access the static final fields
   * provided by this class.
   */
  const TokenType._internal(String this.value, int this.priority);

  String toString() {
    return value;
  }
}

