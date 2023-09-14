part of math_expressions;

/// Any Expression supports basic mathematical operations like
/// addition, subtraction, multiplication, division, power and negate.
///
/// Furthermore, any expression can be differentiated with respect to
/// a given variable. Also expressions know how to simplify themselves.
///
/// There are different classes of expressions:
///
/// * Literals (see [Literal])
///
///     * Number Literals (see [Number])
///     * Variable Literals (see [Variable])
///     * Vector Literals (see [Vector])
///     * Interval Literals (see [IntervalLiteral])
/// * Operators (support auto-wrapping of parameters into Literals)
///
///     * Unary Operators (see [UnaryOperator])
///     * Binary Operators (see [BinaryOperator])
/// * Functions (see [MathFunction])
///
///     * Pre-defined Functions (see [DefaultFunction])
///     * Composite Functions (see [CompositeFunction])
///     * Custom Functions (see [CustomFunction])
///
/// Pre-defined functions are [Exponential], [Log], [Ln], nth-[Root], [Sqrt],
/// [Abs], [Ceil], [Floor], [Sgn], [Sin], [Cos], [Tan], [Asin], [Acos] and [Atan].
abstract class Expression {
  // Basic operations.
  /// Add operator. Creates a [Plus] expression.
  Expression operator +(Expression exp) => Plus(this, exp);

  /// Subtract operator. Creates a [Minus] expression.
  Expression operator -(Expression exp) => Minus(this, exp);

  /// Multiply operator. Creates a [Times] expression.
  Expression operator *(Expression exp) => Times(this, exp);

  /// Divide operator. Creates a [Divide] expression.
  Expression operator /(Expression exp) => Divide(this, exp);

  /// Modulo operator. Creates a [Modulo] expression.
  Expression operator %(Expression exp) => Modulo(this, exp);

  /// Power operator. Creates a [Power] expression.
  Expression operator ^(Expression exp) => Power(this, exp);

  /// Unary minus operator. Creates a [UnaryMinus] expression.
  Expression operator -() => UnaryMinus(this);

  /// Lower than operator. Returns 1 if true, 0 if false
  Expression operator <(Expression exp) => LowerThan(this, exp);

  /// Lower than or equal to operator. Returns 1 if true, 0 if false
  Expression operator <=(Expression exp) => LowerThanOrEqualTo(this, exp);


  /// Derives this expression with respect to the given variable.
  Expression derive(String toVar);
  // TODO: Return simplified version of derivation. This might not be possible
  //       with the current model. Probably needs some kind of evaluator
  //       construct.

  /// Returns a simplified version of this expression.
  /// Subclasses should overwrite this method, if applicable.
  Expression simplify() => this;
  // TODO: Return maximally simplified version of expression. This might not be
  //       possible with the current model, see above.

  /// Evaluates this expression according to given type and context.
  dynamic evaluate(EvaluationType type, ContextModel context);

  /// Returns a string version of this expression.
  /// Subclasses should override this method. The output should be kept
  /// compatible with the [Parser].
  @override
  String toString();

  /// Converts the given argument to a valid expression.
  ///
  /// Returns the argument, if it is already an expression.
  /// Else wraps the argument in a [Number] or [Variable] Literal.
  ///
  /// Throws ArgumentError, if given arg is not an Expression, num oder String.
  ///
  /// __Note__:
  /// Does not handle negative numbers, will treat them as positives!
  Expression _toExpression(dynamic arg) {
    if (arg is Expression) {
      return arg;
    }

    if (arg is num) {
      // can not handle negative numbers - use parser for this case!
      return Number(arg);
    }

    if (arg is String) {
      return Variable(arg);
    }

    throw ArgumentError('$arg is not a valid expression!');
  }

  /// Returns true, if the given expression is a constant literal and its value
  /// matches the given value.
  bool _isNumber(Expression exp, [num value = 0]) {
    // Check for literal.
    if (exp is Literal && exp.isConstant()) {
      return exp.getConstantValue() == value;
    }

    return false;
  }
}

/// A binary operator takes two expressions and performs an operation on them.
abstract class BinaryOperator extends Expression {
  late final Expression first, second;

