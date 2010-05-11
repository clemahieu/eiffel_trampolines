note
	description: "Summary description for {GCC_X64_TRAMPOLINE}."
	author: "Colin LeMahieu"
	date: "$Date$"
	revision: "$Revision$"
	quote: "Can our form of government, our system of justice, survive if one can be denied a freedom because he might abuse it? - Harlon Carter"

class
	TRAMPOLINE

create
	make

feature {NONE} -- Creation

	make (zone: MALLOC_ZONE; target_object: POINTER; target_function: POINTER)
		local
			code: SPECIAL [NATURAL_8]
			target_object_offset: INTEGER_32
			target_function_offset: INTEGER_32
			code_array: ARRAY [NATURAL_8]
			managed_code: MANAGED_POINTER
			code_pointer: POINTER
		do
			create code.make_empty (trampoline_size)

			code.extend (0x48) code.extend (0x83) code.extend (0xec) code.extend (0x70) -- rex -- sub -- rsp -- 0x70
			code.extend (0x48) code.extend (0x89) code.extend (0x3c) code.extend (0x24) -- rex -- mov -- [rsp] -- rdi
			code.extend (0x48) code.extend (0x89) code.extend (0x74) code.extend (0x24) code.extend (0x08) -- rex -- mov -- [rsp + 0x08] -- rsi
			code.extend (0x48) code.extend (0x89) code.extend (0x54) code.extend (0x24) code.extend (0x10) -- rex -- mov -- [rsp + 0x10] -- rdx
			code.extend (0x48) code.extend (0x89) code.extend (0x4c) code.extend (0x24) code.extend (0x18) -- rex -- mov -- [rsp + 0x18] -- rcx
			code.extend (0x4c) code.extend (0x89) code.extend (0x44) code.extend (0x24) code.extend (0x20) -- rex -- mov -- [rsp + 0x20] -- r8
			code.extend (0x4c) code.extend (0x89) code.extend (0x4c) code.extend (0x24) code.extend (0x28) -- rex -- mov -- [rsp + 0x28] -- r9
			code.extend (0xf2) code.extend (0x0f) code.extend (0x11) code.extend (0x44) code.extend (0x24) code.extend (0x30)-- movsd -- [rsp + 0x30] -- xmm0
			code.extend (0xf2) code.extend (0x0f) code.extend (0x11) code.extend (0x4c) code.extend (0x24) code.extend (0x38) -- movsd -- [rsp + 0x38] -- xmm1
			code.extend (0xf2) code.extend (0x0f) code.extend (0x11) code.extend (0x54) code.extend (0x24) code.extend (0x40) -- movsd -- [rsp + 0x40] -- xmm2
			code.extend (0xf2) code.extend (0x0f) code.extend (0x11) code.extend (0x5c) code.extend (0x24) code.extend (0x48) -- movsd -- [rsp + 0x48] -- xmm3
			code.extend (0xf2) code.extend (0x0f) code.extend (0x11) code.extend (0x64) code.extend (0x24) code.extend (0x50) -- movsd -- [rsp + 0x50] -- xmm4
			code.extend (0xf2) code.extend (0x0f) code.extend (0x11) code.extend (0x6c) code.extend (0x24) code.extend (0x58) -- movsd -- [rsp + 0x58] -- xmm5
			code.extend (0xf2) code.extend (0x0f) code.extend (0x11) code.extend (0x74) code.extend (0x24) code.extend (0x60) -- movsd -- [rsp + 0x60] -- xmm6
			code.extend (0xf2) code.extend (0x0f) code.extend (0x11) code.extend (0x7c) code.extend (0x24) code.extend (0x68) -- movsd -- [rsp + 0x68] -- xmm7

			code.extend (0x48) code.extend (0x89) code.extend (0xe6) -- rex -- mov -- rsi, rsp
			code.extend (0x48) code.extend (0xbf) -- rex -- mov rdi
			target_object_offset := code.count
			code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0)
			code.extend (0x48) code.extend (0x8b) code.extend (0x3f) -- rex -- mov -- rdi, [rdi]
			code.extend (0x48) code.extend (0xb8) -- rex -- mov rax
			target_function_offset := code.count
			code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0)
			code.extend (0xff) code.extend (0xd0) -- call rax
			code.extend (0x48) code.extend (0x83) code.extend (0xc4) code.extend (0x70) -- rex -- add -- rsp -- 0x70
			code.extend (0xc3) -- ret

			create code_array.make_from_special (code)
			code_pointer := zone.malloc (trampoline_size.to_natural_64)
			create managed_code.share_from_pointer (code_pointer, trampoline_size)
			make_read_write_executable (code_pointer)
			managed_code.put_array (code_array, 0)
			managed_code.put_pointer (target_object, target_object_offset)
			managed_code.put_pointer (target_function, target_function_offset)
			make_read_executable (code_pointer)

			function := managed_code.item
		end

feature

	function: POINTER

feature {NONE} -- Implementation

	trampoline_size: INTEGER = 114

	prot_none: INTEGER = 0x0
	prot_read: INTEGER = 0x1
	prot_write: INTEGER = 0x2
	prot_exec: INTEGER = 0x4

	make_read_write_executable (address: POINTER)
		local
			start_page: NATURAL_64
			end_page: NATURAL_64
			return: INTEGER_32
		do
			start_page := number_for_address (address)
			end_page := start_page + trampoline_size.to_natural_64 - 1
			start_page := start_page.bit_and (0xffff_ffff_ffff_f000)
			end_page := end_page + 4096 - 1
			end_page := end_page.bit_and (0xffff_ffff_ffff_f000)
			return := mprotect (address_for_number (start_page), end_page - start_page, prot_read.bit_or (prot_write).bit_or (prot_exec))
		end

	make_read_executable (address: POINTER)
		local
			start_page: NATURAL_64
			end_page: NATURAL_64
			return: INTEGER_32
		do
			start_page := number_for_address (address)
			end_page := start_page + trampoline_size.to_natural_64 - 1
			start_page := start_page.bit_and (0xffff_ffff_ffff_f000)
			end_page := end_page + 4096 - 1
			end_page := end_page.bit_and (0xffff_ffff_ffff_f000)
			return := mprotect (address_for_number (start_page), end_page - start_page, prot_read.bit_or (prot_exec))
		end

feature {NONE} -- Externals

	number_for_address (address: POINTER): NATURAL_64
		external
			"C inline"
		alias
			"[
				return (unsigned long)$address;
			]"
		end

	address_for_number (number: NATURAL_64): POINTER
		external
			"C inline"
		alias
			"[
				return (void *)$number;		
			]"
		end

	mprotect (address: POINTER; length: NATURAL_64; protection: INTEGER_32): INTEGER_32
		external
			"C inline use %"sys/mman.h%""
		alias
			"[
				return mprotect ($address, $length, $protection);
			]"
		end
end
