# Minecraft "Tips" Mod Auto-Lang Tool
<!-- MANPAGE: BEGIN EXCLUDED SECTION -->
<div align="center">
  
Darkhax-Minecraft's "Tips" mod can be found here:

[![CurseForge Downloads](https://img.shields.io/curseforge/dt/306549?style=for-the-badge&logo=curseforge&label=CurseForge&color=%23F16436)](https://www.curseforge.com/minecraft/mc-mods/tips)
[![Modrinth Downloads](https://img.shields.io/modrinth/dt/AMCbgyVw?style=for-the-badge&logo=modrinth&label=Modrinth&color=%2300AF5C)](https://modrinth.com/mod/tips)
[![Static Badge](https://img.shields.io/badge/Github-Darkhax--Minecraft%2FTips-white?style=for-the-badge&logo=github&color=%23181717)](https://github.com/Darkhax-Minecraft/Tips)

</div>
<!-- MANPAGE: END EXCLUDED SECTION -->

This is a batch script designed for Darkhax's "Tips" mod for Minecraft.

It was made specifically with "Tips-fabric-1.21.1-21.1.2" as a reference, but I have no reason to believe it shouldn't work for other versions of the mod since this script is so simple in its opperation.

All you need to do is simply provide a list of loading screen tip titles, and the script will create all the files and reference keys you need, all referenced in one easy-to-edit language file.

An example tip file list in the form of "vanillatweaks_datapacks.txt" is included so that users can instantly get a sense of what it's like to run the script and what it does.

Highly configurable.

Still under development, but I wanted to get a head-start on the GitHub page.

Not affiliated with Darkhax-Minecraft in any way.

## Problem(s): 
* In order to make a tip resource pack, you have to:
  - Create an individual .json file for every loading screen tip you want to add,
  - and write down each tip's text in in each file,
  - or write a unique reference key in each tip file, then copy that reference key to a localle code .json in a separate "lang" folder.
* Not much documentation exists for the 1.21.1 version of the "Tips" mod.
* I havent been able to find a single tip resource pack on Modrinth, probably because they're so difficult to make.
* There are too few loading screen tips present in the mod.
## Solution(s): 
* Bullet
## Settings:
### Terms

* __tip_folder_name [any valid string] (doesn't change anything unless advanced_mode is 2)

This is the name of the folder in which the entry file(s) will go.

The Tips mod will not recognize this folder if it is called anything other than "tips".

I do not know why I made this a setting you can change.

* __lang_folder_name [any valid string] (doesn't change anything unless advanced_mode is 2)

This is the name of the folder in which the output file will go.

The Tips mod will not recognize this folder if it is called anything other than "lang".

I do not know why I made this a setting you can change.

* __tip_file_list [path to existing .txt / blank]

* __namespace_overwrite [valid path to potential folder and \ or any valid string]

### Entry Files

* __tip_file_rep_space [any valid string]

* __tip_file_prefix [any valid string / blank]

* __tip_file_suffix [any valid string / blank]

* __tip_file_dupes [ask / keep / replace]

* __tip_file_template [path to existing .txt / blank]

* __tip_file_ext [any valid string] (doesn't change anything unless advanced_mode is 2)

### Output File

* __lang_file_name [any valid string]

* __lang_file_ext [any valid string] (doesn't change anything unless advanced_mode is 2)

### Keys

* __tip_key_prefix [any valid string / blank]

* __tip_key_suffix [any valid string / blank]

* __custom_title_key [any valid string / blank]

### General

* __open_output_folder [true / false]

### Not-yet-implemented Settings

* __batch_file [path to existing .txt / blank]

* __tip_file_reformat [true / false]

* __lang_file_template [path to existing .txt / blank]

### Optional Settings

* new_manual_defaults (0/1) -- Exports all entered settings into a New Defaults file. Automatically renames itself if conflicts are detected.

### Verbosity

* verbose_func (0-2) Sets the minimum for all "verbose_func" variables to itself. (not yet implemented 20250613)

* verbose_processing_md (0-2)

* verbose_confirm_n (0,1)

### Other Debug Settings

* force_unset (0,1) Forcibly sets all "var_set" variables to 0 in the ":unset_settings" function.

* advanced_mode (0,2) Enables setting tips+lang folder names, plus their files' extensions.

