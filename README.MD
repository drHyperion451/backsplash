Backsplash
=============
Changes the background main menu image from a set of custom wallpapers.

<p style="color:red; font-weight:bold"> Linux is not tested. If someone could test it and make pull requested it will be very, very appreciated :penguin: </p>
<a href='https://ko-fi.com/drhyperion451' target='_blank'><img height='35' style='border:0px;height:46px;' src='https://az743702.vo.msecnd.net/cdn/kofi5.png?v=0' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>


# Disclaimer
This mod is in beta so it will have bugs. 
**The adventure mode beta is not supported..yet.**

# Requirements
- Dwarf Fortress premium (Steam or itch.io version, but steam is easier)
- [DFHack](https://store.steampowered.com/app/2346660/DFHack__Dwarf_Fortress_Modding_Engine/). 

# Installation
## Steam Workshop. 
Not avaliable yet. It will when the mod is in a good state, I find it how to upload it and I find a cool artwork.

## Manual installation
1. Download the latest release of this mod here: [Latest Release](https://github.com/drHyperion451/backsplash/releases/latest). Decompress the zip file into a folder called `backsplash/`
2. Place the mod folder inside the `Dwarf Fortress/mods` folder. If you are on steam you can access to the `Dwarf Fortress` directory: Right click the game in your steam library, Manage -> browse local files.
3. Inside the mod folder there's a file called `dfhack_backsplash.init`. Copy and paste it into `Dwarf Fortress/dfhack-config/init/`. This will make it run at startup.
4. **Backup `Dwarf Fortress/data/art/title_background.png` file**
5. Run DFHack from steam once. It will generate a folder  `Dwarf Fortress/data/art/backgrounds`. Place the .png files there.

Each time you open or close the game it will cicle randomly between all your backgrounds.

## Use DFHack command line instead of running at launch
Follow the normal installation but do not place the .init file. Instead, open the DFHack console and run:
A gui option inside DFHack is planned, but is not priority.

`[DFHack]# backsplash`.
It should run without errors

# Uninstalling this mod
1. Delete the mod folder inside mods.
2. Delete the `Dwarf Fortress/dfhack-config/init/dfhack_backsplash.init` if it exists.
3. Remove the `Dwarf Fortress/data/art/background/` directory.
4. **IMPORTANT** Add the original `title_background.png` inside `Dwarf Fortress/data/art/`. **If there is NO title_background.png file the game will NOT run!

If you lost the original title screen or you have strange errors. Just verify the game files in steam.

Thanks to @myk002 from the DFHack dev team for helping me create my first mod for Dwarf Fortress.

Strike the earth!
