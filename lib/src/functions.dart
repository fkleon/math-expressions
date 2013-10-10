part of math_expressions;

/**
 * A function with an arbitrary number of arguments.
 *
 * **Note:** Functions do not offer auto-wrapping of arguments into [Literal]s.
 */
abstract class MathFunction extends Expression {
  /// Name of this function.
  String name;

  /// List of arguments of this function.
  /// Must be a variable.
  List<Variable> args;

  //TODO
  // isComplete() => all bound?

  /**
   * Creates a new function with the given name and arguments.
   */
  MathFunction(this.name, this.args);

  /**
   * Creates a new function with the given name.
   *
   * __Note__:
   * Must only be used internally by subclasses, as it does not define any
   * arguments.
   */
  MathFunction._empty(this.name);

  /**
   * Returns the i-th parameter of this function.
   */
  Variable getParam(int i) => args[i];

  /// The dimension of the domain of definition of this function.
  int get domainDimension => args.length;

  String toString() => '$name($args)';

  /**
   * Returns the full string representation of this function.
   * This could include the name, variables and expression.
   *
   * Any subclass should decide whether to override this method.
   */
  String toFullString() => toString();
}

/**
 * A composition of two given [MathFunction]s.
 */
//TODO: How to infer evaluator types? How to infer domain and range? How to check compatibility?
//      Allow composites which are not complete and create new functions?
//      -> Add more information on expected behaviour to MathFunctions? Better matching!
//      -> What if functions are overloaded and can operate on several types? Duplicate functions..
class CompositeFunction extends MathFunction {
  /// Members `f` and `g` of the composite function.
  MathFunction f, g;

  /**
   * Creates a function composition.
   *
   * For example, given `f(x): R -> R^3` and `g(x,y,z): R^3 -> R`
   * the composition yields `(g ° f)(x): R -> R^3 -> R`. First
   * `f` is applied, then `g` is applied.
   *
   * Given some requirements
   *     x = new Variable('x');
   *     xPlus = new Plus(x, 1);
   *     xMinus = new Minus(x, 1);
   *
   *     fExpr = new Vector([x, xPlus, xMinus]);        // Transforms x to 3-dimensional vector
   *     f = new CustomFunction('f', [x], fExpr);       // Creates a function R -> R^3 from fExpr
   *
   *     y = new Variable('z');
   *     z = new Variable('y');
   *
   *     gExpr = x + y + z;                             // Transforms 3-dimensional input to real value
   *     g = new CustomFunction('g', [x, y, z], gExpr)  // Creates a function R^3 -> R from gExpr
   *
   * a composition can be created as follows:
   *     composite = new CompositeFunction(f, g); // R -> R
   *                                              // composite(2) = 6
   */
  CompositeFunction(MathFunction f, MathFunction g):
    super('comp(${f.name},${g.name})', f.args) {
    this.f = f;
    this.g = g;
  }

  /// The domain of the 'second' function, which should match the range
  /// of the 'first function.
  int get gDomainDimension => g.domainDimension;

  /// The domain of the 'first' function.
  int get domainDimension => f.domainDimension;

  Expression derive(String toVar) {
    MathFunction gDF;
    Expression gD = g.derive(toVar);

    if (!(gD is MathFunction)) {
    // Build function again..
      gDF = new CustomFunction('d${g.name}', g.args, gD);
    } else {
      gDF = (gD as MathFunction);
    }

    // Chain rule.
    return new CompositeFunction(f, gDF) * f.derive(toVar);
  }

  /**
   * Simplifies both component functions.
   */
  Expression simplify() {
    MathFunction fSimpl = f.simplify();
    MathFunction gSimpl = g.simplify();

    return new CompositeFunction(fSimpl, gSimpl);
  }

