
IEex_DisableCodeProtection()

if IEex_ThreadWatcherEnabled then

	IEex_HookBeginningOfFunction(0xA3A478, 5, {[[
		call #L(ThreadWatcherBindings_OnSyncThreadEntry)
	]]})

	IEex_HookBeginningOfFunction(0x9A8E1F, 7, {[[
		call #L(ThreadWatcherBindings_OnAsyncThreadEntry)
	]]})
end

IEex_HookAfterCall(0x676423, {[[
	push 1
	call dword ptr ds:[0xAA5390] ; Sleep
]]})

IEex_EnableCodeProtection()
