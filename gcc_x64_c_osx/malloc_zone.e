note
	description: "Summary description for {MALLOC_ZONE}."
	author: "Colin LeMahieu"
	date: "$Date$"
	revision: "$Revision$"
	quote: "Liberty is always dangerous, but it is the safest thing we have. - Harry Emerson Fosdick"

class
	MALLOC_ZONE

create
	make

feature {NONE}

	make (size: NATURAL_64)
		local
			error: INTEGER_32
			zone_l: POINTER
		do
			malloc_create_zone (size, 0, $zone_l, $error)
			zone := zone_l
		end

feature

	malloc (size: NATURAL_64): POINTER
		do
			malloc_zone_malloc (zone, size, $Result);
		end

	zone: POINTER

feature {NONE} -- Externals

	malloc_create_zone (start_size: NATURAL_64; flags: NATURAL_64; ret: TYPED_POINTER [POINTER]; error: TYPED_POINTER [INTEGER_32])
		external
			"C inline use %"malloc/malloc.h%""
		alias
			"[
				malloc_zone_t * result;
				
				result = malloc_create_zone ($start_size, $flags);
				*((unsigned long *)$error) = errno;
				
				*((void **)$ret) = result;
			]"
		end

	malloc_zone_malloc (zone_a: POINTER; size: NATURAL_64; ret: TYPED_POINTER [POINTER])
		external
			"C inline use %"malloc/malloc.h%", %"errno.h%""
		alias
			"[
				void * result;
				
				result = malloc_zone_malloc	($zone_a, $size);
				
				*((void **) $ret) = result;
			]"
		end

invariant
	zone /= default_pointer
note
	copyright: "Copyright (c) 1984-2010, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
