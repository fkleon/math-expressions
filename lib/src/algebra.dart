part of '../math_expressions.dart';

/// A point in 3-dimensional space, which is a Vector3.
/// This implementation supplies common mathematical operations on points.
class Point3 extends Vector3 {
  /// Creates a new Point3 with the given coordinates.
  factory Point3(double x, double y, double z) =>
      Point3.zero()..setValues(x, y, z);

  /// Creates a new Point3 from the given Vector3.
  factory Point3.vec(Vector3 other) => Point3.zero()..setFrom(other);

  /// Creates a new Point3 at the coordinate origin.
  Point3.zero() : super.zero();

  /// Returns a new point which position is determined by moving the old point
  /// along the given vector.
  @override
  Point3 operator +(Vector3 v) =>
      Point3(this.x + v.x, this.y + v.y, this.z + v.z);

  /// Returns the [Vector3] pointing from the given point to this point.
  @override
  Vector3 operator -(Vector3 p2) =>
      Vector3(this.x - p2.x, this.y - p2.y, this.z - p2.z);

  /// Negates the point's components.
  @override
  Point3 operator -() => Point3(-this.x, -this.y, -this.z);

  /// Checks for equality. Two points are considered equal, if their coordinates
  /// match.
  @override
  bool operator ==(Object? o) {
    if (o is Point3) {
      return this.x == o.x && this.y == o.y && this.z == o.z;
    } else {
      return false;
    }
  }

  /// Performs a linear interpolation between two points.
  Point3 lerp(Point3 p2, num coeff) => Point3(
      this.x * coeff + p2.x * (1 - coeff),
      this.y * coeff + p2.y * (1 - coeff),
      this.z * coeff + p2.z * (1 - coeff));
  // TODO 3d lerp?

  /// Transforms the point to its homogeneous vector4 representation.
  /// The w component is set to 1.
  Vector4 toVec4() => Vector4(this.x, this.y, this.z, 1.0);

  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + x.hashCode;
    result = 37 * result + y.hashCode;
    result = 37 * result + z.hashCode;
    return result;
  }

  @override
  String toString() => '$x,$y,$z';
}

/// An [Interval] is defined by its minimum and maximum values, where
/// _min <= max_.
///
/// This implementation offers basic interval arithmetic operations like
/// addition, subtraction, multiplication and division. Operations always
/// return a new interval and will not modify the existing ones. Additionally
/// this class implementions comparison relations for intervals.
///
/// This implementation (partly) supports unbounded intervals with borders
/// at +/- infinity and empty sets.
///
/// Operator and comparison definitions are based on:
/// _Bohlender, Gerd, and Ulrich Kulisch. 2010.
/// ["Deﬁnition of the Arithmetic Operations and Comparison Relations for an Interval Arithmetic Standard"]
/// (https://interval.louisiana.edu/reliable-computing-journal/volume-15/no-1/reliable-computing-15-pp-36-42.pdf).
/// Reliable Computing 15 (1): 36–42._
///
/// __Note__: This implementation does not offer a complete set of operations yet:
///
/// * No handling of unbounded intervals in operators.
/// * No proper rounding.
class Interval implements Comparable<Interval> {
  /// Interval bounds.
  num min, max;

  /// True, if this represents the empty set.
  final bool _emptySet;

  /// Immutable singleton instance of empty set.
  static final Interval _emptyInterval = Interval._empty();

  /// Creates a new interval with given borders.
  ///
  /// The parameter `min` must be smaller or equal than `max` for the interval
  /// to work properly.
  Interval(this.min, this.max) : this._emptySet = false;

  /// Returns an immutable empty set.
  factory Interval.empty() => _emptyInterval;

  /// Internal constructor for an empty set.
  Interval._empty()
      : this.min = double.nan,
        this.max = double.nan,
        this._emptySet = true;

  /// Performs an interval addition.
  ///
  ///     [a, b] + [c, d] = [a + c, b + d]
  Interval operator +(Interval i) {
    if (this.isEmpty() || i.isEmpty()) {
      return Interval.empty();
    } else {
      return Interval(this.min + i.min, this.max + i.max);
    }
  }

  /// Unary minus on intervals.
  ///
  ///     -[a, b] = [-b, -a]
  Interval operator -() {
    if (this.isEmpty()) {
      return Interval.empty();
    } else {
      return Interval(-max, -min);
    }
  }

  /// Performs an interval subtraction.
  ///
  ///     [a, b] + [c, d] = [a - d, b - c]
  Interval operator -(Interval i) {
    if (this.isEmpty() || i.isEmpty()) {
      return Interval.empty();
    } else {
      return Interval(this.min - i.max, this.max - i.min);
    }
  }

