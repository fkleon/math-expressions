part of '../math_expressions.dart';

/// Mathematical expressions must be evaluated under a certain [EvaluationType].
///
/// Currently there are three types, but not all expressions support each type.
/// If you try to evaluate an expression with an unsupported type, it will raise
/// an [UnimplementedError] or [UnsupportedError].
///
/// - REAL
/// - VECTOR
/// - INTERVAL
///
enum EvaluationType { REAL, VECTOR, INTERVAL }

/// The context model keeps track of all known variables and functions.
///
/// It is structured hierarchically to offer nested scopes.
class ContextModel {
  /// The parent scope.
  final ContextModel? parentScope;

  /// Variable map of this scope (name -> expression).
  final Map<String, Expression> variables = <String, Expression>{};

  /// Function set of this scope.
  // TODO: Do we even need to track function names?
  final Set<MathFunction> functions = <MathFunction>{};

  /// Creates a new, empty root context model.
  ContextModel() : parentScope = null;

  /// Internal constructor for creating a child scope.
  ContextModel._child(this.parentScope);

  /// Returns a new child scope of this scope.
  ContextModel createChildScope() => ContextModel._child(this);

  /// Returns the bound expression for the given variable.
  /// Performs recursive lookup through `parentScope`.
  ///
  /// Throws a [StateError], if variable is still unbound at the root scope.
  Expression getExpression(String varName) {
    if (variables.containsKey(varName)) {
      return variables[varName]!;
    }

    if (parentScope != null) {
      return parentScope!.getExpression(varName);
    } else {
      throw StateError('Variable not bound: $varName');
    }
  }

  /// Returns the function for the given function name.
  /// Performs recursive lookup through `parentScope`.
  ///
  /// Throws a [StateError], if function is still unbound at the root scope.
  MathFunction getFunction(String name) {
    final Iterable<MathFunction> candidates = functions.where(
      (mathFunction) => mathFunction.name == name,
    );
    if (candidates.isNotEmpty) {
      // just grab first - should not contain doubles.
      return candidates.first;
    } else if (parentScope != null) {
      return parentScope!.getFunction(name);
    } else {
      throw StateError('Function not bound: $name');
    }
  }

  /// Binds a variable to an expression in this context.
  void bindVariable(Variable v, Expression e) {
    variables[v.name] = e;
  }

  /// Binds a variable name to an expression in this context.
  void bindVariableName(String vName, Expression e) {
    variables[vName] = e;
  }

  /// Unbinds a variable name in this context
  void unbindVariableName(String vName) {
    variables.remove(vName);
  }

  /// Binds a function to this context.
  void bindFunction(MathFunction f) {
    //TODO force non-duplicates.
    functions.add(f);
  }

  @override
  String toString() =>
      'ContextModel['
      'PARENT: $parentScope, '
      'VARS: ${variables.toString()}, '
      'FUNCS: ${functions.toString()}]';
}

/// An expression visitor that collects all variables in an expression.
class VariableCollector extends NullExpressionVisitor {
  final Set<String> _variables = {};

  /// Evaluate the given expression.
  ///
  /// Returns the distinct variable names found in the given expression.
  Iterable<String> evaluate(Expression exp) {
    assert(_variables.isEmpty);

    try {
      exp.accept(this);
      return {..._variables};
    } finally {
      _variables.clear();
    }
  }

  @override
  void visitVariable(Variable literal) {
    this._variables.add(literal.name);
  }
}

/// Implementation of a stack interface on top of a list.
class Stack<E> {
  final _list = <E>[];

  void clear() => _list.clear();
  void push(E value) => _list.add(value);

  E pop() => _list.removeLast();

  E get peek => _list.last;

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  int get depth => _list.length;

  @override
  String toString() => _list.toString();
}

abstract class ExpressionEvaluator<T> extends NullExpressionVisitor {
  final EvaluationType type;
  final ContextModel context;
  final Stack<T> _values = Stack();

  ExpressionEvaluator(this.type, this.context);

  /// Evaluate the given expression.
  T evaluate(Expression exp) {
    assert(_values.isEmpty);

    try {
      exp.accept(this);
      assert(_values.depth == 1);
      return _values.pop();
    } finally {
      _values.clear();
    }
  }

  (T,) pop1() {
    return (this._values.pop(),);
  }

  (T, T) pop2() {
    return (this._values.pop(), this._values.pop());
  }