  evaluate(EvaluationType type, ContextModel context) {
    //TODO check if necessary variables have been bound to context.
    //TODO type checks.
    var fEval;

    // We expect result to be of dimension gDomainDimension.
    if (gDomainDimension == 1) {
      fEval = f.evaluate(EvaluationType.REAL, context);
      // Should be a real. Bind (single) input of g to fEval.
      context.bindGlobalVariable(g.getParam(0), _toExpression(fEval));
      // and try to evaluate..
      return g.evaluate(type, context);
    }

    if (gDomainDimension == 2) {
      fEval = f.evaluate(EvaluationType.VECTOR, context);
      // Should be a 2 dimensional vector then.
      context.bindGlobalVariable(g.getParam(0), _toExpression(fEval));
      context.bindGlobalVariable(g.getParam(1), _toExpression(fEval));
      return g.evaluate(type, context);
    }

    if (gDomainDimension == 3) {
      fEval = f.evaluate(EvaluationType.VECTOR, context);
      // Should be a 3 dimensional vector then.
      context.bindGlobalVariable(g.getParam(0), _toExpression(fEval));
      context.bindGlobalVariable(g.getParam(1), _toExpression(fEval));
      context.bindGlobalVariable(g.getParam(2), _toExpression(fEval));
      return g.evaluate(type, context);
    }

    if (gDomainDimension == 4) {
      fEval = f.evaluate(EvaluationType.VECTOR, context);
      // Should be a 4 dimensional vector then.
      context.bindGlobalVariable(g.getParam(0), fEval.x);
      context.bindGlobalVariable(g.getParam(1), fEval.y);
      context.bindGlobalVariable(g.getParam(2), fEval.z);
      context.bindGlobalVariable(g.getParam(3), fEval.w);
      return g.evaluate(type, context);
    }

    if (gDomainDimension > 4) {
      //TODO Handle arbitrary vectors.
      throw new UnimplementedError('Vectors > 4 not supported yet.');
    }
  }
}

/**
 * Any user-created function is a CustomFunction.
 */
//TODO Interpret as Function call instead?
class CustomFunction extends MathFunction {
  /// Function expression of this function.
  /// Used for non-default or user-defined functions.
  Expression expression;

  /**
   * Create a custom function with the given name, argument variables,
   * and expression.
   */
  CustomFunction(String name, List<Variable> args, Expression this.expression): super(name, args);

  Expression derive(String toVar) => new CustomFunction(name, args, expression.derive(toVar));

  Expression simplify() => new CustomFunction(name, args, expression.simplify());

  //TODO variablen ersetzen/einsetzen?

  evaluate(EvaluationType type, ContextModel context) {
    //TODO First check if all necessary variables are bound.
    return expression.evaluate(type, context);
  }

  String toFullString() => '$name($args) = ${expression.toString()}';
}

/**
 * A default function is predefined in this library.
 * It contains no expression, because the appropriate [Evaluator] knows
 * how to handle them.
 *
 * __Note__:
 * User-defined custom functions should derive from [CustomFunction], which
 * supports arbitrary expressions.
 */
abstract class DefaultFunction extends MathFunction {

  /**
   * Creates a new unary function with given name and argument.
   * If the argument is not a variable, it will be wrapped into an anonymous
   * variable, which binds the given expression.
   *
   * __Note__:
   * Must only be used internally for pre-defined functions, as it does not
   * contain any expression. The Evaluator needs to know how to handle this.
   */
  DefaultFunction._unary(String name, Expression arg) : super._empty(name) {
    Variable bindingVariable = _wrapIntoVariable(arg);
    this.args = [bindingVariable];
  }

  /**
   * Creates a new binary function with given name and two arguments.
   * If the arguments are not variables, they will be wrapped into anonymous
   * variables, which bind the given expressions.
   *
   * __Note__:
   * Must only be used internally for pre-defined functions, as it does not
   * contain any expression. The Evaluator needs to know how to handle this.
   */
  DefaultFunction._binary(String name, Expression arg1, Expression arg2): super._empty(name) {
    Variable bindingVariable1 = _wrapIntoVariable(arg1);
    Variable bindingVariable2 = _wrapIntoVariable(arg2);
    this.args = [bindingVariable1, bindingVariable2];
  }

