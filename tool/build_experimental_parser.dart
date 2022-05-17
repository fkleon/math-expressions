import 'package:math_expressions/math_expressions.dart';
import 'package:parser_builder/branch.dart';
import 'package:parser_builder/bytes.dart';
import 'package:parser_builder/char_class.dart';
import 'package:parser_builder/character.dart';
import 'package:parser_builder/combinator.dart';
import 'package:parser_builder/error.dart';
import 'package:parser_builder/expression.dart';
import 'package:parser_builder/fast_build.dart';
import 'package:parser_builder/memoization.dart';
import 'package:parser_builder/multi.dart';
import 'package:parser_builder/parser_builder.dart';
import 'package:parser_builder/sequence.dart';

Future<void> main(List<String> args) async {
  final context = Context();
  await fastBuild(
      context, [_parse, _refExpression], 'lib/src/experimental_parser.dart',
      header: __header, footer: __footer);
}

const __footer = r'''
Expression _toBinary(Expression left, String op, Expression right) {
  switch (op) {
    case '+':
      return left + right;
    case '-':
    case '−':
      return left - right;
    case '*':
    case '×':
      return left * right;
    case '/':
    case '÷':
      return left / right;
    case '%':
      return left % right;
    case '^':
      return left ^ right;
    default:
      throw "Unsupported binary operation '$op'";
  }
}

Expression _toFunction(
    State<String> state, Result2<String, List<Expression>> declaration) {
  final name = declaration.$0;
  final arguments = declaration.$1;
  Expression func(bool condition, Expression Function() f) {
    if (condition) {
      return f();
    } else {
      throw StateError('Invalid number of arguments or their type: $name');
    }
  }

  final length = arguments.length;
  switch (name) {
    case 'abs':
      return func(length == 1, () => Abs(arguments[0]));
    case 'arccos':
      return func(length == 1, () => Acos(arguments[0]));
    case 'arcsin':
      return func(length == 1, () => Asin(arguments[0]));
    case 'arctan':
      return func(length == 1, () => Atan(arguments[0]));
    case 'ceil':
      return func(length == 1, () => Ceil(arguments[0]));
    case 'cos':
      return func(length == 1, () => Cos(arguments[0]));
    case 'e^':
      return func(length == 1, () => Exponential(arguments[0]));
    case 'floor':
      return func(length == 1, () => Floor(arguments[0]));
    case 'ln':
      return func(length == 1, () => Ln(arguments[0]));
    case 'log':
      return func(length == 2, () => Log(arguments[0], arguments[1]));
    case 'nrt':
      return func(length == 2 && arguments[0] is Number,
          () => Root.fromExpr(arguments[0] as Number, arguments[1]));
    case 'sgn':
      return func(length == 1, () => Sgn(arguments[0]));
    case 'sin':
      return func(length == 1, () => Sin(arguments[0]));
    case 'sqrt':
      return func(length == 1, () => Sqrt(arguments[0]));
    case 'tan':
      return func(length == 1, () => Tan(arguments[0]));
    default:
      final context = state.context as _Context;
      final handlers = context.handlers;
      var handler = handlers[name];
      handler ??= (List arguments) =>
          throw StateError('Function Handler not found: $name');
      return AlgorithmicFunction(name, arguments, handler);
  }
}

Expression _toPostfix(Expression expression, String operand) {
  switch (operand) {
    case '!':
      return Factorial(expression);
    case '°':
      if (expression is Number) {
        return Number((expression.value as num) * 3.141592653589793 / 180);
      } else {
        return expression * Number(3.141592653589793 / 180);
      }
  }
  throw StateError('Unknown postfix operator: $operand');
}

Expression _toUnary(String operand, Expression expression) {
  switch (operand) {
    case '-':
      return -expression;
    case '−':
      return -expression;
    case '√':
      return Sqrt(expression);
    case '∛':
      return Root.fromExpr(Number(3), expression);
    case '∜':
      return Root.fromExpr(Number(4), expression);
  }
  throw StateError('Unknown unary operator: $operand');
}

bool _verifyArguments(Result2<String, List<Expression>> declaration) {
  final name = declaration.$0;
  final arguments = declaration.$1;
  switch (name) {
    case 'abs':
    case 'arccos':
    case 'arcsin':
    case 'arctan':
    case 'ceil':
    case 'cos':
    case 'e^':
    case 'floor':
    case 'ln':
    case 'sgn':
    case 'sin':
    case 'sqrt':
    case 'tan':
      return arguments.length == 1;
    case 'log':
      return arguments.length == 2;
    case 'nrt':
      return arguments.length == 2 && arguments[0] is Number;
    default:
      return true;
  }
}

class _Context {
  final Map<String, Function> handlers;

  _Context({required this.handlers});
}
''';

const __header = r'''
import 'package:math_expressions/math_expressions.dart';

Expression parseString(String source,
    {Map<String, Function> handlers = const {}}) {
  final state = State(source);
  state.context = _Context(handlers: handlers);
  final result = _parse(state);
  if (!state.ok) {
    final message = _errorMessage(source, state.errors);
    throw FormatException('\n$message');
  }

  return result!;
}

Expression? parse(State<String> state,
    {Map<String, Function> handlers = const {}}) {
  state.context = _Context(handlers: handlers);
  return _parse(state);
}''';

const _additive = Named(
    '_additive',
    BinaryExpression(_multiplicative, _additiveOperator, _multiplicative,
        _toBinaryExpession));

const _additiveOperator =
    Named('_additiveOperator', Terminated(Tags(['+', '-', '−']), _ws));

const _argumentList = Named('_argumentList',
    SeparatedList0(_expression, Silent<String, dynamic>(_comma)));

