part of '../math_expressions.dart';

/// This parser uses a grammar-based approach to parse the input and
/// build the expression.
class GrammarParser implements ExpressionParser {
  late final pp.Parser<Expression> parser;

  /// Constants and their values.
  final constants = {'e': math.e, 'pi': math.pi};

  /// Functions with one argument.
  final functions1 = {
    'ln': Ln.new,
    'sqrt': Sqrt.new,
    'cos': Cos.new,
    'sin': Sin.new,
    'tan': Tan.new,
    'arccos': Acos.new,
    'arcsin': Asin.new,
    'arctan': Atan.new,
    'abs': Abs.new,
    'sgn': Sgn.new,
    'e': Exponential.new,
    'ceil': Ceil.new,
    'floor': Floor.new,
  };

  /// Functions with two arguments.
  final functions2 = {
    'log': Log.new,
    //'nrt': Root.fromExpr,
  };

  /// Dynamically defined algorithmic functions.
  final functionsC = <String, dynamic>{};

  /// Creates an expression from the given identifier, and list of arguments.
  /// May return a constant, function or variable.
  Expression _createBinding(String name, List<Expression> arguments) {
    switch (arguments.length) {
      // Check for Constant
      case 0:
        if (constants.containsKey(name)) {
          return Number(constants[name]!);
        }
      // Check for Function with one argument
      case 1:
        if (functions1.containsKey(name)) {
          return functions1[name]!(arguments[0]);
        }
        continue custom;
      // Check for Function with two arguments
      case 2:
        if (functions2.containsKey(name)) {
          return functions2[name]!(arguments[0], arguments[1]);
        }
        continue custom;
      // Check for Algorithmic function
      custom:
      default:
        if (functionsC.containsKey(name)) {
          return AlgorithmicFunction(name, arguments, functionsC[name]);
        }
    }

    // No function match, return Variable
    return Variable(name);
  }

  /// Creates a new parser.
  /// The given [options] can be used to configure the behaviour.
  GrammarParser([ParserOptions options = const ParserOptions()]) {
    if (options.implicitMultiplication) {
      throw UnimplementedError(
          'Implicit multiplication is not supported by this parser');
    }

    final builder = ExpressionBuilder<Expression>();

    final identifier =
        ((letter() | char('\$')) & word().star()).flatten().trim();

    final arguments = seq3(
            char('('),
            builder.loopback
                .starSeparated(char(','))
                .map((args) => args.elements),
            char(')'))
        .map3((_, args, __) => args)
        .optionalWith(const <Expression>[]);

    final functionOrVariable = seq2(identifier, arguments)
        .map2((name, args) => _createBinding(name, args));

    // Numbers and variables
    builder
      // Numbers
      ..primitive(digit()
          .plus()
          .seq(char('.').seq(digit().plus()).optional())
          .flatten()
          .trim()
          .map(num.parse)
          .map<Expression>((n) => Number(n)))
      // Special case for exponential function notation of form `e^x`
      ..primitive(seq2(char('e').trim() & char('^').trim(), builder.loopback)
          .map2((_, exp) => Exponential(exp)))
      // Generic constants, functions or variables
      ..primitive(functionOrVariable)
      // Parenthesis to group terms
      ..group().wrapper(char('(').trim(), char(')').trim(), (l, e, r) => e);

    // Binary operators (right associative)
    builder.group().right(char('^').trim(), (l, op, r) => Power(l, r));

    // Unary operators
    builder.group().postfix(char('!').trim(), (e, op) => Factorial(e));

    builder.group()
      ..prefix(char('-').trim(), (op, e) => UnaryMinus(e))
      ..prefix(char('+').trim(), (op, e) => UnaryPlus(e));

    // Binary operators (left associative)
    builder.group().left(char('%').trim(), (l, op, r) => Modulo(l, r));
    builder.group()
      ..left(char('*').trim(), (l, op, r) => Times(l, r))
      ..left(char('/').trim(), (l, op, r) => Divide(l, r));
    builder.group()
      ..left(char('+').trim(), (l, op, r) => Plus(l, r))
      ..left(char('-').trim(), (l, op, r) => Minus(l, r));

    parser = builder.build().end();
  }

  @override
  Expression parse(String input) {
    Result<Expression> result = parser.parse(input);
    if (result is Failure) {
      throw FormatException(result.message);
    } else {
      return result.value;
    }
  }

  @override
  void addFunction(String name, dynamic handler, {bool replace = false}) {
    if (functionsC.containsKey(name) && !replace) {
      throw FormatException('Cannot redefine existing function $name');
    }
    functionsC[name] = handler;
  }
}
