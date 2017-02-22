--
-- album_artwork.scpt
-- A script which writes the current song's album artwork to .jpg or .png
--

-- Get the raw bytes for the current track artwork
tell application "iTunes" to tell artwork 1 of current track
  set srcBytes to raw data
  if format is «class PNG » then
    set ext to ".png"
  else
    set ext to ".jpg"
  end if
end tell

-- Write the bytes to a temporary file
set fileName to (((path to music folder) as text) & "album_artwork" & ext)
set outFile to open for access file fileName with write permission
set eof outFile to 0
write srcBytes to outFile
close access outFile