# math_expressions

A library for parsing and evaluating mathematical expressions.

* Performs evaluations in real, vector, and [interval][bohlender2010] contexts.
* Supports expression simplification and differentiation.

math_expressions is inspired by [mathExpr][] for Java and distributed under the MIT license as described in the [LICENSE][] file.

## Features

* Evaluation of expressions in various modes: Real, Vector and [Interval][bohlender2010].
* Parsing, simplification and differentiation of mathematical expressions.
* Supporting most [basic math functions][defaultFunctions] out of the box.
* Extensible through custom function definitions in code.
* Well [documented][dartdoc] and tested.

This package contains a very simple [command-line interpreter](bin/interpreter.dart) for real numbers:

    pub run math_expressions:interpreter

### What's not working yet?

* Some evaluations in vector and interval space (especially functions).
* N-dimensional vectors. Curently no more than four dimensions are supported.
* The parser only works for real numbers.
* Complex numbers.

Suggestions and pull requests are always welcome!

## Examples

Below are two basic examples of how to use this library. There also is some [additional example code](example/main.dart).

### 1. Expression creation and evaluation

This example shows how to evaluate

![Equation 1][exampleEq1]

for
![xy][exampleEq1xy]

#### Build the expression

You can either create an mathematical expression programmatically or parse a string.

* Create the expression programmatically:
```dart
  Variable x = new Variable('x'), y = new Variable('y');
  Power xSquare = new Power(x, 2);
  Cos yCos = new Cos(y);
  Number three = new Number(3.0);
  Expression exp = (xSquare + yCos) / three;
```

* Create the expression via the parser:
```dart
  Parser p = new Parser();
  Expression exp = p.parse("(x^2 + cos(y)) / 3");
```

#### Evaluate the expression

* Bind variables and evaluate the expression as real number:
```dart
  // Bind variables:
  ContextModel cm = new ContextModel();
  cm.bindVariable(x, new Number(2.0));
  cm.bindVariable(y, new Number(Math.PI));

  // Evaluate expression:
  double eval = exp.evaluate(EvaluationType.REAL, cm);

  print(eval) // = 1.0
```

### 2. Expression simplification and differentiation

This example shows how to simplify and differentiate

![Example 2][exampleEq2]

* Expressions can be simplified and differentiated with respect to a given variable:
```dart
  Expression exp = p.parse("x*1 - (-5)");

  print(exp);            // = ((x * 1.0) - -(5.0))
  print(exp.simplify()); // = (x + 5.0)

  Expression expDerived = exp.derive('x');

  print(expDerived);            // = (((x * 0.0) + (1.0 * 1.0)) - -(0.0))
  print(expDerived.simplify()); // = 1.0
```

[mathExpr]: https://www3.math.tu-berlin.de/geometrie/jtem/mathExpr/
[bohlender2010]: https://interval.louisiana.edu/reliable-computing-journal/volume-15/no-1/reliable-computing-15-pp-36-42.pdf "Deﬁnition of the Arithmetic Operations and Comparison Relations for an Interval Arithmetic Standard, PDF"
[license]: LICENSE
[dartdoc]: https://pub.dartlang.org/documentation/math_expressions/latest/
[defaultFunctions]: https://pub.dartlang.org/documentation/math_expressions/latest/math_expressions/DefaultFunction-class.html
[exampleEq1]: https://latex.codecogs.com/gif.latex?%28x%5E2%2Bcos%28y%29%29%2F3
[exampleEq1xy]: https://latex.codecogs.com/gif.latex?x%3D2%2Cy%3D%5Cpi
[exampleEq2]: https://latex.codecogs.com/gif.latex?x*1-%28-5%29