  List<T> popN(int count) {
    var vals = <T>[];
    while (count-- > 0) {
      vals.add(this._values.pop());
    }
    return vals;
  }

  void push1(T val) {
    this._values.push(val);
  }

  UnimplementedError _unimplemented(Expression exp) {
    throw UnimplementedError(
      '${this.runtimeType} does not implement: ${exp.runtimeType}',
    );
  }

  @override
  void visitNumber(Number literal) {
    throw _unimplemented(literal);
  }

  @override
  void visitVector(Vector literal) {
    throw _unimplemented(literal);
  }

  @override
  void visitInterval(IntervalLiteral literal) {
    throw _unimplemented(literal);
  }

  @override
  void visitVariable(Variable literal) {
    // Resolve variable and evaluate its expression
    this.context.getExpression(literal.name).accept(this);
  }

  @override
  void visitUnaryPlus(UnaryPlus op) {
    throw _unimplemented(op);
  }

  @override
  void visitUnaryMinus(UnaryMinus op) {
    throw _unimplemented(op);
  }

  @override
  void visitPlus(Plus op) {
    throw _unimplemented(op);
  }

  @override
  void visitMinus(Minus op) {
    throw _unimplemented(op);
  }

  @override
  void visitTimes(Times op) {
    throw _unimplemented(op);
  }

  @override
  void visitDivide(Divide op) {
    throw _unimplemented(op);
  }

  @override
  void visitModulo(Modulo op) {
    throw _unimplemented(op);
  }

  @override
  void visitPower(Power op) {
    throw _unimplemented(op);
  }

  @override
  void visitFunction(MathFunction func) {
    // no-op
  }

  @override
  void visitDefaultFunction(DefaultFunction func) {
    // no-op
  }

  @override
  void visitAlgorithmicFunction(AlgorithmicFunction func) {
    throw _unimplemented(func);
  }

  @override
  void visitCustomFunction(CustomFunction func) {
    // nothing to do, this is simply a proxy object to an underlying expression
  }

  @override
  void visitCompositeFunction(CompositeFunction func) {
    throw _unimplemented(func);
  }

  @override
  void visitExponential(Exponential func) {
    throw _unimplemented(func);
  }

  @override
  void visitLog(Log func) {
    throw _unimplemented(func);
  }

  @override
  void visitLn(Ln func) {
    throw _unimplemented(func);
  }

  @override
  void visitRoot(Root func) {
    throw _unimplemented(func);
  }

  @override
  void visitSqrt(Sqrt func) {
    throw _unimplemented(func);
  }

  @override
  void visitSin(Sin func) {
    throw _unimplemented(func);
  }

  @override
  void visitCos(Cos func) {
    throw _unimplemented(func);
  }

  @override
  void visitTan(Tan func) {
    throw _unimplemented(func);
  }

  @override
  void visitAsin(Asin func) {
    throw _unimplemented(func);
  }

  @override
  void visitAcos(Acos func) {
    throw _unimplemented(func);
  }

  @override
  void visitAtan(Atan func) {
    throw _unimplemented(func);
  }

  @override
  void visitAbs(Abs func) {
    throw _unimplemented(func);
  }

  @override
  void visitCeil(Ceil func) {
    throw _unimplemented(func);
  }

  @override
  void visitFloor(Floor func) {
    throw _unimplemented(func);
  }

  @override
  void visitSgn(Sgn func) {
    throw _unimplemented(func);
  }

  @override
  void visitFactorial(Factorial func) {
    throw _unimplemented(func);
  }
}

/// An evaluator for real numbers as per [EvaluationType.REAL].
///
///     var expression = Number(4) + Variable('x');
///     var context = ContextModel()..bindVariableName('x', Number(1));
///     var evaluator = RealEvaluator();
///
///     num result = evaluator.evaluate(expression); // 5
///
class RealEvaluator extends ExpressionEvaluator<num> {
  /// Create a new evaluator with the given context.
  RealEvaluator([ContextModel? context])
    : super(EvaluationType.REAL, context ?? ContextModel());

  @override
  bool visitEnter(Expression exp) {
    if (exp is CompositeFunction) {
      // Skip visiting this sub-tree, and handle
      // nested evaluation in visitCompositeFunction() instead.
      return false;
    }

    return super.visitEnter(exp);
  }

  @override
  void visitNumber(Number literal) {
    push1(literal.value);
  }

