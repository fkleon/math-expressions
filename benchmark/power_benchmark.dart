import 'package:benchmark/benchmark.dart';
import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

const int ITER = 10000;

void main() {

  Expression? exp;
  ContextModel? cm;

  setUpAll(() {
    Parser p = Parser();
    exp = p.parse('78^7897^7867');
    cm = ContextModel();
    //print('Expression is $exp');
  });

  benchmark('Math.pow', () {
    for (int i = 0;  i<ITER; i++) {
      num eval = math.pow(math.pow(78, 7897), 7867);
      assert(eval.isInfinite);
    }
  });

  benchmark('math_expressions.pow', () {
    for (int i = 0;  i<ITER; i++) {
      num eval = exp!.evaluate(EvaluationType.REAL, cm!);
      assert(eval.isInfinite);
    }
  });

}
