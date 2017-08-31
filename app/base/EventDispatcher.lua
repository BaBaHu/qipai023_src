
local EventDispatcher = class("EventDispatcher")

function EventDispatcher:ctor()
	self._listeners = {}
	self._handle_index = 0
end

function EventDispatcher:addEventListener(eventName, listener, target)
	eventName = string.upper(eventName)
	local listeners = self._listeners[eventName]
	if not listeners then
		listeners = {}
		self._listeners[eventName] = listeners
	end

	local ttarget = type(target)
	if ttarget == "table" or ttarget == "userdata" then
		listener = handler(target, listener)
	end

	self._handle_index = self._handle_index + 1
	local handle = tostring(self._handle_index)
	listeners[handle] = listener
	return handle
end

function EventDispatcher:dispatchEvent(eventName, ...)

	local eventName = string.upper(eventName)
	local listeners = self._listeners[eventName]
	if not listeners then return end
	local params = {...}
	if #params <= 0 then
		params = nil
	end
	for handle, listener in pairs(listeners) do
		listener(...)
	end
end

function EventDispatcher:removeEventListener(eventName, handle)
	print("remove2 aaaa "..eventName)

	local eventName = string.upper(eventName)
	local listeners = self._listeners[eventName]
	if not listeners then return end
	listeners[handle] = nil
end

return EventDispatcher