  @override
  void visitVector(Vector literal) {
    // Interpret vector as real number,
    // i.e. a vector where all elements are equal.
    var val = popN(literal.length).toSet().single;
    push1(val);
  }

  @override
  void visitInterval(IntervalLiteral literal) {
    var (max, min) = pop2();
    // Interpret interval as real number,
    // i.e. an interval where min == max.
    if (min != max) {
      throw StateError("Too many values");
    }
    assert(min == max);
    push1(min);
  }

  @override
  void visitUnaryPlus(UnaryPlus op) {
    // no-op
  }

  @override
  void visitUnaryMinus(UnaryMinus op) {
    var (val,) = pop1();
    push1(-val);
  }

  @override
  void visitPlus(Plus op) {
    var (addend, augend) = pop2();
    push1(augend + addend);
  }

  @override
  void visitMinus(Minus op) {
    var (subtrahend, minuend) = pop2();
    push1(minuend - subtrahend);
  }

  @override
  void visitTimes(Times op) {
    var (multiplicand, multiplier) = pop2();
    push1(multiplier * multiplicand);
  }

  @override
  void visitDivide(Divide op) {
    var (divisor, dividend) = pop2();

    /// For real numbers this method performs a double divison and
    /// returns [double.infinity] if a divide by zero is encountered.
    push1(dividend / divisor);
  }

  @override
  void visitModulo(Modulo op) {
    var (n, a) = pop2();
    push1(a % n);
  }

  @override
  void visitPower(Power op) {
    var (exponent, base) = pop2();

    // TODO: Unnecessary calculations already done in case of expression rewrite below.

    // Consider the following equation: x^(2/y).
    // This equation can be evaluated for any negative x, since the sub result
    // is positive due to the even numerator. However, the IEEE Standard for
    // for Floating-Point Arithmetic defines NaN in the case of a negative
    // base and a finite non-integer as the exponent. That's why we rewrite
    // the equation manually.
    if (base.isNegative && op.second is Divide) {
      var numerator = (op.second as Divide).first;
      var denominator = (op.second as Divide).second;
      var newBase = Power(base, numerator);
      var newExponent = Number(1) / denominator;
      var newPower = Power(newBase, newExponent);
      return newPower.accept(this);
    }

    // In case the exponent is a unary minus e.g. x^(-(2/y)), we rewrite the
    // equation to 1/x^(2/3), for the same reason as stated above.
    if (base.isNegative && op.second is UnaryMinus) {
      var exponent = (op.second as UnaryMinus).exp;
      var newPower = Number(1) / Power(base, exponent);
      return newPower.accept(this);
    }

    push1(math.pow(base, exponent));
  }

  @override
  void visitFunction(MathFunction func) {
    // no-op
  }

  @override
  void visitDefaultFunction(DefaultFunction func) {
    // no-op
  }

  @override
  void visitAlgorithmicFunction(AlgorithmicFunction func) {
    var vals = popN(
      func.args.length,
    ).reversed.map((n) => n.toDouble()).toList();
    push1(func.handler(vals));
  }

  @override
  void visitCustomFunction(CustomFunction func) {
    // nothing to do, this is simply a proxy object to an underlying expression
  }

  @override
  void visitCompositeFunction(CompositeFunction func) {
    assert(func.domainDimension == 1);
    push1(func.evaluate(this.type, context));
  }

  @override
  void visitExponential(Exponential func) {
    var (val,) = pop1();
    push1(math.exp(val));
  }

  @override
  void visitLog(Log func) {
    var (number, base) = pop2();
    // Convert to natural logarithm
    push1(math.log(number) / math.log(base));
  }

  @override
  void visitLn(Ln func) {
    var (val,) = pop1();
    push1(math.log(val));
  }

  @override
  void visitRoot(Root func) {
    var (radicant, degree) = pop2();
    // Convert to power form
    push1(math.pow(radicant, 1 / degree));
  }

  @override
  void visitSqrt(Sqrt func) {
    var (val,) = pop1();
    push1(math.sqrt(val));
  }

  @override
  void visitSin(Sin func) {
    var (val,) = pop1();

    // Compensate for inaccuracies in machine-pi.
    // If val divides cleanly from pi, return 0.
    if ((val / math.pi).abs() % 1 == 0) {
      push1(0.0);
    } else {
      push1(math.sin(val));
    }
  }