  /// Creates a [BinaryOperator] from two given arguments.
  ///
  /// If an argument is not an expression, it will be wrapped in an appropriate
  /// literal.
  ///
  /// * A (positive) number will be encapsulated in a [Number] Literal,
  /// * A string will be encapsulated in a [Variable] Literal.
  BinaryOperator(dynamic first, dynamic second) {
    this.first = _toExpression(first);
    this.second = _toExpression(second);
  }

  /// Creates a new [BinaryOperator] from two given expressions.
  BinaryOperator.raw(this.first, this.second);
}

/// A unary operator takes one argument and performs an operation on it.
abstract class UnaryOperator extends Expression {
  late final Expression exp;

  /// Creates a [UnaryOperator] from the given argument.
  ///
  /// If the argument is not an expression, it will be wrapped in an appropriate
  /// literal.
  ///
  /// * A (positive) number will be encapsulated in a [Number] Literal,
  /// * A string will be encapsulated in a [Variable] Literal.
  UnaryOperator(dynamic exp) {
    this.exp = _toExpression(exp);
  }

  /// Creates a [UnaryOperator] from the given expression.
  UnaryOperator.raw(this.exp);
}

/// The unary minus negates its argument.
class UnaryMinus extends UnaryOperator {
  /// Creates a new unary minus operation on the given expression.
  ///
  /// For example, to create -1:
  ///
  ///     one = Number(1);
  ///     minus_one = UnaryMinus(one);
  ///
  /// or just:
  ///
  ///     minus_one = UnaryMinus(1);
  UnaryMinus(dynamic exp) : super(exp);

  @override
  Expression derive(String toVar) => UnaryMinus(exp.derive(toVar));

  /// Possible simplifications:
  ///
  /// 1. -(-a) = a
  /// 2. -0 = 0
  @override
  Expression simplify() {
    final Expression simplifiedOp = exp.simplify();

    // double minus
    if (simplifiedOp is UnaryMinus) {
      return simplifiedOp.exp;
    }

    // operand == 0
    if (_isNumber(simplifiedOp, 0)) {
      return simplifiedOp;
    }

    // nothing to do..
    return UnaryMinus(simplifiedOp);
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) =>
      -(exp.evaluate(type, context));

  @override
  String toString() => '(-$exp)';
}

class UnaryPlus extends UnaryOperator {
  /// Creates a new unary plus operation on the given expression.
  ///
  /// For example, to create +1:
  ///
  ///     one = Number(1);
  ///     plus_one = UnaryPlus(one);
  ///
  /// or just:
  ///
  ///     plus_one = UnaryPlus(1);
  UnaryPlus(dynamic exp) : super(exp);

  @override
  Expression derive(String toVar) => UnaryPlus(exp.derive(toVar));

  /// Possible simplifications:
  ///
  /// 1. +a = a
  @override
  Expression simplify() => exp.simplify();

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) =>
      exp.evaluate(type, context);

  @override
  String toString() => '(+$exp)';
}

/// The plus operator performs an addition.
class Plus extends BinaryOperator {
  /// Creates an addition operation on the given expressions.
  //
  /// For example, to create x + 4:
  ///
  ///     addition = Plus('x', 4);
  ///
  /// or:
  ///
  ///     addition = Variable('x') + Number(4);
  Plus(dynamic first, dynamic second) : super(first, second);

  @override
  Expression derive(String toVar) =>
      Plus(first.derive(toVar), second.derive(toVar));

  /// Possible simplifications:
  ///
  /// 1. a + 0 = a
  /// 2. 0 + a = a
  /// 3. a + -(b) = a - b
  @override
  Expression simplify() {
    final Expression firstOp = first.simplify();
    final Expression secondOp = second.simplify();

    if (_isNumber(firstOp, 0)) {
      return secondOp;
    }

    if (_isNumber(secondOp, 0)) {
      return firstOp;
    }

    if (secondOp is UnaryMinus) {
      return firstOp - secondOp.exp; // a + -(b) = a - b
    }

    return Plus(firstOp, secondOp);
    //TODO -a + b = b - a
    //TODO -a - b = - (a+b)
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) =>
      first.evaluate(type, context) + second.evaluate(type, context);

