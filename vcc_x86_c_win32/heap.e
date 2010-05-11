note
	description: "Summary description for {HEAP}."
	author: "Colin LeMahieu"
	date: "$Date$"
	revision: "$Revision$"
	quote: "The best government is the one that charges you the least blackmail for leaving you alone. - Thomas Rudmose-Brown (1996)"

class
	HEAP

create
	make

feature {NONE}

	make (size: NATURAL_32)
		local
		do
			heap_handle := heap_create (0, size, 0)
		end

feature

	malloc (size: NATURAL_32): POINTER
		do
			Result := heap_alloc (heap_handle, 0, size)
		end

	heap_handle: POINTER

feature {NONE} -- External

	heap_create (options: NATURAL_32; initial_size: NATURAL_32; maximum_size: NATURAL_32): POINTER
		external
			"C inline use %"windows.h%""
		alias
			"[
				return HeapCreate ($options, $initial_size, $maximum_size);
			]"
		end

	heap_alloc (heap: POINTER; flags: NATURAL_32; bytes: NATURAL_32): POINTER
		external
			"C inline use %"windows.h%""
		alias
			"[
				return HeapAlloc ($heap, $flags, $bytes);		
			]"
		end

end
