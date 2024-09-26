/// A generic key-value pair used for plotting data points in [LineSeries].
///
/// The [ValuePair] class encapsulates an X and Y value, where the X value is
/// of a generic type [T] and the Y value is a nullable `double`. This allows
/// flexibility in defining the X-axis data type, such as `String`, `DateTime`,
/// or any other type that suits the data representation.
///
/// Example usage:
///
/// ```dart
/// // Using String as the X value
/// ValuePair<String> januaryData = ValuePair(x: 'Jan', y: 30.0);
///
/// // Using DateTime as the X value
/// ValuePair<DateTime> dateData = ValuePair(
///   x: DateTime(2023, 1, 1),
///   y: 25.5,
/// );
class ValuePair<T> {
  /// Creates a constant instance of [ValuePair].
  ///
  /// Both [x] and [y] are required parameters.
  ///
  /// The [x] parameter represents the X-coordinate value and is of generic type [T],
  /// allowing for flexibility in the type of data it can hold.
  ///
  /// The [y] parameter represents the Y-coordinate value and is a nullable `double`.
  /// It will not be displayed on the chart if assigned null.
  const ValuePair({
    required this.x,
    required this.y,
  });

  /// The X-coordinate value.
  final T x;

  /// The Y-coordinate value.
  final double? y;
}
