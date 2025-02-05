part of 'math_expressions_test.dart';

/// Contains a test set for testing the parser
class PetitParserTests extends TestSet {
  @override
  String get name => 'Petit Parser Tests';

  @override
  String get tags => 'petitparser';

  @override
  Map<String, Function> get testFunctions => {
        // TODO: Refactor these to be included in the individual test groups
        'Parse from toString())': parseFromToString,
      };

  @override
  Map<String, Function> get testGroups => {
        // Lint
        'Lint': lint,

        // Literals
        'Number': parseNumber,
        'Constant': parseConstant,
        'Custom Constant': parseCustomConstant,
        'Variable': parseVariable,
        'Parenthesis': parseParenthesis,

        // Operators
        'Unary Minus': parseUnaryMinus,
        'Unary Plus': parseUnaryPlus,
        'Power': parsePower,
        'Modulo': parseModulo,
        'Multiplication': parseMultiplication,
        //'ImplicitMultiplication': parseImplicitMultiplication,
        'Division': parseDivision,
        'Addition': parsePlus,
        'Subtraction': parseMinus,
        'Operator Precedence': parseOperatorPrecedence,

        // Functions
        'Functions': parseFunctions,
        //'Custom functions': parseCustomFunctions,
        'Algorithmic functions': parseAlgorithmicFunctions,

        // Expressions
        'Complex expression': parseComplexExpression,

        // Negative test cases
        'Invalid': parserExpressionTestInvalid,
      };

  @override
  void initTests() {}

  GrammarParser parser = GrammarParser();

  void parameterized(Map<String, Expression> cases,
      {ExpressionParser? parser}) {
    parser ??= this.parser;
    cases.forEach((key, value) {
      test(
          '$key -> $value',
          () => expect(
              parser!
                  .parse(
                    key,
                  )
                  .toString(),
              value.toString()));
    });
  }

  void lint() {
    test('detect common problems', () {
      expect(linter(parser.parser), isEmpty);
    });
  }

  void parseNumber() {
    var cases = {
      '0': Number(0),
      '1': Number(1),
      '1.0': Number(1.0),
      math.pi.toStringAsFixed(11): Number(3.14159265359),
      '0.0': Number(0.0),
      // max precision 15 digits
      '999999999999999': Number(999999999999999),
    };
    parameterized(cases);
  }

  void parseConstant() {
    var cases = {
      'e': Number(math.e),
      'ln10': Number(math.ln10),
      'ln2': Number(math.ln2),
      'log10e': Number(math.log10e),
      'log2e': Number(math.log2e),
      'pi': Number(math.pi),
      'sqrt1_2': Number(math.sqrt1_2),
      'sqrt2': Number(math.sqrt2),
    };
    parameterized(cases);
  }

  void parseCustomConstant() {
    const PHI = 1.6180339887;
    var constants = {
      'π': math.pi,
      'Π': math.pi,
      '∏': math.pi,
      'ᴨ': math.pi,
      'phi': PHI,
      'Φ': PHI,
      'φ': PHI,
      'ϕ': PHI,
      'ɸ': PHI,
    };

    var cases = constants.map((k, v) => MapEntry(k, Number(v)));

    ExpressionParser parser =
        GrammarParser(ParserOptions(constants: constants));

    parameterized(cases, parser: parser);
  }

  void parseVariable() {
    var cases = {
      'x': Variable('x'),
      ' x': Variable('x'),
      '(y )': Variable('y'),
      'var2': Variable('var2'),
      'va2r': Variable('va2r'),
      '\$s2': Variable('\$s2'),
      //'Veränderung': Variable('Veränderung'),
      'longname': Variable('longname'),
    };
    parameterized(cases);
  }

  void parseUnaryMinus() {
    var cases = {
      '-0': -Number(0),
      '-1': -Number(1),
      '-1.0': -Number(1.0),
    };
    parameterized(cases);
  }

  void parseUnaryPlus() {
    var cases = {
      '+0': UnaryPlus(Number(0)),
      '+1': UnaryPlus(Number(1)),
      '+1.0': UnaryPlus(Number(1.0)),
    };
    parameterized(cases);
  }

  void parsePower() {
    var cases = {
      '1^1': Number(1) ^ Number(1),
      '1^0': Number(1) ^ Number(0),
      '(-1) ^ 2': -Number(1) ^ Number(2),
      '-1^2': -(Number(1) ^ Number(2)),
      '1^0 ^20': Number(1) ^ (Number(0) ^ Number(20)),
    };
    parameterized(cases);
  }

  void parseModulo() {
    var cases = {
      '1%1': Number(1) % Number(1),
      '100.0 % 20': Number(100.0) % Number(20),
    };
    parameterized(cases);
  }

  void parseMultiplication() {
    var cases = {
      '0 * 1': Number(0) * Number(1),
      '-2.0 * 5': -Number(2.0) * Number(5),
    };
    parameterized(cases);
  }

  void parseImplicitMultiplication() {
    var cases = {
      '(5)(5)': Number(5) * Number(5),
      '(-2.0)5': -Number(2.0) * Number(5),
    };

    var parser = GrammarParser(ParserOptions(implicitMultiplication: true));
    parameterized(cases, parser: parser);
  }