  @override
  void visitCos(Cos func) {
    var (val,) = pop1();

    // Compensate for inaccuracies in machine-pi.
    // If val divides cleanly from pi (when shifted back to Sin from Cos), return 0.
    if (((val - math.pi / 2) / math.pi).abs() % 1 == 0) {
      push1(0.0);
    } else {
      push1(math.cos(val));
    }
  }

  @override
  void visitTan(Tan func) {
    var (val,) = pop1();

    // Compensate for inaccuracies in machine-pi.
    // If val divides cleanly from pi, return 0.
    if ((val / math.pi).abs() % 1 == 0) {
      push1(0.0);
    } else {
      push1(math.tan(val));
    }
  }

  @override
  void visitAsin(Asin func) {
    var (val,) = pop1();
    push1(math.asin(val));
  }

  @override
  void visitAcos(Acos func) {
    var (val,) = pop1();
    push1(math.acos(val));
  }

  @override
  void visitAtan(Atan func) {
    var (val,) = pop1();
    push1(math.atan(val));
  }

  @override
  void visitAbs(Abs func) {
    var (val,) = pop1();
    push1(val.abs());
  }

  @override
  void visitCeil(Ceil func) {
    var (val,) = pop1();
    push1(val.ceil().toDouble());
  }

  @override
  void visitFloor(Floor func) {
    var (val,) = pop1();
    push1(val.floor().toDouble());
  }

  @override
  void visitSgn(Sgn func) {
    var (val,) = pop1();
    var ret = val == 0
        ? 0.0
        : val < 0
        ? -1.0
        : 1.0;
    push1(ret);
  }

  @override
  void visitFactorial(Factorial func) {
    var (val,) = pop1();

    if (val < 0) {
      throw ArgumentError.value(
        val,
        'Factorial',
        'Negative values not supported.',
      );
    }

    if (val == double.infinity) {
      throw ArgumentError.value(val, 'Factorial', 'Infinity not supported.');
    }

    var product = 1.0;
    for (int i = 1; i <= val.round(); i++) {
      product *= i;
    }
    push1(product);
  }
}

class IntervalEvaluator extends ExpressionEvaluator<Interval> {
  /// Create a new evaluator with the given context.
  IntervalEvaluator([ContextModel? context])
    : super(EvaluationType.INTERVAL, context ?? ContextModel());

  @override
  bool visitEnter(Expression exp) {
    if (exp is IntervalLiteral) {
      // Skip visiting this sub-tree, and handle
      // nested evaluation in visitInterval() instead.
      return false;
    }

    return super.visitEnter(exp);
  }

  @override
  void visitNumber(Number literal) {
    if (literal.value is num) {
      push1(Interval(literal.value, literal.value));
    } else if (literal.value is Interval) {
      push1(literal.value);
    } else {
      throw UnsupportedError(
        'Number $literal with type ${literal.value.runtimeType} can not be interpreted as: $type',
      );
    }
  }

  @override
  void visitInterval(IntervalLiteral literal) {
    // Evaulate the interval boundaries as REAL numbers.
    var eval = RealEvaluator(this.context);
    var (min, max) = (eval.evaluate(literal.min), eval.evaluate(literal.max));

    push1(Interval(min, max));
  }

  @override
  void visitUnaryPlus(UnaryPlus op) {
    // no-op
  }

  @override
  void visitUnaryMinus(UnaryMinus op) {
    var (val,) = pop1();
    push1(-val);
  }

  @override
  void visitPlus(Plus op) {
    var (addend, augend) = pop2();
    push1(augend + addend);
  }

  @override
  void visitMinus(Minus op) {
    var (subtrahend, minuend) = pop2();
    push1(minuend - subtrahend);
  }

  @override
  void visitTimes(Times op) {
    var (multiplicand, multiplier) = pop2();
    push1(multiplier * multiplicand);
  }

  @override
  void visitDivide(Divide op) {
    var (divisor, dividend) = pop2();
    push1(dividend / divisor);
  }

