MEAudioUtils = {}

MEAudioUtils.musicOn_ 	= true
MEAudioUtils.soundOn_ 	= true
MEAudioUtils.sounds 	= {}

function MEAudioUtils.playMusic(filename, isLoop)
    MEAudioUtils.musicFile = filename
	if MEAudioUtils.musicOn_ then
		audio.playMusic(filename, isLoop)
	end
end

function MEAudioUtils.playSoundEffect(SoundName)
	if MEAudioUtils.soundOn_ then
		audio.playSound(SoundName, false)
	end
end

function MEAudioUtils.setMusicEnable(enable)
	MEAudioUtils.musicOn_ = enable
	if not enable then
		audio.stopMusic(false)
	else
        if MEAudioUtils.musicFile then
            audio.playMusic(MEAudioUtils.musicFile, true)
        end
    end
end

function MEAudioUtils.isMusicEnable()
	return MEAudioUtils.musicOn_
end

function MEAudioUtils.setSoundEnable(enable)
	MEAudioUtils.soundOn_ = enable
end

function MEAudioUtils.isSoundEnable()
	return MEAudioUtils.soundOn_
end