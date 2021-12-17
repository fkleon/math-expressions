part of math_expressions;

/// A function with an arbitrary number of arguments.
///
/// __Note:__ Functions do not offer auto-wrapping of arguments into [Literal]s.
abstract class MathFunction extends Expression {
  /// Name of this function.
  String name;

  /// List of arguments of this function. Arguments ust be of type [Variable].
  List<Variable> args;

  /// Creates a new function with the given name and arguments.
  MathFunction(this.name, this.args);

  /// Creates a new function with the given name.
  ///
  /// __Note__:
  /// Must only be used internally by subclasses, as it does not define any
  /// arguments.
  MathFunction._empty(this.name) : args = [];

  /// Compose operator. Creates a [CompositeFunction].
  MathFunction operator &(MathFunction g) => CompositeFunction(this, g);

  /// Returns the i-th parameter of this function (0-based).
  Variable getParam(int i) => args[i];

  /// Returns the parameter with the given name.
  Variable getParamByName(String name) =>
      args.singleWhere((e) => e.name == name);

  /// The dimension of the domain of definition of this function.
  int get domainDimension => args.length;

  @override
  String toString() => '$name($args)';

  /// Returns the full string representation of this function.
  /// This could include the name, variables and expression.
  ///
  /// Any subclass should decide whether to override this method.
  String toFullString() => toString();
}

/// A composition of two given [MathFunction]s.
//TODO: How to infer evaluator types? How to infer domain and range? How to check compatibility?
//      Allow composites which are not complete and create new functions?
//      -> Add more information on expected behaviour to MathFunctions? Better matching!
//      -> What if functions are overloaded and can operate on several types? Duplicate functions..
class CompositeFunction extends MathFunction {
  /// Members `f` and `g` of the composite function.
  MathFunction f, g;

  /// Creates a function composition.
  ///
  /// For example, given `f(x): R -> R^3` and `g(x,y,z): R^3 -> R`
  /// the composition yields `(g ° f)(x): R -> R^3 -> R`. First
  /// `f` is applied, then `g` is applied.
  ///
  /// Given some requirements
  ///
  ///     x = Variable('x');
  ///     xPlus = Plus(x, 1);
  ///     xMinus = Minus(x, 1);
  ///
  ///     fExpr = Vector([x, xPlus, xMinus]);        // Transforms x to 3-dimensional vector
  ///     f = CustomFunction('f', [x], fExpr);       // Creates a function R -> R^3 from fExpr
  ///
  ///     y = Variable('z');
  ///     z = Variable('y');
  ///
  ///     gExpr = x + y + z;                         // Transforms 3-dimensional input to real value
  ///     g = CustomFunction('g', [x, y, z], gExpr)  // Creates a function R^3 -> R from gExpr
  ///
  /// a composition can be created as follows:
  ///
  ///     composite = CompositeFunction(f, g); // R -> R
  ///                                          // composite(2) = 6
  CompositeFunction(this.f, this.g)
      : super('comp(${f.name},${g.name})', f.args);

  /// The domain of the 'second' function, which should match the range
  /// of the 'first function.
  int get gDomainDimension => g.domainDimension;

  /// The domain of the 'first' function.
  @override
  int get domainDimension => f.domainDimension;

  @override
  Expression derive(String toVar) {
    MathFunction gDF;
    final Expression gD = g.derive(toVar);

    if (!(gD is MathFunction)) {
      // Build function again..
      gDF = CustomFunction('d${g.name}', g.args, gD);
    } else {
      gDF = gD;
    }

    // Chain rule.
    return CompositeFunction(f, gDF) * f.derive(toVar);
  }

  /// Simplifies both component functions.
  @override
  Expression simplify() {
    final fSimpl = f.simplify() as MathFunction;
    final gSimpl = g.simplify() as MathFunction;

    return CompositeFunction(fSimpl, gSimpl);
  }

