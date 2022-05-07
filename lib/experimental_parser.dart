import 'math_expressions.dart';
import 'src/experimental_parser.dart' as parser;

class Parser2 implements Parser {
  static const _reservedWords = {
    'nrt',
    'sqrt',
    'log',
    'cos',
    'sin',
    'tan',
    'arccos',
    'arcsin',
    'arctan',
    'abs',
    'ceil',
    'floor',
    'sgn',
    'ln'
  };

  @override
  Map<String, dynamic> functionHandlers = <String, dynamic>{};

  @override
  Lexer get lex => throw UnimplementedError();

  @override
  void addFunction(String name, dynamic handler) {
    if (handler is! Function) {
      throw ArgumentError.value(handler, 'handler', "Must be 'Function'");
    }

    if (functionHandlers.containsKey(name) && _reservedWords.contains(name)) {
      throw FormatException('Cannot redefine existing function $name');
    }

    functionHandlers[name] = handler;
  }

  @override
  Expression parse(String inputString) {
    final result =
        parser.parseString(inputString, handlers: functionHandlers.cast());
    return result;
  }
}
