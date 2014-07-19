part of math_expressions;

/**
 * The Parser creates a mathematical [Expression] from a given input string.
 *
 * It uses a [Lexer] to create a RPN token stream and then builds the
 * expression.
 *
 * Usage example:
 *     Parser p = new Parser();
 *     Expression exp = p.parse("(x^2 + cos(y)) / 3");
 */
class Parser {
  final Lexer lex;

  /**
   * Creates a new parser.
   */
  Parser(): lex = new Lexer();

  /**
   * Parses the given input string into an [Expression]. Throws a
   * [ArgumentError] if the given [inputString] is empty. Throws a
   * [StateError] if the token stream is invalid. Returns a valid
   * [Expression].
   */
  Expression parse(String inputString) {
    if (inputString == null || inputString.trim().isEmpty) {
      throw new ArgumentError("The given input string was empty.");
    }

    List<Expression> exprStack = new List<Expression>();
    List<Token> inputStream = lex.tokenizeToRPN(inputString);

    for (Token currToken in inputStream){
      Expression currExpr, left, right;

      switch(currToken.type) {
        case TokenType.VAL:
          currExpr = new Number(double.parse(currToken.text));
          break;
        case TokenType.VAR:
          currExpr = new Variable(currToken.text);
          break;
        case TokenType.UNMINUS:
          currExpr = -exprStack.removeLast();
          break;
        case TokenType.PLUS:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = left + right;
          break;
        case TokenType.MINUS:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = left - right;
          break;
        case TokenType.TIMES:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = left * right;
          break;
        case TokenType.DIV:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = left / right;
          break;
        case TokenType.POW:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = left ^ right;
          break;
        case TokenType.EFUNC:
          currExpr = new Exponential(exprStack.removeLast());
          break;
        case TokenType.LOG:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = new Log(left, right);
          break;
        case TokenType.LN:
          currExpr = new Ln(exprStack.removeLast());
          break;
        case TokenType.SQRT:
          currExpr = new Sqrt(exprStack.removeLast());
          break;
        case TokenType.ROOT:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = new Root.fromExpr((left as Number), right);
          break;
        case TokenType.SIN:
          currExpr = new Sin(exprStack.removeLast());
          break;
        case TokenType.COS:
          currExpr = new Cos(exprStack.removeLast());
          break;
        case TokenType.TAN:
          currExpr = new Tan(exprStack.removeLast());
          break;
        case TokenType.ABS:
          currExpr = new Abs(exprStack.removeLast());
          break;
        case TokenType.SGN:
          currExpr = new Sgn(exprStack.removeLast());
          break;
        default: throw new ArgumentError('Unsupported token: $currToken');
      }

      exprStack.add(currExpr);
    }

    if(exprStack.length > 1) {
      throw new StateError("The input String is not a correct expression");
    }

    return exprStack.last;
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

  /// Buffer for numbers
  String intBuffer = "";

  /// Buffer for variable and function names
  String varBuffer = "";

  /**
   * Creates a new lexer.
   */
  Lexer() {
    keywords["+"] = TokenType.PLUS;
    keywords["-"] = TokenType.MINUS;
    keywords["_"] = TokenType.UNMINUS;
    keywords["*"] = TokenType.TIMES;
    keywords["/"] = TokenType.DIV;
    keywords["^"] = TokenType.POW;
    keywords["nrt"] = TokenType.ROOT;
    keywords["sqrt"] = TokenType.SQRT;
    keywords["log"] = TokenType.LOG;
    keywords["cos"] = TokenType.COS;
    keywords["sin"] = TokenType.SIN;
    keywords["tan"] = TokenType.TAN;
    keywords["abs"] = TokenType.ABS;
    keywords["sgn"] = TokenType.SGN;
    keywords["ln"] = TokenType.LN;
    keywords["e"] = TokenType.EFUNC;
    keywords["("] = TokenType.LBRACE;
    keywords[")"] = TokenType.RBRACE;
    keywords["{"] = TokenType.LBRACE;
    keywords["}"] = TokenType.RBRACE;
    keywords[","] = TokenType.SEPAR;
  }

  /**
   * Tokenizes a given input string.
   * Returns a list of [Token] in infix notation.
   */
  List<Token> tokenize(String inputString) {
    List<Token> tempTokenStream = new List<Token>();

    String clearedString = inputString.replaceAll(" ", "").trim();

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
        // MH - Bit of a hack here to handle exponentials of the form e^x rather than e(x)
        if (keywords[si] == TokenType.POW && tempTokenStream.last.type == TokenType.EFUNC) {
          // Clear varBuffer since we have nothing to add to the stream as EFUNC is already in it
          //_doVarBuffer(tempTokenStream);
          varBuffer = "";
        } else {
          // Normal behaviour
          tempTokenStream.add(new Token(si, keywords[si]));
        }
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

          // The current string is not a number and not a simple keyword, so it has to be a variable or function.
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
   * algorithm. Returns a list of [Token] in RPN form. Throws an
   * [ArgumentError] if the list is empty.
   */
  List<Token> shuntingYard(List<Token> stream) {
    if(stream.isEmpty) {
      throw new ArgumentError("The given tokenStream was empty.");
    }

    List<Token> outputStream = new List<Token>();
    List<Token> operatorBuffer = new List<Token>();

    Token prevToken;

    for(Token curToken in stream) {
      // If the current Token is a value or a variable, put them into the output stream.
      if(curToken.type == TokenType.VAL || curToken.type == TokenType.VAR) {
        outputStream.add(curToken);
        prevToken = curToken;
        continue;
      }

      // If the current Token is a function, put it onto the operator stack.
      if(curToken.type.function) {
        operatorBuffer.add(curToken);
        prevToken = curToken;
        continue;
      }

      /*
       *  If the current Token is a function argument separator, pop operators
       *  to output stream until a left brace is encountered.
       */
      if(curToken.type == TokenType.SEPAR) {
        while(!operatorBuffer.isEmpty && operatorBuffer.last.type != TokenType.LBRACE) {
          outputStream.add(operatorBuffer.removeLast());
        }
        // If no left brace is encountered, separator was misplaced or parenthesis mismatch
        if(!operatorBuffer.isEmpty && operatorBuffer.last.type != TokenType.LBRACE) {
          //TODO never reached, check this.
          throw new StateError('Misplaced separator or mismatched parenthesis.');
        }
        prevToken = curToken;
        continue;
      }

      /* if the current Tokens type is MINUS and the previous Token is an operator or type LBRACE
       * or we're at the beginning of the expression (prevToken == null) the current Token is
       * an unary minus, so the tokentype has to be changed.
       */
      if(curToken.type == TokenType.MINUS && (prevToken == null || prevToken.type.operator || prevToken.type == TokenType.LBRACE)) {
        Token newToken = new Token(curToken.text, TokenType.UNMINUS);
        operatorBuffer.add(newToken);
        prevToken = newToken;
        continue;
      }

      /*
       * If the current token is an operator and it's priority is lower than the priority of the last
       * operator in the operator buffer, than put the operators from the operator buffer into the output
       * stream until you find an operator with a priority lower or equal as the current tokens.
       * Then add the current Token to the operator buffer.
       */
      if(curToken.type.operator) {
        while(!operatorBuffer.isEmpty && ((curToken.type.leftAssociative && curToken.type.priority <= operatorBuffer.last.type.priority)
            || (!curToken.type.leftAssociative && curToken.type.priority < operatorBuffer.last.type.priority))) {
          outputStream.add(operatorBuffer.removeLast());
        }
        operatorBuffer.add(curToken);
        prevToken = curToken;
        continue;
      }

      // If the current Token is a left brace, put it on the operator buffer.
      if(curToken.type == TokenType.LBRACE) {
        operatorBuffer.add(curToken);
        prevToken = curToken;
        continue;
      }

      // If the current Token is a right brace, empty the operator buffer until you find a left brace.
      if(curToken.type == TokenType.RBRACE) {
        while(!operatorBuffer.isEmpty && operatorBuffer.last.type != TokenType.LBRACE) {
          outputStream.add(operatorBuffer.removeLast());
        }

        // Expect next token on stack to be left parenthesis and pop it
        if(operatorBuffer.isEmpty || operatorBuffer.removeLast().type != TokenType.LBRACE) {
          throw new StateError('Mismatched parenthesis.');
        }

        // If the token at the top of the stack is a function token, pop it onto the output queue.
        if (!operatorBuffer.isEmpty && operatorBuffer.last.type.function) {
          outputStream.add(operatorBuffer.removeLast());
        }
      }
      prevToken = curToken;
    }

    /*
     * When the algorithm reaches the end of the input stream, we add the
     * tokens in the operatorBuffer to the outputStream. If the operator
     * on top of the stack is a parenthesis, there are mismatched parenthesis.
     */
    while(!operatorBuffer.isEmpty) {
      if (operatorBuffer.last.type == TokenType.LBRACE ||
          operatorBuffer.last.type == TokenType.RBRACE) {
        throw new StateError('Mismatched parenthesis.');
      }
      outputStream.add(operatorBuffer.removeLast());
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
  /// The text of this token.
  final String text;

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

  String toString() => "($type: $text)";
}

/**
 * A token type. Access token types via the static fields.
 *
 * For example, to access the token type PLUS:
 *     plusType = TokenType.PLUS;
 *
 * The type defines the `priority` (precedence) of the token.
 *     (+,-) < (*,/) < (^) < functions < (-u)
 *
 * It also defines the associativity of the token. True stands for
 * left-associative, false for right-associative.
 */
class TokenType {
  // Variables and values
  static const TokenType VAR = const TokenType._internal("VAR",10);
  static const TokenType VAL = const TokenType._internal("VAL",10);

  // Braces and Separators
  static const TokenType LBRACE = const TokenType._internal("LBRACE",-1);
  static const TokenType RBRACE = const TokenType._internal("RBRACE",-1);
  static const TokenType SEPAR = const TokenType._internal("SEPAR",-1);

  // Operators
  static const TokenType PLUS = const TokenType._internal("PLUS",1,operator:true);
  static const TokenType MINUS = const TokenType._internal("MINUS",1,operator:true);
  static const TokenType TIMES = const TokenType._internal("TIMES",2,operator:true);
  static const TokenType DIV = const TokenType._internal("DIV",2,operator:true);
  static const TokenType POW = const TokenType._internal("POW",3,leftAssociative:false,operator:true);
  static const TokenType UNMINUS = const TokenType._internal("UNMINUS",5,leftAssociative:false,operator:true);

  // Functions
  static const TokenType SQRT = const TokenType._internal("SQRT",4,function:true);
  static const TokenType ROOT = const TokenType._internal("ROOT",4,function:true);
  static const TokenType LOG = const TokenType._internal("LOG",4,function:true);
  static const TokenType LN = const TokenType._internal("LN",4,function:true);
  static const TokenType COS = const TokenType._internal("COS",4,function:true);
  static const TokenType SIN = const TokenType._internal("SIN",4,function:true);
  static const TokenType TAN = const TokenType._internal("TAN",4,function:true);
  static const TokenType ABS = const TokenType._internal("ABS",4,function:true);
  static const TokenType SGN = const TokenType._internal("SGN",4,function:true);
  static const TokenType EFUNC = const TokenType._internal("EFUNC",4,function:true);

  /// The string value of this token type.
  final String value;

  /// The priority of this token type.
  final int priority;

  /// Associativity of this token type. true = left.
  final bool leftAssociative;

  /// True, if this token is an operator.
  final bool operator;

  /// True, if this token is a function.
  final bool function;

  /**
   * Internal constructor for a [TokenType].
   * To retrieve a token type, directly access the static final fields
   * provided by this class.
   */
  const TokenType._internal(String this.value, int this.priority,
      {bool this.leftAssociative: true, bool this.operator: false,
       bool this.function: false});

  String toString() => value;
}

