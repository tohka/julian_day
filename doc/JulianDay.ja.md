# JulianDay

## 概要

ユリウス日を保持するクラスです。

## 作成

### JulianDay.new

```ruby
require 'julian_day'

jd = JulianDay.new
```

引数を省略すると現在時刻のユリウス日が作成されます。

### JulianDay.new(num, is_julian = false)

```ruby
jd = JulianDay.new(2451545)
```

引数に数値を与えると、指定されたユリウス日が作成されます。

第二引数を指定すると、暦モードを変更します。 `true` を与えるとユリウス暦をデフォルトにします。

### JulianDay.new(time, is_julian = false)

```ruby
time = Time.local(2012, 1, 23)
jd = JulianDay.new(time)
```

引数に Time オブジェクトを与えると、オブジェクトが示す日時のユリウス日が作成されます。

第二引数を指定すると、暦モードを変更します。 `true` を与えるとユリウス暦をデフォルトにします。

### JulianDay.new(array, is_julian = false)

```ruby
# 2012-01-23 04:56:07.89 +09:00
jd = JulianDay.new([2012, 1, 23, 4, 56, 7, 890000, 540])
# 1234-12-03 01:23:04 CET in Julian Calendar
jd = JulianDay.new([1234, 12, 3, 1, 23, 4, 0, JulianDay::CET], true)
```

第一引数に配列を与えると、指定した日時のユリウス日が作成されます。第二引数が `true` ならユリウス暦として、 `false` ならグレゴリオ暦として第一引数を解釈します。第一引数の配列の要素は `[year, month, day, hour, min, sec, usec, tz_offset]` です。なお `tz_offset` は時差を分単位にしたもので、東を正とします。

第二引数を指定すると、暦モードを変更します。 `true` を与えるとユリウス暦をデフォルトにします。

## 値の設定

### JulianDay#at(num)

```ruby
jd.at(2455555 + Rational(67, 86400))
```

`JulianDay.new(num)` と同様、与えたユリウス日に設定します。また、エイリアスとして `JulianDay#jd=(num)` を用いることができます。

### JulianDay#at_time(time)

`JulianDay.new(time)` と同様、与えた Time オブジェクトの示す日時に設定します。また、エイリアスとして `JulianDay#time=(time)` を用いることができます。

### JulianDay#at_time(array, is_julian = nil)

`JulianDay.new(array, is_julian)` と同様、与えた引数の示す日時に設定します。ただし、第二引数 `is_julian` は省略されると、現在の暦モードが使用されます。 `is_julian` を指定しても、暦モードの変更は行いません。

エイリアスとして `JulianDay#time=(array)` を用いることができますが、暦モードの指定はできません。あらかじめ `JulianDay#gregorian` か `JulianDay#julian` でモードを変更のうえ使用するか、 `JulianDay#at_time(array, is_julian)` を使用してください。

### JulianDay#at_time(num)

```ruby
JulianDay.new.at_time(1325376000)
```

`JulianDay.new(num)` や `JulianDay#at(num)` と異なり、引数を UNIX time として指定された日時に設定します。

## 値の取得

### JulianDay#jd

```ruby
puts JulianDay.new.jd
```

ユリウス日を Rational で返します。エイリアスとして `JulianDay#to_r` も使用できます。

### JulianDay#to_f

ユリウス日を浮動小数点数で返します。型の有効桁数の制限から、小さな時間は丸められる可能性があります。

### JulianDay#mjd

```ruby
puts JulianDay.new.mjd
```

修正ユリウス日を Rational で返します。

### JulianDay#jdn

```ruby
puts JulianDay.new.jdn
```

ユリウス通日を整数で返します。ここで言うユリウス通日は、ユリウス日に 0.5 を加え、端数を切り捨てた Julian Day Number を指します。エイリアスとして `JulianDay#to_i` も使用できます。

### JulianDay#sec

```ruby
puts JulianDay.new.sec
```

00:00 UTC からの経過秒を整数で返します。

### JulianDay#usec

```ruby
puts JulianDay.new.usec
```

秒以下の端数をマイクロ秒として整数で返します。

### JulianDay#to_s

