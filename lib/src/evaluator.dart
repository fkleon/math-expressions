part of math_expressions;

/**
 * Mathematical expressions must be evaluated under a certain [EvaluationType].
 *
 * Currently there are three types, but not all expressions support each type.
 * If you try to evaluate an expression with an unsupported type, it will raise an
 * [UnimplementedError] or [UnsupportedError].
 *
 * - REAL
 * - VECTOR
 * - INTERVAL
 *
 * _Note_: This class emulates an enumeration, since they are not supported
 * by Dart yet.
 */
class EvaluationType {

  /// Our type map.
  static Map<int, EvaluationType> _cache;
  int type;
  String _text;

  /**
   * Private singleton constructor, no need to instantiate new objects
   * all the time.
   */
  factory EvaluationType._private(int type, String text) {
    if (_cache == null) {
      _cache = new Map<int, EvaluationType>();
    }

    if (_cache.containsKey(type)) {
      // We already have cached this type.
      return _cache[type];
    } else {
      // Create new Type Object.
      final EvaluationType et = new EvaluationType._internal(type, text);
      _cache[type] = et;
      return et;
    }
  }

  /**
   * Internal constructor for EvaluationTypes.
   */
  EvaluationType._internal(int this.type, String this._text);

  /// Public constructor for REAL types. Always returns the same instance of a REAL type.
  static EvaluationType get REAL => new EvaluationType._private(REAL_INT, 'REAL');

  /// Public constructor for VECTOR types. Always returns the same instance of a VECTOR type.
  static EvaluationType get VECTOR => new EvaluationType._private(VECTOR_INT, 'VECTOR');

  /// Public constructor for INTERVAL types. Always returns the same instance of a INTERVAL type.
  static EvaluationType get INTERVAL => new EvaluationType._private(INTERVAL_INT, 'INTERVAL');

  /// Internal integer value for REAL type.
  static final int REAL_INT = 1;

  /// Internal integer value for VECTOR type.
  static final int VECTOR_INT = 2;

  /// Internal integer value for INTERVAL type.
  static final int INTERVAL_INT = 3;

  /**
   * Two types are equal, if their internal int matches.
   */
  operator==(EvaluationType et) => this.type == et.type;

  String toString() => 'Type[$_text]';
}

/**
 * The context model keeps track of all known variables and functions.
 */
class ContextModel {

  /// Variable map (name -> bound expression).
  Map <String, Expression> variables;

  // Function set.
  Set<MathFunction> functions;

  /**
   * Creates a new, empty context model.
   */
  ContextModel() {
    variables = new Map();
    functions = new Set();
  }

  /**
   * Returns the bound expression for the given variable.
   *
   * Throws a StateError, if variable is not bound.
   */
  Expression getExpression(String varName) {
    if (variables.containsKey(varName)) {
      return variables[varName];
    } else {
      throw new StateError('Variable not bound: $varName');
    }
  }

  /**
   * Returns the function for the given function name.
   *
   * Throws a StateError, if function is not bound.
   */
  MathFunction getFunction(String name) {
    var candidates = functions.where((mathFunction) => mathFunction.name == name).toSet();
    if (candidates.length > 1) {
      for (MathFunction fun in candidates) {
        // just grab first - should not contain doubles.
        return fun;
      }
    } else {
      throw new StateError('Function not bound: $name');
    }
  }

  /**
   * Binds a variable to an expression in this context.
   */
  void bindGlobalVariable(Variable v, Expression e) {
    variables[v.name] = e;
  }

  /**
   * Binds a variable name to an expression in this context.
   */
  void bindGlobalVariableName(String vName, Expression e) {
    variables[vName] = e;
  }

  /**
   * Binds a function to this context.
   */
  void bindGlobalFunction(MathFunction f) {
    //TODO force non-duplicates.
    functions.add(f);
  }

}

/*
class EvaluatorFactory {

  getEvaluator(BinaryOperator binOp, EvaluationType type) {
    if (binOp is Plus) {
      return new PlusEvaluator(binOp.first, binOp.second, type);
    }

    if (binOp is Times) {

    }

    if (binOp is Minus) {

    }

    if (binOp is Divide) {

    }

    if (binOp is Power) {

    }

    throw new UnsupportedError('Unsupported BinaryOperator: ${binOp}.');
  }
}

abstract class Evaluator {
  EvaluationType returnType;

  Evaluator(EvaluationType this.returnType);

  evaluate();
}

abstract class BinaryOpEvaluator extends Evaluator {
  Evaluator op1, op2;

  BinaryOpEvaluator(this.op1, this.op2, type): super(type);
}

class PlusEvaluator extends BinaryOpEvaluator {

  PlusEvaluator(op1, op2, type): super(op1, op2, type);

  evaluate() => op1.evaluate() + op2.evaluate();
}

class MinusRealEvaluator extends BinaryOpEvaluator {
  MinusRealEvaluator(op1, op2): super(op1, op2, EvaluationType.REAL);

  evaluate() => op1.evaluate() - op2.evaluate();
}

class TimesRealEvaluator extends BinaryOpEvaluator {
  TimesRealEvaluator(op1, op2): super(op1, op2, EvaluationType.REAL);

  evaluate() => op1.evaluate() * op2.evaluate();
}

class DivideRealEvaluator extends BinaryOpEvaluator {
  DivideRealEvaluator(op1, op2): super(op1, op2, EvaluationType.REAL);

  evaluate() => op1.evaluate() / op2.evaluate();
}

class ConstantEvaluator extends Evaluator {

  ConstantEvaluator(Literal l, type): super(type);

  evaluate();
}
*/