  @override
  void visitPower(Power op) {
    // Expect base to be interval.
    var (exp, base) = pop2();

    // Expect exponent to be a natural number.
    assert(exp.min == exp.max);
    int exponent = exp.min.toInt();
    num evalMin, evalMax;

    // Distinction of cases depending on oddity of exponent.
    if (exponent.isOdd) {
      // [x, y]^n = [x^n, y^n] for n = odd
      evalMin = math.pow(base.min, exponent);
      evalMax = math.pow(base.max, exponent);
    } else {
      // [x, y]^n = [x^n, y^n] for x >= 0
      if (base.min >= 0) {
        // Positive interval.
        evalMin = math.pow(base.min, exponent);
        evalMax = math.pow(base.max, exponent);
      }

      // [x, y]^n = [y^n, x^n] for y < 0
      if (base.min >= 0) {
        // Positive interval.
        evalMin = math.pow(base.max, exponent);
        evalMax = math.pow(base.min, exponent);
      }

      // [x, y]^n = [0, max(x^n, y^n)] otherwise
      evalMin = 0;
      evalMax = math.max(
        math.pow(base.min, exponent),
        math.pow(base.min, exponent),
      );
    }

    assert(evalMin <= evalMax);
    push1(Interval(evalMin, evalMax));
  }

  @override
  void visitExponential(Exponential func) {
    var (val,) = pop1();

    // Special case of a^[x, y] = [a^x, a^y] for a > 1 (with a = e)
    // Expect exponent to be interval.
    push1(Interval(math.exp(val.min), math.exp(val.max)));
  }

  @override
  void visitLog(Log func) {
    // TODO prevent entering to avoid unnecessary computation
    var (_, _) = pop2();
    // Convert to natural logarithm
    // log_a([x, y]) = [log_a(x), log_a(y)] for [x, y] positive and a > 1
    func.asNaturalLogarithm().accept(this);
  }

  @override
  void visitLn(Ln func) {
    var (val,) = pop1();
    push1(Interval(math.log(val.min), math.log(val.max)));
  }

  @override
  void visitRoot(Root func) {
    // TODO prevent entering to avoid unnecessary computation
    var (_, _) = pop2();
    // Convert to power form
    func.asPower().accept(this);
  }

  @override
  void visitSqrt(Sqrt func) {
    var (val,) = pop1();
    // Piecewiese sqrting.
    push1(Interval(math.sqrt(val.min), math.sqrt(val.max)));
  }

  @override
  void visitSin(Sin func) {
    // TODO evaluate endpoints and critical points ((1/2 + n) * pi)
    // or just return [-1, 1] if half a period is in the given interval
    super.visitSin(func);
  }

  @override
  void visitCos(Cos func) {
    // TODO evaluate endpoints and critical points (n * pi)
    // or just return [-1, 1] if half a period is in the given interval
    super.visitCos(func);
  }
}

/// The vector evaluator can operate on mixed datatypes,
/// so is typed less strict. The underlying data types could
/// be Vector2, Vector3, Vector4 and double (scalars).
class VectorEvaluator extends ExpressionEvaluator<Object> {
  /// Create a new evaluator with the given context.
  VectorEvaluator([ContextModel? context])
    : super(EvaluationType.VECTOR, context ?? ContextModel());

  @override
  List<double> popN(int count) {
    return super.popN(count).cast<double>().reversed.toList();
  }

  @override
  bool visitEnter(Expression exp) {
    if (exp is Vector) {
      // Skip visiting this sub-tree, and handle
      // nested evaluation in visitVector() instead.
      return false;
    }

    if (exp is CompositeFunction) {
      // Skip visiting this sub-tree, and handle
      // nested evaluation in visitCompositeFunction() instead.
      return false;
    }

    return super.visitEnter(exp);
  }

  @override
  void visitNumber(Number literal) {
    if (literal.value is num) {
      // Interpret number as scalar
      push1(literal.value);
    } else if (literal.value is Vector2 ||
        literal.value is Vector3 ||
        literal.value is Vector4) {
      push1(literal.value);
    } else {
      throw UnsupportedError(
        'Number $literal with type ${literal.value.runtimeType} can not be interpreted as: $type',
      );
    }
  }

  @override
  void visitVector(Vector literal) {
    // Evaulate each vector element as REAL number.
    var eval = RealEvaluator(this.context);
    var elems = literal.elements
        .map(eval.evaluate)
        .map((n) => n.toDouble())
        .toList();

    switch (literal.length) {
      case 0:
        return;
      case 1:
        // Does not seem to be a vector, evaluate as scalar.
        return push1(elems[0]);
      case 2:
        return push1(Vector2.array(elems));
      case 3:
        return push1(Vector3.array(elems));
      case 4:
        return push1(Vector4.array(elems));
      default:
        throw UnsupportedError(
          'Vector of arbitrary length (> 4) are not supported.',
        );
    }
  }

