part of math_expressions;

/**
 * A point in 3-dimensional space.
 * This implementation supplies common mathematical operations on points.
 */
class Point3D {

  double x, y, z;

  /**
   * Creates a new Point3D with the given coordinates.
   */
  Point3D(double this.x, double this.y, double this.z);

  /**
   * Creates a new Point3D from given vector3 / vector4.
   */
  Point3D.vec(var vec): this.x = vec.x, this.y = vec.y, this.z = vec.z;

  /**
   * Creates a new Point3D and "splats" the given value to each coordinate.
   */
  Point3D.splat(num val): this.x = val, this.y = val, this.z = val;

  /**
   * Creates a new Point3D at the coordinate origin.
   */
  Point3D.zero(): x = 0.0, y = 0.0, z = 0.0;

  /**
   * Returns a new point which position is determined by moving the old point
   * along the given vector.
   */
  Point3D operator+(Vector3 v) => new Point3D(this.x + v.x, this.y + v.y, this.z + v.z);

  /**
   * Returns the [Vector3] pointing from the given point to this point.
   */
  Vector3 operator-(Point3D p2) => new Vector3(this.x - p2.x, this.y - p2.y, this.z - p2.z);

  /**
   * Negates the point's components.
   */
  Point3D operator-() => new Point3D(-this.x, -this.y, -this.z);

  /**
   * Checks for equality. Two points are considered equal, if their coordinates
   * match.
   */
  bool operator==(Object o) {
    if (o is Point3D) {
      return this.x == o.x && this.y == o.y && this.z == o.z;
    } else {
      return false;
    }
  }

  /**
   * Performs a linear interpolation between two points.
   */
  Point3D lerp(Point3D p2, num coeff) {
    return new Point3D(
        this.x * coeff + p2.x * (1-coeff),
        this.y * coeff + p2.y * (1-coeff),
        this.z * coeff + p2.z * (1-coeff)
    );
  }
  // TODO 3d lerp?

  /**
   * Transforms the point to its vector representation.
   */
  Vector3 toVec3() => new Vector3(this.x, this.y, this.z);

  /**
   * Transforms the point to its homogeneous vector4 representation.
   * The w component is set to 1.
   */
  Vector4 toVec4() => new Vector4(this.x, this.y, this.z, 1.0);

  int get hashCode {
    int result = 17;
    result = 37 * result + x.hashCode;
    result = 37 * result + y.hashCode;
    result = 37 * result + z.hashCode;
    return result;
  }
  
  String toString() => "$x,$y,$z";
}

/**
 * An [Interval] is defined by its minimum and maximum values, where
 * _min <= max_.
 *
 * This implementation offers basic interval arithmetic operations like
 * addition, subtraction, multiplication and division. Operations always
 * return a new interval and will not modify the existing ones. Additionally
 * this class implementions comparison relations for intervals.
 *
 * This implementation (partly) supports unbounded intervals with borders
 * at +/- infinity and empty sets.
 *
 * Operator and comparison definitions are based on: 
 * _Bohlender, Gerd, and Ulrich Kulisch. 2010.
 * ["Deﬁnition of the Arithmetic Operations and Comparison Relations for an Interval Arithmetic Standard"]
 * (http://interval.louisiana.edu/reliable-computing-journal/volume-15/no-1/reliable-computing-15-pp-36-42.pdf).
 * Reliable Computing 15 (1): 36–42._
 * 
 * __Note__: This implementation does not offer a complete set of operations yet:
 *
 * * No handling of unbounded intervals in operators.
 * * No proper rounding.
 */
class Interval implements Comparable {

  /// Interval borders.
  num min, max;

  /// True, if this represents the empty set.
  final bool _emptySet;

  /// Immutable singleton instance of empty set.
  static final Interval _emptyInterval = new Interval._empty();

  /**
   * Creates a new interval with given borders.
   *
   * The parameter min must be smaller or equal than max for the interval
   * to work properly.
   */
  Interval(this.min, this.max): this._emptySet = false;

  /**
   * Returns an immutable empty set.
   */
  factory Interval.empty() => _emptyInterval;

  /**
   * Internal constructor for an empty set.
   */
  Interval._empty():  this.min = double.NAN,
                      this.max = double.NAN,
                      this._emptySet = true;

  /**
   * Performs an interval addition.
   *
   *     [a, b] + [c, d] = [a + c, b + d]
   */
  operator+(Interval i) {
    if (this.isEmpty() || i.isEmpty()) return new Interval.empty();
    return new Interval(this.min + i.min, this.max + i.max);
  }

  /**
   * Unary minus on intervals.
   *
   *     -[a, b] = [-b, -a]
   */
  operator-() {
    if (this.isEmpty()) return new Interval.empty();
    return new Interval(-max, -min);
  }
  /**
   * Performs an interval subtraction.
   *
   *     [a, b] + [c, d] = [a - d, b - c]
   */
  operator-(Interval i) {
    if (this.isEmpty() || i.isEmpty()) return new Interval.empty();
    return new Interval(this.min - i.max, this.max - i.min);
  }

  /**
   * Performs an interval multiplication.
   *
   *     [a, b] * [c, d] = [min(ac, ad, bc, bd), max(ac, ad, bc, bd)]
   */
  operator*(Interval i) {
    if (this.isEmpty() || i.isEmpty()) return new Interval.empty();
    num min = _min(this.min*i.min, this.min*i.max, this.max*i.min, this.max*i.max);
    num max = _max(this.min*i.min, this.min*i.max, this.max*i.min, this.max*i.max);
    return new Interval(min, max);
  }

