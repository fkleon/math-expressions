part of math_expressions;

/// The Parser creates a mathematical [Expression] from a given input string.
///
/// It uses a [Lexer] to create a RPN token stream and then builds the
/// expression.
///
/// Usage example:
///
///     Parser p = Parser();
///     Expression exp = p.parse("(x^2 + cos(y)) / 3");
class Parser {
  final Lexer lex;

  /// Creates a new parser.
  Parser() : lex = Lexer();
  Map<String, dynamic> functionHandlers = <String, dynamic>{};

  /// Parses the given input string into an [Expression]. Throws a
  /// [ArgumentError] if the given [inputString] is empty. Throws a
  /// [StateError] if the token stream is invalid. Returns a valid
  /// [Expression].
  Expression parse(String inputString) {
    if (inputString.trim().isEmpty) {
      throw FormatException('The given input string was empty.');
    }

    final List<Expression> exprStack = <Expression>[];
    final List<Token> inputStream = lex.tokenizeToRPN(inputString);

    for (Token currToken in inputStream) {
      Expression currExpr, left, right;

      switch (currToken.type) {
        case TokenType.VAL:
          currExpr = Number(double.parse(currToken.text));
          break;
        case TokenType.VAR:
          currExpr = Variable(currToken.text);
          break;
        case TokenType.UNMINUS:
          currExpr = -exprStack.removeLast();
          break;
        case TokenType.UNPLUS:
          currExpr = UnaryPlus(exprStack.removeLast());
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
        case TokenType.MOD:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = left % right;
          break;
        case TokenType.POW:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = left ^ right;
          break;
        case TokenType.LTE:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = LowerThanOrEqualTo(left, right);
          break;
        case TokenType.LT:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = left < right;
          break;
        case TokenType.EFUNC:
          currExpr = Exponential(exprStack.removeLast());
          break;
        case TokenType.LOG:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = Log(left, right);
          break;
        case TokenType.LN:
          currExpr = Ln(exprStack.removeLast());
          break;
        case TokenType.SQRT:
          currExpr = Sqrt(exprStack.removeLast());
          break;
        case TokenType.ROOT:
          right = exprStack.removeLast();
          left = exprStack.removeLast();
          currExpr = Root.fromExpr(left as Number, right);
          break;
        case TokenType.SIN:
          currExpr = Sin(exprStack.removeLast());
          break;
        case TokenType.COS:
          currExpr = Cos(exprStack.removeLast());
          break;
        case TokenType.TAN:
          currExpr = Tan(exprStack.removeLast());
          break;
        case TokenType.ASIN:
          currExpr = Asin(exprStack.removeLast());
          break;
        case TokenType.ACOS:
          currExpr = Acos(exprStack.removeLast());
          break;
        case TokenType.ATAN:
          currExpr = Atan(exprStack.removeLast());
          break;
        case TokenType.ABS:
          currExpr = Abs(exprStack.removeLast());
          break;
        case TokenType.CEIL:
          currExpr = Ceil(exprStack.removeLast());
          break;
        case TokenType.FLOOR:
          currExpr = Floor(exprStack.removeLast());
          break;
        case TokenType.SGN:
          currExpr = Sgn(exprStack.removeLast());
          break;
        case TokenType.FACTORIAL:
          currExpr = Factorial(exprStack.removeLast());
          break;
        case TokenType.FUNC:
          List<Expression> args = [];
          for (var i = 0; i < currToken.argCount; ++i) {
            args.insert(0, exprStack.removeLast());
          }
          currExpr = AlgorithmicFunction(
              currToken.text, args, functionHandlers[currToken.text]);
          break;
        default:
          throw FormatException('Unsupported token: $currToken');
      }

      exprStack.add(currExpr);
    }

    if (exprStack.length > 1) {
      throw FormatException('The input String is not a correct expression');
    }

    return exprStack.last;
  }

  /// Registers a function handler with the parser.
  ///
  /// This can be used to define custom functions that run native Dart code.
  void addFunction(String name, dynamic handler) {
    if (lex.keywords.containsKey(name)) {
      throw FormatException('Cannot redefine existing function $name');
    }
    lex.keywords[name] = TokenType.FUNC;
    functionHandlers[name] = handler;
  }
}

/// The lexer creates tokens (see [TokenType] and [Token]) from an input string.
/// The input string is expected to be in
/// [infix notation form](https://en.wikipedia.org/wiki/Infix_notation).
/// The lexer can convert an infix stream into a
/// [postfix stream](https://en.wikipedia.org/wiki/Reverse_Polish_notation)
/// (Reverse Polish Notation) for further processing by a [Parser].
class Lexer {
  final Map<String, TokenType> keywords = <String, TokenType>{};

