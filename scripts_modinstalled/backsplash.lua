-- backsplash.lua
-- Swaps the current title_background with any background inside the wallpaper_dir folder
-- It should run before statup. This way the background would cicle between some avaliable options

local root_dir = dfhack.filesystem.getcwd()
-- EDIT THIS IF YOU WANT TO RENAME YOUR FOLDER AND THE EXTENSION:
local art_dir = root_dir .. '/data/art/'
local wallpaper_dir_relative = 'data/art/backgrounds/'
local wallpaper_dir = root_dir.. "/".. wallpaper_dir_relative
local applied_background = 'title_background.png'
local img_extension = '.png' -- It is not recommended to change this

print("Root directory:", root_dir)
print("art directory:", art_dir)
print("Wallpaper folder (absolute):", wallpaper_dir)
print("Wallpaper folder (relative):", wallpaper_dir_relative)
print("File extension", img_extension)
print("Applied background file:", applied_background)
-- [[ LIBS ]] --
--- Just for keeping track of debug messages and delete it before its on release
local function dbg_error(msg)
	error(msg)
end
local function tmsg(i)
	local i = i or 0
	print("This line is running!", i)
end
local function printTable(t)
	for _, value in ipairs(t) do
		print(value)
	end
end
-- Detecs OS. https://gist.github.com/Zbizu/43df621b3cd0dc460a76f7fe5aa87f30
-- Posible OS: Windows, Darwin, Linux 
local function getOS()
	-- ask LuaJIT first
	--[[ if jit then
		return jit.os
	end
	]]--

	-- Unix, Linux variants
	local fh,err = assert(io.popen("uname -o 2>/dev/null","r"))
	if fh then
		Osname = fh:read()
	end

	return Osname or "Windows"
end

---Gets a list of any files.
---@param dir string Set the directory to be scan (e.g. './wallpapers')
---@param ext string Set the extension to be filter out (e.g. '.png')
local function deprecrated_getFiles(dir, ext)
	local ext = ext or "."
	local files = {}

	if getOS() ~= 'Windows' then
		for dir in io.popen("find '" ..dir.. "' -name '*" .. ext .."'"):lines() 
			do table.insert(files, dir)
		end
	else
		-- TODO: Windows
		error("Windows is not supported")
		for dir in io.popen([[dir "C:\Program Files\" /b]]):lines() 
			do print(dir)
		end
	end

	return files
end

local function getFiles(dir, ext)
	local ext = ext or "."
	local files = dfhack.filesystem.listdir(dir)
	local filtered_files = {}
	for _, filename in ipairs(files) do
		-- Check if the filename ends with .png
		for file in string.gmatch(filename, ".*%"..ext.."$") do
			table.insert(filtered_files, file)
		end
	end
	return filtered_files
end

-- Extracts filename and extension given any path name
---@param filenameWithExtension string Path string, can be absolute or relative.
---@return string filename Filename
---@return string filename Extension
local function extractFilenameAndExtension(filenameWithExtension) --path
    -- Find the last occurrence of '/' or '\' in the path
    --[[local slashIndex = string.find(path, "/")

    if not slashIndex then
		error("Error at function extractFilenameAndExtension(). slashIndex is nil: ")
    end

    -- Extract the filename with extension from the path
    local filenameWithExtension = path:sub(slashIndex + 1)
	]]--
    -- Find the last occurrence of '.' in the filename
    local dotIndex = filenameWithExtension:find("%.[^%.]*$")

    -- If no dot is found, return the filename
    if not dotIndex then
        return filenameWithExtension, ""
    end

    -- Extract the filename and extension
    local filename = filenameWithExtension:sub(1, dotIndex - 1)
    local extension = filenameWithExtension:sub(dotIndex)
    return filename, extension
end

---Finds a string inside a table:
---@param table table
---@param searchString string
---@return boolean
local function isStringInTable(table, searchString)
	for _, value in ipairs(table) do
		if type(value) == "string" and value == searchString
		then
			return true
		end
	end
	return false
end





-- MAIN FUNCTION

-- Creates the 'backgrounds' folder if it does not exist
if dfhack.filesystem.mkdir(wallpaper_dir) then
	print("Backgrounds folder does not exist: generating...")
end


-- Get the files inside root directory and folders

local wallpaper_files = getFiles(wallpaper_dir, img_extension)
local active_files = getFiles(wallpaper_dir, '.active')
local art_files = getFiles(art_dir, img_extension)
print("Files\n")
printTable(art_files)
print("-------")
-- *.active file. Just the filename with no .active extension
local dot_active = (active_files[1] or "default")..tostring(math.random(1, 9)) -- fallback
dot_active = extractFilenameAndExtension(dot_active) --default#
print("Already applied background: "..dot_active)

-- If there's already an active background in the root folder it will move the applied background
-- aka. title_background.png back to the 'backgrounds' folder.
printTable(active_files)

if isStringInTable(active_files, dot_active..".active")
then
	print("Already an active background. Saving it to the backgrounds folder...")
	-- This way it would preserve the filename if possible.
	--dbg_error(wallpaper_dir..dot_active.. img_extension)
	os.rename(art_dir..applied_background, wallpaper_dir..dot_active.. img_extension)
	--assert(os.rename(art_dir..applied_background, wallpaper_dir..dot_active.. img_extension), "Couldn't move active background file from art dir")
	os.remove(wallpaper_dir ..dot_active..".active") -- purge old .active file
else
	-- If there is no .active Save the current background with a random default#.png name
	print("There is not an active background. Saving the original one. Applying one ramdomly instead from: "..wallpaper_dir)
	os.rename(art_dir..applied_background, wallpaper_dir..dot_active.. img_extension)
end

-- Select new active filename and move it to the art/ directory, renaming it accordingly
-- This applies the background, as the game just detects if title_background.png already exists
if #wallpaper_files ~= 0 then
	dot_active = extractFilenameAndExtension(wallpaper_files[math.random(1, #wallpaper_files)])
	print(dot_active)
	-- writes the new .active to preserve the filename of the original wallpaper
	local file = io.open(wallpaper_dir..dot_active.. ".active", "w")
	if file then
		file:close()
	else
		error("Couldn't write files. Check permissions for the folder: '".. art_dir.."' and '"..wallpaper_dir)
	end

	print("Applying new background: ".. dot_active)
	os.rename(wallpaper_dir.. "/".. dot_active .. img_extension, art_dir..applied_background)

else
	print("The wallpapers folder is empty! Please go to '", wallpaper_dir, "and fill it with\
PNG files. Try to match the 1920x1080 resolution if possible.")
end
