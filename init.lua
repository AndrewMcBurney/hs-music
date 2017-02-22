--------------------------------------------------------------------------------
-- @module: hs-music
--
-- @usage:  A set of bindings and functions for iTunes and Spotify.
-- @author: Andrew McBurney
--------------------------------------------------------------------------------

-- Mash for iTunes and Spotify
local iTunesMash  = {"cmd", "alt", "shift"}
local spotifyMash = {"cmd", "ctrl", "shift"}

-- Images for notifications
local iTunesImage  = hs.image.imageFromPath("./hs-music/images/iTunes.png")
local spotifyImage = hs.image.imageFromPath("./hs-music/images/spotify.png")

-- Notify the user what song is playing
local function notifySong(songInfo, image, additionalInfo)
  title = additionalInfo .. songInfo.track
  info  = songInfo.album .. " - " .. songInfo.artist
  hs.notify.new({title=title, informativeText=info, contentImage=image}):send()
end

--------------------------------------------------------------------------------
-- iTunes
--
-- @see: A set of functions and keybindings for iTunes
--------------------------------------------------------------------------------

-- Gets current track information and returns a table of KVPs
local function iTunesTrackInfo()
  return {
    track  = hs.itunes.getCurrentTrack(),
    album  = hs.itunes.getCurrentAlbum(),
    artist = hs.itunes.getCurrentArtist()
  }
end

-- Display current track information in a hammerspoon notification
local function iDisplayTrackInfo()
  notifySong(iTunesTrackInfo(), iTunesImage, "")
end

-- Display track being played
local function iPlayTrack()
  hs.itunes.play()
  notifySong(iTunesTrackInfo(), iTunesImage, "Playing song: ")
end

-- Display track being played
local function iPauseTrack()
  hs.itunes.pause()
  notifySong(iTunesTrackInfo(), iTunesImage, "Pausing song: ")
end

-- iTunes Keybindings
hs.hotkey.bind(iTunesMash, 'space', iDisplayTrackInfo)
hs.hotkey.bind(iTunesMash, 'A',     iPlayTrack)
hs.hotkey.bind(iTunesMash, 'S',     iPauseTrack)
hs.hotkey.bind(iTunesMash, 'D',     hs.itunes.next)
hs.hotkey.bind(iTunesMash, 'F',     hs.itunes.previous)

--------------------------------------------------------------------------------
-- Spotify
--
-- @see: A set of keybindings for Spotify
--------------------------------------------------------------------------------

-- Gets current track information and returns a table of KVPs
local function spotifyTrackInfo()
  return {
    track  = hs.spotify.getCurrentTrack(),
    album  = hs.spotify.getCurrentAlbum(),
    artist = hs.spotify.getCurrentArtist()
  }
end

-- Spotify Keybindings
hs.hotkey.bind(spotifyMash, 'space', hs.spotify.displayCurrentTrack)
hs.hotkey.bind(spotifyMash, 'A',     hs.spotify.play)
hs.hotkey.bind(spotifyMash, 'S',     hs.spotify.pause)
hs.hotkey.bind(spotifyMash, 'D',     hs.spotify.next)
hs.hotkey.bind(spotifyMash, 'F',     hs.spotify.previous)

--------------------------------------------------------------------------------
-- Other
--
-- @see: Functions for playing and pausing music for headphone jack state
--------------------------------------------------------------------------------

-- State of iTunes music (whether a track is playing when jack disconnects)
local musicPlaying = false

-- Log audioWatch for device argument
logger = hs.logger.new("main")
local function audioWatch(arg) logger.df("audioWatch arg: %s", arg) end

-- Set watcher callback and start watcher
hs.audiodevice.watcher.setCallback(audioWatch)
hs.audiodevice.watcher.start()

-- Notify the state of the headphone jack to user
local function notifyJackState(title, text, image)
  hs.notify.new({title=title, informativeText=text, contentImage=image}):send()
end

-- Function which watches for changes in headphone jack state
local function audioDeviceWatch(uid, eventName, eventScope, eventElement)
  device = hs.audiodevice.findDeviceByUID(uid)

  if eventName == 'jack' then
    if device:jackConnected() then
      if musicPlaying then
        hs.itunes.play()
        notifyJackState("Headphones plugged in", "Resume music.", iTunesImage)
      end
    elseif hs.itunes.isPlaying() then
      hs.itunes.pause()
      notifyJackState("Headphones unplugged", "Pausing music.", iTunesImage)
      musicPlaying = true
    end
  end
end

-- Perform watcher callback for each audio output device
for index, device in ipairs(hs.audiodevice.allOutputDevices()) do
  device:watcherCallback(audioDeviceWatch):watcherStart()
end