  /**
   * Returns a variable, bound to the given [Expression].
   * Returns the parameter itself, if it is already a variable.
   */
  Variable _wrapIntoVariable(Expression e) {
    if (e is Variable) {
      // Good to go..
      return e as Variable;
    } else {
      // Need to wrap..
     return new BoundVariable(e);
    }
  }
}

/**
 * The exponential function.
 */
class Exponential extends DefaultFunction {

  /**
   * Creates a exponential operation on the given expressions.
   *
   * For example, to create e^4:
   *     four = new Number(4);
   *     exp = new Exponential(four);
   *
   * You also can use variables or arbitrary expressions:
   *     x = new Variable('x');
   *     exp = new Exponential(x);
   *     exp = new Exponential(x + four);
   */
  Exponential(exp): super._unary("exp", exp);

  /// The exponent of this exponential function.
  Expression get exp => getParam(0);

  Expression derive(String toVar) => new Times(this, exp.derive(toVar));

  /**
   * Possible simplifications:
   *
   * 1. e^0 = 1
   * 2. e^1 = e
   * 3. e^(x*ln(y)) = y^x (usually easier to read for humans)
   */
  Expression simplify() {
    Expression expSimpl = exp.simplify();

    if (_isNumber(expSimpl,0)) {
      return new Number(1); // e^0 = 1
    }

    if (_isNumber(expSimpl,1)) {
      return new Number(Math.E); // e^1 = e
    }

    if (expSimpl is Times && (expSimpl as Times).second is Ln) {
     Times t = expSimpl as Times;
     Ln ln = t.second;
     return new Power(ln.arg, t.first); // e^(x*ln(y)) = y^x
    }

    return new Exponential(expSimpl);
  }

  evaluate(EvaluationType type, ContextModel context) {
    var expEval = exp.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      // Expect exponent to be real number.
      return Math.exp(expEval);
    }

    if (type == EvaluationType.INTERVAL) {
      // Special case of a^[x, y] = [a^x, a^y] for a > 1 (with a = e)
      // Expect exponent to be interval.
      return new Interval(Math.exp(expEval.min), Math.exp(expEval.max));
    }

    throw new UnimplementedError('Can not evaluate exp on ${type} yet.');
  }

  String toString() => 'exp(${exp.toString()})';
}

/**
 * The logarithm function.
 */
class Log extends DefaultFunction {

  /**
   * Creates a logarithm function with given base and argument.
   *
   * For example, to create log_10(2):
   *     base = new Number(10);
   *     arg = new Number(2);
   *     log = new Log(base, arg);
   *
   * To create a naturally based logarithm, see [Ln].
   */
  Log(Expression base, Expression arg): super._binary("log", base, arg);

  /**
   * Creates a natural logarithm.
   * Must only be used internally by the Ln class.
   */
  Log._ln(arg): super._binary("ln", new Number(Math.E), arg);

  /// The base of this logarithm.
  Expression get base => getParam(0);

  /// The argument of this logarithm.
  Expression get arg => getParam(1);

  Expression derive(String toVar) => this.asNaturalLogarithm().derive(toVar);

  /**
   * Simplifies base and argument.
   */
  Expression simplify() {
    return new Log(base.simplify(), arg.simplify());
  }

  evaluate(EvaluationType type, ContextModel context) {
    if (type == EvaluationType.REAL) {
      // Be lazy, convert to Ln.
      return asNaturalLogarithm().evaluate(type, context);
    }

    if (type == EvaluationType.INTERVAL) {
      // log_a([x, y]) = [log_a(x), log_a(y)] for [x, y] positive and a > 1
      return asNaturalLogarithm().evaluate(type, context);
    }

    throw new UnimplementedError('Can not evaluate log on ${type} yet.');
  }

  String toString() => 'log_${base.toString()}(${arg.toString()})';

