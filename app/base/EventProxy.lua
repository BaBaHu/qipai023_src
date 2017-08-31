
local EventProxy = class("EventProxy")

function EventProxy:ctor(eventDispatcher)
	self._eventDispatcher = eventDispatcher
	self._listeners = {}
end

function EventProxy.extend(target, eventDispatcher)
	local t = tolua.getpeer(target)
	if not t then
		setmetatable(target, EventProxy)
	else
		setmetatable(t, EventProxy)
	end
	EventProxy.ctor(target, eventDispatcher)
	target.super = EventProxy
	return target
end

-- abstract
function EventProxy:onEnter()
	-- body
end

function EventProxy:onExit()
	self:removeAllEventListeners()
end

function EventProxy:addEventListener(eventName, listener, target)
	local handle = self._eventDispatcher:addEventListener(eventName, listener, target)
	self._listeners[#self._listeners + 1] = {eventName, handle}
end

function EventProxy:addAttrListener(attr_key, listener, target)
	local eventName = string.format("ATTR:%s", attr_key)
	self:addEventListener(eventName, listener, target)
end

function EventProxy:removeAllEventListeners()
	for _, listener in ipairs(self._listeners) do
		local eventName = listener[1]
		local handle = listener[2]
		self._eventDispatcher:removeEventListener(eventName, handle)
	end
	self._listeners = {}
end

-- excute all listeners which has the same eventName
function EventProxy:dispatchEvent(eventName, ...)
	return self._eventDispatcher:dispatchEvent(eventName, ...)
end

return EventProxy
