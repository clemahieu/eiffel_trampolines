note
	description: "Summary description for {VCC_X86_C_TRAMPOLINE}."
	author: "Colin LeMahieu"
	date: "$Date$"
	revision: "$Revision$"
	quote: "Americans have the right and advantage of being armed – unlike the citizens of other countries whose governments are afraid to trust the people with arms. - James Madison"

class
	TRAMPOLINE

create
	make

feature

	make (heap: HEAP; target_object: POINTER; target_function: POINTER)
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
			make_read_write_executable (code_pointer)
			managed_code.put_array (code_array, 0)
			managed_code.put_pointer (target_object, target_object_offset)
			managed_code.put_pointer (target_function, target_function_offset)
			make_read_executable (code_pointer)
			function := managed_code.item
		end

	function: POINTER

feature {NONE} -- Externals

	trampoline_size: INTEGER_32 = 24

	page_execute_read: NATURAL_32 = 0x20
	page_execute_readwrite: NATURAL_32 = 0x40

	make_read_write_executable (address: POINTER)
		local
			start_page: NATURAL_32
			end_page: NATURAL_32
			return: BOOLEAN
			old_protect: NATURAL_32
		do
			start_page := number_for_address (address)
			end_page := start_page + trampoline_size.to_natural_32 - 1
			start_page := start_page.bit_and (0xffff_f000)
			end_page := end_page + 4096 - 1
			end_page := end_page.bit_and (0xffff_f000)
			return := virtual_protect (address_for_number (start_page), end_page - start_page, page_execute_readwrite, $old_protect)
		end

	make_read_executable (address: POINTER)
		local
			start_page: NATURAL_32
			end_page: NATURAL_32
			return: BOOLEAN
			old_protect: NATURAL_32
		do
			start_page := number_for_address (address)
			end_page := start_page + trampoline_size.to_natural_32 - 1
			start_page := start_page.bit_and (0xffff_f000)
			end_page := end_page + 4096 - 1
			end_page := end_page.bit_and (0xffff_f000)
			return := virtual_protect (address_for_number (start_page), end_page - start_page, page_execute_read, $old_protect)
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

	virtual_protect (address: POINTER; size: NATURAL_32; new_protect: NATURAL_32; old_protect: POINTER): BOOLEAN
		external
			"C inline use %"windows.h%""
		alias
			"[
				return VirtualProtect ($address, $size, $new_protect, $old_protect);
			]"
		end
end