  @override
  String toString() => '($first + $second)';
}

/// The LowerThan operator returns 1 (as double) if true, 0 (as double) if false
class LowerThan extends BinaryOperator{
  LowerThan(dynamic first, dynamic second) : super(first, second);

  @override
  Expression derive(String toVar) =>
      LowerThan(first.derive(toVar), second.derive(toVar));

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic firstEval = first.evaluate(type, context);
    final dynamic secondEval = second.evaluate(type, context);
    double _true = 1;
    double _false = 0;

    if(firstEval is double && secondEval is double){
      if (firstEval < secondEval){
        return _true;
      }
    }
    return _false;
  }


  @override
  String toString() => '($first < $second)';
}

/// The LowerThanOrEqual operator returns 1 (as double) if true, 0 (as double) if false
class LowerThanOrEqualTo extends BinaryOperator{
  LowerThanOrEqualTo(dynamic first, dynamic second) : super(first, second);

  @override
  Expression derive(String toVar) =>
      LowerThanOrEqualTo(first.derive(toVar), second.derive(toVar));

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic firstEval = first.evaluate(type, context);
    final dynamic secondEval = second.evaluate(type, context);
    double _true = 1;
    double _false = 0;

    if(firstEval is double && secondEval is double){
      if (firstEval <= secondEval){
        return _true;
      }
    }
    return _false;
  }


  @override
  String toString() => '($first <= $second)';
}

/// The minus operator performs a subtraction.
class Minus extends BinaryOperator {
  /// Creates a subtaction operation on the given expressions.
  ///
  /// For example, to create 5 - x:
  ///
  ///     subtraction = Minus(5, 'x');
  ///
  /// or:
  ///
  ///     subtraction = Number(5) - Variable('x');
  Minus(dynamic first, dynamic second) : super(first, second);

  @override
  Expression derive(String toVar) =>
      Minus(first.derive(toVar), second.derive(toVar));

  /// Possible simplifications:
  ///
  /// 1. a - 0 = a
  /// 2. 0 - a = - a
  /// 3. a - -(b) = a + b
  @override
  Expression simplify() {
    final Expression firstOp = first.simplify();
    final Expression secondOp = second.simplify();

    if (_isNumber(secondOp, 0)) {
      return firstOp;
    }

    if (_isNumber(firstOp, 0)) {
      return -secondOp;
    }

    if (secondOp is UnaryMinus) {
      return firstOp + secondOp.exp; // a - -(b) = a + b
    }

    return Minus(firstOp, secondOp);
    //TODO -a + b = b - a
    //TODO -a - b = - (a + b)
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) =>
      first.evaluate(type, context) - second.evaluate(type, context);

  @override
  String toString() => '($first - $second)';
}

/// The times operator performs a multiplication.
class Times extends BinaryOperator {
  /// Creates a product operation on the given expressions.
  ///
  /// For example, to create 7 * x:
  ///
  ///     product = Times(7, 'x');
  ///
  /// or:
  ///
  ///     product = Number(7) * Variable('x');
  Times(dynamic first, dynamic second) : super(first, second);

  @override
  Expression derive(String toVar) => Plus(
      Times(first, second.derive(toVar)), Times(first.derive(toVar), second));

