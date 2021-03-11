part of math_expressions_test;

/**
 * Contains methods to test the math algebra implementation.
 */
class AlgebraTests extends TestSet {
  @override
  String get name => 'Algebra Tests';

  @override
  get testFunctions => {
        'Point Creation': pointCreation,
        'Point Equality': pointEquality,
        'Point Subtraction': pointSubtraction,
        'Point Addition': pointAddition,
        'Point LERP': pointLerp,
        'Interval Creation': intervalCreation,
        'Interval Arithmetic': intervalArithmetic,
        'Interval Comparison': intervalComparison,
      };

  // Initialises the test points and vectors
  @override
  void initTests() {
    // do some funky stuff
    p0 = Point3.zero();
    p1 = Point3(1.0, 2.0, 3.0);
    p2 = Point3(4.0, -5.0, 7.0);
    v1 = Vector3(1.0, -2.0, 5.0);
    v2 = Vector3(-1.0, 0.0, -7.0);

    iNull1 = Interval(0, 30);
    iNull2 = Interval(-20, 0);
    iPos = Interval(2, 7);
    iNeg = Interval(-5, -1);
    iZero = Interval(-1, 1);
    iEmpty = Interval.empty();

    i = Interval(0.00002, 300);
  }

  /*
   *  Tests and variables.
   */
  late final Point3 p0, p1, p2;
  late final Vector3 v1, v2;
  late final Interval i, iNull1, iNull2, iPos, iNeg, iZero, iEmpty;

  // Tests the expected state after point creation.
  void pointCreation() {
    expect(p0.x, equals(0));
    expect(p0.y, equals(0));
    expect(p0.z, equals(0));

    expect(p1.x, equals(1));
    expect(p1.y, equals(2));
    expect(p1.z, equals(3));

    expect(p2.x, equals(4));
    expect(p2.y, equals(-5));
    expect(p2.z, equals(7));
  }

  // Tests the point equality operator.
  void pointEquality() {
    expect(p0 == p0, isTrue);
    expect(p0 == p1, isFalse);
    expect(p1 == p0, isFalse);
    expect(p1 == p2, isFalse);
    expect(p2 == p2, isTrue);
  }

  // Tests the unary minus and point subtraction operators.
  void pointSubtraction() {
    // unary minus
    Point3 pMinus = -p0;
    expect(pMinus.x, equals(0));
    expect(pMinus.y, equals(0));
    expect(pMinus.z, equals(0));

    pMinus = -p2;
    expect(pMinus.x, equals(-p2.x));
    expect(pMinus.y, equals(-p2.y));
    expect(pMinus.z, equals(-p2.z));

    // subtraction
    var diff = p1 - p0;
    expect(diff.x, equals(p1.x));
    expect(diff.y, equals(p1.y));
    expect(diff.z, equals(p1.z));

    diff = p0 - p1;
    expect(diff.x, equals(-p1.x));
    expect(diff.y, equals(-p1.y));
    expect(diff.z, equals(-p1.z));

    diff = p1 - p2;
    expect(diff.x, equals(p1.x - p2.x));
    expect(diff.y, equals(p1.y - p2.y));
    expect(diff.z, equals(p1.z - p2.z));
  }

  // Tests the point addition operator.
  void pointAddition() {
    var add = p1 + v1;
    expect(add.x, equals(p1.x + v1.x));
    expect(add.y, equals(p1.y + v1.y));
    expect(add.z, equals(p1.z + v1.z));

    add = p0 + v2;
    expect(add.x, equals(v2.x));
    expect(add.y, equals(v2.y));
    expect(add.z, equals(v2.z));
  }

  // Tests the linear interpolation of points.
  void pointLerp() {
    var coeff = 0.6;
    var lerped = p1.lerp(p0, coeff);
    expect(lerped.x, closeTo(p1.x * coeff, EPS));
    expect(lerped.y, closeTo(p1.y * coeff, EPS));
    expect(lerped.z, closeTo(p1.z * coeff, EPS));

    coeff = 0.41;
    lerped = p1.lerp(p2, coeff);
    expect(lerped.x, closeTo(2.77, EPS));
    expect(lerped.y, closeTo(-2.13, EPS));
    expect(lerped.z, closeTo(5.36, EPS));
  }

  void intervalCreation() {
    expectInterval(i, 0.00002, 300, true, false);
    expectInterval(iZero, -1, 1, false, true);
    expectInterval(iPos, 2, 7, true, false);
    expectInterval(iNeg, -5, -1, false, false);
    expectInterval(iNull1, 0, 30, true, true);
    expectInterval(iNull2, -20, 0, false, true);
    expectEmptyInterval(iEmpty);
  }

  void expectInterval(Interval i, num iMin, num iMax, bool iPos, bool iZero) {
    expect(i.min, equals(iMin));
    expect(i.max, equals(iMax));
    expect(i.isPositive() == iPos, isTrue);
    expect(i.containsZero() == iZero, isTrue);
    expect(i.length(), equals(i.max - i.min));
  }

  void expectEmptyInterval(Interval i) {
    expect(i.isEmpty(), isTrue);
    expect(i.min.isNaN, i.max.isNaN);
  }

  void intervalArithmetic() {
    Interval result;

    result = iPos + iNeg;
    expectInterval(result, -3, 6, false, true);

    result = iNeg + iNeg;
    expectInterval(result, -10, -2, false, false);

    result = iNeg - iNeg;
    expectInterval(result, -4, 4, false, true);

    //TODO interval tests * and /
  }

  void intervalComparison() {
    // equality
    expect(iPos, equals(iPos));
    expect(iPos, isNot(equals(iNeg)));

    // equality with non-Interval
    expect(iPos, isNot(equals(1)));
    expect(iPos, isNot(equals('1')));

    // comparison
    expect(iPos < iNeg, isFalse);
    expect(iNeg < iPos, isTrue);
  }
}