  /// The EvaluationType of `f` is detected automatically based on
  /// the domain dimension of `g`. This is because the input of
  /// `g` is the output of `f` (composite function).
  ///
  /// The given EvaluationType is used for `g` because there is no
  /// information on the expected output.
  ///
  /// Furthermore `g` is assigned a separate child scope of the given
  /// `context`, so that variable naming does not interfer with the
  /// evaluation.
  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    //TODO - Check if necessary variables have been bound to context.
    //     - Type checks.
    dynamic fEval;
    final ContextModel childScope = context.createChildScope();

    // We expect result to be of dimension gDomainDimension.
    if (gDomainDimension == 1) {
      // Expect f to evaluate to a real.
      fEval = f.evaluate(EvaluationType.REAL, context);
      // Create new context and bind (single) input of g to fEval.
      childScope.bindVariable(g.getParam(0), _toExpression(fEval));
      return g.evaluate(type, childScope);
    }

    if (gDomainDimension == 2) {
      // Expect f to evaluate to a 2-dimensional vector.
      fEval = f.evaluate(EvaluationType.VECTOR, context);
      childScope
        ..bindVariable(g.getParam(0), _toExpression(fEval.x))
        ..bindVariable(g.getParam(1), _toExpression(fEval.y));
      return g.evaluate(type, childScope);
    }

    if (gDomainDimension == 3) {
      // Expect f to evaluate to a 3-dimensional vector.
      fEval = f.evaluate(EvaluationType.VECTOR, context);
      childScope
        ..bindVariable(g.getParam(0), _toExpression(fEval.x))
        ..bindVariable(g.getParam(1), _toExpression(fEval.y))
        ..bindVariable(g.getParam(2), _toExpression(fEval.z));
      return g.evaluate(type, childScope);
    }

    if (gDomainDimension == 4) {
      // Expect f to evaluate to a 4-dimensional vector.
      fEval = f.evaluate(EvaluationType.VECTOR, context);
      childScope
        ..bindVariable(g.getParam(0), _toExpression(fEval.x))
        ..bindVariable(g.getParam(1), _toExpression(fEval.y))
        ..bindVariable(g.getParam(2), _toExpression(fEval.z))
        ..bindVariable(g.getParam(3), _toExpression(fEval.w));
      return g.evaluate(type, childScope);
    }

    //TODO Handle arbitrary vectors.
    throw UnimplementedError('Vectors > 4 not supported yet.');
  }
}

/// A user-defined [MathFunction] with an arbitrary expression.
//TODO Interpret as Function call instead?
class CustomFunction extends MathFunction {
  /// Function expression of this function.
  /// Used for non-default or user-defined functions.
  Expression expression;

  /// Create a custom function with the given name, argument variables,
  /// and expression.
  ///
  /// For example, the following is the implementation of the arithmetical left
  /// shift operation as a custom function. It is characterised as
  /// `f(x, k): R^2 -> R`, where `x` is the value to be multiplied by 2 to the
  /// power of `k`.
  ///
  ///     k = Variable('k');
  ///     fExpr = x * Power(2, k);                        // The left shift operation
  ///     f = CustomFunction('leftshift', [x, k], fExpr); // Creates a function R^2 -> R from fExpr
  ///
  /// The name of the function has no functional impact, and is only used in the
  /// string representation.
  CustomFunction(String name, List<Variable> args, this.expression)
      : super(name, args);

  @override
  Expression derive(String toVar) =>
      CustomFunction(name, args, expression.derive(toVar));

  @override
  Expression simplify() => CustomFunction(name, args, expression.simplify());

  // TODO: Substitute external variables?
  //       => Shouldn't be necessary as context model is handed over.
  //          (FL 2013-11-08)
  @override
  dynamic evaluate(EvaluationType type, ContextModel context) =>
      // TODO: First check if all necessary variables are bound.
      //       => Not necessary with current system, has to be handled by calling
      //          instance (throws unbound variable exception).
      //          (FL 2013-11-08)
      expression.evaluate(type, context);

  @override
  String toFullString() => '$name($args) = $expression';
}