  /**
   * Returns the natural from of this logarithm.
   * E.g. log_10(2) = ln(2) / ln(10)
   *
   * This method is used to determine the derivation of a logarithmic
   * expression.
   */
  Expression asNaturalLogarithm() => new Ln(arg) / new Ln(base);
}

/**
 * The natural logarithm (log based e).
 */
class Ln extends Log {

  /**
   * Creates a natural logarithm function with given argument.
   *
   * For example, to create ln(10):
   *     num10 = new Number(10);
   *     ln = new Ln(num10);
   *
   * To create a logarithm with arbitrary base, see [Log].
   */
  Ln(Expression arg): super._ln(arg);

  Expression derive(String toVar) => arg.derive(toVar) / arg;

  /**
   * Possible simplifications:
   *
   * 1. ln(1) = 0
   */
  Expression simplify() {
    Expression argSimpl = arg.simplify();

    if (_isNumber(argSimpl, 1)) {
      return new Number(0); // ln(1) = 0
    }

    return new Ln(argSimpl);
  }

  evaluate(EvaluationType type, ContextModel context) {
    var argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return Math.log(argEval);
    }

    if (type == EvaluationType.INTERVAL) {
      // Expect argument of type interval
      return new Interval(Math.log(argEval.min), Math.log(argEval.max));
    }

    throw new UnimplementedError('Can not evaluate ln on ${type} yet.');
  }

  String toString() => 'ln(${arg.toString()})';
}

/**
 * The n-th root function. n needs to be a natural number.
 */
class Root extends DefaultFunction {

  /// N-th root.
  int n;

  /**
   * Creates the n-th root of arg.
   *
   * For example, to create the 5th root of x:
   *     root = new Root(5, new Variable('x'));
   */
  Root(int this.n, arg): super._unary('root', arg);

  /**
   * Creates the n-th root of arg where n is a [Number] literal.
   */
  Root.fromExpr(Number n, arg): super._unary('root', arg) {
    this.n = n.getConstantValue().toInt();
  }
  
  /**
   * Creates the square root of arg.
   *
   * For example, to create the square root of x:
   *     sqrt = new Root.sqrt(new Variable('x'));
   *
   * Note: For better simplification and display, use the [Sqrt] class.
   */
  Root.sqrt(arg): super._unary('sqrt', arg), n = 2;

  Expression get arg => getParam(0);

  Expression derive(String toVar) => this.asPower().derive(toVar);

  /**
   * Simplify argument.
   */
  Expression simplify() {
    return new Root(n, arg.simplify());
  }

  evaluate(EvaluationType type, ContextModel context) {
    return this.asPower().evaluate(type, context);
  }

  String toString() => 'nrt_$n(${arg.toString()})';

  /**
   * Returns the power form of this root.
   * E.g. root_5(x) = x^(1/5)
   *
   * This method is used to determine the derivation of a root
   * expression.
   */
  Expression asPower() => new Power(arg, new Divide(1,n));
}

/**
 * The square root function.
 */
class Sqrt extends Root {

  /**
   * Creates the square root of arg.
   *
   * For example, to create the square root of x:
   *     sqrt = new Sqrt(new Variable('x'));
   */
  Sqrt(arg): super.sqrt(arg);

  /**
   * Possible simplifications:
   *
   * 1. sqrt(x^2) = x
   * 2. sqrt(0) = 0
   * 3. sqrt(1) = 1
   *
   * Note: This simplification works _only_ for real numbers and
   * _not_ for complex numbers.
   */
  Expression simplify() {
    Expression argSimpl = arg.simplify();

    if (argSimpl is Power) {
      Expression exponent = (argSimpl as Power).second;
      if (exponent is Number) {
        if ((exponent as Number).value == 2) {
          return (argSimpl as Power).first; // sqrt(x^2) = x
        }
      }
    }

    if (_isNumber(argSimpl, 0)) {
      return new Number(0); // sqrt(0) = 0
    }

    if (_isNumber(argSimpl, 1)) {
      return new Number(1); // sqrt(1) = 1
    }

    return new Sqrt(argSimpl);
  }

