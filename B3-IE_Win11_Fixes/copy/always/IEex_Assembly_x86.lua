
-------------
-- Hooking --
-------------

function IEex_HookAfterCall(address, assemblyT)
	local opcode = IEex_ReadU8(address)
	if opcode ~= 0xE8 then IEex_Error("Not disp32 call: "..IEex_ToHex(opcode)) end
	local afterCall = address + 5
	IEex_DefineAssemblyLabel("return", afterCall)
	local target = afterCall + IEex_Read32(address + 1)
	local hookAddress = IEex_JITNear(IEex_FlattenTable({
		{"call #$(1) #ENDL", {target}},
		assemblyT,
		{"jmp #$(1) #ENDL", {afterCall}},
	}))
	IEex_JITAt(address, {"jmp short "..hookAddress})
end

function IEex_HookBeforeRestore(address, restoreDelay, restoreSize, returnDelay, assemblyT)

	local restoreBytes = IEex_StoreBytesAssembly(address + restoreDelay, restoreSize)
	local returnAddress = address + returnDelay

	local hookCode = IEex_JITNear(IEex_FlattenTable({
		assemblyT,
		{[[
			return:
		]]},
		restoreBytes,
		{[[
			jmp ]], returnAddress, [[ #ENDL
		]]},
	}))

	IEex_JITAt(address, {[[
		jmp short ]], hookCode, [[ #ENDL
		#REPEAT(#$(1),nop #ENDL) ]], {returnDelay - 5}
	})
end

function IEex_HookBeginningOfFunction(address, restoreSize, assemblyT)

	if IEex_ReadU8(address) == 0xE9 then

		-- Someone already hooked this point
		local interlopingJmpDest = address + 5 + IEex_Read32(address + 1)

		local hookCode = IEex_JITNear(IEex_FlattenTable({
			assemblyT,
			{[[
				return:
				jmp ]], interlopingJmpDest, [[ #ENDL
			]]},
		}))

		IEex_JITAt(address, {[[
			jmp short ]], hookCode, [[ #ENDL
			#REPEAT(#$(1),nop #ENDL) ]], {restoreSize - 5}
		})

		return
	end

	IEex_HookBeforeRestore(address, 0, restoreSize, restoreSize, assemblyT)
end

function IEex_StoreBytesAssembly(startAddress, size)
	if size <= 0 then return {} end
	local bytes = {".DB "}
	for i = startAddress, startAddress + size - 1 do
		table.insert(bytes, IEex_ReadU8(i))
		table.insert(bytes, ", ")
	end
	if size > 0 then
		table.remove(bytes)
		table.insert(bytes, "#ENDL")
	end
	return bytes
end