/// A default function is predefined in this library.
/// It contains no expression because the appropriate evaluation method usually
/// uses native Dart math code.
///
/// __Note__:
/// User-defined custom functions should derive from [CustomFunction], which
/// supports arbitrary expressions.
abstract class DefaultFunction extends MathFunction {
  /// Creates a new unary function with given name and argument.
  /// If the argument is not a variable, it will be wrapped into an anonymous
  /// variable, which binds the given expression.
  ///
  /// __Note__:
  /// Must only be used internally for pre-defined functions, as it does not
  /// contain any expression. The Evaluator needs to know how to handle this.
  DefaultFunction._unary(String name, Expression arg) : super._empty(name) {
    final Variable bindingVariable = _wrapIntoVariable(arg);
    this.args = <Variable>[bindingVariable];
  }

  /// Creates a new binary function with given name and two arguments.
  /// If the arguments are not variables, they will be wrapped into anonymous
  /// variables, which bind the given expressions.
  ///
  /// __Note__:
  /// Must only be used internally for pre-defined functions, as it does not
  /// contain any expression. The Evaluator needs to know how to handle this.
  DefaultFunction._binary(String name, Expression arg1, Expression arg2)
      : super._empty(name) {
    final Variable bindingVariable1 = _wrapIntoVariable(arg1);
    final Variable bindingVariable2 = _wrapIntoVariable(arg2);
    this.args = <Variable>[bindingVariable1, bindingVariable2];
  }

  /// Creates a new function with given name and any arguments.
  /// If the arguments are not variables, they will be wrapped into anonymous
  /// variables, which bind the given expressions.
  DefaultFunction._any(String name, List<Expression> args)
      : super._empty(name) {
    this.args = args.map((arg) => _wrapIntoVariable(arg)).toList();
  }

  /// Returns a variable, bound to the given [Expression].
  /// Returns the parameter itself, if it is already a variable.
  Variable _wrapIntoVariable(Expression e) {
    if (e is Variable) {
      // Good to go..
      return e;
    } else {
      // Need to wrap..
      return BoundVariable(e);
    }
  }

  @override
  String toString() => '$name(${args.join(',')})';
}

/// The exponential function.
class Exponential extends DefaultFunction {
  /// Creates a exponential operation on the given expressions.
  ///
  /// For example, to create e^4:
  ///
  ///     four = Number(4);
  ///     exp = Exponential(four);
  ///
  /// You also can use variables or arbitrary expressions:
  ///
  ///     x = Variable('x');
  ///     exp = Exponential(x);
  ///     exp = Exponential(x + four);
  Exponential(Expression exp) : super._unary('e', exp);

  /// The exponent of this exponential function.
  Expression get exp => getParam(0);

  @override
  Expression derive(String toVar) => Times(this, exp.derive(toVar));

  /// Possible simplifications:
  ///
  /// 1. e^0 = 1
  /// 2. e^1 = e
  /// 3. e^(x*ln(y)) = y^x (usually easier to read for humans)
  @override
  Expression simplify() {
    final Expression expSimpl = exp.simplify();

    if (_isNumber(expSimpl, 0)) {
      return Number(1); // e^0 = 1
    }

    if (_isNumber(expSimpl, 1)) {
      return Number(math.e); // e^1 = e
    }

    if (expSimpl is Times && expSimpl.second is Ln) {
      final ln = expSimpl.second as Ln;
      return Power(ln.arg, expSimpl.first); // e^(x*ln(y)) = y^x
    }

    return Exponential(expSimpl);
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic expEval = exp.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      // Expect exponent to be real number.
      return math.exp(expEval);
    }

    if (type == EvaluationType.INTERVAL) {
      // Special case of a^[x, y] = [a^x, a^y] for a > 1 (with a = e)
      // Expect exponent to be interval.
      return Interval(math.exp(expEval.min), math.exp(expEval.max));
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }
}

/// The logarithm function.
class Log extends DefaultFunction {
  /// Creates a logarithm function with given base and argument.
  ///
  /// For example, to create log_10(2):
  ///
  ///     base = Number(10);
  ///     arg = Number(2);
  ///     log = Log(base, arg);
  ///
  /// To create a naturally based logarithm, see [Ln].
  Log(Expression base, Expression arg) : super._binary('log', base, arg);

