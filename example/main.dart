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
  Parser p = Parser();
  Expression exp = p.parse('(x^2 + cos(y)) / 3');

  // (1b) Build expression: (x^2 + cos(y)) / 3
  Variable x = Variable('x'), y = Variable('y');
  Power xSquare = Power(x, 2);
  Cos yCos = Cos(y);
  Number three = Number(3.0);
  exp = (xSquare + yCos) / three;

  // Bind variables and evaluate the expression as real number.
  // (2) Bind variables:
  ContextModel cm = ContextModel()
    ..bindVariable(x, Number(2.0))
    ..bindVariable(y, Number(math.pi));

  // (3) Evaluate expression:
  double eval = exp.evaluate(EvaluationType.REAL, cm);

  print('Expression: $exp');
  print('Evaluated expression: $eval\n  (with context: $cm)'); // = 1
}

/// Example 2: Expression simplification and differentiation
///
/// How to simplify an expression, and how to differentiate it with respect
/// to a given variable.
void _expression_simplification_and_differentiation() {
  print('\nExample 2: Expression simplification and differentiation\n');

  // (1) Parse expression:
  Parser p = Parser();
  Expression exp = p.parse('x*1 - (-5)');

  // (2) Simplify expression:
  print('Expression: $exp'); // = ((x * 1.0) - -(5.0))
  print('Simplified expression: ${exp.simplify()}\n'); // = (x + 5.0)

  // (2) Differentiate expression with respect to variable 'x':
  Expression expDerived = exp.derive('x');

  print(
      'Differentiated expression: $expDerived'); // = (((x * 0.0) + (1.0 * 1.0)) - -(0.0))
  print(
      'Simplified differentiated expression: ${expDerived.simplify()}'); // = 1.0
}

/// Example 3: Custom function definition and use
///
/// How to create an arbitrary custom function expression and evaluate it.
void _custom_function_definition_and_use() {
  print('\nExample 3: Custom function definition and use\n');

  // (1) Create and evaluate custom function: DOUBLEUP (R -> R)
  ContextModel cm = ContextModel();
  Variable x = Variable('x');
  CustomFunction doubleup = CustomFunction('doubleup', [x], x * Number(2));

  cm.bindVariable(x, Number(0.5));

  print('$doubleup = ${doubleup.expression}');
  print(
      'doubleup(${cm.getExpression('x')}) = ${doubleup.evaluate(EvaluationType.REAL, cm)}\n');

  // (1) Create and evaluate custom function: LEFTSHIFT (R² -> R)
  // Shifting to the left makes the number larger, effectively multiplying the
  // number by pow(2, shiftIndex). Custom implementation of x << i.
  Variable shiftIndex = Variable('i');
  CustomFunction leftshift =
      CustomFunction('leftshift', [x, shiftIndex], x * Power(2, shiftIndex));

  cm.bindVariable(x, Number(250));
  cm.bindVariable(shiftIndex, Number(8));

  print('$leftshift = ${leftshift.expression}');
  print(
      'leftshift(${cm.getExpression('x')}, ${cm.getExpression('i')}) = ${leftshift.evaluate(EvaluationType.REAL, cm)}');
}

/// Example 4: Algorithmic function definition and use
///
/// How to create and parse an algorithmic function that's bound to a Dart handler.
void _algorithmic_function_definition_and_use() {
  print('\nExample 4: Algorithmic function definition and use\n');

  // (1) Create expression via parser by registering a function name
  Parser p = Parser();
  p.addFunction('my_min', (List<double> args) => args.reduce(math.min));
  Expression exp = p.parse('my_min(1, x, -1)');

  print('my_min(1, x, -1) = $exp');

  // (1) Evaluate algorithmic function: MY_MIN (R^3 -> R)
  ContextModel cm = ContextModel();
  Variable x = Variable('x');

  cm.bindVariable(x, -Number(2));

  double res = exp.evaluate(EvaluationType.REAL, cm);
  print('my_min(1, ${cm.getExpression('x')}, -1) = $res');
}
