# math_expressions

A library for parsing and evaluating mathematical expressions.

* Performs evaluations in real, vector, and [interval][bohlender2010] contexts.
* Supports expression simplification and differentiation.

math_expressions is inspired by [mathExpr][] for Java and distributed under the
[MIT license][LICENSE].

## Features

* Evaluation of expressions in various modes: Real, Vector and [Interval][bohlender2010].
* Parsing, simplification and differentiation of mathematical expressions.
* Supporting most [basic math functions][defaultFunctions] out of the box.
* Extensible through custom function definitions in code.
* Well [documented][dartdoc] and tested.

This package contains a very simple [command-line interpreter](bin/interpreter.dart)
for real numbers:

    dart pub run math_expressions:interpreter

### What's not working yet?

* Some evaluations in vector and interval space (especially functions).
* N-dimensional vectors. Curently no more than four dimensions are supported.
* The parser only works for real numbers.
* Complex numbers.

Suggestions and pull requests are always welcome!

## Usage

Below are two basic examples of how to use this library. There also is some [additional example code](example/main.dart) available.

### Evaluation modes

`math_expressions` ships three evaluator implementations. Pick the evaluator that matches the numeric space you care about and keep the rest of the pipeline (parser, context binding, expression tree) the same.

| Mode    | Evaluator           | Result type                       | Typical use case |
|---------|---------------------|-----------------------------------|------------------|
| Real    | `RealEvaluator`     | `num`                             | Deterministic scalar calculations |
| Interval| `IntervalEvaluator` | `Interval` (`[min, max]`)         | Error propagation, value ranges |
| Vector  | `VectorEvaluator`   | `double`, `Vector2`, `Vector3`, `Vector4` | Working with 2D/3D/4D vectors |

Each evaluator consumes the same expression tree but interprets literals differently. The usual workflow looks like this:

```dart
final parser = GrammarParser();
final Expression exp = parser.parse('sin(x) + y');

final context = ContextModel()
  ..bindVariableName('x', Number(math.pi / 2))
  ..bindVariableName('y', Number(1));

final evaluator = RealEvaluator(context); // swap for IntervalEvaluator or VectorEvaluator
final result = evaluator.evaluate(exp);
```

The following sections expand on the available evaluation modes with concrete examples.

### 1. Expression creation and evaluation (real numbers)

This example shows how to evaluate

$\frac{(x^2+\cos y)}{3}$


for $x=2, y=\pi$

#### Build the expression

You can either create an mathematical expression programmatically or parse a string.

* Create the expression programmatically:
```dart
  var x = Variable('x'), y = Variable('y');
  var xSquare = Power(x, 2);
  var yCos = Cos(y);
  var three = Number(3.0);
  Expression exp = (xSquare + yCos) / three;
```

* Create the expression via the parser:
```dart
  ExpressionParser p = GrammarParser();
  Expression exp = p.parse("(x^2 + cos(y)) / 3");
```

#### Evaluate the expression

* Bind variables and evaluate the expression as real number:
```dart
  // Bind variables:
  var context = ContextModel()
    ..bindVariableName('x', Number(2.0));
    ..bindVariableName('y', Number(math.pi));

  // Evaluate expression:
  var evaluator = RealEvaluator(context);
  num eval = evaluator.evaluate(exp);

  print(eval) // = 1.0
```

### 2. Expression simplification and differentiation

This example shows how to simplify and differentiate

$x \cdot 1 - (-5)$

* Expressions can be simplified and differentiated with respect to a given variable:
```dart
  Expression exp = p.parse("x*1 - (-5)");

  print(exp);            // = ((x * 1.0) - -(5.0))
  print(exp.simplify()); // = (x + 5.0)

  Expression expDerived = exp.derive('x');

  print(expDerived);            // = (((x * 0.0) + (1.0 * 1.0)) - -(0.0))
  print(expDerived.simplify()); // = 1.0
```

### 3. Working with intervals