```ruby
puts JulianDay.new.to_s
```

ユリウス日を実数として変換した結果を文字列として返します。浮動小数点数型が保持できる精度よりも高精度になります。エイリアスとして `JulianDay#inspect` も使用できます。

### JulianDay#datetime(tz_offset = 0)

```ruby
jd = JulianDay.new([1234, 12, 3, 1, 23, 4, 0, JulianDay::CET], true)
jd.gregorian
puts jd.datetime(540).inspect
```

引数で与えた時差の時間帯における日時を配列で返します。返す配列の要素は `[year, month, day, hour, min, sec, usec, tz_offset]` です。

### JulianDay#to_unix_time

```ruby
puts JulianDay.new.to_unix_time
```

UNIX time に変換して整数で返します。

### JulianDay#to_time

```ruby
puts JulianDay.new.to_time
```

Time オブジェクトで返します。

### JulianDay#wday

```ruby
puts ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][JulianDay.new.wday]
```

曜日を整数で返します。日曜が 0 で、土曜が 6 です。

### JulianDay#t

```ruby
puts JulianDay.new.t.to_f
```

J2000.0 からの経過ユリウス世紀 T を Rational で返します。

## 演算

### JulianDay#+(num)

```ruby
jd = JulianDay.new + Rational(67, 86400)
```

引数で与えた日だけ進めた日時の JulianDay オブジェクトを返します。

### JulianDay#-(num)

```ruby
jd = JulianDay.new - 36525
```

引数で与えた日だけ前の日時の JulianDay オブジェクトを返します。

### JulianDay#-(jd)

```ruby
puts JulianDay.new - JulianDay.new([2000, 1, 1, 12, 0, 0])
```

引数で与えられた JulianDay オブジェクトとの差を Rational として返します。単位は日数です。

### その他

比較演算子を定義しています。

## 暦のモード

`JulianDay#at_time(array)` `JulianDay#time=(array)` や `JulianDay#datetime(tz_offset = 0)` では、そのときの暦モードに従ってユリウス暦かグレゴリオ暦のどちらかとみなして処理を行います。

暦モードはコンストラクタの第二引数で指定できるほか、 `JulianDay#julian` と `JulianDay#gregorian` で変更することができます。

また現在の暦モードを確認するために `JulianDay#julian?` と `JulianDay#gregorian?` が使用できます。

## 定数

*   `JulianDay::J2000` : 2000-01-01 12:00:00Z のユリウス日
*   `JulianDay::UTC`   : 協定世界時
*   `JulianDay::AEDT`  : オーストラリア東部夏時間
*   `JulianDay::ACDT`  : オーストラリア中部夏時間
*   `JulianDay::AEST`  : オーストラリア東部標準時
*   `JulianDay::ACST`  : オーストラリア中部標準時
*   `JulianDay::JST`   : 日本標準時
*   `JulianDay::AWST`  : オーストラリア西部標準時
*   `JulianDay::IST`   : インド標準時
*   `JulianDay::MSK`   : モスクワ標準時
*   `JulianDay::EEST`  : 東部ヨーロッパ夏時間
*   `JulianDay::EET`   : 東部ヨーロッパ時間
*   `JulianDay::CEST`  : 中部ヨーロッパ夏時間
*   `JulianDay::CET`   : 中部ヨーロッパ時間
*   `JulianDay::WEST`  : 西部ヨーロッパ夏時間
*   `JulianDay::WET`   : 西部ヨーロッパ時間
*   `JulianDay::ADT`   : 大西洋夏時間
*   `JulianDay::AST`   : 大西洋標準時
*   `JulianDay::EDT`   : 東部夏時間
*   `JulianDay::EST`   : 東部標準時
*   `JulianDay::CDT`   : 中部夏時間
*   `JulianDay::CST`   : 中部標準時
*   `JulianDay::MDT`   : 山岳部夏時間
*   `JulianDay::MST`   : 山岳部標準時
*   `JulianDay::PDT`   : 太平洋夏時間
*   `JulianDay::PST`   : 太平洋標準時
*   `JulianDay::AKDT`  : アラスカ夏時間
*   `JulianDay::AKST`  : アラスカ標準時