  @override
  void visitUnaryPlus(UnaryPlus op) {
    // no-op
  }

  @override
  void visitUnaryMinus(UnaryMinus op) {
    var (val,) = pop1();

    if (val is num) {
      return push1(-val);
    }

    if (val is Vector2) {
      return push1(-val);
    }

    if (val is Vector3) {
      return push1(-val);
    }

    if (val is Vector4) {
      return push1(-val);
    }

    throw UnsupportedError(
      '${op.runtimeType} of ${val.runtimeType} can not be evaluated as: $type',
    );
  }

  @override
  void visitPlus(Plus op) {
    var (addend, augend) = pop2();

    // vector and vector
    if (augend is Vector2 && addend is Vector2) {
      return push1(augend + addend);
    }

    if (augend is Vector3 && addend is Vector3) {
      return push1(augend + addend);
    }

    if (augend is Vector4 && addend is Vector4) {
      return push1(augend + addend);
    }

    throw UnsupportedError(
      '${op.runtimeType} of ${augend.runtimeType} and ${addend.runtimeType} can not be evaluated as: $type',
    );
  }

  @override
  void visitMinus(Minus op) {
    var (subtrahend, minuend) = pop2();

    // vector and vector
    if (minuend is Vector2 && subtrahend is Vector2) {
      return push1(minuend - subtrahend);
    }

    if (minuend is Vector3 && subtrahend is Vector3) {
      return push1(minuend - subtrahend);
    }

    if (minuend is Vector4 && subtrahend is Vector4) {
      return push1(minuend - subtrahend);
    }

    throw UnsupportedError(
      '${op.runtimeType} of ${minuend.runtimeType} and ${subtrahend.runtimeType} can not be evaluated as: $type',
    );
  }

  @override
  void visitTimes(Times op) {
    var (multiplicand, multiplier) = pop2();

    // vector and vector
    if (multiplier is Vector2 && multiplicand is Vector2) {
      return push1(multiplier..multiply(multiplicand));
    }

    if (multiplier is Vector3 && multiplicand is Vector3) {
      return push1(multiplier..multiply(multiplicand));
    }

    if (multiplier is Vector4 && multiplicand is Vector4) {
      return push1(multiplier..multiply(multiplicand));
    }

    // vector and scalar
    if (multiplier is Vector2 && multiplicand is double) {
      return push1(multiplier * multiplicand);
    }

    if (multiplier is Vector3 && multiplicand is double) {
      return push1(multiplier * multiplicand);
    }

    if (multiplier is Vector4 && multiplicand is double) {
      return push1(multiplier * multiplicand);
    }

    if (multiplier is num) {
      throw ArgumentError.value(
        op,
        "multiplier",
        '${op.runtimeType} as $type requires scalar to be on right-hand side of the expression.',
      );
    }

    throw UnsupportedError(
      '${op.runtimeType} of ${multiplier.runtimeType} and ${multiplicand.runtimeType} can not be evaluated as: $type',
    );
  }

  @override
  void visitDivide(Divide op) {
    var (divisor, dividend) = pop2();

    // vector and vector
    if (dividend is Vector2 && divisor is Vector2) {
      return push1(dividend..divide(divisor));
    }

    if (dividend is Vector3 && divisor is Vector3) {
      return push1(dividend..divide(divisor));
    }

    if (dividend is Vector4 && divisor is Vector4) {
      return push1(dividend..div(divisor));
    }

    // vector and scalar
    if (dividend is Vector2 && divisor is double) {
      return push1(dividend / divisor);
    }

    if (dividend is Vector3 && divisor is double) {
      return push1(dividend / divisor);
    }

    if (dividend is Vector4 && divisor is double) {
      return push1(dividend / divisor);
    }

    if (dividend is num) {
      throw ArgumentError.value(
        op,
        "dividend",
        '${op.runtimeType} as $type requires scalar to be on right-hand side of the expression.',
      );
    }

    throw UnsupportedError(
      '${op.runtimeType} of ${dividend.runtimeType} and ${divisor.runtimeType} can not be evaluated as: $type',
    );
  }

  @override
  void visitCompositeFunction(CompositeFunction func) {
    assert(func.domainDimension >= 1);
    push1(func.evaluate(this.type, context));
  }
}
