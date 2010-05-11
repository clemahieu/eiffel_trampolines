note
	description : "test_interop application root class"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make6
		local
			tramp: TRAMPOLINE
			b: B
			curr: POINTER
			func: POINTER
			i: INTEGER
		do
			io.put_string ("Starting%N")
			create b
			func := b.b7_pointer
		end

	make
		local
			tramp: TRAMPOLINE
			b: B
			curr: POINTER
			func: POINTER
			i: INTEGER
			heap: HEAP
		do
			io.put_string ("Starting%N")
			create heap.make ({NATURAL_64}1024 * {NATURAL_64}1024)
			create b
			tramp := b.tramp7 (heap)
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

	make4
		local
			tramp: TRAMPOLINE
			b: B
			curr: POINTER
			func: POINTER
			i: INTEGER
			heap: HEAP
		do
			io.put_string ("Starting%N")
			create heap.make ({NATURAL_64}1024 * {NATURAL_64}1024)
			create b
			tramp := b.tramp4 (heap)
			from
				i := 0
			until
				i = 100
			loop
				callout4 (tramp.function)
				io.put_string ("Current i: " + b.i.out + " sum: " + sum (b.i).out)
				io.put_new_line
				i := i + 1
			end
		end

	make3
		local
			tramp: TRAMPOLINE
			b: B
			curr: POINTER
			func: POINTER
			i: INTEGER
			heap: HEAP
		do
			io.put_string ("Starting%N")
			create b
			create heap.make ({NATURAL_64}1024 * {NATURAL_64}1024)
			tramp := b.tramp3 (heap)
			from
				i := 0
			until
				i = 100
			loop
				callout3 (tramp.function)
				io.put_string ("Current i: " + b.i.out + " sum: " + sum (b.i).out)
				io.put_new_line
				i := i + 1
			end
		end

	make2
		local
			tramp: TRAMPOLINE
			b: B
			curr: POINTER
			func: POINTER
			i: INTEGER
			heap: HEAP
		do
			io.put_string ("Starting%N")
			create heap.make ({NATURAL_64}1024 * {NATURAL_64}1024)
			create b
			tramp := b.tramp2 (heap)
			from
				i := 0
			until
				i = 100
			loop
				callout2 (tramp.function)
				io.put_string ("Current i: " + b.i.out + " sum: " + sum (b.i).out)
				io.put_new_line
				i := i + 1
			end
		end

	make1
		local
			tramp: TRAMPOLINE
			b: B
			curr: POINTER
			func: POINTER
			i: INTEGER
			heap: HEAP
		do
			io.put_string ("Starting%N")
			create heap.make ({NATURAL_64}1024 * {NATURAL_64}1024)
			create b
			tramp := b.tramp (heap)
			from
				i := 0
			until
				i = 100
			loop
				callout (tramp.function)
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

	callout7 (obj: POINTER; function: POINTER; arg: POINTER)
		external
			"C inline"
		alias
			"[
				void (*typed_func) (void *, void *);
				
				typed_func = (void (*) (void *, void *))$function;
				typed_func ($obj, $arg);
			]"
		end

	callout6 (function: POINTER)
		external
			"C inline"
		alias
			"[
				void (*typed_func) (int);

				typed_func = $function;
				typed_func (4);
			]"
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

	callout4 (function: POINTER)
		external
			"C inline"
		alias
			"[
				void (*typed_func) (int, int, int, int, int, int);
				
				typed_func = $function;
				typed_func (4, 3, 7, 8, 2, 1);
			]"
		end

	callout3 (function: POINTER)
		external
			"C inline"
		alias
			"[
				void (*typed_func) (int, int, double, double);
				
				typed_func = $function;
				typed_func (4, 3, 2.8, 1.777779999);
			]"
		end

	callout2 (function: POINTER)
		external
			"C inline"
		alias
			"[
				void (*typed_func) (int, int, int, int);
				
				typed_func = $function;
				typed_func (4, 3, 2, 1);
			]"
		end

	callout (function: POINTER)
		external
			"C inline"
		alias
			"[
				void (*typed_func) (int, int);
				
				typed_func = $function;
				typed_func (1, 2);
			]"
		end
end
