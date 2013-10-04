part of math_expressions_test;

/**
 * Contains methods to test the math expression implementation.
 */
class ExpressionTests extends TestSet {

  get name => 'Expression Tests';

  get testFunctions => {
    'Expression REAL Creation': simpleRealCreation,
    'Expression INTERVAL Creation': simpleIntervalCreation,
    'Expression VECTOR Creation': simpleVectorCreation,
    'Simple REAL evaluation': simpleRealEval,
    'Simple INTERVAL evaluation': simpleIntervalEval,
    'Simple VECTOR evaluation': simpleVectorEval,
    'Default Function Creation': defFuncCreation,
    'Default Function REAL evaluation': defFuncRealEval,
    'Default Function INTERVAL evaluation': defFuncIntervalEval,
    'Default Function VECTOR evaluation': defFuncVectorEval,
    'Custom Function Creation': cusFuncCreation,
    'Custom Function REAL evaluation': cusFuncRealEval,
    'Custom Function INTERVAL evaluation': cusFuncIntervalEval,
    'Custom Function VECTOR evaluation': cusFuncVectorEval,
    'Composite Function creation': compFunCreation,
    'Composite Function evaluation': compFunEval,
    'Expression and Function differentiation': deriveTest,
    'Expression and Function simplification': simplifyTest,
  };

  void initTests() {
    num1 = 2.25;
    num2 = 5;
    num3 = 199.9999999;
    n1 = new Number(num1);
    n2 = new Number(num2);
    n3 = new Number(num3);

    int1 = new Interval(num1, num2);
    int2 = new Interval(num2, num3);
    int3 = new Interval(-num3, num2);;

    i1 = new IntervalLiteral(n1, n2);
    i2 = new IntervalLiteral(n2, n3);
    i3 = new IntervalLiteral(-n3, n2);

    real = EvaluationType.REAL;
    interval = EvaluationType.INTERVAL;
    vector = EvaluationType.VECTOR;

    cm = new ContextModel();
  }

  num num1, num2, num3;
  Interval int1, int2, int3;

  Number n1, n2, n3, n4;
  IntervalLiteral i1, i2, i3;
  Variable v1, v2, v3;
  Expression e1, e2, e3, e4, e5, e6;

  EvaluationType real, interval, vector;
  ContextModel cm;

  void _createBasicExpressions(EvaluationType type) {
    if (type == EvaluationType.REAL) {
      e1 = n1 * n2;
      e2 = n1 / n2;
      e3 = n1 ^ n2;
      e4 = n1 + n2;
      e5 = n1 - n2;
      e6 = -n1;
      return;
    }

    if (type == EvaluationType.INTERVAL) {
      e1 = i1 * i2;
      e2 = i1 / i2;
      //e3 = i1 ^ i2;
      e4 = i1 + i2;
      e5 = i1 - i2;
      e6 = -i1;
      return;
    }

    //TODO vector
  }

  void simpleRealCreation() {
    _createBasicExpressions(real);

    expect(e1 is Times, isTrue);
    expect(_hasMember(e1, n1, n2), isTrue);

    expect(e2 is Divide, isTrue);
    expect(_hasMember(e2, n1, n2), isTrue);

    expect(e3 is Power, isTrue);
    expect(_hasMember(e3, n1, n2), isTrue);

    expect(e4 is Plus, isTrue);
    expect(_hasMember(e4, n1, n2), isTrue);

    expect(e5 is Minus, isTrue);
    expect(_hasMember(e5, n1, n2), isTrue);

    expect(e6 is UnaryMinus, isTrue);
    expect(_hasMember(e6, n1), isTrue);
  }

  void simpleIntervalCreation() {
    _createBasicExpressions(interval);

    expect(e1 is Times, isTrue);
    expect(_hasMember(e1, i1, i2), isTrue);

    expect(e2 is Divide, isTrue);
    expect(_hasMember(e2, i1, i2), isTrue);

    // no power OP on intervals yet
//    expect(e3 is Power, isTrue);
//    expect(_hasMember(e3, i1, i2), isTrue);

    expect(e4 is Plus, isTrue);
    expect(_hasMember(e4, i1, i2), isTrue);

    expect(e5 is Minus, isTrue);
    expect(_hasMember(e5, i1, i2), isTrue);

    expect(e6 is UnaryMinus, isTrue);
    expect(_hasMember(e6, i1), isTrue);
  }

