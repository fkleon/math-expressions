part of '../math_expressions.dart';

/// This parser uses a grammar-based approach to parse the input and
/// build the expression.
///
/// It's possible to customise the default symbols and functions by subclassing
/// this parser. For example, to remove the constant 'e':
///
///     class MyGrammarParser extends GrammarParser {
///       MyGrammarParser([super.options]) {
///         constants.remove('e');
///       }
///     }
class GrammarParser implements ExpressionParser {
  late final pp.Parser<Expression> parser;

  /// Constants and their values.
  final constants = <String, num>{
    'e': math.e,
    'pi': math.pi,
    'ln10': math.ln10,
    'ln2': math.ln2,
    'log10e': math.log10e,
    'log2e': math.log2e,
    'sqrt1_2': math.sqrt1_2,
    'sqrt2': math.sqrt2,
  };

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
    'nrt': Root.new,
  };

  /// Dynamically defined algorithmic functions.
  final functionsC = <String, dynamic>{};

  /// Creates an expression from the given identifier, and list of arguments.
  /// May return a constant, function or variable.
  Expression _createBinding(String name, List<Expression> arguments) {
    switch (arguments.length) {
      // Check for Constant or Variable
      case 0:
        var val = constants[name];
        return (val != null) ? Number(val) : Variable(name);
      // Check for Function with one argument
      case 1:
        var fun1 = functions1[name];
        if (fun1 != null) {
          return fun1(arguments[0]);
        }
        continue custom;
      // Check for Function with two arguments
      case 2:
        var fun2 = functions2[name];
        if (fun2 != null) {
          return fun2(arguments[0], arguments[1]);
        }
        continue custom;
      // Check for Algorithmic function
      custom:
      default:
        var fun = functionsC[name];
        if (fun != null) {
          return AlgorithmicFunction(name, arguments, functionsC[name]);
        }
    }

    // No match
    throw ArgumentError.value(name);
  }

  /// Creates a new parser.
  /// The given [options] can be used to configure the behaviour.
  GrammarParser([ParserOptions options = const ParserOptions()]) {
    if (options.implicitMultiplication) {
      throw UnimplementedError(
          'Implicit multiplication is not supported by this parser');
    }

    this.constants.addAll(options.constants);

    final builder = ExpressionBuilder<Expression>();

    final constant =
        ChoiceParser(constants.keys.map((s) => s.toParser().trim()));

    final identifier = constant |
        ((letter() | char('\$')) & word().star())
            .flatten('Identifier expected')
            .trim();

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

    final number = (digit().plus() & (char('.') & digit().plus()).optional())
        .flatten('Number expected')
        .trim()
        .map(num.parse)
        .map(Number.new);

    // Numbers and variables
    builder
      // Numbers
      ..primitive(number)
      // Special case for exponential function notation of form `e^x`
      ..primitive(seq2(char('e').trim() & char('^').trim(), builder.loopback)
          .map2((_, exp) => Exponential(exp)))
      // Generic constants, functions or variables
      ..primitive(functionOrVariable)
      // Parenthesis to group terms
      ..group().wrapper(char('(').trim(), char(')').trim(), (l, e, r) => e)
      // Backwards compat: Curly braces to group function arguments
      ..group().wrapper(char('{').trim(), char('}').trim(), (l, e, r) => e);

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