  /// Buffer for numbers
  String intBuffer = '';

  /// Buffer for variable and function names
  String varBuffer = '';

  /// Creates a new lexer.
  Lexer() {
    keywords['+'] = TokenType.PLUS;
    keywords['-'] = TokenType.MINUS;
    keywords['*'] = TokenType.TIMES;
    keywords['/'] = TokenType.DIV;
    keywords['%'] = TokenType.MOD;
    keywords['^'] = TokenType.POW;
    keywords['<'] = TokenType.LT;
    keywords['≤'] = TokenType.LTE;
    keywords['!'] = TokenType.FACTORIAL;
    keywords['nrt'] = TokenType.ROOT;
    keywords['sqrt'] = TokenType.SQRT;
    keywords['log'] = TokenType.LOG;
    keywords['cos'] = TokenType.COS;
    keywords['sin'] = TokenType.SIN;
    keywords['tan'] = TokenType.TAN;
    keywords['arccos'] = TokenType.ACOS;
    keywords['arcsin'] = TokenType.ASIN;
    keywords['arctan'] = TokenType.ATAN;
    keywords['abs'] = TokenType.ABS;
    keywords['ceil'] = TokenType.CEIL;
    keywords['floor'] = TokenType.FLOOR;
    keywords['sgn'] = TokenType.SGN;
    keywords['ln'] = TokenType.LN;
    keywords['e'] = TokenType.EFUNC;
    keywords['('] = TokenType.LBRACE;
    keywords[')'] = TokenType.RBRACE;
    keywords['{'] = TokenType.LBRACE;
    keywords['}'] = TokenType.RBRACE;
    keywords[','] = TokenType.SEPAR;
  }

