import 'dart:math' as math;
import 'package:dart2_constant/math.dart' as math_polyfill;
import 'package:math_expressions/math_expressions.dart';

//TODO Documentation
void main() {
  //_expressionTest();
  //_evaluateTest();
  _example1();
  _example2();
  _example3();
}

/**
 * Example 1: Expression creation and evaluation
 */
void _example1() {
  // (1a) Parse expression:
  Parser p = new Parser();
  Expression exp = p.parse('(x^2 + cos(y)) / 3');

  // (1b) Build expression: (x^2 + cos(y)) / 3
  Variable x = new Variable('x'), y = new Variable('y');
  Power xSquare = new Power(x, 2);
  Cos yCos = new Cos(y);
  Number three = new Number(3.0);
  exp = (xSquare + yCos) / three;

  // (2) Bind variables:
  ContextModel cm = new ContextModel()
    ..bindVariable(x, new Number(2.0))
    ..bindVariable(y, new Number(math_polyfill.pi));

  // (3) Evaluate expression:
  double eval = exp.evaluate(EvaluationType.REAL, cm);

  print(eval); // = 1
}

/**
 * Example 2: Expression simplification and derivation
 */
void _example2() {
  Parser p = new Parser();
  Expression exp = p.parse('x*1 - (_5)');

  print(exp); // = ((x * 1.0) - -(5.0))
  print(exp.simplify()); // = (x + 5.0)

  Expression expDerived = exp.derive('x');

  print(expDerived); // = (((x * 0.0) + (1.0 * 1.0)) - -(0.0))
  print(expDerived.simplify()); // = 1.0
}

void _example3() {
  //TODO move to functional tests.
  Parser p = new Parser();
  Expression exp = p.parse('x * 2^2.5 * log(10,100)');

  print(exp);

  ContextModel cm = new ContextModel()..bindVariableName('x', new Number(1.0));

  double eval = exp.evaluate(EvaluationType.REAL, cm);
  print(eval);
}

void _expressionTest() {
  Expression x = new Variable('x'),
      a = new Variable('a'),
      b = new Variable('b'),
      c = new Variable('c');
  //Expression pow = new Power(x, new Number(2));
  //Expression e = a+b;
  //Expression e = a*pow+b*x+c;
  //Expression e = a*x*x+b*x+c;
  //print(e);
  //print(e.derive('x'));

  Expression exp = new Power('x', 2);
  Expression mul = new Times('x', 'x');

  print('exp: ${exp.toString()}');
  print('expD: ${exp.derive('x').toString()}');
  print('expDSimp: ${exp.derive('x').simplify().toString()}');
  print(
      'expDSimpDSimp: ${exp.derive('x').simplify().derive('x').simplify().toString()}');
  print('expDD: ${exp.derive('x').derive('x').toString()}');
  print('expDDSimp: ${exp.derive('x').derive('x').simplify().toString()}');

  print('mul: ${mul.toString()}');
  print('mulD: ${mul.derive('x').toString()}');
  print('mulDSimp: ${mul.derive('x').simplify().toString()}');

  Expression div = new Divide(exp, 'x');
  print('div: ${div.toString()}');
  print('divD: ${div.derive('x').toString()}');
  print('divDSimp: ${div.derive('x').simplify().toString()}');

  Expression log = new Log(new Number(10), exp);
  print('log: ${log.toString()}');
  print('logD: ${log.derive('x').toString()}');
  print('logDSimp: ${log.derive('x').simplify().toString()}');

  Expression expXY = x ^ a;
  print('expXY: ${expXY.toString()}');
  print('expXYD: ${expXY.derive('x').toString()}');
  print('expXYDsimp: ${expXY.derive('x').simplify().toString()}');

  Expression sqrt = new Sqrt(exp);
  print('sqrt: ${sqrt.toString()}');
  print('sqrtD: ${sqrt.derive('x').toString()}');
  print('sqrtDsimpl: ${sqrt.derive('x').simplify().toString()}');

  Expression root = new Root(5, exp);
  print('root: ${root.toString()}');
  print('rootD: ${root.derive('x').toString()}');
  print('rootDsimpl: ${root.derive('x').simplify().toString()}');

  Expression negate = -exp;
  print(negate);

  Expression vector = new Vector([x * new Number(1), div, exp]);
  print('vector: ${vector}');
  print('vectorS: ${vector.simplify()}');
  print('vectorSD: ${vector.simplify().derive('x')}');

  Expression logVar = new Log(new Number(11), new Variable('x'));
  print('logVar: ${logVar.toString()}');
  print('logVarD: ${logVar.derive('x').toString()}');

  Expression composite = new CompositeFunction(logVar, sqrt);
  print('composite: ${composite.toString()}');
  print('compositeD: ${composite.derive('x').toString()}');
  print('compositeDS: ${composite.derive('x').simplify().toString()}');

  Expression fExpr = new Vector([
    x,
    new Plus(x, 1),
    new Minus(x, 1)
  ]); // Transforms x to 3-dimensional vector
  MathFunction f = new CustomFunction('f', [x], fExpr); // R -> R^3
  Expression gExpr = x + a + b;
  MathFunction g = new CustomFunction('g', [x, a, b], gExpr); // R^3 -> R
  composite = new CompositeFunction(f, g); // R -> R

  print('composite2: ${composite.toString()}');
}

void _evaluateTest() {
  EvaluationType type = EvaluationType.REAL;
  ContextModel context = new ContextModel();

  Expression x = new Variable('x');
  Expression exp = new Power('x', 2);

  Expression mul = new Number(10) * new Number(5);
  _print('mul', mul);
  _print('mul =', mul.evaluate(type, context));

  context.bindVariable(x, new Number(2));
  Expression sqrt = new Sqrt(exp);
  print('sqrt: ${sqrt.toString()}');
  print('sqrtD: ${sqrt.derive('x').toString()}');
  print('sqrtDsimpl: ${sqrt.derive('x').simplify().toString()}');
  print(
      'sqrtDEval: ${sqrt.derive('x').simplify().evaluate(type, context).toString()}');
  print('sqrtEval: ${sqrt.evaluate(type, context).toString()}');

  Expression negate = -exp;
  print(negate.evaluate(type, context));

  Expression vector = new Vector([x * new Number(1), x, exp]);
  print('vector: ${vector}');
  print('vectorS: ${vector.simplify()}');
  print('vectorSD: ${vector.simplify().derive('x')}');
  print(
      'vectorS: ${vector.simplify().evaluate(EvaluationType.VECTOR, context)}');

  Expression interval1 = new IntervalLiteral(new Number(-1), new Number(4));
  Expression interval2 = new IntervalLiteral(new Number(5), new Number(10));

  Expression intAdd = (interval1 + interval2);
  Expression intMul = (interval1 * interval2);
  Expression intDiv = (interval2 / interval1);
  print('intAdd: ${intAdd}');
  print(
      'intAdd: ${intAdd.simplify().evaluate(EvaluationType.INTERVAL, context)}');
  print('intMul: ${intMul}');
  print(
      'intMul: ${intMul.simplify().evaluate(EvaluationType.INTERVAL, context)}');
  print('intDiv: ${intDiv}');
  try {
    // This should throw an exception (divide by 0)
    print(
        'intDiv: ${intDiv.simplify().evaluate(EvaluationType.INTERVAL, context)}');
  } catch (e) {
    // expected
  }
}

void _print(prefix, stuff) => print('$prefix: $stuff');
