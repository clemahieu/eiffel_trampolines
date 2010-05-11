note
	description : "GCC_X64_trampoline application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make
		local
			zone: MALLOC_ZONE
			b: B
			tramp: TRAMPOLINE
			i: INTEGER
		do
			create zone.make ({NATURAL_64}1024 * {NATURAL_64}1024)
			io.put_string ("Starting%N")
			create b
			tramp := b.tramp7 (zone)
			from
				i := 0
			until
				i = 100
			loop
				callout5 (tramp.function)
				io.put_string ("Current i: " + b.i.out + " sum: " + sum (b.i).out)
				io.put_new_line
				i := i + 1
			end
		end

	sum (i: INTEGER): INTEGER
			-- Calculate something recursively to test stack integrity
		do
			if
				i = 0
			then
				Result := 0
			else
				Result := i + sum (i - 1)
			end
		end

	callout5 (function: POINTER)
		external
			"C inline"
		alias
			"[
				void (*typed_func) (int, int, double, double, double, double);
				
				typed_func = $function;
				typed_func (4, 3, 7.8, 8.777779999, 2.345, 1.234);
			]"
		end
end