  /// Possible simplifications:
  ///
  /// 1. -a * b = - (a * b)
  /// 2. a * -b = - (a * b)
  /// 3. -a * -b = a * b
  /// 4. a * 0 = 0
  /// 5. 0 * a = 0
  /// 6. a * 1 = a
  /// 7. 1 * a = a
  @override
  Expression simplify() {
    Expression firstOp = first.simplify();
    Expression secondOp = second.simplify();
    Expression? tempResult;

    bool negative = false;
    if (firstOp is UnaryMinus) {
      firstOp = (firstOp).exp;
      negative = !negative;
    }

    if (secondOp is UnaryMinus) {
      secondOp = (secondOp).exp;
      negative = !negative;
    }

    if (_isNumber(firstOp, 0)) {
      return firstOp; // = 0
    }

    if (_isNumber(firstOp, 1)) {
      tempResult = secondOp;
    }

    if (_isNumber(secondOp, 0)) {
      return secondOp; // = 0
    }

    if (_isNumber(secondOp, 1)) {
      tempResult = firstOp;
    }

    // If temp result is not set, we return a multiplication
    if (tempResult == null) {
      tempResult = Times(firstOp, secondOp);
      return negative ? -tempResult : tempResult;
    }

    // Otherwise we return the only constant and just check for sign before
    return negative ? UnaryMinus(tempResult) : tempResult;
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic firstEval = first.evaluate(type, context);
    final dynamic secondEval = second.evaluate(type, context);

    if (type == EvaluationType.VECTOR) {
      if (secondEval is double) {
        // scale - nothing special to do
      } else {
        // multiply
        final dynamic eval = firstEval.clone()..multiply(secondEval);
        return eval;
      }
    }

    return firstEval * secondEval;
  }

  @override
  String toString() => '($first * $second)';
}

/// The divide operator performs a division.
class Divide extends BinaryOperator {
  /// Creates a division operation on the given expressions.
  ///
  /// For example, to create x/(y+2):
  ///
  ///     div = Divide('x', Plus('y', 2));
  ///
  /// or:
  ///
  ///     div = Variable('x') / (Variable('y') + Number(2));
  Divide(dynamic dividend, dynamic divisor) : super(dividend, divisor);

  @override
  Expression derive(String toVar) =>
      ((first.derive(toVar) * second) - (first * second.derive(toVar))) /
      (second * second);

  /// Possible simplifications:
  ///
  /// 1. -a / b = - (a / b)
  /// 2. a / -b = - (a / b)
  /// 3. -a / -b = a / b
  /// 5. 0 / a = 0
  /// 6. a / 1 = a
  @override
  Expression simplify() {
    Expression firstOp = first.simplify();
    Expression secondOp = second.simplify();
    Expression tempResult;

    bool negative = false;

    if (firstOp is UnaryMinus) {
      firstOp = (firstOp).exp;
      negative = !negative;
    }

    if (secondOp is UnaryMinus) {
      secondOp = (secondOp).exp;
      negative = !negative;
    }

    if (_isNumber(firstOp, 0)) {
      return firstOp; // = 0
    }

    if (_isNumber(secondOp, 1)) {
      tempResult = firstOp;
    } else {
      tempResult = Divide(firstOp, secondOp);
    }

    return negative ? UnaryMinus(tempResult) : tempResult;
    // TODO cancel down/out? - needs equals on literals (and expressions?)!
  }

  /// For real numbers this method performs a double divison and
  /// returns [double.infinity] if a divide by zero is encountered.
  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic firstEval = first.evaluate(type, context);
    final dynamic secondEval = second.evaluate(type, context);

    if (type == EvaluationType.VECTOR) {
      if (secondEval is double) {
        // scale - nothing special to do
      } else {
        // divide
        final dynamic eval = firstEval.clone()..divide(secondEval);
        return eval;
      }
    }

    return firstEval / secondEval;
  }

  @override
  String toString() => '($first / $second)';
}

/// The modulo operator performs a Euclidean modulo operation, as Dart performs
/// it. That is, a % b = a - floor(a / |b|) |b|. For positive integers, this is a
/// remainder.
class Modulo extends BinaryOperator {
  /// Creates a modulo operation on the given expressions.
  ///
  /// For example, to create x % (y+2):
  ///
  ///     r = Modulo('x', Plus('y', 2));
  /// or:
  ///
  ///     r = Variable('x') % (Variable('y') + Number(2));
  Modulo(dynamic dividend, dynamic divisor) : super(dividend, divisor);

  @override
  Expression derive(String toVar) {
    final Abs a2 = Abs(second);
    return first.derive(toVar) - Floor(first / a2) * a2.derive(toVar);
  }