  /// Performs an interval multiplication.
  ///
  ///     [a, b] * [c, d] = [min(ac, ad, bc, bd), max(ac, ad, bc, bd)]
  Interval operator *(Interval i) {
    if (this.isEmpty() || i.isEmpty()) return Interval.empty();
    final num min = _min(
        this.min * i.min, this.min * i.max, this.max * i.min, this.max * i.max);
    final num max = _max(
        this.min * i.min, this.min * i.max, this.max * i.min, this.max * i.max);
    return Interval(min, max);
  }

  /// Performs an interval division.
  ///
  ///     [a, b] * [c, d] = [a, b] * (1/[c, d]) = [a, b] * [1/d, 1/c]
  ///
  /// __Note:__ Does not handle division by zero and throws an [ArgumentError] instead.
  Interval operator /(Interval i) {
    if (this.isEmpty() || i.isEmpty()) return Interval.empty();

    if (i.containsZero()) {
      // Fuck. Somebody is dividing by zero, the world is going to end.
      // Just kidding - we actually can handle this situation here.

      // Case 1: This interval is strictly negative.
      if (!this.isPositive()) {
        if (i.min == 0 && i.max == 0) {
          // Result = empty set
          return Interval.empty();
        }

        if (i.min < i.max && i.max == 0) {
          // round down new min
          return Interval(this.max / i.min, double.infinity);
        }

        if (i.min < i.max && i.min == 0) {
          // round up new max
          return Interval(double.negativeInfinity, this.max / i.max);
        }
      }

      // Case 2: This interval contains zero.
      if (this.containsZero()) {
        return Interval(double.negativeInfinity, double.infinity);
      }

      // Case 3: This interval is strictly positive.
      if (this.max > 0) {
        if (i.min == 0 && i.max == 0) {
          // Result = empty set
          return Interval.empty();
        }

        if (i.min < i.max && i.max == 0) {
          // round up new max
          return Interval(double.negativeInfinity, this.min / i.min);
        }

        if (i.min < i.max && i.min == 0) {
          // round down new min
          return Interval(this.min / i.max, double.infinity);
        }
      }
      throw ArgumentError('Can not divide by 0');
    }

    return this * Interval(1.0 / i.max, 1.0 / i.min);
  }

  /// Equals operator on intervals.
  ///
  ///     [a, b] == [c, d], if a == c && b == d
  @override
  bool operator ==(Object i) =>
      (i is Interval) && this.min == i.min && this.max == i.max;

  /// Less than operator on intervals.
  ///
  ///     [a, b] < [c, d], if a < c && b < d
  bool operator <(Interval i) => this.min < i.min && this.max < i.max;

  /// Less or equal than operator on intervals.
  ///
  ///     [a, b] <= [c, d], if a <= c && b <= d
  bool operator <=(Interval i) => this.min <= i.min && this.max <= i.max;

  /// Greater than operator on intervals.
  ///
  ///     [a, b] > [c, d], if a > c && b > d
  bool operator >(Interval i) => this.min > i.min && this.max > i.max;

  /// Greater or equal than operator on intervals.
  ///
  ///     [a, b] >= [c, d], if a >= c && b >= d
  bool operator >=(Interval i) => this.min >= i.min && this.max >= i.max;

  /// Returns the greatest lower bound.
  Interval glb(Interval i) =>
      Interval(math.min(min, i.min), math.min(max, i.max));

  /// Returns the least upper bound.
  Interval lub(Interval i) =>
      Interval(math.max(min, i.min), math.max(max, i.max));

  /// Inclusion relation. Returns true, if the given interval is included
  /// in this interval.
  ///
  ///     [a, b] subset of [c, d] <=> c <= a && b >= d
  bool includes(Interval i) => this.min <= i.min && i.max <= this.max;

  /// Element-of relation. Returns true, if given element is included
  /// in this interval.
  /// Defined on a real number i and an interval:
  ///
  ///     i element of [a, b] <=> a <= i && i <= b
  bool contains(num element) => this.min <= element && element <= this.max;

  /// Returns true, if this interval contains zero (min <= 0 <= max).
  bool containsZero() => this.min <= 0 && 0 <= this.max;

  /// Returns true, if this interval is positive (min >= 0)
  bool isPositive() => this.min >= 0;

  /// Returns true, if neither min or max values are infinite.
  bool isBound() => !this.min.isInfinite && !this.max.isInfinite;

  /// Returns true, if this is the empty set.
  bool isEmpty() => this._emptySet;

  /// Returns the minimal value of four given values.
  num _min(num a, num b, num c, num d) =>
      math.min(math.min(a, b), math.min(c, d));

  /// Returns the maximum value of four given values.
  num _max(num a, num b, num c, num d) =>
      math.max(math.max(a, b), math.max(c, d));

  /// Returns the length of this interval.
  num length() => max - min;

  @override
  String toString() => '[${this.min},${this.max}]';

  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + min.hashCode;
    result = 37 * result + max.hashCode;
    return result;
  }

  @override
  int compareTo(Interval other) {
    // For now, only allow compares to other intervals.
    // Equality, less and greater tests.
    if (this < other) return -1;
    return (this > other) ? 1 : 0;
  }
}