  /// Creates a natural logarithm.
  /// Must only be used internally by the [Ln] class.
  Log._ln(Expression arg) : super._binary('ln', Number(math.e), arg);

  /// The base of this logarithm.
  Expression get base => getParam(0);

  /// The argument of this logarithm.
  Expression get arg => getParam(1);

  @override
  Expression derive(String toVar) => this.asNaturalLogarithm().derive(toVar);

  /// Simplifies base and argument.
  @override
  Expression simplify() => Log(base.simplify(), arg.simplify());

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    if (type == EvaluationType.REAL) {
      // Be lazy, convert to Ln.
      return asNaturalLogarithm().evaluate(type, context);
    }

    if (type == EvaluationType.INTERVAL) {
      // log_a([x, y]) = [log_a(x), log_a(y)] for [x, y] positive and a > 1
      return asNaturalLogarithm().evaluate(type, context);
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }

  /// Returns the natural from of this logarithm.
  /// E.g. log_10(2) = ln(2) / ln(10)
  ///
  /// This method is used to determine the derivation of a logarithmic
  /// expression.
  Expression asNaturalLogarithm() => Ln(arg) / Ln(base);
}

/// The natural logarithm (log based e).
class Ln extends Log {
  /// Creates a natural logarithm function with given argument.
  ///
  /// For example, to create ln(10):
  ///
  ///     num10 = Number(10);
  ///     ln = Ln(num10);
  ///
  /// To create a logarithm with arbitrary base, see [Log].
  Ln(Expression arg) : super._ln(arg);

  @override
  Expression derive(String toVar) => arg.derive(toVar) / arg;

  /// Possible simplifications:
  ///
  /// 1. ln(1) = 0
  @override
  Expression simplify() {
    final Expression argSimpl = arg.simplify();

    if (_isNumber(argSimpl, 1)) {
      return Number(0); // ln(1) = 0
    }

    return Ln(argSimpl);
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return math.log(argEval);
    }

    if (type == EvaluationType.INTERVAL) {
      // Expect argument of type interval
      return Interval(math.log(argEval.min), math.log(argEval.max));
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }

  @override
  String toString() => 'ln($arg)';
}

/// The n-th root function. n needs to be a natural number.
//TODO: Allow n to be an expression?
class Root extends DefaultFunction {
  /// N-th root.
  late final int n;

  /// Creates the n-th root of arg.
  ///
  /// For example, to create the 5th root of x:
  ///
  ///     root = Root(5, Variable('x'));
  Root(this.n, Expression arg) : super._unary('nrt', arg);

  /// Creates the n-th root of arg where n is a [Number] literal.
  Root.fromExpr(Number n, Expression arg) : super._unary('nrt', arg) {
    this.n = n.getConstantValue().toInt();
  }

  /// Creates the square root of arg.
  ///
  /// For example, to create the square root of x:
  ///
  ///     sqrt = Root.sqrt(Variable('x'));
  ///
  /// __Note__:
  /// For better simplification and display, use the [Sqrt] class.
  Root.sqrt(Expression arg)
      : n = 2,
        super._unary('sqrt', arg);

  Expression get arg => getParam(0);

  @override
  Expression derive(String toVar) => this.asPower().derive(toVar);

  /// Simplify argument.
  @override
  Expression simplify() => Root(n, arg.simplify());

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) =>
      this.asPower().evaluate(type, context);

  @override
  String toString() => 'nrt($n,$arg)';

  /// Returns the power form of this root.
  /// E.g. root_5(x) = x^(1/5)
  ///
  /// This method is used to determine the derivation of a root
  /// expression.
  Expression asPower() => Power(arg, Divide(Number(1), Number(n)));
}