  /// Possible simplifications:
  ///
  /// 1. a % -b = a % b
  /// 2. 0 % a = 0
  @override
  Expression simplify() {
    final Expression firstOp = first.simplify();
    Expression secondOp = second.simplify();

    if (_isNumber(firstOp, 0)) {
      return firstOp; // = 0
    }

    if (secondOp is UnaryMinus) {
      secondOp = (secondOp).exp;
    }

    return Modulo(firstOp, secondOp);
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic firstEval = first.evaluate(type, context);
    final dynamic secondEval = second.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return firstEval % secondEval;
    }

    throw UnimplementedError(
        'Evaluate Modulo with type $type not supported yet.');
  }

  @override
  String toString() => '($first % $second)';
}

/// The power operator.
class Power extends BinaryOperator {
  /// Creates a power operation on the given expressions.
  ///
  /// For example, to create x^3:
  ///
  ///     pow = Power('x', 3);
  /// or:
  ///
  ///     pow = Variable('x') ^ Number(3.0);
  Power(dynamic x, dynamic exp) : super(x, exp);

  @override
  Expression derive(String toVar) => this.asE().derive(toVar);

  /// Possible simplifications:
  ///
  /// 1. 0^x = 0
  /// 2. 1^x = 1
  /// 3. x^0 = 1
  /// 4. x^1 = x
  @override
  Expression simplify() {
    final Expression baseOp = first.simplify();
    final Expression exponentOp = second.simplify();

    //TODO unboxing
    /*
    bool baseNegative = false, expNegative = false;

    // unbox unary minuses
    if (baseOp is UnaryMinus) {
      baseOp = baseOp.exp;
      baseNegative = !baseNegative;
    }
    if (exponentOp is UnaryMinus) {
      exponentOp = exponentOp.exp;
      expNegative = !expNegative;
    }
    */

    if (_isNumber(baseOp, 0)) {
      return baseOp; // 0^x = 0
    }

    if (_isNumber(baseOp, 1)) {
      return baseOp; // 1^x = 1
    }

    if (_isNumber(exponentOp, 0)) {
      return Number(1.0); // x^0 = 1
    }

    if (_isNumber(exponentOp, 1)) {
      return baseOp; // x^1 = x
    }

    return Power(baseOp, exponentOp);
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final num base = first.evaluate(type, context);
    if (type == EvaluationType.REAL) {
      // Consider the following equation: x^(2/y).
      // This equation can be evaluated for any negative x, since the sub result
      // is positive due to the even numerator. However, the IEEE Standard for
      // for Floating-Point Arithmetic defines NaN in the case of a negative
      // base and a finite non-integer as the exponent. That's why we rewrite
      // the equation manually.
      if (base.isNegative && second is Divide) {
        final Expression numerator = (second as Divide).first;
        final Expression denominator = (second as Divide).second;
        final double newBase = Power(base, numerator).evaluate(type, context);
        final double newExponent = 1 / denominator.evaluate(type, context);
        return Power(newBase, newExponent).evaluate(type, context);
      }
      // In case the exponent is a unary minus e.g. x^(-(2/y)), we rewrite the
      // equation to 1/x^(2/3), for the same reason as stated above.
      if (base.isNegative && second is UnaryMinus) {
        final Expression exponent = (second as UnaryMinus).exp;
        return 1 / Power(base, exponent).evaluate(type, context);
      }
      return math.pow(base, second.evaluate(type, context));
    }

    if (type == EvaluationType.INTERVAL) {
      // Expect base to be interval.
      final Interval interval = first.evaluate(type, context);

      // Expect exponent to be a natural number.
      dynamic exponent = second.evaluate(EvaluationType.REAL, context);

      if (exponent is double) {
        //print('Warning, expected natural exponent but is real. Interpreting as int: ${this}');
        exponent = exponent.toInt();
      }

      num evalMin, evalMax;
      // Distinction of cases depending on oddity of exponent.
      if (exponent.isOdd) {
        // [x, y]^n = [x^n, y^n] for n = odd
        evalMin = math.pow(interval.min, exponent);
        evalMax = math.pow(interval.max, exponent);
      } else {
        // [x, y]^n = [x^n, y^n] for x >= 0
        if (interval.min >= 0) {
          // Positive interval.
          evalMin = math.pow(interval.min, exponent);
          evalMax = math.pow(interval.max, exponent);
        }

        // [x, y]^n = [y^n, x^n] for y < 0
        if (interval.min >= 0) {
          // Positive interval.
          evalMin = math.pow(interval.max, exponent);
          evalMax = math.pow(interval.min, exponent);
        }

        // [x, y]^n = [0, max(x^n, y^n)] otherwise
        evalMin = 0;
        evalMax = math.max(
            math.pow(interval.min, exponent), math.pow(interval.min, exponent));
      }

      assert(evalMin <= evalMax);

      return Interval(evalMin, evalMax);
    }

    throw UnimplementedError(
        'Evaluate Power with type $type not supported yet.');
  }

