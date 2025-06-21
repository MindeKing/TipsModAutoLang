# Minecraft "Tips" Mod Auto-Lang Tool
Alpha version 5.0.0 (not yet available for download)
<!-- MANPAGE: BEGIN EXCLUDED SECTION -->
<div align="center">
  
<ins>Darkhax-Minecraft's "Tips" mod can be found here:</ins>

[![Modrinth Downloads](https://img.shields.io/modrinth/dt/AMCbgyVw?style=for-the-badge&logo=modrinth&label=Modrinth&color=%2300AF5C)](https://modrinth.com/mod/tips)
[![CurseForge Downloads](https://img.shields.io/curseforge/dt/306549?style=for-the-badge&logo=curseforge&label=CurseForge&color=%23F16436)](https://www.curseforge.com/minecraft/mc-mods/tips)
[![Static Badge](https://img.shields.io/badge/Github-Darkhax--Minecraft%2FTips-white?style=for-the-badge&logo=github&color=%23181717)](https://github.com/Darkhax-Minecraft/Tips)

<ins>Please check out the "Tips" mod wiki and documentation if you wish to better familiarize yourself with the mod:</ins>\
<sup>(It's really not perfect, and it's missing some critical information, but hopefully it shouldn't take you too long to figure out the basics.)</sup>\
<sup>((Not required.))</sup>

[![Static Badge](https://img.shields.io/badge/Github-Tips%2Fwiki%2FLatest--Documentation-white?style=for-the-badge&logo=github&color=%23181717)](https://github.com/Darkhax-Minecraft/Tips/wiki/Latest-Documentation)

</div>
<!-- MANPAGE: END EXCLUDED SECTION -->

*MindeKing's "Tips" Mod Auto-Lang Tool* is a batch script designed to simplify and streamline file creation in tip resource packs for Darkhax-Minecraft's "Tips" mod for Minecraft.

It was made specifically with "Tips-fabric-1.21.1-21.1.2" as a reference, but I have no reason to believe it shouldn't work for other versions of the mod since this script is so simple in its operation.

All you need to do is simply provide a .txt list of potential loading screen tip names, and the script will create all the files and reference keys you need, all referenced in one easy-to-edit language / output file.

An example *tip file list*, in the form of "vanillatweaks_datapacks.txt", is included so that users can instantly get a sense of what it's like to run the script and what it does.

Highly configurable.

Still under development, but I wanted to get a head-start on the GitHub page.

<ins>Not affiliated with Darkhax-Minecraft in any way.</ins>

Although the "Tips" mod has built-in support for text formatting (as seen in its wiki), if you want more granular control in your tips or titles, visit [the Minecraft Wiki's formatting code editor](https://minecraft.wiki/w/Formatting_codes#Formatting_code_editor), and copy the "output" text into your lang .json file for the tip / title you want to format.

## Problem(s) (without script): 
* Normally, in order to make a tip resource pack, you have to:
  * Create an individual .json file for every loading screen tip you want to add,
  * and write down each tip's text in in each file,
  * or write a unique reference key in each tip file, then copy that reference key to a localle code .json in a separate "lang" folder.
* Not much documentation exists for the 1.21.1 version of the "Tips" mod.
* I havent been able to find a single tip resource pack on Modrinth, probably because they're so tedious to make.
* There are too few loading screen tips present in the vanilla mod.
## Solution(s) (with script): 
* Bullet
## What This Script Does:
* Bullet
## Settings:
### Terms:
* `__tip_file_list` [path to existing .txt / blank]\
The *tip file list* is a .txt file containing one name per line per loading screen tooltip.\
By default, the *namespace folder* for your generated files is based on the name of this file.\
It's also a mask.

* `__namespace_overwrite` [valid path to potential folder and \ or any valid string]\
texst

### Entry Files:
* `__tip_file_rep_space` [any valid string / blank]\
Since the "Tips" mod can't read files with spaces in their names,\
(or capital letters, but that's besides the point,)\
it's necessary to replace any spaces in the *tip file list*.\
With this setting, you can provide the character(s) you want to use to replace any spaces that might exist for names provided in the *tip file list*.\
If left blank, all spaces will just be deleted.

* `__tip_file_prefix` [any valid string / blank]\
If you're planning on using the same *namespace folder* for multiple kinds of tips, say, belonging to different mods,\
it can be helpful to organize these files based on what mod or author they're from.\
For example, if you wanted to create tips for Vanilla Tweaks "Datapacks" and "Crafting Tweaks",\
You could set the former's *tip file prefix* be "vt.dp." and the latter's be "vt.ct.".\
This setting will add that specified string to the start of every file generated from the contents of the *tip file list*.

  If the names in your *tip file list* are identical to the names of the files in the tips / entries folder, ***BUT***\
they have different file prefixes or suffixes, those pre-existing files will NOT be replaced when running the script.

* `__tip_file_suffix` [any valid string / blank]\
Same as *tip file prefix*, but it appends the specified string to the end of each file instead.

* `__tip_file_dupes` [ask / keep / replace]\
Select, by default, whether you want the script to automatically keep or replace any file conflicts when generating tip files.\
If this setting is set to `ask`, upon any file conflicts being found, you will be given the option to:
  * Keep one file
  * Replace one file
  * Manually rename one file
  * Automatically rename one file

  After which point, you will be asked if you want the script to do the same for all following file conflicts.\
  Additionally, if set to "replace", the lang / output file will automatically be replaced too.

* `__tip_file_template` [path to existing .txt / blank]\
The *tip file template* refers to a .txt file containing the basic layout that tip files will be generated with.\
Most importantly here are the variables `CTKey` and `TipKey`, which will be used to automatically fill every\
tip file with the *custom title reference key* (if provided) and that tip's unique *tip reference key*.\
I'd highly recommend not editing this file.

  Blank entry is only allowed if no *tip file list* is provided.

* `__tip_file_reformat` [true / false]\
If set to `true`, replaces the contents of ALL files in the tips / entries folder based\
on the contents of the *tip file template*, regardless if you're using a *tip file list*.

  Will still create new files present in the *tip file list* if one is provided.

* `__tip_file_ext` [any valid string]\
<sup>(doesn't change anything unless `advanced_mode` is `2`)</sup>\
Whether you want the tip / entry files to be output as anything other than .json.\
This setting doesn't make sense if you're trying to use this script solely for the "Tips" mod,\
but my delusions of grandeur know no bounds.

### Output File:
* `__lang_file_name` [any valid string]\
The *lang file name* is the resulting name of the lang / output file, and\
it depends on what language you will be using.\
For example: "en_us" for US English, "en_uk" for British English.\
Visit https://minecraft.wiki/w/Language for a list of all the\
locale codes that Minecraft (and, by extension, the "Tips" mod) uses.

* `__lang_file_ext` [any valid string]\
<sup>(doesn't change anything unless `advanced_mode` is `2`)</sup>\
Whether you want the tip / entry files to be output as anything other than .json.\
This setting doesn't make sense if you're trying to use this script solely for the "Tips" mod,\
but my delusions of grandeur know no bounds.

* `__lang_file_template` [path to existing .txt]\
Opperates in a similar way to the *tip file template*, only for the lang / output file instead.

### Reference Keys:
* `__tip_key_prefix` [any valid string / blank]\
texst

* `__tip_key_suffix` [any valid string / blank]\
Same as *tip key prefix*, but it appends the specified string to the end of each tip's reference key instead.

* `__custom_title_key` [any valid string / blank]\
Use this setting if you want your tips to have a custom title.\
Once the lang / output file is generated, at the top of the file should be your\
*custom title key* followed by text reading "placeholder".\
Whatever you change "placeholder" to will become the title of all tips generated with\
this *custom title key*.\
(you also need to make sure that the tip / entry files are set up to receive the\
*custom title key* in your *tip file template* file.)

  Otherwise, if left blank, all tips will be assigned the "Tips" mod default\
title of, "tipsmod.title.default".

### General Settings:
* `__open_output_folder` [true / false]\
Whether the script should or shouldn't open the lang / output folder in a new File\
Explorer window which the lang / output file is generated.\
Helpful if the output folder and batch script aren't in the same location.
#
#
### Optional Settings:
* `new_manual_defaults` (0,1)\
Exports all entered settings into a New Defaults file. Automatically renames itself if conflicts are detected.\
Useful if you want to create multiple presets via the script, to ensure all provided settings are valid.\
Also useful if you want to provide a list of settings used for debugging purposes.

### Not-yet-implemented Settings:
* `__tip_folder_name` [valid path to potential folder and \ or any valid string]\
<sup>(doesn't change anything unless `advanced_mode` is `2`)</sup>\
This is the name of the folder in which the entry file(s) will go.\
I don't believe the "Tips" mod will recognize this folder if it is called anything other than "tips".\
I do not know why I made this a setting you can change.

* `__lang_folder_name` [valid path to potential folder and \ or any valid string]\
<sup>(doesn't change anything unless `advanced_mode` is `2`)</sup>\
This is the name of the folder in which the output file will go.\
I don't believe the "Tips" mod will recognize this folder if it is called anything other than "lang".\
I do not know why I made this a setting you can change.

* `__batch_file` [path to existing .txt / blank]\
If you have multiple *tip file list*s that you want to turn into namespaces all with just one opperation of the script,\
this might become the way to do that.\
But it's also a very niche use-case that'd probably be very difficult to account for, so don't expect this to come anytime soon.

### Verbosity:
* `verbose_func` (0-2)\
Provides more information about every other function that doesn't have its own verbosity setting.

* `verbose_processing_md` (0-2)\
Provides more information about the function that verifies whether the provided settings are valid or not.

* `verbose_confirm_n` (0,1)\
Provides more information about the "confirm_n" function.

### Other Debug Settings:
* `force_unset` (0,1)\
Forcibly sets all "var_set" variables to 0 in the ":unset_settings" function.\
This makes it such that, even if settings are provided by the defaults or config files,\
the script will think that they aren't.

* `advanced_mode` (0,2)\
Enables changing the "tips" and "lang" folder names via the defaults / config files.\
Enables changing the file extensions of the tip / entry and lang / output files.

## Credits:
[MindeKing](https://github.com/MindeKing) - for writing most of the script.

https://www.dostips.com - for some functions used in the script.

[James K](https://stackoverflow.com/users/1530402/james-k) - (I think?) for providing the [function that replaces asterisks](https://stackoverflow.com/a/11685376).

### With special thanks to:

[Darkhax-Minecraft](https://github.com/Darkhax-Minecraft) for creating the "Tips" mod.

https://ss64.com - for being far more helpful than Microsoft's own commands guides.

yt-dlp - for inspiration.

AI coding tools - for, sometimes, the only way to do something the right way is to first see it done the wrong way. (Also because I knew literally nothing about batch script before going into this, and CGPT is a significantly better "search engine" for this stuff than Google.)

My father, sibling, and those I know online who claimed to want to assist with bug testing (you know who you are).