/// The square root function. A specialisation of [Root].
class Sqrt extends Root {
  /// Creates the square root of arg.
  ///
  /// For example, to create the square root of x:
  ///
  ///     sqrt = Sqrt(Variable('x'));
  Sqrt(Expression arg) : super.sqrt(arg);

  /// Possible simplifications:
  ///
  /// 1. sqrt(x^2) = x
  /// 2. sqrt(0) = 0
  /// 3. sqrt(1) = 1
  ///
  /// __Note__:
  /// This simplification works _only_ for real numbers and _not_ for complex
  /// numbers.
  @override
  Expression simplify() {
    final Expression argSimpl = arg.simplify();

    if (argSimpl is Power) {
      final Expression exponent = argSimpl.second;
      if (exponent is Number) {
        if (exponent.value == 2) {
          return argSimpl.first; // sqrt(x^2) = x
        }
      }
    }

    if (_isNumber(argSimpl, 0)) {
      return Number(0); // sqrt(0) = 0
    }

    if (_isNumber(argSimpl, 1)) {
      return Number(1); // sqrt(1) = 1
    }

    return Sqrt(argSimpl);
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return math.sqrt(argEval);
    }

    if (type == EvaluationType.VECTOR) {
      //TODO apply function to all vector elements
    }

    if (type == EvaluationType.INTERVAL) {
      // Piecewiese sqrting.
      return Interval(math.sqrt(argEval.min), math.sqrt(argEval.max));
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }

  @override
  String toString() => 'sqrt($arg)';
}

/// The sine function. Expects input in `radians`.
class Sin extends DefaultFunction {
  /// Creates a new sine function with given argument expression.
  Sin(Expression arg) : super._unary('sin', arg);

  /// The argument of this sine function.
  Expression get arg => getParam(0);

  @override
  Expression derive(String toVar) => Cos(arg) * arg.derive(toVar);

  /// Possible simplifications:
  ///
  /// 1. sin(0) = 0
  @override
  Expression simplify() {
    final Expression argSimpl = arg.simplify();

    if (_isNumber(argSimpl, 0)) {
      return Number(0); // sin(0) = 0
    }

    return Sin(argSimpl);
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      // Compensate for inaccuracies in machine-pi.
      // If argEval divides cleanly from pi, return 0.
      if ((argEval / math.pi).abs() % 1 == 0) {
        return 0.0;
      }
      return math.sin(argEval);
    }

    if (type == EvaluationType.VECTOR) {
      //TODO Apply function to all vector elements
    }

    if (type == EvaluationType.INTERVAL) {
      // TODO evaluate endpoints and critical points ((1/2 + n) * pi)
      // or just return [-1, 1] if half a period is in the given interval
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }
}

/// The cosine function. Expects input in `radians`.
class Cos extends DefaultFunction {
  /// Creates a new cosine function with given argument expression.
  Cos(Expression arg) : super._unary('cos', arg);

  /// The argument of this cosine function.
  Expression get arg => getParam(0);

  @override
  Expression derive(String toVar) => -Sin(arg) * arg.derive(toVar);

  /// Possible simplifications:
  ///
  /// 1. cos(0) = 1
  @override
  Expression simplify() {
    final Expression argSimpl = arg.simplify();

    if (_isNumber(argSimpl, 0)) {
      return Number(1); // cos(0) = 1
    }

    return Cos(argSimpl);
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      // Compensate for inaccuracies in machine-pi.
      //
      // If argEval divides cleanly from pi (when shifted back to Sin from Cos), return 0.
      if (((argEval - math.pi / 2) / math.pi).abs() % 1 == 0) {
        return 0.0;
      }
      return math.cos(argEval);
    }

    if (type == EvaluationType.VECTOR) {
      //TODO apply function to all vector elements
    }

    if (type == EvaluationType.INTERVAL) {
      // TODO evaluate endpoints and critical points (n * pi)
      // or just return [-1, 1] if half a period is in the given interval
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }
}

/// The tangens function. Expects input in `radians`.
class Tan extends DefaultFunction {
  /// Creates a new tangens function with given argument expression.
  Tan(Expression arg) : super._unary('tan', arg);

