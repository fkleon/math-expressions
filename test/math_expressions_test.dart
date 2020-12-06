library math_expressions_test;

import 'dart:math' as math;

import 'package:test/test.dart';
import 'package:vector_math/vector_math.dart' show Vector3;
import 'package:math_expressions/math_expressions.dart';

import 'test_framework.dart';

part 'algebra_test_set.dart';
part 'expression_test_set.dart';
part 'parser_test_set.dart';

/// relative accuracy for floating-point calculations
const num EPS = 0.000001;

/// Registers all math test sets and executes the test suite afterwards.
void main() {
  final List<TestSet> testSets = <TestSet>[
    AlgebraTests(),
    ParserTests(),
    ExpressionTests()
  ];

  TestExecutor.initWith(testSets).runTests();
}
