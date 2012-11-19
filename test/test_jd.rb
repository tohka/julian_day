#!/usr/bin/ruby

require 'julian_day'

# generate a Julian Day object
#
# at now time
jd = JulianDay.new
# 2000-01-23 04:56:07.89Z in Gregorian Calendar
jd = JulianDay.new([2000, 1, 23, 4, 56, 7, 890000])
# 1234-05-06 12:34:56 +0900 in Julian Calendar
jd = JulianDay.new([1234, 5, 6, 12, 34, 56, 0, 540], true)
# from Julian Day
jd = JulianDay.new(2451545)
# from Time object
jd = JulianDay.new(Time.local(2012, 1, 1))
# from unix time
jd = JulianDay.new.at_time(1353348747)


# get another Julian Day
#
# the following day
jd = JulianDay.new
jd = jd + 1
# the previous hour
jd = jd - Rational(1, 24)

# get information of Julian Day
#
# get Julian Day (as Rational)
jd = JulianDay.new
puts jd.jd
# get Modified Julian Day (as Rational)
puts jd.mjd
# get Julian Day Number
puts jd.jdn
# get Julian Day as real number
puts jd.to_f
# get Julian Day as string (higher precision than one of real number)
puts jd.to_s

# convert to another data
#
# to Time object
puts jd.to_time
# to unix time
puts jd.to_unix_time
# to wday (0 => Sunday, ..., 6 => Saturday)
puts jd.wday
# to Julian century from J2000.0
puts jd.t

# get date and time (as Array)
#
# timezone = UTC in Gregorian Calendar
jd.gregorian
puts jd.datetime.inspect
# timezone = EST in Gregorian Calendar
puts jd.datetime(JulianDay::EST).inspect
# timezone = CET in Julian Calendar
jd.julian
puts jd.datetime(JulianDay::CET).inspect