  /// The argument of this tangens function.
  Expression get arg => getParam(0);

  @override
  Expression derive(String toVar) => asSinCos().derive(toVar);

  /// Possible simplifications:
  ///
  /// 1. tan(0) = 0
  @override
  Expression simplify() {
    final Expression argSimpl = arg.simplify();

    if (_isNumber(argSimpl, 0)) {
      return Number(0); // tan(0) = 0
    }

    return Tan(argSimpl);
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      // Compensate for inaccuracies in machine-pi.
      // If argEval divides cleanly from pi, return 0.
      if ((argEval / math.pi).abs() % 1 == 0) {
        return 0.0;
      }
      return math.tan(argEval);
    }

    if (type == EvaluationType.VECTOR) {
      //TODO apply function to all vector elements
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }

  /// Returns this tangens as sine and cosine representation:
  /// `tan(x) = sin(x) / cos(x)`
  Expression asSinCos() => Sin(arg) / Cos(arg);
}

/// The arcus sine function.
class Asin extends DefaultFunction {
  /// Creates a new arcus sine function with given argument expression.
  Asin(Expression arg) : super._unary('arcsin', arg);

  /// The argument of this arcus sine function.
  Expression get arg => getParam(0);

  @override
  Expression derive(String toVar) =>
      Number(1) / Sqrt(Number(1) - (arg ^ Number(2)));

  /// Possible simplifications:
  @override
  Expression simplify() {
    return Asin(arg.simplify());
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return math.asin(argEval);
    }

    // TODO VECTOR and INTERVAL evaluation
    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }
}

/// The arcus cosine function.
class Acos extends DefaultFunction {
  /// Creates a new arcus cosine function with given argument expression.
  Acos(Expression arg) : super._unary('arccos', arg);

  /// The argument of this arcus cosine function.
  Expression get arg => getParam(0);

  @override
  Expression derive(String toVar) =>
      -Number(1) / Sqrt(Number(1) - (arg ^ Number(2)));

  /// Possible simplifications:
  @override
  Expression simplify() {
    return Acos(arg.simplify());
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return math.acos(argEval);
    }

    // TODO VECTOR and INTERVAL evaluation
    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }
}

/// The arcus tangens function.
class Atan extends DefaultFunction {
  /// Creates a new arcus tangens function with given argument expression.
  Atan(Expression arg) : super._unary('arctan', arg);

  /// The argument of this arcus tangens function.
  Expression get arg => getParam(0);

  @override
  Expression derive(String toVar) =>
      Number(1) / (Number(1) + (arg ^ Number(2)));

  /// Possible simplifications:
  @override
  Expression simplify() {
    return Atan(arg.simplify());
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return math.atan(argEval);
    }

    // TODO VECTOR and INTERVAL evaluation
    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }
}

/// The absolute value function.
class Abs extends DefaultFunction {
  /// Creates a new absolute value function with given argument expression.
  Abs(Expression arg) : super._unary('abs', arg);

  /// The argument of this absolute value function.
  Expression get arg => getParam(0);

  /// The differentiation of Abs is Sgn
  //TODO No differentiation possible for x = 0
  @override
  Expression derive(String toVar) => Sgn(arg) * arg.derive(toVar);

  /// Possible simplifications:
  @override
  Expression simplify() => Abs(arg.simplify());

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return argEval.abs();
    }

    if (type == EvaluationType.VECTOR) {
      //TODO apply function to all vector elements
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }
}

/// The ceil function.
class Ceil extends DefaultFunction {
  /// Creates a new ceil function with given argument expression.
  Ceil(Expression arg) : super._unary('ceil', arg);

  /// The argument of this ceil function.
  Expression get arg => getParam(0);

  /// Ceil never has a slope.
  //TODO No differentiation possible for integer x
  @override
  Expression derive(String toVar) => Number(0);

  /// Possible simplifications:
  ///
  /// 1. ceil(floor(a)) = floor(a)
  /// 2. ceil(ceil(a)) = ceil(a)
  @override
  Expression simplify() {
    final Expression sarg = arg.simplify();
    return sarg is Floor || sarg is Ceil ? sarg : Ceil(sarg);
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return argEval.ceil().toDouble();
    }