Interval evaluation propagates ranges through every operation and yields an `Interval` object whose `min`/`max` describe all possible outcomes for the given variable bounds. You build ranges with `IntervalLiteral` (or by binding variables to other expressions that produce intervals) and evaluate with `IntervalEvaluator`.

```dart
final parser = GrammarParser();
final exp = parser.parse('nrt(2, x) + y'); // sqrt(x) + y

final context = ContextModel()
  ..bindVariableName('x', IntervalLiteral(Number(4), Number(9)))
  ..bindVariableName('y', IntervalLiteral(Number(-1), Number(2)));

final intervalEval = IntervalEvaluator(context);
final Interval result = intervalEval.evaluate(exp);
print(result); // Interval(1.0, 5.0)
```

**What works today**

* Basic arithmetic operators, powers with natural exponents, `e^x`, `ln`, `log`, `sqrt`/`nrt` and other algebraic combinations.
* Interval literals created from concrete bounds or derived expressions.

**Current limitations and gotchas**

* Many functions are not implemented yet (trigonometric, inverse trig, factorial, `abs`, etc.). They currently throw `UnsupportedError` or `UnimplementedError`. See `test/evaluator_interval_test_set.dart` for the latest status.
* Exponents are expected to evaluate to natural numbers; fractional or symbolic exponents are not supported in interval mode.
* Vector literals are not yet consumable by `IntervalEvaluator`.

### 4. Working with vectors

Vector evaluation interprets `Vector` literals with 2, 3, or 4 elements as `Vector2`, `Vector3`, or `Vector4` from `package:vector_math`. Mixed scalar/vector arithmetic is limited to the combinations implemented inside `VectorEvaluator` (vector ± vector, scalar on the right-hand side for multiplication/division).

```dart
final parser = GrammarParser();
final exp = parser.parse('(a * 2) + b');

final context = ContextModel()
  ..bindVariableName('a', Vector([Number(1), Number(2), Number(3)]))
  ..bindVariableName('b', Vector([Number(-1), Number(0), Number(4)]));

final vectorEval = VectorEvaluator(context);
final Vector3 result = vectorEval.evaluate(exp) as Vector3;
print(result); // Vector3(1.0, 4.0, 10.0)
```

**What to keep in mind**

* Vectors must have between 2 and 4 components; a single-element vector collapses to a scalar, and longer vectors throw `UnsupportedError`.
* For multiplication/division, scalars must appear on the **right-hand side** (`vector * scalar`, `vector / scalar`). The opposite order currently throws an `ArgumentError`.
* Non-vector-aware functions (e.g., `sin`, `log`) cannot consume vectors directly—evaluate each component separately or map vectors back to scalars before applying such functions.

## Alternatives

Here are some other Dart libraries that implement similar functionality to
math_expression: parsing and evaluating mathematical expressions.

* [expressions][]: an elegant and small library to parse and evaluate simple
  expressions.
* [function_tree][]: a library for parsing, evaluating and plotting single- and
  multi-variables numerical functions.

To the author's knowledge math_expressions is currently the only library
supporting interval arithmetics.

[mathExpr]: https://www3.math.tu-berlin.de/geometrie/jtem/mathExpr/ "The mathExpr library provides classes to parse and evaluate mathematical expressions."
[bohlender2010]: https://interval.louisiana.edu/reliable-computing-journal/volume-15/no-1/reliable-computing-15-pp-36-42.pdf "Deﬁnition of the Arithmetic Operations and Comparison Relations for an Interval Arithmetic Standard, PDF"
[license]: LICENSE "MIT LICENSE"
[expressions]: https://pub.dartlang.org/packages/expressions "A library to parse and evaluate simple expressions."
[function_tree]: https://pub.dartlang.org/packages/function_tree "A library for parsing and evaluating numerical functions built from strings."
[dartdoc]: https://pub.dartlang.org/documentation/math_expressions/latest/
[defaultFunctions]: https://pub.dartlang.org/documentation/math_expressions/latest/math_expressions/DefaultFunction-class.html