  void parseDivision() {
    var cases = {
      '0 / 1': Number(0) / Number(1),
      '-2.0 / 5': -Number(2.0) / Number(5),
    };
    parameterized(cases);
  }

  void parsePlus() {
    var cases = {
      'x + 2': Variable('x') + Number(2),
    };
    parameterized(cases);
  }

  void parseMinus() {
    var cases = {
      'x - 2': Variable('x') - Number(2),
      '0 - 2': Number(0) - Number(2),
    };
    parameterized(cases);
  }

  void parseOperatorPrecedence() {
    var cases = {
      '-3^2': UnaryMinus(Number(3.0) ^ Number(2.0)),
      '-3*2': UnaryMinus(Number(3.0)) * Number(2.0),
    };
    parameterized(cases);
  }

  void parseParenthesis() {
    var cases = {
      '(0)': Number(0),
      '(0-x)': Number(0) - Variable('x'),
    };
    parameterized(cases);
  }

  void parseFunctions() {
    var cases = {
      'log(10,100)': Log(Number(10), Number(100)),
      'ln(2)': Ln(Number(2)),
      'sqrt(10)': Sqrt(Number(10)),
      // n-th root
      'nrt(2,10)': Root(2, Number(10)),
      'nrt(5,10-1)': Root(5, Number(10) - Number(1)),
      'cos(10)': Cos(Number(10)),
      'sin(10)': Sin(Number(10)),
      'tan(10)': Tan(Number(10)),
      'arccos(1)': Acos(Number(1)),
      'arcsin(1)': Asin(Number(1)),
      'arctan(10)': Atan(Number(10)),
      'abs(10)': Abs(Number(10)),
      'sgn(10)': Sgn(Number(10)),
      // Exponential - function syntax
      'e(x)': Exponential(Variable('x')),
      // Exponential - power syntax
      'e^x': Exponential(Variable('x')),
      'e^(x+2)': Exponential(Variable('x') + Number(2)),
      'ceil(9.5)': Ceil(Number(9.5)),
      'floor(9.5)': Floor(Number(9.5)),
      '10!': Factorial(Number(10)),
    };
    parameterized(cases);
  }

  void parseCustomFunctions() {
    var cases = {
      'myCustomFunction(x)':
          CustomFunction('myCustomFunction', [Variable('x')], Number(0)),
    };
    parameterized(cases);
  }

  void parseAlgorithmicFunctions() {
    var cases = {
      'myAlgorithmicFunction(1.0)': AlgorithmicFunction(
          'myAlgorithmicFunction', [Number(1.0)], () => null),
      'my_min(1,x,-2)': AlgorithmicFunction('my_min',
          [Number(1), Variable('x'), UnaryMinus(Number(2))], () => null),
    };

    parser.addFunction('myAlgorithmicFunction', () => null, replace: true);
    parser.addFunction('my_min', (List<double> args) => args.reduce(math.min),
        replace: true);

    parameterized(cases);
  }

  void parseComplexExpression() {
    var cases = {
      'x * 2^2.5 * log(10,100)': Variable('x') *
          Power(Number(2), Number(2.5)) *
          Log(Number(10), Number(100))
    };
    parameterized(cases);
  }

  void parseFromToString() {
    const expressions = [
      'x + 2',
      'x - 2',
      '0 - 1',
      '(0 - 1)',
      '0 * 1',
      '0 / 1',
      '-1',
      '(-1)',
      '-(1)',
      '+1',
      '(+1)',
      '+(1)',
      '1^1^1',
      'log(10,100)',
      'ln(10)',
      'sqrt(10)',
      'cos(10)',
      'sin(10)',
      'tan(10)',
      'arccos(1)',
      'arcsin(1)',
      'arctan(10)',
      'abs(10)',
      'sgn(10)',
      'nrt(2,10)',
      'nrt(5,10-1)',
      'ceil(1.2)',
      'floor(1.2)',
      '10!',
      'e(x)',
      'e^x',
      'e^(x+2)',
      'my_min(1,x,-2)',
      'x * 2^2.5 * log(10,100)',
    ];

    ContextModel context = ContextModel()
      ..bindVariableName('x', Number(math.pi));

    for (String expression in expressions) {
      /// Expression doesn't implement equal, so as an approximation
      /// we're testing whether the expression re-parses and evaluates
      /// to the same value.
      Expression exp = parser.parse(expression);

      try {
        Expression exp2 = parser.parse(exp.toString());

        double r1 = exp.evaluate(EvaluationType.REAL, context);
        double r2 = exp2.evaluate(EvaluationType.REAL, context);
        expect(r2, r1, reason: 'Expected $r2 for $exp ($exp2)');
      } on FormatException catch (fe) {
        expect(fe, isNot(isFormatException),
            reason: 'Expected no exception for $expression ($exp)');
      }
    }
  }

  void parserExpressionTestInvalid() {
    Map<String, Matcher> invalidCases = {
      '': throwsFormatException,
      '(': throwsFormatException,
      ')': throwsFormatException,
      '1+1)': throwsFormatException,
      '(1+1': throwsFormatException,
      'log(,1)': throwsFormatException,
      'log(1,)': throwsFormatException,
      '8e': throwsFormatException,
      '8E': throwsFormatException,
    };

    for (String expr in invalidCases.keys) {
      test(expr, () => expect(() => parser.parse(expr), invalidCases[expr]));
    }
  }
}