    if (type == EvaluationType.VECTOR) {
      //TODO apply function to all vector elements
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }
}

/// The floor function.
class Floor extends DefaultFunction {
  /// Creates a new floor function with given argument expression.
  Floor(Expression arg) : super._unary('floor', arg);

  /// The argument of this floor function.
  Expression get arg => getParam(0);

  /// Floor never has a slope.
  //TODO No differentiation possible for integer x
  @override
  Expression derive(String toVar) => Number(0);

  /// Possible simplifications:
  ///
  /// 1. floor(floor(a)) = floor(a)
  /// 2. floor(ceil(a)) = ceil(a)
  @override
  Expression simplify() {
    final Expression sarg = arg.simplify();
    return (sarg is Floor) || (sarg is Ceil) ? sarg : Floor(sarg);
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return argEval.floor().toDouble();
    }

    if (type == EvaluationType.VECTOR) {
      //TODO apply function to all vector elements
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }
}

/// The sign function.
class Sgn extends DefaultFunction {
  /// Creates a new sign function with given argument expression.
  Sgn(Expression arg) : super._unary('sgn', arg);

  /// The argument of this sign function.
  Expression get arg => getParam(0);

  //TODO not differentiable at 0.
  @override
  Expression derive(String toVar) => Number(0);

  @override
  Expression simplify() => Sgn(arg.simplify());

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      if (argEval < 0) return -1.0;
      if (argEval == 0) return 0.0;
      if (argEval > 0) return 1.0;
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }
}

/// simple factorial function
/// might be expanded to the [Gamma function](https://en.wikipedia.org/wiki/Gamma_function)
/// to allow negative and complex numbers and deriving
class Factorial extends DefaultFunction {
  Factorial(Expression arg) : super._unary('factorial', arg);

  Expression get arg => getParam(0);

  @override
  String toString() => '$arg!';

  @override
  Expression derive(String toVar) => Number(0);

  @override
  Expression simplify() {
    final Expression sarg = arg.simplify();
    if (sarg is Number && (sarg.value == 0 || sarg.value == 1)) {
      return Number(1);
    }
    return Factorial(arg.simplify());
  }

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    final dynamic argEval = arg.evaluate(type, context);

    if (argEval < 0) {
      throw ArgumentError.value(
          argEval, 'Factorial', 'Negative values not supported.');
    } else if (argEval == double.infinity) {
      throw ArgumentError.value(
          argEval, 'Factorial', 'Infinity not supported.');
    }
    if (type == EvaluationType.REAL) {
      dynamic product = 1.0;
      for (int i = 1; i <= argEval.round(); i++) {
        product *= i;
      }
      return product;
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }
}

class AlgorithmicFunction extends DefaultFunction {
  /// Creates a generic function with variable number of arguments.
  ///
  /// For example, to create a function that returns the minimum value
  /// in a given list of arguments:
  ///
  ///     args = [ Number(2), Number(1), Number(100) ]
  ///     handler = (List<double> args) => args.reduce(math.min)
  ///     f = AlgorithmicFunction('my_min', args, handler);
  ///
  /// The name of the function has no functional impact, and is only used in the
  /// string representation. If the function is defined via the Parser#addFunction
  /// method instead it is supported by the parser.
  AlgorithmicFunction(String name, List<Expression> args, this.handler)
      : super._any(name, args);

  Function handler;

  @override
  dynamic evaluate(EvaluationType type, ContextModel context) {
    if (type == EvaluationType.REAL) {
      List<double> values = args
          .map<double>((v) => (v.value ?? context.getExpression(v.name))
              .evaluate(type, context))
          .toList();
      return handler(values);
    }

    throw UnimplementedError('Can not evaluate $name on $type yet.');
  }

  @override
  Expression derive(String toVar) =>
      throw UnimplementedError('Can not derive algorithmic functions.');
}