  @override
  String toString() => '($first^$second)';

  /// Returns the exponential form of this operation.
  /// E.g. x^4 = e^(4*ln(x))
  ///
  /// This method is used to determine the derivation of a power expression.
  Expression asE() => Exponential(second * Ln(first));
}

/// A literal can be a number, a constant or a variable.
abstract class Literal extends Expression {
  dynamic value;

  /// Creates a literal. The optional paramter `value` can be used to specify
  /// its value.
  Literal([this.value]);

  /// Returns true, if this literal is a constant.
  bool isConstant() => false;

  /// Returns the constant value of this literal.
  /// Throws StateError if literal is not constant, check before usage with
  /// `isConstant()`.
  dynamic getConstantValue() {
    throw StateError('Literal $this is not constant.');
  }

  @override
  String toString() => value.toString();
}

/// A number is a constant number literal.
class Number extends Literal {
  /// Creates a number literal with given value.
  /// Always holds a double internally.
  Number(num value) : super(value.toDouble());

  @override
  bool isConstant() => true;

  @override
  double getConstantValue() => value;

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    if (type == EvaluationType.REAL) {
      return value;
    }

    if (type == EvaluationType.INTERVAL) {
      // interpret number as interval
      final IntervalLiteral intLit = IntervalLiteral.fromSingle(this);
      return intLit.evaluate(type, context);
    }

    if (type == EvaluationType.VECTOR) {
      // interpret number as scalar
      return value;
    }

    throw UnsupportedError('Number $this can not be interpreted as: $type');
  }

  @override
  Expression derive(String toVar) => Number(0.0);
}

/// A vector of arbitrary size.
class Vector extends Literal {
  /// Creates a vector with the given element expressions.
  ///
  /// For example, to create a 3-dimensional vector:
  ///
  ///     x = y = z = Number(1);
  ///     vec3 = Vector([x, y, z]);
  Vector(List<Expression> elements) : super(elements);

  /// Convenience operator to access vector elements.
  Expression operator [](int i) => elements[i];

  /// The elements of this vector.
  List<Expression> get elements => value;

  /// The length of this vector.
  int get length => elements.length;

  @override
  Expression derive(String toVar) {
    final elementDerivative =
        elements.map((item) => item.derive(toVar)).toList();

    return Vector(elementDerivative);
  }

  /// Simplifies all elements of this vector.
  @override
  Expression simplify() {
    final simplifiedElements = elements.map((item) => item.simplify()).toList();

    return Vector(simplifiedElements);
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    if (type == EvaluationType.VECTOR) {
      // XXX Support for vectors in vectors
      final EvaluationType elementType = EvaluationType.REAL;

      if (length == 1) {
        // Does not seem to be a vector, try to return REAL.
        return elements[0].evaluate(elementType, context);
      }

      // Interpret vector elements as REAL.
      if (length == 2) {
        double x, y;
        x = elements[0].evaluate(elementType, context);
        y = elements[1].evaluate(elementType, context);
        return Vector2(x, y);
      }

      if (length == 3) {
        double x, y, z;
        x = elements[0].evaluate(elementType, context);
        y = elements[1].evaluate(elementType, context);
        z = elements[2].evaluate(elementType, context);
        return Vector3(x, y, z);
      }

      if (length == 4) {
        double x, y, z, w;
        x = elements[0].evaluate(elementType, context);
        y = elements[1].evaluate(elementType, context);
        z = elements[2].evaluate(elementType, context);
        w = elements[3].evaluate(elementType, context);
        return Vector4(x, y, z, w);
      }

      if (length > 4) {
        throw UnimplementedError(
            'Vector of arbitrary length (> 4) are not supported yet.');
      }
    }

    if (type == EvaluationType.REAL && length == 1) {
      // Interpret vector as real number.
      return elements[0].evaluate(type, context);
    }

    throw UnsupportedError(
        'Vector $this with length $length can not be interpreted as: $type');
  }

