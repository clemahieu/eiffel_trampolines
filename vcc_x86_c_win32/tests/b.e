note
	description: "Summary description for {B}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	B

feature

	tramp6 (heap: HEAP): TRAMPOLINE
		local
			obj: POINTER
			func: POINTER

		do
			obj := curr (Current)
			func := $b6
			create Result.make (heap, obj, func)
		end

	curr (in: ANY): POINTER
		external
			"C inline"
		alias
			"[
				return $in;
			]"
		end

	eif_protect (obj: POINTER): POINTER
		external
			"C inline"
		alias
			"[
				return eif_protect ($obj);
			]"
		end

	eif_adopt (obj: POINTER): POINTER
		external
			"C inline"
		alias
			"[
				return eif_adopt ($obj);
			]"
		end

	i: INTEGER

feature {NONE}

	b (one: INTEGER; two: INTEGER): INTEGER
		do
			i := i + one + two
		end

	b2 (one: INTEGER; two: INTEGER; three: INTEGER; four: INTEGER)
		do
			i := i + three + four
		end

	b3 (one: INTEGER; two: INTEGER; three: REAL_64; four: REAL_64)
		do
			i := i + three.truncated_to_integer + four.truncated_to_integer
		end

	b4 (one: INTEGER; two: INTEGER; three: INTEGER; four: INTEGER; five: INTEGER; six: INTEGER)
		do
			i := i + five + six
		end

	b5 (one: INTEGER; two: INTEGER; three: REAL_64; four: REAL_64; five: REAL_64; six: REAL_64)
		do
			i := i + five.truncated_to_integer + six.truncated_to_integer
		end

	b6 (arguments: POINTER)
		local
			pointer: MANAGED_POINTER
			one: INTEGER_32
			two: INTEGER_32
			three: REAL_64
			four: REAL_64
			five: REAL_64
			six: REAL_64
		do
			create pointer.share_from_pointer (arguments, 44)
			one := pointer.read_integer_32 (4)
			two := pointer.read_integer_32 (8)
			three := pointer.read_real_64 (12)
			four := pointer.read_real_64 (20)
			five := pointer.read_real_64 (28)
			six := pointer.read_real_64 (36)
			i := i + five.truncated_to_integer + six.truncated_to_integer
		end

	b7 (arguments: POINTER)
		local
			pointer: MANAGED_POINTER
			one: INTEGER_32
			two: INTEGER_32
			three: REAL_64
			four: REAL_64
			five: REAL_64
			six: REAL_64
		do
			create pointer.share_from_pointer (arguments, 40)
			one := pointer.read_integer_32 (0)
			two := pointer.read_integer_32 (8)
			three := pointer.read_real_64 (48)
			four := pointer.read_real_64 (56)
			five := pointer.read_real_64 (72)
			six := pointer.read_real_64 (80)
			i := i + five.truncated_to_integer + six.truncated_to_integer
		end
end
