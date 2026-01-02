import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

/// This file contains the following examples:
///  - Example 1: Expression creation and evaluation
///               (through the Parser and programmatically)
///  - Example 2: Expression simplification and differentiation
///  - Example 3: Custom function definition and use (function bound to expression)
///  - Example 4: Generic function definition and use (function bound to Dart handler)
void main() {
  _expression_creation_and_evaluation();
  _expression_simplification_and_differentiation();
  _custom_function_definition_and_use();
  _algorithmic_function_definition_and_use();
  _interval_and_vector_evaluation();
}

/// Example 1: Expression creation and evaluation
///
/// How to create an expression (a) via the Parser, (b) programmatically,
/// and how to evaluate an expression given a context.
void _expression_creation_and_evaluation() {
  print('\nExample 1: Expression creation and evaluation\n');

  // You can either create an mathematical expression programmatically or parse
  // a string.
  // (1a) Parse expression:
  ExpressionParser p = GrammarParser();
  Expression exp = p.parse('(x^2 + cos(y)) / 3');

  // (1b) Build expression: (x^2 + cos(y)) / 3
  var x = Variable('x'), y = Variable('y');
  var xSquare = Power(x, 2);
  var yCos = Cos(y);
  var three = Number(3.0);
  exp = (xSquare + yCos) / three;

  // Bind variables and evaluate the expression as real number.
  // (2) Bind variables:
  var context = ContextModel()
    ..bindVariable(x, Number(2.0))
    ..bindVariable(y, Number(math.pi));

  // (3) Evaluate expression:
  var evaluator = RealEvaluator(context);
  num eval = evaluator.evaluate(exp);

  print('Expression: $exp');
  print('Evaluated expression: $eval\n  (with context: $context)'); // = 1
}

/// Example 2: Expression simplification and differentiation
///
/// How to simplify an expression, and how to differentiate it with respect
/// to a given variable.
void _expression_simplification_and_differentiation() {
  print('\nExample 2: Expression simplification and differentiation\n');

  // (1) Parse expression:
  ExpressionParser p = GrammarParser();
  Expression exp = p.parse('x*1 - (-5)');

  // (2) Simplify expression:
  print('Expression: $exp'); // = ((x * 1.0) - -(5.0))
  print('Simplified expression: ${exp.simplify()}\n'); // = (x + 5.0)

  // (2) Differentiate expression with respect to variable 'x':
  Expression expDerived = exp.derive('x');

  print(
    'Differentiated expression: $expDerived',
  ); // = (((x * 0.0) + (1.0 * 1.0)) - -(0.0))
  print(
    'Simplified differentiated expression: ${expDerived.simplify()}',
  ); // = 1.0
}

/// Example 3: Custom function definition and use
///
/// How to create an arbitrary custom function expression and evaluate it.
void _custom_function_definition_and_use() {
  print('\nExample 3: Custom function definition and use\n');

  // (1) Create and evaluate custom function: DOUBLEUP (R -> R)
  var context = ContextModel();
  var evaluator = RealEvaluator(context);
  var x = Variable('x');
  CustomFunction doubleup = CustomFunction('doubleup', [x], x * Number(2));

  context.bindVariable(x, Number(0.5));

  print('$doubleup = ${doubleup.expression}');
  print(
    'doubleup(${context.getExpression('x')}) = ${evaluator.evaluate(doubleup)}\n',
  );

  // (1) Create and evaluate custom function: LEFTSHIFT (R² -> R)
  // Shifting to the left makes the number larger, effectively multiplying the
  // number by pow(2, shiftIndex). Custom implementation of x << i.
  var shiftIndex = Variable('i');
  CustomFunction leftshift = CustomFunction('leftshift', [
    x,
    shiftIndex,
  ], x * Power(2, shiftIndex));

  context.bindVariable(x, Number(250));
  context.bindVariable(shiftIndex, Number(8));

  print('$leftshift = ${leftshift.expression}');
  print(
    'leftshift(${context.getExpression('x')}, ${context.getExpression('i')}) = ${evaluator.evaluate(leftshift)}',
  );
}

/// Example 4: Algorithmic function definition and use
///
/// How to create and parse an algorithmic function that's bound to a Dart handler.
void _algorithmic_function_definition_and_use() {
  print('\nExample 4: Algorithmic function definition and use\n');

  // (1) Create expression via parser by registering a function name
  ExpressionParser p = GrammarParser();
  p.addFunction('my_min', (List<double> args) => args.reduce(math.min));
  Expression exp = p.parse('my_min(1, x, -1)');

  print('my_min(1, x, -1) = $exp');

  // (1) Evaluate algorithmic function: MY_MIN (R^3 -> R)
  var context = ContextModel();
  var evaluator = RealEvaluator(context);
  var x = Variable('x');

  context.bindVariable(x, -Number(2));

  num res = evaluator.evaluate(exp);
  print('my_min(1, ${context.getExpression('x')}, -1) = $res');
}

/// Example 5: Interval and vector evaluation
///
/// Demonstrates how to evaluate the same expression under interval and vector contexts.
void _interval_and_vector_evaluation() {
  print('\nExample 5: Interval and vector evaluation\n');

  final parser = GrammarParser();

  // Interval example: sqrt(x) + y, where x and y are ranges.
  final intervalExpression = parser.parse('nrt(2, x) + y');
  final intervalContext = ContextModel()
    ..bindVariableName('x', IntervalLiteral(Number(4), Number(9)))
    ..bindVariableName('y', IntervalLiteral(Number(-1), Number(2)));
  final intervalEvaluator = IntervalEvaluator(intervalContext);
  final Interval intervalResult = intervalEvaluator.evaluate(
    intervalExpression,
  );
  print('Interval result: $intervalResult');

  // Vector example: (a * 2) + b, where a and b are 3D vectors.
  final vectorExpression = parser.parse('(a * 2) + b');
  final vectorContext = ContextModel()
    ..bindVariableName('a', Vector([Number(1), Number(2), Number(3)]))
    ..bindVariableName('b', Vector([Number(-1), Number(0), Number(4)]));
  final vectorEvaluator = VectorEvaluator(vectorContext);
  final Vector3 vectorResult =
      vectorEvaluator.evaluate(vectorExpression) as Vector3;
  print('Vector result: $vectorResult');
}
