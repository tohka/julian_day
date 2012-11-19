if RUBY_VERSION < '1.9'
	require 'rational'
end

class JulianDay
	GREGORIAN = 0
	JULIAN    = 1

	SUNDAY    = 0
	MONDAY    = 1
	TUESDAY   = 2
	WEDNESDAY = 3
	THURSDAY  = 4
	FRIDAY    = 5
	SATURDAY  = 6

	UTC  =    0
	AEDT =  660 # オーストラリア東部夏時間
	ACDT =  630 # オーストラリア中部夏時間 (UTC+10:30)
	AEST =  600 # オーストラリア東部標準時
	ACST =  570 # オーストラリア中部標準時 (UTC+9:30)
	JST  =  540 # 日本標準時
	AWST =  480 # オーストラリア西部標準時
	# CST  =  480 # 中国標準時
	IST  =  330 # インド標準時 (UTC+5:30)
	MSK  =  240 # モスクワ標準時
	EEST =  180 # 東部ヨーロッパ夏時間
	EET  =  120 # 東部ヨーロッパ時間
	CEST =  120 # 中部ヨーロッパ夏時間
	CET  =   60 # 中部ヨーロッパ時間
	WEST =   60 # 西部ヨーロッパ夏時間
	WET  =    0 # 西部ヨーロッパ時間
	ADT  = -180 # 大西洋夏時間
	AST  = -240 # 大西洋標準時
	EDT  = -240 # 東部夏時間
	EST  = -300 # 東部標準時
	CDT  = -300 # 中部夏時間
	CST  = -360 # 中部標準時
	MDT  = -360 # 山岳部夏時間
	MST  = -420 # 山岳部標準時
	PDT  = -420 # 太平洋夏時間
	PST  = -480 # 太平洋標準時
	AKDT = -480 # アラスカ夏時間
	AKST = -540 # アラスカ標準時

	# コンストラクタ
	#
	# @param [JulianDay, Numeric, Time, Array] arg 指定する日時。
	#   * 省略すると現在の日時で生成します。
	#   * JulianDay で与えると同じ日時で生成します。
	#   * Numeric で与えると値をユリウス日とみなして生成します。
	#       時分秒など細かく指定するときは Rational を用いる方が
	#       正確に処理できます。 unix time として指定したいときは
	#       {#at_time} を用います。
	#   * Time で与えるとその日時で生成します。
	#   * Array で与えると [year = 2000, month = 1, day = 1,
	#       hour = 0, min = 0, sec = 0, usec = 0, tz_offset = 0] と
	#       処理します。ただし各要素は整数とみなします。
	#       +day+ は 0 を取ることができ、前月末日とみなされます。
	#       +tz_offset+ は分単位の時差で東が正です。
	# @param [Boolean] is_julian ユリウス暦とみなすかどうか。
	#   日付からユリウス日を生成するときや、その逆のときに
	#   ユリウス暦かグレゴリオ暦かを指定します。デフォルトは
	#   グレゴリオ暦です。この値は {#julian} や {#gregorian} で
	#   変更することができます。
	# @return self
	# @raise [TypeError] 引数が想定していない型のとき。
	# @raise [RangeError] +arg+ が配列のとき、各要素値が範囲内にないとき。
	def initialize(arg = nil, is_julian = false)
		is_julian ? julian : gregorian
		
		if arg.nil?
			at_time(Time.now)
		elsif arg.kind_of?(self.class) || arg.kind_of?(Numeric)
			at(arg)
		elsif arg.kind_of?(Time) || arg.kind_of?(Array)
			at_time(arg)
		else
			raise TypeError
		end

		self
	end

	# 指定したユリウス日に変更します。
	#
	# @param [JulianDay, Numeric] julian_day 指定するユリウス日。
	# @return self
	# @raise [TypeError] 引数が想定していない型のとき。
	def at(julian_day)
		if julian_day.kind_of?(self.class)
			@jdn  = julian_day.jdn
			@sec  = julian_day.sec
			@usec = julian_day.usec
			julian_day.julian? ? julian : gregorian
		elsif julian_day.kind_of?(Numeric)
			julian_day = Rational(julian_day) + Rational(1, 2)
			@jdn  = julian_day.floor
			sec   = (julian_day - @jdn) * 86400
			@sec  = sec.floor
			@usec = ((sec - @sec) * 1000000).round
		else
			raise TypeError
		end

		self
	end

	# {#at} のエイリアス。
	#
	# @param [JulianDay, Numeric] julian_day 指定するユリウス日。
	# @return self
	# @raise [TypeError] 引数が想定していない型のとき。
	def jd=(julian_day)
		at(julian_day)
	end

	# 指定した日時に変更します。
	#
	# @param [Time, Numeric, Array] time 指定する日時。
	#   * Time で与えるとその日時で生成します。
	#   * Numeric で指定した値は unix time とみなされる点が
	#       コンストラクタと異なります。
	#       なお、時間は協定世界時です。
	#   * Array で与えると [year = 2000, month = 1, day = 1,
	#       hour = 0, min = 0, sec = 0, usec = 0, tz_offset = 0] と
	#       処理します。ただし各要素は整数とみなします。
	#       +day+ は 0 を取ることができ、前月末日とみなされます。
	#       +tz_offset+ は分単位の時差で東が正です。
	# @param [Boolean] is_julian ユリウス日とみなすかどうか。
	#   省略すると現在のモードが採用されます。このメソッドの
	#   +is_julian+ はこのメソッド限りの指定値となります。
	#   暦のモード自体を変更するには {#julian} {#gregorian} を
	#   用います。
	# @return self
	# @raise [TypeError] 引数が想定していない型のとき。
	# @raise [RangeError] +time+ が配列のとき、各要素値が範囲内にないとき。
	def at_time(time, is_julian = nil)
		if time.kind_of?(Time)
			time.utc
			at_time([time.year, time.month, time.day,
					time.hour, time.min, time.sec, time.usec], false)
		elsif time.kind_of?(Numeric)
			# epoch of unix time
			# 2440587.5 (1970-01-01 00:00:00Z)
			at(Rational(4881175, 2) + Rational(time, 86400))
		elsif time.kind_of?(Array)
			year   = time[0].nil? ? 2000 : time[0].to_i
			month  = time[1].nil? ? 1 : time[1].to_i
			day    = time[2].nil? ? 1 : time[2].to_i
			hour   = time[3].to_i
			min    = time[4].to_i
			sec    = time[5].to_i
			usec   = time[6].to_i
			offset = time[7].to_i
			raise RangeError unless (1 .. 12).include?(month)
			raise RangeError unless (0 .. 31).include?(day)
			raise RangeError unless (0 .. 23).include?(hour)
			raise RangeError unless (0 .. 59).include?(min)
			raise RangeError unless (0 .. 60).include?(sec)
			raise RangeError unless (0 .. 999999).include?(usec)
			raise RangeError unless (-1080 .. 1080).include?(offset)

			is_julian = julian? if is_julian.nil?

			# day = 0 のときは前日末日として計算する
			# (実際は day = 1 として計算し、そのあと 1 を引く)
			is_day_zero = day.zero?
			day = 1 if is_day_zero

			a = (14 - month) / 12
			y = year + 4800 - a
			m = month + 12 * a - 3
			if is_julian
				@jdn = 365 * y + (y / 4) + ((153 * m + 2) / 5) + day - 32083
			else
				@jdn = 365 * y + (y / 4) - (y / 100) + (y / 400) +
						((153 * m + 2) / 5) + day - 32045
			end
			@sec = 3600 * hour + 60 * min + sec
			@usec = usec
			
			# day = 0 のときは 1 を引く
			@jdn -= 1 if is_day_zero

			# 時差の処理
			@sec -= offset * 60
			if @sec >= 86400
				@jdn += 1
				@sec -= 86400
			elsif @sec < 0
				@jdn -= 1
				@sec += 86400
			end
		else
			raise TypeError
		end

		self
	end

	# {#at_time} のエイリアス。
	# 
	# エイリアスですが、暦のモードを指定することができません。
	#   あらかじめ {#julian} {#gregorian} を用いるか、 {#at_time} を
	#   使用してください。
	#
	# @param [Time, Numeric, Array] time 指定する日時。
	#   * Time で与えるとその日時で生成します。
	#   * Numeric で指定した値は unix time とみなされる点が
	#       {#initialize コンストラクタ}と異なります。
	#   * Array で与えると [year = 2000, month = 1, day = 1,
	#       hour = 0, min = 0, sec = 0, usec = 0, tz_offset = 0] と
	#       処理します。ただし各要素は整数とみなします。
	#       +day+ は 0 を取ることができ、前月末日とみなされます。
	#       +tz_offset+ は分単位の時差で東が正です。
	# @return self
	# @raise [TypeError] 引数が想定していない型のとき。
	# @raise [RangeError] +time+ が配列のとき、各要素値が範囲内にないとき。
	def time=(time)
		at_time(time)
	end

	# 日時を返します。
	#
	# 日にちはユリウス暦ないしグレゴリオ暦が施行されているとして
	# 計算します。どちらの暦で計算するかは {#julian} {#gregorian} で
	# あらかじめ指定してください。時間は協定世界時です。
	#
	# @param [Integer] tz_offset 時差。
	#   東が正で、分単位です。日本標準時は 540 になります。
	# @return [Array] 年、月、日、時、分、秒、マイクロ秒、時差からなる配列。
	# @raise [TypeError] 引数が想定していない型のとき。
	# @raise [RangeError] +tz_offset+ が前後 18 時間の範囲内にないとき。
	def datetime(tz_offset = 0)
		if tz_offset.kind_of?(Integer)
			raise RangeError unless (-1080 .. 1080).include?(tz_offset)
		else
			raise TypeError
		end
		# 簡易的に時差の分だけ進んでいるユリウス日を作成する
		t = self + Rational(tz_offset, 1440)
		y = -4800
		m = d = 1
		if julian?
			# -4800/03/00 からの通日
			days = t.jdn + 32083
			y += 4 * (days / 1461)
			days %= 1461
			if days.zero?
				m = 2
				d = 29
			else
				y += days / 365
				days %= 365
				m, d = get_md(days)
			end
		else
			# -4800/03/00 からの通日
			days = t.jdn + 32045
			y += 400 * (days / 146097)
			days %= 146097
			if days.zero?
				m = 2
				d = 29
			else
				y += 100 * (days / 36524)
				days %= 36524
				if days.zero?
					m = 2
					d = 28
				else
					y += 4 * (days / 1461)
					days %= 1461
					if days.zero?
						m = 2
						d = 29
					else
						y += days / 365
						days %= 365
						m, d = get_md(days)
					end
				end
			end
		end
		if m > 12
			y += 1
			m -= 12
		end

		h = t.sec / 3600
		[y, m, d, h, (t.sec - 3600 * h) / 60, t.sec % 60, t.usec, tz_offset]
	end

	# {#to_r} のエイリアス
	#
	# @return [Rational] ユリウス日
	def jd
		to_r
	end

	# 修正ユリウス日を Rational で返します。
	#
	# @return [Rational] 修正ユリウス日。
	def mjd
		jd - Rational(4800001, 2) # 2400000.5
	end

	# ユリウス通日を整数で返します。
	#
	# ここでのユリウス通日はユリウス日に 0.5 を加え、端数を
	#   切り捨てた Julian Day Number を指します。
	#
	# @return [Integer] ユリウス通日。
	def jdn
		@jdn
	end

	# 00時00分からの秒を整数で返します。
	#
	# @return [Integer] 00時00分からの秒。
	def sec
		@sec
	end

	# 秒以下の端数をマイクロ秒として整数で返します。
	#
	# @return [Integer] 秒以下のマイクロ秒。
	def usec
		@usec
	end

	# {#jdn} のエイリアス。
	#
	# @return [Integer] ユリウス通日。
	def to_i
		@jdn
	end

	# ユリウス日を浮動小数点数で返します。
	#
	# 秒以下の情報は情報落ちが発生する可能性があります。
	#
	# @return [Float] ユリウス日
	def to_f
		jd.to_f
	end

	# ユリウス日を Rational で返します。
	#
	# @return [Rational] ユリウス日。
	def to_r
		Rational(@jdn) - Rational(1, 2) + Rational(@sec, 86400) +
				Rational(@usec, 86400000000)
	end

	# ユリウス日を文字列で返します。
	#
	# @return [String] ユリウス日。
	def to_s
		# マイクロ秒は小数点以下 15 桁くらいあれば表現できる
		# ここでは 24 桁まで出力する
		r = jd
		str = r < 0 ? "-" : ""
		r = r.abs
		str += r.floor.to_s
		r = (r - r.floor) * 1000000000000
		str += ".%012d" % r.floor
		r = (r - r.floor) * 1000000000000
		str += "%012d" % r.round
		str
	end

	# {#to_s} のエイリアス。
	#
	# @return [String] ユリウス日。
	def inspect
		to_s
	end

	# unix time を浮動小数点数で返します。
	#
	# @return [Float] unix time 。
	def to_unix_time
		(@jdn - 2440588) * 86400 + @sec + @usec / 1000000.0
	end

	# Time オブジェクトを返します。
	#
	# @return [Time] Time オブジェクト。
	# @raise Time の取り得ることのできない日時(環境依存)。
	def to_time
		time = (@jdn - 2440588) * 86400 + @sec
		Time.at(time, @usec)
	end

	# J2000 からの経過ユリウス世紀を返します。
	#
	# @return [Rational] 経過ユリウス世紀 T 。
	def t
		(jd - 2451545) / 36525
	end

	# 曜日を 0 (日曜) から 6 (土曜) までの整数で返します。
	#
	# ただし、時差による日付変更の考慮はありません。
	#
	# @return [Integer] 0 から 6 までの整数。
	def wday
		(@jdn + 1) % 7
	end

	# 自身より day 日だけ進んだ日を返します。
	#
	# @param [Numeric] day 進ませる日にち。
	# @return [JulianDay] 新しいユリウス日。
	# @raise [TypeError] 引数が想定していない型のとき。
	def +(other)
		if other.kind_of?(Numeric)
			self.class.new(jd + Rational(other), julian?)
		else
			raise TypeError
		end
	end

	# @overload 自身より day 日だけ前の日を返します。
	#   @param [Numeric] day 遡る日にち。
	#   @return [JulianDay] 新しいユリウス日。
	# @overload 他のユリウス日との差を返します。
	#   @param [JulianDay] 引く値。
	#   @return [Rational] 自身と引数との差。単位は日。
	# @raise [TypeError] 引数が想定していない型のとき。
	def -(other)
		if other.kind_of?(self.class)
			jd - other.jd
		elsif other.kind_of?(Numeric)
			self.class.new(jd - Rational(other), julian?)
		else
			raise TypeError
		end
	end

	# 大小を比較します。
	#
	# @param [JulianDay, Numeric] other 比較の対象。
	# @return [Integer] 大小を表す数値。
	# @raise [TypeError] 引数が想定していない型のとき。
	def <=>(other)
		if other.kind_of?(self.class)
			jd <=> other.jd
		elsif other.kind_of?(Numeric)
			jd <=> other
		else
			raise TypeError
		end
	end

	def <(other)
		if other.kind_of?(self.class)
			jd < other.jd
		elsif other.kind_of?(Numeric)
			jd < other
		else
			raise TypeError
		end
	end
	def <=(other)
		if other.kind_of?(self.class)
			jd <= other.jd
		elsif other.kind_of?(Numeric)
			jd <= other
		else
			raise TypeError
		end
	end
	def >(other)
		if other.kind_of?(self.class)
			jd > other.jd
		elsif other.kind_of?(Numeric)
			jd > other
		else
			raise TypeError
		end
	end
	def >=(other)
		if other.kind_of?(self.class)
			jd >= other.jd
		elsif other.kind_of?(Numeric)
			jd >= other
		else
			raise TypeError
		end
	end
	def ==(other)
		if other.kind_of?(self.class)
			jd == other.jd
		elsif other.kind_of?(Numeric)
			jd == other
		else
			raise TypeError
		end
	end

	def succ
		self.class.new(jd + 1)
	end

	def gregorian
		@mode = GREGORIAN
	end
	def gregorian?
		@mode == GREGORIAN
	end
	def julian
		@mode = JULIAN
	end
	def julian?
		@mode == JULIAN
	end

	private

	# yday から月日を得ます。
	#
	# @param [Integer] yday 日にち。ただし 3 月 0 日起算。
	# @return [Array] 月、日の配列。
	def get_md(yday)
		days = [1, 32, 62, 93, 123, 154, 185, 215, 246, 276, 307, 338, 367]
		m = d = 0
		if yday.zero?
			# うるう年は例外として処理したあとに呼ばれるので
			# 平年として、前月末日の 2 月 28 日とする
			m = 2
			d = 28
		else
			12.times do |i|
				if (days[i] ... days[i+1]).include?(yday)
					m = i
					break
				end
			end
			d = yday - days[m] + 1
			m += 3
		end
		[m, d]
	end
end

JulianDay::J2000 = JulianDay.new(2451545)



