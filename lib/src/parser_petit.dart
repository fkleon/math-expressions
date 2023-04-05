part of '../math_expressions.dart';

class ExpressionParser {
  late final p.Parser parser;

  ExpressionParser() {
    final builder = ExpressionBuilder<Expression>();

    // Numbers and variables
    builder.group()
      ..primitive(digit()
          .plus()
          .seq(char('.').seq(digit().plus()).optional())
          .flatten()
          .trim()
          .map(num.parse)
          .map<Expression>((n) => Number(n)))
      ..primitive((letter() & word().star())
          .flatten()
          .trim()
          .map<Expression>((value) => Variable(value)))
      ..wrapper(char('(').trim(), char(')').trim(), (l, e, r) => e);

    // Binary operators (right associative)
    builder.group().right(char('^').trim(), (l, op, r) => Power(l, r));

    // Unary operators
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

    // Functions
    /*
    builder.group()
      ..primitive((letter().plus() & char('(') & letter().plus() & char(')'))
          .map((x) => CustomFunction(x[0], x.sublist(1), null)));
    */

    parser = builder.build().end();
  }

  Expression parse(String input) {
    Result<dynamic> result = parser.parse(input);
    if (result is Failure) {
      throw FormatException(result.message);
    } else {
      print(result.value);
      return result.value as Expression;
    }
  }
}
