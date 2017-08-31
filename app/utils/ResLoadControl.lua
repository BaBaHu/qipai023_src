--资源加载
ResLoadControl = {}

function ResLoadControl:instance()
	--body
	if self._isValid == nil or self._isValid == false then
		self._isValid = true --是否有效
		
		self.resModelList = {}
		
		
		self.waitLoadResList = {}
		
	    if self.schedulerID ~= nil then
	        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
	        self.schedulerID = nil
	    end
	    local function tick()
	    	self:update()
	    end
	    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 0.02, false)
	end
	return self
end

function ResLoadControl:dispose()
	if self.schedulerID ~= nil then
	    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
	    self.schedulerID = nil
	end
	
	for k,v in pairs(self.resModelList) do
		self:unloadArmatureModelRes(k)
	end
	self.resModelList = {}
	self._isValid = false
end


function ResLoadControl:update()
	-- body
	if not self._isValid then
		return
	end
	for k,v in pairs(self.waitLoadResList ) do
		--print(k,v)
		if v.type == 1 then
			v["startTime"] = os.clock()
			cc.Director:getInstance():getTextureCache():addImageAsync(k, function(texture)
				print("load plist time = ", (os.clock() - v.startTime)*1000 )

				if v.plist then
					cc.SpriteFrameCache:getInstance():addSpriteFrames(v.plist)
				end
				if v.callfunc then
					v.callfunc()
				end
        	end)
		elseif v.type == 2 then
			v["startTime"] = os.clock()
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfoAsync(k, function(texture)
				print("load armature time = ", (os.clock() - v.startTime)*1000 )
				if v.callfunc then
					v.callfunc()
				end
        	end)
			local data = {}
			data["bTemporary"] = v.bTemporary
			self.resModelList[k] = data
		elseif v.type == 3 then
			v["startTime"] = os.clock()
			local ret = cc.MESkeletonAnimationHelper:getInstance():loadWithFile(k, 1)
			if not ret then
				print("load spine error !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ", k)
				return
			end
			local data = {}
			data["bTemporary"] = v.bTemporary
			self.resModelList[k] = data
			cc.Director:getInstance():getTextureCache():addImageAsync(k .. ".png", function(texture)
				print("load spine time = ", (os.clock() - v.startTime)*1000 )
				if v.callfunc then
					v.callfunc()
				end
        	end)
		end
		self.waitLoadResList[k] = nil
		break
	end
end


function ResLoadControl:loadTextureResAsync(texPath, plistPath, callfunc)
	-- body
	if not self._isValid then
		return
	end
		if self.waitLoadResList[texPath] == nil then
			local data = {}
			data["type"]	   = 1
			data["plist"] 	   = plistPath
			data["callfunc"]   = callfunc
			self.waitLoadResList[texPath] = data
		end
end


function ResLoadControl:loadArmatureModelResAsync(filePath, callfunc, bTemporary)
	-- body
	if not self._isValid then
		return
	end
	if bTemporary == nil then
		bTemporary = false
	end

	if self.resModelList[filePath] ~= nil then
		if callfunc then
			callfunc()
		end
	else
		if self.waitLoadResList[filePath] == nil then
			local data = {}
			data["type"]	   = 2
			data["bTemporary"] = bTemporary
			data["callfunc"]   = callfunc
			self.waitLoadResList[filePath] = data
		end
	end
end


function ResLoadControl:loadSprineResAsync(filePath, callfunc, bTemporary)
	-- body
	if not self._isValid then
		return
	end
	if bTemporary == nil then
		bTemporary = false
	end

	if self.resModelList[filePath] ~= nil then
		if callfunc then
			callfunc()
		end
	else
		if self.waitLoadResList[filePath] == nil then
			local data = {}
			data["type"]	   = 3
			data["bTemporary"] = bTemporary
			data["callfunc"]   = callfunc
			self.waitLoadResList[filePath] = data
		end
	end
end


function ResLoadControl:isLoadRes( filePath )
	-- body
	if not self._isValid then
		return false
	end
	local data = self.resModelList[filePath]
	if data == nil then
		return false
	end
	return true
end


function ResLoadControl:unloadArmatureModelRes( filePath )
	-- body
	if not self._isValid then
		return
	end
	local data = self.resModelList[filePath]
	if data ~= nil then
		print("unload model :", filePath)
		ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(filePath )
		self.resModelList[filePath] = nil
	end
end


function ResLoadControl:ClearTempLoadRes()
	-- body
	if self._isValid then
		for k,v in pairs(self.resModelList) do
			if v.bTemporary then
				self:unloadArmatureModelRes(k)
			end
		end
	end
end

return ResLoadControl