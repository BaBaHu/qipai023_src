
me = me or {}

me.isnull = tolua.isnull
me.notnull = function(...)
	return not me.isnull(...)
end
-----------------------------------------Instance----------------------------------------
me.Director 			= cc.Director:getInstance()
me.TextureCache 		= cc.Director:getInstance():getTextureCache()
me.FileUtils 			= cc.FileUtils:getInstance()
me.FrameCache 			= cc.SpriteFrameCache:getInstance()
me.EGLView 				= cc.Director:getInstance():getOpenGLView()
me.Scheduler 			= cc.Director:getInstance():getScheduler()
me.Application 			= cc.Application:getInstance()
me.AudioEngine			= cc.SimpleAudioEngine:getInstance()
me.ArmatureDataManager	= ccs.ArmatureDataManager:getInstance()
me.UserDefault 			= cc.UserDefault:getInstance()

-----------------------------------------properties--------------------------------------
me.designWidth 			= 1920
me.designHeight			= 1080
me.winSize 				= me.Director:getWinSize()
me.frameSize 			= me.EGLView:getFrameSize()
me.width              	= me.frameSize.width
me.height             	= me.frameSize.height
me.cx                 	= me.width / 2
me.cy                 	= me.height / 2
me.left               	= 0
me.right              	= me.width
me.top                	= me.height
me.bottom             	= 0
me.ENABLE_AUTOUPDATE    = false
------------------------------------------platform-----------------------------------------
me.PLATFORM 				  = me.Application:getTargetPlatform()
me.platforms = {
	[cc.PLATFORM_OS_WINDOWS          ] =	"win32",
	[cc.PLATFORM_OS_LINUX            ] =	"linux",
	[cc.PLATFORM_OS_MAC              ] =	"mac",
	[cc.PLATFORM_OS_ANDROID          ] =	"android",
	[cc.PLATFORM_OS_IPHONE           ] =	"iphone",
	[cc.PLATFORM_OS_IPAD             ] =	"ipa",
	[cc.PLATFORM_OS_BLACKBERRY       ] =	"blackberry",
	[cc.PLATFORM_OS_NACL             ] =	"nacl",
	[cc.PLATFORM_OS_EMSCRIPTEN       ] =	"emscripten",
	[cc.PLATFORM_OS_TIZEN            ] =	"tizen",
} 

me.platform = me.platforms[me.PLATFORM]

me.KeyCode = {
	BACK_SPACE 		= 0x0008,
	MENU 			= 0x1067,
}

-- avoid memory leak
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)
------------------------------------------------------info

print()
print("=======================MEFramework Infos===============")
print("me.platform: " .. me.platform)
print(string.format("me.winSize: width(%d)  height(%d)", me.winSize.width, me.winSize.height))
print(string.format("me.frameSize: width(%d)  height(%d)", me.frameSize.width, me.frameSize.height))
print("DEBUG status: ", DEBUG)
print("Lua collect pause: 100")
print("Lua collect stepmul: 5000")
print('=======================================================')
print()