  @override
  bool isConstant() => elements.fold(
      true, (prev, elem) => prev && (elem is Literal && elem.isConstant()));

  @override
  Vector getConstantValue() {
    // TODO unit test
    final constVals = elements.map<Expression>((e) => (e is Literal)
        ? e.getConstantValue()
        : throw UnsupportedError('Vector $this is not constant.'));

    return Vector(constVals as List<Expression>);
  }
}

/// A variable is a named literal.
class Variable extends Literal {
  /// The name of this variable.
  String name;

  /// Creates a variable literal with given name.
  Variable(this.name);

  @override
  Expression derive(String toVar) => name == toVar ? Number(1.0) : Number(0.0);

  @override
  String toString() => '$name';

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) =>
      context.getExpression(name).evaluate(type, context);
}

/// A bound variable is an anonymous variable, e.g. a variable without name,
/// which is bound to an expression.
//TODO This is only used for DefaultFunctions, might as well use an expression
//      directly then and remove some complexity.. leaving this in use right now,
//      since it might be useful some time - maybe for composite functions? (FL)
class BoundVariable extends Variable {
  /// Creates an anonymous variable which is bound to the given expression.
  BoundVariable(Expression expr) : super('anon') {
    this.value = expr;
  }

  // TODO Make this work on arbitrary expressions, not just literals?
  @override
  bool isConstant() => value is Literal ? value.isConstant() : false;

  @override
  dynamic getConstantValue() => value.value;

  // Anonymous, bound variable, derive content and unbox.
  @override
  Expression derive(String toVar) => value.derive(toVar); //TODO Needs boxing?

  // TODO Might need boxing in another variable?
  //      How to reassign anonymous variables to functions?
  @override
  Expression simplify() => value.simplify();

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) =>
      value.evaluate(type, context);

  /// Put bound variable in curly brackets to make them distinguishable.
  @override
  String toString() => '{$value}';
}

/// An interval literal.
class IntervalLiteral extends Literal {
  /// The interval bounds.
  Expression min, max;

  /// Creates a new interval with given bounds.
  IntervalLiteral(this.min, this.max);

  /// Creates a new interval with identical bounds.
  IntervalLiteral.fromSingle(Expression exp)
      : this.min = exp,
        this.max = exp;

  @override
  Expression derive(String toVar) {
    // Can not derive this yet..
    // TODO Implement interval differentiation.
    throw UnimplementedError('Interval differentiation not supported yet.');
  }

  @override
  Expression simplify() => IntervalLiteral(min.simplify(), max.simplify());

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    // Interval borders should evaluate to real numbers..
    final num minEval = min.evaluate(EvaluationType.REAL, context);
    final num maxEval = max.evaluate(EvaluationType.REAL, context);

    if (type == EvaluationType.INTERVAL) {
      return Interval(minEval, maxEval);
    }

    if (type == EvaluationType.REAL) {
      // If min == max, we can interpret an interval as real.
      //TODO But should we?
      if (minEval == maxEval) {
        return minEval;
      }
    }

    throw UnsupportedError('Interval $this can not be interpreted as: $type');
  }

  @override
  String toString() => 'I[$min, $max]';

  @override
  bool isConstant() =>
      min is Literal &&
      (min as Literal).isConstant() &&
      max is Literal &&
      (max as Literal).isConstant();

  @override
  Interval getConstantValue() => Interval(
      (min as Literal).getConstantValue(), (max as Literal).getConstantValue());
}