  evaluate(EvaluationType type, ContextModel context) {
    var argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return Math.sqrt(argEval);
    }

    if (type == EvaluationType.VECTOR) {
      //TODO apply function to all vector elements
    }

    if (type == EvaluationType.INTERVAL) {
      // Piecewiese sqrting.
      return new Interval(Math.sqrt(argEval.min), Math.sqrt(argEval.max));
    }

    throw new UnimplementedError('Can not evaluate sqrt on ${type} yet.');
  }

  String toString() => 'sqrt(${arg.toString()})';
}

/**
 * The sine function.
 */
class Sin extends DefaultFunction {

  /**
   * Creates a new sine function with given argument expression.
   */
  Sin(arg): super._unary('sin', arg);

  /// The argument of this sine function.
  Expression get arg => getParam(0);

  Expression derive(String toVar) => new Cos(arg);

  /**
   * Possible simplifications:
   *
   * 1. sin(0) = 0
   */
  Expression simplify() {
    Expression argSimpl = arg.simplify();

    if (_isNumber(argSimpl, 0)) {
      return new Number(0); // sin(0) = 0
    }

    return new Sin(argSimpl);
  }

  evaluate(EvaluationType type, ContextModel context) {
    var argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return Math.sin(argEval);
    }

    if (type == EvaluationType.VECTOR) {
      //TODO apply function to all vector elements
    }

    if (type == EvaluationType.INTERVAL) {
      // TODO evaluate endpoints and critical points ((1/2 + n) * pi)
      // or just return [-1, 1] if half a period is in the given interval
    }

    throw new UnimplementedError('Can not evaluate sin on ${type} yet.');
  }
}

/**
 * The cosine function.
 */
class Cos extends DefaultFunction {

  /**
   * Creates a new cosine function with given argument expression.
   */
  Cos(arg): super._unary('cos', arg);

  /// The argument of this cosine function.
  Expression get arg => getParam(0);

  Expression derive(String toVar) => -new Sin(arg);

  /**
   * Possible simplifications:
   *
   * 1. cos(0) = 1
   */
  Expression simplify() {
    Expression argSimpl = arg.simplify();

    if (_isNumber(argSimpl, 0)) {
      return new Number(1); // cos(0) = 1
    }

    return new Cos(argSimpl);
  }

  evaluate(EvaluationType type, ContextModel context) {
    var argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return Math.cos(argEval);
    }

    if (type == EvaluationType.VECTOR) {
      //TODO apply function to all vector elements
    }

    if (type == EvaluationType.INTERVAL) {
      // TODO evaluate endpoints and critical points (n * pi)
      // or just return [-1, 1] if half a period is in the given interval
    }

    throw new UnimplementedError('Can not evaluate cos on ${type} yet.');
  }
}

/**
 * The tangens function.
 */
class Tan extends DefaultFunction {

  /**
   * Creates a new tangens function with given argument expression.
   */
  Tan(arg): super._unary('tan', arg);

  /// The argument of this tangens function.
  Expression get arg => getParam(0);

  Expression derive(String toVar) => asSinCos().derive(toVar);

  /**
   * Possible simplifications:
   *
   * 1. tan(0) = 0
   */
  Expression simplify() {
    Expression argSimpl = arg.simplify();

    if (_isNumber(argSimpl, 0)) {
      return new Number(0); // tan(0) = 0
    }

    return new Tan(argSimpl);
  }

  evaluate(EvaluationType type, ContextModel context) {
    var argEval = arg.evaluate(type, context);

    if (type == EvaluationType.REAL) {
      return Math.tan(argEval);
    }

    if (type == EvaluationType.VECTOR) {
      //TODO apply function to all vector elements
    }

    throw new UnimplementedError('Can not evaluate tan on ${type} yet.');
  }

  /**
   * Returns this tangens as sine and cosine representation.
   *
   * `tan(x) = sin(x) / cos(x)`
   */
  Expression asSinCos() => new Sin(arg) / new Cos(arg);
}