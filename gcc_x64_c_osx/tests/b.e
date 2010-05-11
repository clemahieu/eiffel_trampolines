note
	description: "Summary description for {B}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	B

feature

	tramp (zone: MALLOC_ZONE): TRAMPOLINE
		local
			obj: POINTER
			func: POINTER
		do
			obj := curr (Current)
			func := $b
			create Result.make (zone, obj, func)
		end

	tramp2 (zone: MALLOC_ZONE): TRAMPOLINE
		local
			obj: POINTER
			func: POINTER
		do
			obj := curr (Current)
			func := $b2
			-- 8 Bytes on the stack for padding to 16 bytes
			create Result.make (zone, obj, func)
		end

	tramp3 (zone: MALLOC_ZONE): TRAMPOLINE
		local
			obj: POINTER
			func: POINTER
		do
			obj := curr (Current)
			func := $b3
			-- 8 Bytes on the stack for padding to 16 bytes
			create Result.make (zone, obj, func)
		end

	tramp4 (zone: MALLOC_ZONE): TRAMPOLINE
		local
			obj: POINTER
			func: POINTER
		do
			obj := curr (Current)
			func := $b4
			-- 8 Bytes on the stack for padding to 16 bytes
			create Result.make (zone, obj, func)
		end

	tramp5 (zone: MALLOC_ZONE): TRAMPOLINE
		local
			obj: POINTER
			func: POINTER
		do
			obj := curr (Current)
			func := $b5
			-- 8 Bytes on the stack for padding to 16 bytes
			create Result.make (zone, obj, func)
		end

	tramp7 (zone: MALLOC_ZONE): TRAMPOLINE
		local
			obj: POINTER
			func: POINTER
		do
			obj := curr (Current)
			func := $b7
			create Result.make (zone, obj, func)
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

feature

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
			create pointer.share_from_pointer (arguments, 40)
			one := pointer.read_integer_32 (0)
			two := pointer.read_integer_32 (4)
			three := pointer.read_real_64 (8)
			four := pointer.read_real_64 (16)
			five := pointer.read_real_64 (24)
			six := pointer.read_real_64 (32)
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
			create pointer.share_from_pointer (arguments, 0x60)
			one := pointer.read_integer_32 (0x0)
			two := pointer.read_integer_32 (0x8)
			three := pointer.read_real_64 (0x30)
			four := pointer.read_real_64 (0x38)
			five := pointer.read_real_64 (0x40)
			six := pointer.read_real_64 (0x48)
			i := i + five.truncated_to_integer + six.truncated_to_integer
		end

	b7_pointer: POINTER
		do
			Result := $b7
		end
end
