note
	description: "Summary description for {HEAP}."
	author: "Colin LeMahieu"
	date: "$Date$"
	revision: "$Revision$"
	quote: "The most fundamental purpose of government is defense, not empire. - Joseph Sobran (1995)"

class
	HEAP

create
	make

feature {NONE}

	make (size: NATURAL_64)
		local
		do
			heap_handle := heap_create (0, size, 0)
		end

feature

	malloc (size: NATURAL_64): POINTER
		do
			Result := heap_alloc (heap_handle, 0, size)
		end

	heap_handle: POINTER

feature {NONE} -- External

	heap_create (options: NATURAL_32; initial_size: NATURAL_64; maximum_size: NATURAL_64): POINTER
		external
			"C inline use %"windows.h%""
		alias
			"[
				return HeapCreate ($options, $initial_size, $maximum_size);
			]"
		end

	heap_alloc (heap: POINTER; flags: NATURAL_32; bytes: NATURAL_64): POINTER
		external
			"C inline use %"windows.h%""
		alias
			"[
				return HeapAlloc ($heap, $flags, $bytes);
			]"
		end

end
