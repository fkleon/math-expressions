library math_expressions_test;

import 'dart:math' as math;

import 'package:test/test.dart';
import 'package:vector_math/vector_math.dart' show Vector2, Vector3, Vector4;
import 'package:math_expressions/math_expressions.dart';
import 'package:petitparser/reflection.dart';

import 'test_framework.dart';

part 'algebra_test_set.dart';
part 'expression_test_set.dart';
part 'lexer_test_set.dart';
part 'parser_test_set.dart';
part 'parser_petit_test_set.dart';
part 'evaluator_test_set.dart';
part 'evaluator_interval_test_set.dart';
part 'evaluator_vector_test_set.dart';

/// relative accuracy for floating-point calculations
const num EPS = 0.00001;

/// Registers all math test sets and executes the test suite afterwards.
void main() {
  final List<TestSet> testSets = <TestSet>[
    AlgebraTests(),
    LexerTests(),
    ParserTests(),
    PetitParserTests(),
    ExpressionTests(),
    RealEvaluatorTests(),
    IntervalEvaluatorTests(),
    VectorEvaluatorTests(),
  ];

  TestExecutor.initWith(testSets).runTests();
}
