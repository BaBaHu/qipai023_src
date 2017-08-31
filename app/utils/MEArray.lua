--[[--
	数组
]]
MEArray = class('MEArray')

function MEArray:ctor()
	self.m_list = {}
	self.tail = 1
	self.head = 1
end

function MEArray:length()
	return self.tail - self.head
end
MEArray.size = MEArray.length
MEArray.count = MEArray.length

function MEArray:iterator()
	local s, e = self.head - 1, self.tail
	return function ()
		s = s + 1
		if s >= e then return nil end
		return self.m_list[s]
	end
end

function MEArray:indexOf(obj)
	if self:length() == 0 then return -1 end
	for k, v in pairs(self.m_list) do
		if v == obj then return k - self.head + 1 end		
	end
	return -1
end

function MEArray:splice(nStart, nCount, ...)
	local tb, ins = {}, {...}
	local nLen = self:length()
	if nLen == 0 then
		for k, v in pairs(ins) do
			self:push(v)
		end
		return nil
	end
	local s, e = self.head, self.head + nStart - 1
	e = e > self.head + nLen and self.head + nLen or e
	while s < e do
		tb[s] = self.m_list[s]
		s = s + 1
	end

	for k, v in pairs(ins) do
		tb[s] = v
		s = s + 1
	end

	e = e + nCount
	while e < self.head + nLen do
		tb[s] = self.m_list[e]
		s = s + 1
		e = e + 1
	end
	self.m_list = tb
	self.tail = self.tail + #ins - nCount
end

function MEArray:insertAt(nIndex, obj)
	self:splice(nIndex, 0, obj)
end


function MEArray:push(obj)
	return self:pushBack(obj)
end
	
function MEArray:pushFront(obj)
	if not obj then return end
	if instanceOf(obj) == 'MEArray' then
		local nLen = obj:length()
		for v in obj:iterator() do
			self.head = self.head - 1
			self.m_list[self.head] = v
		end	
	else
		self.head = self.head - 1
		self.m_list[self.head] = obj
	end
	return obj
end


function MEArray:pushBack(obj)
	if not obj then return end
	if instanceOf(obj) == 'MEArray' then
		for v in obj:iterator() do
			self.m_list[self.tail] = v
			self.tail = self.tail + 1
		end	
	else
		self.m_list[self.tail] = obj
		self.tail = self.tail + 1
	end
	return obj
end

function MEArray:assign(obj)
	self:clear()
	if instanceOf(obj) == 'MEArray' then
		for v in obj:iterator() do
			self.m_list[self.tail] = v
			self.tail = self.tail + 1
		end	
	else
		self.m_list[self.tail] = obj
		self.tail = self.tail + 1
	end
	return obj
end

function MEArray:pop()
	return self:popFront()
end


function MEArray:popFront()
	if self.head >= self.tail then return nil end
	local obj = self.m_list[self.head]
	self.m_list[self.head] = nil
	self.head = self.head + 1
	return obj
end

function MEArray:popBack()
	if self.head >= self.tail then return nil end
	local obj = self.m_list[self.tail - 1]
	self.m_list[self.tail - 1] = nil
	self.tail = self.tail - 1
	return obj
end

function MEArray:front()
	return self.m_list[self.head]
end

	
function MEArray:back()
	return self.m_list[self.tail - 1]
end

function MEArray:getObjectAt(nIndex)
	return self.m_list[self.head + nIndex - 1]
end


function MEArray:objectAt(nIndex)
	return self.m_list[self.head + nIndex - 1]
end


function MEArray:removeObjectAt(nIndex)
	self:splice(nIndex, 1)
end


function MEArray:removeObject(obj)
	local nIndex = self:indexOf(obj)
	if nIndex ~= -1 then
		self:splice(nIndex, 1)
	end
end

function MEArray:clear()
	--self:splice(1, self:length())
	self.m_list = {}
	self.tail = 1
	self.head = 1
end

function MEArray:swap(i, j)
	local x = self.m_list[self.head + i - 1]
	local y = self.m_list[self.head + j - 1]
	self.m_list[self.head + i - 1], self.m_list[self.head + j - 1] = y, x
end

function MEArray:qsort(p, r, cmp)
	local function partition(arr, p, r, cmp)
		local x = arr:getObjectAt(r)
		local i = p - 1
		if cmp then
			for j = p, r - 1 do
				if cmp(arr:getObjectAt(j), x) then
					i = i + 1
					arr:swap(i, j)
				end
			end
		elseif not cmp then
			for j = p, r - 1 do
				if arr:getObjectAt(j) <= x then
					i = i + 1
					arr:swap(i, j)
				end
			end
		end
		arr:swap(i + 1, r)
		return i + 1
	end
	if p < r then
		local q = partition(self, p, r, cmp)
		self:qsort(p, q - 1, cmp)
		self:qsort(q + 1, r, cmp)
	end
end


function MEArray:sort(cmp)
	self:qsort(self.head, self.tail - 1, cmp)
end


function MEArray:shuffle()
	local size = self:size()
	if size < 2 then return end

	local nRandomIdx = 1
	local endIdx = self.tail - 1
	for i = self.head, endIdx do 
		if i ~= endIdx then
			nRandomIdx = math.random(i + 1, endIdx) 
			self:swap(i, nRandomIdx)
		end
	end
end
return MEArray