  /// Tokenizes a given input string.
  /// Returns a list of [Token] in infix notation.
  List<Token> tokenize(String inputString) {
    final List<Token> tempTokenStream = <Token>[];
    final String clearedString = inputString.replaceAll(' ', '').trim();
    final RuneIterator iter = clearedString.runes.iterator;

    while (iter.moveNext()) {
      final String si = iter.currentAsString;
      /*
       * Check if the current Character is a keyword. If it is a keyword, check if the intBuffer is not empty and add
       * a Value Token for the intBuffer and the corresponding Token for the keyword.
       */
      bool keywordsContainsKey = keywords.containsKey(si);

      /*
      * There's a situation that 'ceil' conflict with 'e', we use this to look back the buffer and decide
      * which way should go.
      */
      if (si == 'e' && varBuffer.isNotEmpty) {
        keywordsContainsKey = false;
      }

      if (keywordsContainsKey) {
        // check and or do intBuffer and varBuffer
        if (intBuffer.isNotEmpty) {
          _doIntBuffer(tempTokenStream);
        }
        if (varBuffer.isNotEmpty) {
          _doVarBuffer(tempTokenStream);
        }
        // MH - Bit of a hack here to handle exponentials of the form e^x rather than e(x)
        if (keywords[si] == TokenType.POW &&
            tempTokenStream.last.type == TokenType.EFUNC) {
          // Clear varBuffer since we have nothing to add to the stream as EFUNC is already in it
          //_doVarBuffer(tempTokenStream);
          varBuffer = '';
        } else {
          // Normal behaviour
          tempTokenStream.add(Token(si, keywords[si]!));
        }
      } else {
        // Check if the current string is a Number. If it's the case add the string to the intBuffer.
        StringBuffer sb = StringBuffer(intBuffer);
        try {
          int.parse(si);
          // The current string is a number and it is added to the intBuffer.
          sb.write(si);
          intBuffer = sb.toString();
          if (varBuffer.isNotEmpty) {
            _doVarBuffer(tempTokenStream);
          }
        } on FormatException {
          // Check if the current string is part of a floating point input
          if (si == '.') {
            sb.write(si);
            intBuffer = sb.toString();
            continue;
          }

          // The current string is not a number and not a simple keyword, so it has to be a variable or function.
          sb = StringBuffer(varBuffer);
          if (intBuffer.isNotEmpty) {
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

    if (intBuffer.isNotEmpty) {
      // There are no more symbols in the input string but there is still an int in the intBuffer
      _doIntBuffer(tempTokenStream);
    }
    if (varBuffer.isNotEmpty) {
      // There are no more symbols in the input string but there is still a variable or keyword in the varBuffer
      _doVarBuffer(tempTokenStream);
    }
    return tempTokenStream;
  }

  /// Checks if the intBuffer contains a number and adds it to the tokenStream.
  /// Then clears the intBuffer.
  void _doIntBuffer(List<Token> stream) {
    stream.add(Token(intBuffer, TokenType.VAL));
    intBuffer = '';
  }

  /// Checks if the varBuffer contains a keyword or a variable and adds them to the tokenStream.
  /// Then clears the varBuffer.
  void _doVarBuffer(List<Token> stream) {
    if (keywords.containsKey(varBuffer)) {
      stream.add(Token(varBuffer, keywords[varBuffer]!));
    } else {
      stream.add(Token(varBuffer, TokenType.VAR));
    }
    varBuffer = '';
  }

  /// Transforms the lexer's token stream into RPN using the Shunting-yard
  /// algorithm. Returns a list of [Token] in RPN form. Throws an
  /// [ArgumentError] if the list is empty.
  List<Token> shuntingYard(List<Token> stream) {
    if (stream.isEmpty) {
      throw FormatException('The given tokenStream was empty.');
    }

    final List<Token> outputStream = <Token>[];
    final List<Token> operatorBuffer = <Token>[];

    Token? prevToken;

    for (Token curToken in stream) {
      // If the current Token is a value or a variable, put them into the output stream.
      if (curToken.type == TokenType.VAL || curToken.type == TokenType.VAR) {
        outputStream.add(curToken);
        prevToken = curToken;
        continue;
      }

      // If the current Token is a function, put it onto the operator stack.
      if (curToken.type.function) {
        curToken.argCount = 1;
        operatorBuffer.add(curToken);
        prevToken = curToken;
        continue;
      }

      /*
       *  If the current Token is a function argument separator, pop operators
       *  to output stream until a left brace is encountered.
       */
      if (curToken.type == TokenType.SEPAR) {
        while (operatorBuffer.isNotEmpty &&
            operatorBuffer.last.type != TokenType.LBRACE) {
          outputStream.add(operatorBuffer.removeLast());
        }

        if (operatorBuffer.length > 1) {
          var func = operatorBuffer[operatorBuffer.length - 2];
          if (func.type.function) {
            ++func.argCount;
          }
        }

        // If no left brace is encountered, separator was misplaced or parenthesis mismatch
        if (operatorBuffer.isNotEmpty &&
            operatorBuffer.last.type != TokenType.LBRACE) {
          //TODO never reached, check this.
          throw FormatException(
              'Misplaced separator or mismatched parenthesis.');
        }
        prevToken = curToken;
        continue;
      }

      /* if the current Tokens type is PLUS or MINUS and the previous Token is an operator or type LBRACE
       * or we're at the beginning of the expression (prevToken == null) the current Token is
       * an unary plur or minus, so the tokentype has to be changed.
       */
      if ((curToken.type == TokenType.MINUS ||
              curToken.type == TokenType.PLUS) &&
          (prevToken == null ||
              prevToken.type.operator ||
              prevToken.type == TokenType.SEPAR ||
              prevToken.type == TokenType.LBRACE)) {
        final Token newToken = Token(
            curToken.text,
            curToken.type == TokenType.MINUS
                ? TokenType.UNMINUS
                : TokenType.UNPLUS);
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
      if (curToken.type.operator) {
        while (operatorBuffer.isNotEmpty &&
            ((curToken.type.leftAssociative &&
                    curToken.type.priority <=
                        operatorBuffer.last.type.priority) ||
                (!curToken.type.leftAssociative &&
                    curToken.type.priority <
                        operatorBuffer.last.type.priority))) {
          outputStream.add(operatorBuffer.removeLast());
        }
        operatorBuffer.add(curToken);
        prevToken = curToken;
        continue;
      }

      // If the current Token is a left brace, put it on the operator buffer.
      if (curToken.type == TokenType.LBRACE) {
        operatorBuffer.add(curToken);
        prevToken = curToken;
        continue;
      }

      // If the current Token is a right brace, empty the operator buffer until you find a left brace.
      if (curToken.type == TokenType.RBRACE) {
        while (operatorBuffer.isNotEmpty &&
            operatorBuffer.last.type != TokenType.LBRACE) {
          outputStream.add(operatorBuffer.removeLast());
        }

        // Expect next token on stack to be left parenthesis and pop it
        if (operatorBuffer.isEmpty ||
            operatorBuffer.removeLast().type != TokenType.LBRACE) {
          throw FormatException('Mismatched parenthesis.');
        }

        // If the token at the top of the stack is a function token, pop it onto the output queue.
        if (operatorBuffer.isNotEmpty && operatorBuffer.last.type.function) {
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
    while (operatorBuffer.isNotEmpty) {
      if (operatorBuffer.last.type == TokenType.LBRACE ||
          operatorBuffer.last.type == TokenType.RBRACE) {
        throw FormatException('Mismatched parenthesis.');
      }
      outputStream.add(operatorBuffer.removeLast());
    }

    return outputStream;
  }

  /// This method invokes the createTokenStream methode to create an infix token
  /// stream and then invokes the shunting yard method to transform this stream
  /// into a RPN (reverse polish notation) token stream.
  List<Token> tokenizeToRPN(String inputString) {
    final List<Token> infixStream = tokenize(inputString);
    return shuntingYard(infixStream);
  }
}

/// A Token consists of text and has a [TokenType].
class Token {
  /// The text of this token.
  final String text;

  /// The type of this token.
  final TokenType type;
  int argCount = 0;

  /// Creates a new Token with the given text and type.
  Token(this.text, this.type);

  /// Tokens equal, if they have equal text and types.
  @override
  bool operator ==(Object token) =>
      (token is Token) &&
      (token.text == this.text) &&
      (token.type == this.type);

  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + text.hashCode;
    result = 37 * result + type.hashCode;
    return result;
  }

  @override
  String toString() => '($type: $text)';
}

/// A token type. Access token types via the static fields.
///
/// For example, to access the token type PLUS:
///
///     plusType = TokenType.PLUS;
///
/// The type defines the `priority` (precedence) of the token.
///
///     (+,-) < (*,/) < (^) < functions < (-u)
///
/// It also defines the associativity of the token. True stands for
/// left-associative, false for right-associative.
class TokenType {
  // Variables and values
  static const TokenType VAR = TokenType._internal('VAR', 10);
  static const TokenType VAL = TokenType._internal('VAL', 10);

  // Braces and Separators
  static const TokenType LBRACE = TokenType._internal('LBRACE', -1);
  static const TokenType RBRACE = TokenType._internal('RBRACE', -1);
  static const TokenType SEPAR = TokenType._internal('SEPAR', -1);

  // Operators
  static const TokenType PLUS = TokenType._internal('PLUS', 1, operator: true);
  static const TokenType MINUS =
      TokenType._internal('MINUS', 1, operator: true);
  static const TokenType TIMES =
      TokenType._internal('TIMES', 2, operator: true);
  static const TokenType DIV = TokenType._internal('DIV', 2, operator: true);
  static const TokenType MOD = TokenType._internal('MOD', 2, operator: true);
  static const TokenType POW =
      TokenType._internal('POW', 4, leftAssociative: false, operator: true);
  static const TokenType UNMINUS =
      TokenType._internal('UNMINUS', 3, leftAssociative: false, operator: true);
  static const TokenType UNPLUS =
      TokenType._internal('UNPLUS', 3, leftAssociative: false, operator: true);

  // SGS added token
  static const TokenType LT =
  TokenType._internal('LT', 4, operator: true); // Lower than
  static const TokenType LTE =
  TokenType._internal('LTE', 5, operator: true, leftAssociative: false); // Lower than or equal


  // Functions
  static const TokenType FACTORIAL =
      TokenType._internal('FACTORIAL', 5, function: true);
  static const TokenType SQRT = TokenType._internal('SQRT', 5, function: true);
  static const TokenType ROOT = TokenType._internal('ROOT', 5, function: true);
  static const TokenType LOG = TokenType._internal('LOG', 5, function: true);
  static const TokenType LN = TokenType._internal('LN', 5, function: true);
  static const TokenType COS = TokenType._internal('COS', 5, function: true);
  static const TokenType SIN = TokenType._internal('SIN', 5, function: true);
  static const TokenType TAN = TokenType._internal('TAN', 5, function: true);
  static const TokenType ACOS = TokenType._internal('ACOS', 5, function: true);
  static const TokenType ASIN = TokenType._internal('ASIN', 5, function: true);
  static const TokenType ATAN = TokenType._internal('ATAN', 5, function: true);
  static const TokenType ABS = TokenType._internal('ABS', 5, function: true);
  static const TokenType CEIL = TokenType._internal('CEIL', 5, function: true);
  static const TokenType FLOOR =
      TokenType._internal('FLOOR', 5, function: true);
  static const TokenType SGN = TokenType._internal('SGN', 5, function: true);
  static const TokenType EFUNC =
      TokenType._internal('EFUNC', 5, function: true);
  static const TokenType FUNC = TokenType._internal('FUNC', 5, function: true);

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

  /// Internal constructor for a [TokenType].
  /// To retrieve a token type, directly access the static final fields
  /// provided by this class.
  const TokenType._internal(this.value, this.priority,
      {this.leftAssociative = true,
      this.operator = false,
      this.function = false});

  @override
  String toString() => value;
}
