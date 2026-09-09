
-------------
-- Options --
-------------

IEex_ThreadWatcherEnabled = false

----------
-- Main --
----------

IEex_DoFile("IEex_Assembly")
IEex_DoFile("IEex_Assembly_Patch")

if IEex_ThreadWatcherEnabled then
	IEex_OpenLuaBindings("ThreadWatcherBindings")
	ThreadWatcherBindings_LaunchThreadWatcher()
end

IEex_DoFile("IEex_Win11_Fixes_Patch")
