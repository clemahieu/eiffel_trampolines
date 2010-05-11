note
	description: "Creates a function from assembly code that makes a call in to Eiffel.  64-bit version"
	author: "Colin LeMahieu"
	date: "$Date$"
	revision: "$Revision$"
	quote: "More laws, less justice. - Marcus Tullius Ciceroca (42 BC)"

class
	TRAMPOLINE

create
	make

feature

	make (heap: HEAP; target_object: POINTER; target_function: POINTER)
		require
			correct_platform: {PLATFORM}.pointer_bytes = 8
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
			create code.make_empty (trampoline_size.to_integer_32)

			code.extend (0x48) code.extend (0x83) code.extend (0xec) code.extend (0x48) -- rex -- sub -- rsp -- 0x48
			code.extend (0x48) code.extend (0x89) code.extend (0x0c) code.extend (0x24) -- rex -- mov -- [rsp] -- rcx
			code.extend (0x48) code.extend (0x89) code.extend (0x54) code.extend (0x24) code.extend (0x08) -- rex -- mov -- [rsp] -- rdx -- 0x08
			code.extend (0x4c) code.extend (0x89) code.extend (0x44) code.extend (0x24) code.extend (0x10) -- rex -- mov -- [rsp] -- r8 -- 0x10
			code.extend (0x4c) code.extend (0x89) code.extend (0x4c) code.extend (0x24) code.extend (0x18) -- rex -- mov -- [rsp] -- r9 -- 0x18
			code.extend (0xf2) code.extend (0x0f) code.extend (0x11) code.extend (0x44) code.extend (0x24) code.extend (0x20) -- movsd -- rsp, -- xmm0, -- 0x20
			code.extend (0xf2) code.extend (0x0f) code.extend (0x11) code.extend (0x4c) code.extend (0x24) code.extend (0x28) -- movsd -- rsp, -- xmm1, -- 0x28
			code.extend (0xf2) code.extend (0x0f) code.extend (0x11) code.extend (0x54) code.extend (0x24) code.extend (0x30) -- movsd -- rsp, -- xmm2, -- 0x30
			code.extend (0xf2) code.extend (0x0f) code.extend (0x11) code.extend (0x5c) code.extend (0x24) code.extend (0x38) -- movsd -- rsp, -- xmm3, -- 0x38
			code.extend (0x48) code.extend (0x89) code.extend (0xe2) -- rex -- mov -- rdx, rsp
			code.extend (0x48) code.extend (0xb9) -- rex -- mov rcx
			target_object_offset := code.count
			code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0)
			code.extend (0x48) code.extend (0x8b) code.extend (0x09) -- rex -- mov -- rcx, [rcx]
			code.extend (0x48) code.extend (0x83) code.extend (0xec) code.extend (0x20) -- rex -- sub -- rsp -- 0x20
			code.extend (0x48) code.extend (0xb8) -- rex -- mov rax
			target_function_offset := code.count
			code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0) code.extend (0x0)
			code.extend (0xff) code.extend (0xd0) -- call -- rax
			code.extend (0x48) code.extend (0x83) code.extend (0xc4) code.extend (0x68) -- rex -- add -- rsp -- 0x68
			code.extend (0xc3) -- ret

			code_pointer := heap.malloc (trampoline_size)
			create code_array.make_from_special (code)
			create managed_code.share_from_pointer (code_pointer, trampoline_size.to_integer_32)
			make_read_write_executable (code_pointer)
			managed_code.put_array (code_array, 0)
			managed_code.put_pointer (target_object, target_object_offset)
			managed_code.put_pointer (target_function, target_function_offset)
			make_read_executable (code_pointer)
			function := managed_code.item
		end

	function: POINTER;

feature {NONE} -- Externals

	trampoline_size: NATURAL_64 = 84

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
note
	permissions: "BSD license"
	license: "[
	Copyright (c) 2010, Colin LeMahieu
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
     and/or other materials provided with the distribution.
    * Neither the name of Colin LeMahieu nor the names of its contributors
     may be used to endorse or promote products derived from this software
      without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.
]"
end
