part of math_expressions_test;

/// Contains a test set for testing the parser and lexer
class PetitParserTests extends TestSet {
  @override
  String get name => 'Petit Parser Tests';

  @override
  Map<String, Function> get testGroups => {
        'Number': parseNumber,
        'Variable': parseVariable,
        'Unary Minus': parseUnaryMinus,
        'Power': parsePower,
        'Modulo': parseModulo,
        'Multiplication': parseMultiplication,
        'Division': parseDivision,
        'Addition': parsePlus,
        'Subtraction': parseMinus,
        'Parenthesis': parseParenthesis,
        //'Logarithm': parseLog,
        //'Natural Logarithm': parseLn,
        /// TODO functions
        'Functions': parseFunctions,
        //'Algorithmic functions': parseAlgorithmicFunctions,
        'Invalid': parserExpressionTestInvalid,
      };

  @override
  void initTests() {}

  ExpressionParser parser = ExpressionParser();

  void parameterized(Map<String, Expression> cases) {
    cases.forEach((key, value) {
      test('$key -> $value',
          () => expect(parser.parse(key).toString(), value.toString()));
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

  void parseVariable() {
    var cases = {
      'x': Variable('x'),
      ' x': Variable('x'),
      '(y )': Variable('y'),
      'var2': Variable('var2'),
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
      'nrt(2,10)': Root(2, Number(10)),
      'nrt(5,10-1)': Root(5, Number(10) - Number(1)),
      'sin(10)': Sin(Number(10)),
      'tan(10)': Tan(Number(10)),
      'arccos(1)': Acos(Number(1)),
      'arcsin(1)': Asin(Number(1)),
      'arctan(10)': Atan(Number(10)),
      'abs(10)': Abs(Number(10)),
      'sgn(10)': Sgn(Number(10)),
      'e(x)': Exponential(Variable('x')),
      'e^x': Exponential(Variable('x')),
      'e^(x+2)': Exponential(Variable('x') + Number(2)),
      'ceil(9.5)': Ceil(Number(9.5)),
      'floor(9.5)': Floor(Number(9.5)),
    };
    parameterized(cases);
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
    };

    for (String expr in invalidCases.keys) {
      test('$expr', () => expect(() => parser.parse(expr), invalidCases[expr]));
    }
  }
}