const _arguments = Named(
    '_arguments',
    Nested('function arguments',
        Delimited(_openParen, _argumentList, _closeParen)));

const _closeParen = Named('_closeParen', Tag(')'));

const _comma = Named('_comma', Terminated(Tag(','), _ws));

const _constantExpression = Named(
    '_constantExpression',
    Alt3(
      _constantPi,
      _constantInfinity,
      _constantNegativeInfinity,
    ));

const _constantInfinity = Named<String, Expression>(
    '_constantInfinity',
    Preceded(
        Tag('∞'),
        Calculate(
            ExpressionAction<Expression>([], 'Number(double.infinity)'))));

const _constantNegativeInfinity = Named<String, Expression>(
    '_constantNegativeInfinity',
    Preceded(
        Tags(['-∞', '−∞']),
        Calculate(ExpressionAction<Expression>(
            [], 'Number(double.negativeInfinity)'))));

const _constantPi = Named<String, Expression>(
    '_constantPi',
    Preceded(
        Tag('π'),
        Calculate(
            ExpressionAction<Expression>([], 'Number(3.141592653589793)'))));

const _decimal = Named(
    '_decimal',
    Nested(
        'decimal number',
        Map1(Recognize(Tuple3(_memoizedDigits, Silent(Tag('.')), _digits)),
            ExpressionAction<Expression>(['x'], 'Number(num.parse({{x}}))'))));

const _digits = Named('_digit1', Digit1());

const _eof = Named('_eof', Eof<String>());

const _exponentialExpression = Named(
  '_exponentialExpression',
  Alt2(_exponentialOperation, _exponentialFunction),
);

const _exponentialFunction = Named(
    '_exponentialFunction',
    Map1(
        Verify(_wrongNumberOfArguments, Pair(_exponentialLiteral, _arguments),
            ExpressionAction<bool>(['x'], '_verifyArguments({{x}})')),
        ExpressionAction<Expression>(['x'], '_toFunction(state, {{x}})')));

const _exponentialLiteral = Terminated(Tag('e^'), _ws);

const _exponentialOperation = Named(
    '_exponentialOperation',
    Map2(Fast(_exponentialLiteral), _number,
        ExpressionAction<Expression>(['x'], 'Exponential({{x}})')));

const _expression = Ref<String, Expression>('_expression');

const _functionInvocation = Named(
    '_functionInvocation',
    Map1(
        Verify(_wrongNumberOfArguments, Pair(_memoizedIdentifier, _arguments),
            ExpressionAction<bool>(['x'], '_verifyArguments({{x}})')),
        ExpressionAction<Expression>(['x'], '_toFunction(state, {{x}})')));

const _identifier = Named(
    '_identifier',
    Terminated(
        IdentifierExpression(_reservedWords, _isIdentStart, _isIdentEnd), _ws));

const _integer = Named(
    '_integer',
    Expected(
        'integer',
        Map1(Recognize(_memoizedDigits),
            ExpressionAction<Expression>(['x'], 'Number(int.parse({{x}}))'))));

const _isIdentEnd = CharClasses([_isIdentStart, CharClass('[0-9_]')]);

const _isIdentStart = CharClass('[a-zA-Z]');

const _memoizedDigits = Memoize(_digits);

const _memoizedIdentifier = Memoize(_identifier);

const _multiplicative = Named(
    '_multiplicative',
    BinaryExpression(_postfixExpression, _multiplicativeOperator,
        _postfixExpression, _toBinaryExpession));

const _multiplicativeOperator = Named('_multiplicativeOperator',
    Terminated(Tags(['*', '×', '/', '÷', '%', '^']), _ws));

const _number = Named('_number', Nested('number', Alt2(_decimal, _integer)));

const _openParen = Named('_openParen', Terminated(Tag('('), _ws));

const _parse = Named('_parse', Delimited(_ws, _expression, _eof));

const _postfixExpression = Named(
    '_postfixExpression',
    PostfixExpression(
        _unaryExpression,
        _postfixOperator,
        ExpressionAction<Expression>(
            ['expr', 'op'], '_toPostfix({{expr}}, {{op}})')));

const _postfixOperator =
    Named('_postfixOperator', Terminated(Tags(['!', '°']), _ws));

const _primaryExpression = Named(
    '_primaryExpression',
    Terminated(
        Nested(
            'expression',
            Alt6(
              _exponentialExpression,
              _constantExpression,
              _functionInvocation,
              _variable,
              _number,
              Delimited(_openParen, _expression, _closeParen),
            )),
        _ws));

const _refExpression = Named<String, Expression>('_expression', _additive);

const _reservedWords = <String>[
  /*
  'abs',
  'arccos',
  'arcsin',
  'arctan',
  'ceil',
  'cos',
  'e',
  'floor',
  'log',
  'ln',
  'nrt',
  'sgn',
  'sin',
  'sqrt',
  'tan',
  */
];

const _toBinaryExpession = ExpressionAction<Expression>(
    ['left', 'op', 'right'], '_toBinary({{left}}, {{op}}, {{right}})');

const _unaryExpression = Named(
    '_unaryExpression',
    PrefixExpression(
        _unaryOperator,
        _primaryExpression,
        ExpressionAction<Expression>(
            ['op', 'expr'], '_toUnary({{op}}, {{expr}})')));

const _unaryOperator =
    Named('_unaryOperator', Terminated(Tags(['-', '−', '√', '∛', '∜']), _ws));

const _variable = Named(
    '_variable',
    Map1(_memoizedIdentifier,
        ExpressionAction<Expression>(['x'], 'Variable({{x}})')));

const _wrongNumberOfArguments = 'Wrong number or types of arguments';

const _ws = Named('_ws', SkipWhile(CharClass('#x9 | #xA | #xD | #x20')));
