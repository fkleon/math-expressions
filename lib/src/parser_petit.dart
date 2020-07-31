part of math_expressions;

class ExpressionParser {
  late final p.Parser parser;

  ExpressionParser() {
    final builder = ExpressionBuilder();

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
      ..wrapper<String, Expression>(
          char('(').trim(), char(')').trim(), (l, e, r) => e);

    // Unary operators
    builder.group()
      ..prefix<String, Expression>(char('-').trim(), (op, e) => UnaryMinus(e));

    // Binary operators (right associative)
    builder.group()
      ..right<String, Expression>(char('^').trim(), (l, op, r) => Power(l, r));

    // Binary operators (left associative)
    builder.group()
      ..left<String, Expression>(char('%').trim(), (l, op, r) => Modulo(l, r));
    builder.group()
      ..left<String, Expression>(char('*').trim(), (l, op, r) => Times(l, r))
      ..left<String, Expression>(char('/').trim(), (l, op, r) => Divide(l, r));
    builder.group()
      ..left<String, Expression>(char('+').trim(), (l, op, r) => Plus(l, r))
      ..left<String, Expression>(char('-').trim(), (l, op, r) => Minus(l, r));

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
    if (result.isFailure) {
      throw FormatException(result.message);
    } else {
      print(result.value);
      return result.value as Expression;
    }
  }
}
