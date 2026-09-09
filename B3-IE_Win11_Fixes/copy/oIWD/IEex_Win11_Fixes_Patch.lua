
IEex_DisableCodeProtection()

if IEex_ThreadWatcherEnabled then

	IEex_HookBeginningOfFunction(0x9AF5A8, 5, {[[
		call #L(ThreadWatcherBindings_OnSyncThreadEntry)
	]]})

	IEex_HookBeginningOfFunction(0x925DB7, 7, {[[
		call #L(ThreadWatcherBindings_OnAsyncThreadEntry)
	]]})
end

IEex_HookAfterCall(0x658623, {[[
	push 1
	call dword ptr ds:[0xA0B310] ; Sleep
]]})

IEex_EnableCodeProtection()