  void simpleVectorCreation() {
    _createBasicExpressions(vector);

    //TODO vector
    throw new UnimplementedError();
  }

  void simpleRealEval() {
    _createBasicExpressions(real);

    var eval = e1.evaluate(real, cm);
    expect(eval, equals(num1 * num2));

    eval = e2.evaluate(real, cm);
    expect(eval, equals(num1 / num2));

    eval = e2.evaluate(real, cm);
    expect(eval, equals(num1 / num2));

    eval = e3.evaluate(real, cm);
    expect(eval, equals(Math.pow(num1, num2)));

    eval = e4.evaluate(real, cm);
    expect(eval, equals(num1 + num2));

    eval = e5.evaluate(real, cm);
    expect(eval, equals(num1 - num2));

    eval = e6.evaluate(real, cm);
    expect(eval, equals(- num1));
  }

  void simpleIntervalEval() {
    // Interpret REAL as INTERVAL
    _createBasicExpressions(real);

    Interval ri1 = new Interval(num1, num1),
             ri2 = new Interval(num2, num2),
             ri3 = new Interval(num3, num3);

    var eval = e1.evaluate(interval, cm);
    expect(eval, equals(ri1 * ri2));

    eval = e2.evaluate(interval, cm);
    expect(eval, equals(ri1 / ri2));

    eval = e2.evaluate(interval, cm);
    expect(eval, equals(ri1 / ri2));

//    eval = e3.evaluate(interval, cm);
//    expect(eval, equals(ri1 ^ ri2));

    eval = e4.evaluate(interval, cm);
    expect(eval, equals(ri1 + ri2));

    eval = e5.evaluate(interval, cm);
    expect(eval, equals(ri1 - ri2));

    eval = e6.evaluate(interval, cm);
    expect(eval, equals(- ri1));

    // Interpret INTERVAL as INTERVAL
    _createBasicExpressions(interval);

    eval = e1.evaluate(interval, cm);
    expect(eval, equals(int1 * int2));

    eval = e2.evaluate(interval, cm);
    expect(eval, equals(int1 / int2));

    eval = e2.evaluate(interval, cm);
    expect(eval, equals(int1 / int2));

//    eval = e3.evaluate(interval, cm);
//    expect(eval, equals(i1 ^ i2));

    eval = e4.evaluate(interval, cm);
    expect(eval, equals(int1 + int2));

    eval = e5.evaluate(interval, cm);
    expect(eval, equals(int1 - int2));

    eval = e6.evaluate(interval, cm);
    expect(eval, equals(- int1));
  }

  void simpleVectorEval() {
    // TODO test eval
    throw new UnimplementedError();
  }

  void defFuncCreation() {
    // Create all the default functions:
    // Log, Ln, Cos, Sin, Tan, Pow, etc.
    print(e1);
    throw new UnimplementedError();
  }

  void defFuncRealEval() {
    throw new UnimplementedError();
  }

  void defFuncIntervalEval() {
    throw new UnimplementedError();
  }

  void defFuncVectorEval() {
    throw new UnimplementedError();
  }

  void cusFuncCreation() {
    // Create some custom functions.
    throw new UnimplementedError();
  }

  void cusFuncRealEval() {
    throw new UnimplementedError();
  }

  void cusFuncIntervalEval() {
    throw new UnimplementedError();
  }

  void cusFuncVectorEval() {
    throw new UnimplementedError();
  }

  void compFunCreation() {
    // Create some composite functions.
    throw new UnimplementedError();
  }

  void compFunEval() {
    // Evaluate composite functions.
    throw new UnimplementedError();
  }

  // TODO test simplify
  // TODO test derive
  void deriveTest() {
    throw new UnimplementedError();
  }

  void simplifyTest() {
    throw new UnimplementedError();
  }

  bool _hasMember(expr, m, [m2]) {
    if (m2 != null) {
      // Binary op.
      return expr.first == m && expr.second == m2;
    } else {
      // Unary op.
      return expr.exp == m;
    }
  }
}