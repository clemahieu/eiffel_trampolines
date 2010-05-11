note
	description: "Summary description for {VCC_X86_C_TRAMPOLINE}."
	author: "Colin LeMahieu"
	date: "$Date$"
	revision: "$Revision$"
	quote: "There's never been a good government. - Emma Goldman"

class
	TRAMPOLINE

create
	make

feature

	make (heap: MALLOC_ZONE; target_object: POINTER; target_function: POINTER)
		require
			correct_platform: {PLATFORM}.pointer_bytes = 4
			target_object: target_object /= default_pointer
			target_function: target_function /= default_pointer
		local
			code: SPECIAL [NATURAL_8]
			code_array: ARRAY [NATURAL_8]
			code_pointer: POINTER
			managed_code: MANAGED_POINTER
			target_object_offset: INTEGER
			target_function_offset: INTEGER
		do
			create code.make_empty (trampoline_size)

			code.extend (0x89) code.extend (0xe0) -- mov -- eax, esp
			code.extend (0x50) -- push eax
			code.extend (0xb8) -- mov eax
			target_object_offset := code.count
			code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0)
			code.extend (0x8b) code.extend (0x00) -- mov eax, [eax]
			code.extend (0x50) -- push eax
			code.extend (0xb8) -- mov eax
			target_function_offset := code.count
			code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0)
			code.extend (0xff) code.extend (0xd0) -- call eax
			code.extend (0x83) code.extend (0xc4) code.extend (0x08) -- add -- esp -- 0x8
			code.extend (0xc3) -- ret

			code_pointer := heap.malloc (trampoline_size.to_natural_32)
			create code_array.make_from_special (code)
			create managed_code.share_from_pointer (code_pointer, trampoline_size)
--			make_read_write_executable (code_pointer)
			managed_code.put_array (code_array, 0)
			managed_code.put_pointer (target_object, target_object_offset)
			managed_code.put_pointer (target_function, target_function_offset)
--			make_read_executable (code_pointer)
			function := managed_code.item
		end

	function: POINTER

feature {NONE} -- Implementation

	trampoline_size: INTEGER_32 = 24

	prot_none: INTEGER = 0x0
	prot_read: INTEGER = 0x1
	prot_write: INTEGER = 0x2
	prot_exec: INTEGER = 0x4

	make_read_write_executable (address: POINTER)
		local
			start_page: NATURAL_32
			end_page: NATURAL_32
			return: INTEGER_32
		do
			start_page := number_for_address (address)
			end_page := start_page + trampoline_size.to_natural_32 - 1
			start_page := start_page.bit_and (0xffff_f000)
			end_page := end_page + 4096 - 1
			end_page := end_page.bit_and (0xffff_f000)
			return := mprotect (address_for_number (start_page), end_page - start_page, prot_read.bit_or (prot_write).bit_or (prot_exec))
		end

	make_read_executable (address: POINTER)
		local
			start_page: NATURAL_32
			end_page: NATURAL_32
			return: INTEGER_32
		do
			start_page := number_for_address (address)
			end_page := start_page + trampoline_size.to_natural_32 - 1
			start_page := start_page.bit_and (0xffff_f000)
			end_page := end_page + 4096 - 1
			end_page := end_page.bit_and (0xffff_f000)
			return := mprotect (address_for_number (start_page), end_page - start_page, prot_read.bit_or (prot_exec))
		end

feature {NONE} -- Externals

	number_for_address (address: POINTER): NATURAL_32
		external
			"C inline"
		alias
			"[
				return (unsigned long)$address;
			]"
		end

	address_for_number (number: NATURAL_32): POINTER
		external
			"C inline"
		alias
			"[
				return (void *)$number;
			]"
		end

	mprotect (address: POINTER; length: NATURAL_32; protection: INTEGER_32): INTEGER_32
		external
			"C inline use %"sys/mman.h%""
		alias
			"[
				return mprotect ($address, $length, $protection);
			]"
		end
end