  /**
   * Performs an interval division.
   *
   *     [a, b] * [c, d] = [a, b] * (1/[c, d]) = [a, b] * [1/d, 1/c]
   *
   * __Note:__ Does not handle division by zero and throws an [ArgumentError] instead.
   */
  operator/(Interval i) {
    if (this.isEmpty() || i.isEmpty()) return new Interval.empty();

    if (i.containsZero()) {
      // Fuck. Somebody is dividing by zero, the world is going to end.
      // Just kidding - we actually can handle this situation here.

      // Case 1: This interval is strictly negative.
      if (!this.isPositive()) {
        if (i.min == 0 && i.max == 0) {
          // Result = empty set
          return new Interval.empty();
        }

        if (i.min < i.max && i.max == 0) {
          // round down new min
          return new Interval(this.max / i.min, double.INFINITY);
        }

        if (i.min < i.max && i.min == 0) {
          // round up new max
          return new Interval(double.NEGATIVE_INFINITY, this.max / i.max);
        }
      }

      // Case 2: This interval contains zero.
      if (this.containsZero()) {
        return new Interval(double.NEGATIVE_INFINITY, double.INFINITY);
      }

      // Case 3: This interval is strictly positive.
      if (this.max > 0) {
        if (i.min == 0 && i.max == 0) {
          // Result = empty set
          return new Interval.empty();
        }

        if (i.min < i.max && i.max == 0) {
          // round up new max
          return new Interval(double.NEGATIVE_INFINITY, this.min / i.min);
        }

        if (i.min < i.max && i.min == 0) {
          // round down new min
          return new Interval(this.min / i.max, double.INFINITY);
        }
      }
      throw new ArgumentError('Can not divide by 0');
    }

    return this * new Interval(1.0/i.max, 1.0/i.min);
  }

  /**
   * Equals operator on intervals.
   *
   *     [a, b] == [c, d], if a == c && b == d
   */
  operator==(Interval i) => this.min == i.min && this.max == i.max;

  /**
   * Less than operator on intervals.
   *
   *     [a, b] < [c, d], if a < c && b < d
   */
  operator<(Interval i) => this.min < i.min && this.max < i.max;

  /**
   * Less or equal than operator on intervals.
   *
   *     [a, b] <= [c, d], if a <= c && b <= d
   */
  operator<=(Interval i) => this.min <= i.min && this.max <= i.max;

  /**
   * Greater than operator on intervals.
   *
   *     [a, b] > [c, d], if a > c && b > d
   */
  operator>(Interval i) => this.min > i.min && this.max > i.max;

  /**
   * Greater or equal than operator on intervals.
   *
   *     [a, b] >= [c, d], if a >= c && b >= d
   */
  operator>=(Interval i) => this.min >= i.min && this.max >= i.max;

  /**
   * Returns the greatest lower bound.
   */
  Interval glb(Interval i) =>
      new Interval(Math.min(min, i.min), Math.min(max, i.max));

  /**
   * Returns the least upper bound.
   */
  Interval lub(Interval i) =>
      new Interval(Math.max(min, i.min), Math.max(max, i.max));

  /**
   * Inclusion relation. Returns true, if the given interval is included
   * in this interval.
   *
   *     [a, b] subset of [c, d] <=> c <= a && b >= d
   */
  bool includes(Interval i) =>
      this.min <= i.min && i.max <= this.max;

  /**
   * Element-of relation. Returns true, if given element is included
   * in this interval.
   * Defined on a real number i and an interval:
   *
   *     i element of [a, b] <=> a <= i && i <= b
   */
  bool contains(num element) => this.min <= element && element <= this.max;

  /**
   * Returns true, if this interval contains zero (min <= 0 <= max).
   */
  bool containsZero() => this.min <= 0 && 0 <= this.max;

  /**
   * Returns true, if this interval is positive (min >= 0)
   */
  bool isPositive() => this.min >= 0;

  /**
   * Returns true, if neither min or max values are infinite.
   */
  bool isBound() => !this.min.isInfinite && !this.max.isInfinite;

  /**
   * Returns true, if this is the empty set.
   */
  bool isEmpty() => this._emptySet;

  /**
   * Returns the minimal value of four given values.
   */
  num _min(num a, num b, num c, num d) => Math.min(Math.min(a ,b), Math.min(c, d));

  /**
   * Returns the maximum value of four given values.
   */
  num _max(num a, num b, num c, num d) => Math.max(Math.max(a ,b), Math.max(c, d));

  /**
   * Returns the length of this interval.
   */
  num length() => max - min;

  String toString() => '[${this.min},${this.max}]';
  
  int get hashCode {
    int result = 17;
    result = 37 * result + min.hashCode;
    result = 37 * result + max.hashCode;
    return result;
  }

  int compareTo(Comparable other) {
    // For now, only allow compares to other intervals.
    if (other is Interval) {
      // Equality, less and greater tests.
      if (this == other) return 0;
      if (this < other) return -1;
      if (this > other) return 1;
    } else {
      throw new ArgumentError('$other is not comparable to Interval.');
    }
  }
}
