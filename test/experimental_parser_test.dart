import 'dart:io';
import 'dart:math';

import 'package:math_expressions/experimental_parser.dart';
import 'package:math_expressions/src/experimental_parser.dart' as parser;
import 'package:math_expressions/math_expressions.dart';
import 'package:test/test.dart';

void main() {
  _test();
}

void _test() {
  num addTwo(List<num> args) => args[0] + 2;
  final x = 5;
  final numberX = Number(x);
  final testData = [
    _TestData(
      source: ' addThree ( 2 ) ',
      asString: 'addThree({2.0})',
    ),
    _TestData(
        source: ' addTwo ( 3 ) ',
        asString: 'addTwo({3.0})',
        result: 5,
        handlers: {'addTwo': addTwo}),
    _TestData(
      source: ' √100 + x ',
      asString: '(sqrt({100.0}) + x)',
      result: sqrt(100) + x,
      variables: {'x': numberX},
    ),
    _TestData(
      source: ' ∜16 + x ',
      asString: '(nrt(4,{16.0}) + x)',
      result: 2 + x,
      variables: {'x': numberX},
    ),
    _TestData(
      source: ' ∞ ',
      asString: 'Infinity',
      result: double.infinity,
    ),
    _TestData(
      source: ' −∞ ',
      asString: '(-Infinity)',
      result: double.negativeInfinity,
    ),
    _TestData(
      source: ' 2 − 2 ',
      asString: '(2.0 - 2.0)',
      result: 2 - 2,
    ),
    _TestData(
      source: ' 2 × 2 ',
      asString: '(2.0 * 2.0)',
      result: 2 * 2,
    ),
    _TestData(
      source: ' 2 ÷ 2 ',
      asString: '(2.0 / 2.0)',
      result: 2 / 2,
    ),
    _TestData(
      source: ' −2 ',
      asString: '(-2.0)',
      result: -2,
    ),
    _TestData(
      source: ' - 2 ',
      asString: '(-2.0)',
      result: -2,
    ),
    _TestData(
      source: ' e^ 1 ',
      asString: 'e({1.0})',
      result: e,
    ),
    _TestData(
      source: ' e^ ( 1 ) ',
      asString: 'e({1.0})',
      result: e,
    ),
    _TestData(
      source: ' e^ ( 1 , 2 ) ',
      asString: '',
      hasParseErrors: true,
    ),
    _TestData(
      source: ' x + 2 * 3 + x ',
      asString: '((x + (2.0 * 3.0)) + x)',
      result: x + 2 * 3 + x,
      variables: {'x': numberX},
    ),
    _TestData(
      source: ' - 1 * 3 ',
      asString: '((-1.0) * 3.0)',
      result: -1 * 3,
    ),
    _TestData(
      source: ' -1 ^ 2 ^ 3 * 5 ^ 6 % 7 / 8 ',
      asString: '(((((((-1.0)^2.0)^3.0) * 5.0)^6.0) % 7.0) / 8.0)',
      result: pow(pow(pow(-1, 2), 3) * 5, 6) % 7 / 8,
    ),
    _TestData(
      source: ' x ! ',
      asString: 'x!',
      result: 120,
      variables: {'x': numberX},
    ),
    _TestData(
      source: ' x ! * 2 ',
      asString: '(x! * 2.0)',
      result: 120 * 2,
      variables: {'x': numberX},
    ),
    _TestData(
      source: ' - x ! * 2 ',
      asString: '({(-x)}! * 2.0)',
      variables: {'x': numberX},
    ),
    _TestData(
      source: ' 1 + x * 3 - sqrt ( 5 ^ 2.0 ) ',
      asString: '((1.0 + (x * 3.0)) - sqrt({(5.0^2.0)}))',
      result: 1 + x * 3 - sqrt(pow(5, 2.0)),
      variables: {'x': numberX},
    ),
    _TestData(
      source: ' π ',
      asString: '3.141592653589793',
      result: 3.141592653589793,
    ),
    _TestData(
      source: ' π * 2 ',
      asString: '(3.141592653589793 * 2.0)',
      result: 3.141592653589793 * 2,
    ),
    _TestData(
      source: ' sin ( 1 ) ',
      asString: 'sin({1.0})',
      result: sin(1),
    ),
    _TestData(
      source: ' sin ( 90 ° ) ',
      asString: 'sin({1.5707963267948966})',
      result: sin(1.5707963267948966),
    ),
    _TestData(
      source: ' sin ( 90 ° ) ',
      asString: 'sin({1.5707963267948966})',
      result: 1,
    ),
    _TestData(
      source: ' sin ( 85 ° + x ° ) ',
      asString: 'sin({(1.4835298641951802 + (x * 0.017453292519943295))})',
      result: 1,
      variables: {'x': numberX},
    ),
    _TestData(
      source: ' sqrt + sqrt + 1 - 2 ',
      asString: '(((sqrt + sqrt) + 1.0) - 2.0)',
    ),
    _TestData(
      source: ' 1x ',
      asString: '',
      hasParseErrors: true,
    ),
    _TestData(
      source: ' 1 + sqrt ',
      asString: '(1.0 + sqrt)',
    ),
    _TestData(
      source: ' 1 + sqrt ( 2 , 3 ) ',
      asString: '',
      hasParseErrors: true,
    ),
    _TestData(
      source: ' nrt ( x , y ) ',
      asString: '',
      hasParseErrors: true,
    ),
    _TestData(
      source: ' nrt ( 1 ) ',
      asString: '',
      hasParseErrors: true,
    ),
    _TestData(
      source: ' addTwo ( 3 ',
      asString: '',
      hasParseErrors: true,
    ),
    _TestData(
      source: ' addTwo ( 3 , ',
      asString: '',
      hasParseErrors: true,
    ),
    _TestData(
      source: ' addTwo ( 3 ( ',
      asString: '',
      hasParseErrors: true,
    ),
    _TestData(
      source: ' x - ',
      asString: '',
      hasParseErrors: true,
    ),
    _TestData(
      source: ' 5.x ',
      asString: '',
      hasParseErrors: true,
    ),
    _TestData(
      source: ' abs (- 1 ) ',
      asString: 'abs({(-1.0)})',
      result: 1,
    ),
    _TestData(
      source: ' arccos ( 1 ) ',
      asString: 'arccos({1.0})',
      result: acos(1),
    ),
    _TestData(
      source: ' arcsin ( 1 ) ',
      asString: 'arcsin({1.0})',
      result: asin(1),
    ),
    _TestData(
      source: ' arctan ( 1 ) ',
      asString: 'arctan({1.0})',
      result: atan(1),
    ),
    _TestData(
      source: ' ceil ( 1 ) ',
      asString: 'ceil({1.0})',
      result: 1.ceil(),
    ),
    _TestData(
      source: ' cos ( 1 ) ',
      asString: 'cos({1.0})',
      result: cos(1),
    ),
    _TestData(
      source: ' e^ ( 1 ) ',
      asString: 'e({1.0})',
      result: e,
    ),
    _TestData(
      source: ' floor ( 1 ) ',
      asString: 'floor({1.0})',
      result: 1.floor(),
    ),
    _TestData(
      source: ' ln ( 1 ) ',
      asString: 'ln({1.0})',
      result: log(1),
    ),
    _TestData(
      source: ' log ( 10 , 100 ) ',
      asString: 'log({10.0},{100.0})',
      result: log(100) / log(10),
    ),
    _TestData(
      source: ' nrt ( 2, 9 ) ',
      asString: 'nrt(2,{9.0})',
      result: 3,
    ),
    _TestData(
      source: ' sgn ( -5 ) ',
      asString: 'sgn({(-5.0)})',
      result: -1,
    ),
    _TestData(
      source: ' sin ( 1 ) ',
      asString: 'sin({1.0})',
      result: sin(1),
    ),
    _TestData(
      source: ' sqrt ( 9 ) ',
      asString: 'sqrt({9.0})',
      result: sqrt(9),
    ),
    _TestData(
      source: ' tan ( 1 ) ',
      asString: 'tan({1.0})',
      result: tan(1),
    ),
  ];

  test('Experimental Parser Test', () {
    for (final data in testData) {
      final context = ContextModel();
      data.variables.forEach((k, v) => context.bindVariable(Variable(k), v));
      if (data.hasParseErrors) {
        final state = parser.State(data.source);
        parser.parse(state, handlers: data.handlers);
        expect(state.ok, false, reason: 'Test state.ok: ' + data.source);
        continue;
      }

      var hasErrors = false;
      dynamic error;
      try {
        final p = Parser2();
        data.handlers.forEach(p.addFunction);
        final result = p.parse(data.source);
        expect('$result', data.asString,
            reason: 'Test toString(): ' + data.source);
        expect(result.evaluate(EvaluationType.REAL, context), data.result,
            reason: 'Test result: ' + data.source);
      } catch (e) {
        if (e is TestFailure) {
          rethrow;
        } else {
          error = e;
          hasErrors = true;
        }
      } finally {
        expect(hasErrors, data.result == null,
            reason: 'Test has errors: ' + data.source + '\n$error');
      }
    }
  });

  {
    final sb = StringBuffer();
    for (final data in testData) {
      sb.writeln('-----------------');
      sb.write(data.source);
      try {
        final p = Parser2();
        data.handlers.forEach(p.addFunction);
        final result = p.parse(data.source);
        sb.writeln(' => $result');
        final context = ContextModel();
        data.variables.forEach((k, v) => context.bindVariable(Variable(k), v));
        Object? result2 = result.evaluate(EvaluationType.REAL, context);
        sb.writeln('vars: ${context.variables}');
        sb.writeln('$result2');
      } catch (e) {
        sb.writeln(' => ERROR');
        sb.writeln(e);
      } finally {
        //
      }
    }

    File('test/_test_results.txt').writeAsStringSync(sb.toString());
  }
}

class _TestData {
  final String asString;

  final Map<String, Function> handlers;

  final bool hasParseErrors;

  final dynamic result;

  final String source;

  final Map<String, Expression> variables;

  final void Function()? test;

  _TestData(
      {required this.asString,
      this.handlers = const {},
      this.hasParseErrors = false,
      this.result,
      required this.source,
      this.test,
      this.variables = const {}});

  @override
  String toString() {
    return source;
  }
}
