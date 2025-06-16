# TipsModAutoLang
Batch script designed for Darkhax's "Tips" mod for Minecraft.

Made specifically with "Tips-fabric-1.21.1-21.1.2" as a reference, but I have no reason to believe it shouldn't work for other versions of the mod since this script is so simple in its opperation.

Simply provide a list of loading screen tip titles, and the script will create all the files and reference keys you need, all referenced in one easy-to-edit language file.

Highly configurable.

Still under development, but I wanted to get a head-start on the GitHub page.
# Settings:
## Terms

__tip_folder_name [any valid string]

__lang_folder_name [any valid string]

__tip_file_list [path to existing .txt / blank]

__namespace_overwrite [valid path to potential folder and \ or any valid string]

## Entry Files

__tip_file_rep_space [any valid string]

__tip_file_prefix [any valid string / blank]

__tip_file_suffix [any valid string / blank]

__tip_file_dupes [ask / keep / replace]

__tip_file_reformat [true / false]

__tip_file_template [path to existing .txt / blank]

__tip_file_ext [any valid string]

## Output File

__lang_file_name [any valid string]

__lang_file_ext [any valid string]

__lang_file_template [path to existing .txt / blank]

## Keys

__tip_key_prefix [any valid string / blank]

__tip_key_suffix [any valid string / blank]

__custom_title_key [any valid string / blank]

## General

__batch_file [path to existing .txt / blank]

__open_output_folder [true / false]

==================== Optional Settings ====================

new_manual_defaults (0/1) -- Exports all entered settings into a New Defaults file. Automatically renames itself if conflicts are detected.

==================== Debug Settings ====================

:: Function verbosity:

verbose_func (0-2) Sets the minimum for all "verbose_func" variables to itself. (not yet implemented 20250613)

verbose_processing_md (0-2)

verbose_confirm_n (0,1)

:: Debug settings

force_unset (0,1) Forcibly sets all "var_set" variables to 0 in the ":unset_settings" function.

advanced_mode (0,2) Enables setting tips+lang folder names, plus their files' extensions.

