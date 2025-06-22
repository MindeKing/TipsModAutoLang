@echo off
setlocal EnableDelayedExpansion
:START
title !title_default!
call :colorlib & echo !format_reset!Starting script...
call :debugs
REM Path to config and defaults files
REM Only file name + .txt is necessary if they are in the same folder as the .bat file




set "config=TipsModAutoLang Config.txt"
set "defaults=TipsModAutoLang Defaults.txt"
set "Light_or_Dark_mode="




REM Light or dark mode?
if not "!Light_or_Dark_mode!"=="" (
	call :confirm_n "!Light_or_Dark_mode!" "1l 2d" "0" "ui_color"
)
if "!ui_color!"=="" (
	echo.
	echo If you don't want to be asked this every time, open "%~nx0" with
	echo any text editor and put "Light" or "Dark" after the = in the line:
	echo set "Light_or_Dark_mode="
	echo near the top of the script.
	echo.
	call :confirm_n "Do you want this script to run in !format_underline!L!format_reset!ight mode or !format_underline!D!format_reset!ark mode?: " "1l 2d" "1" "ui_color"
	echo.
)
if "!ui_color!"=="0" (color f0) else (color 0f)
call :colorlib

REM If config and defaults variables don't refer to valid or existing files, ask user for their location and verify that they exist
if "!defaults!"=="Verify Settings" (goto :Section_Verify_Settings)
call :is_ext "defaults" ".txt"
if "!is_ext!"=="0" (
	:md_defaults
	if "!md_defaults_asked!"=="" (
		echo.
		call :error_message_light Path to the defaults .txt file is invalid.
		echo If you don't have a defaults file, the script can generate one for you later on.
		call :confirm_n "Do you have a defaults .txt file to use? (Y/N): " "0nf2 1y5" "1" "confirm_n"
		if not "!confirm_n!"=="1" (goto :skip_md_defaults)
		set "md_defaults_asked=1"
	)
	set "defaults="
	title !title_default_og! !title_prompting!
	set /p "defaults=Path to defaults .txt is invalid. Please provide path to the defaults file: "
	title !title_default!
	call :is_ext "defaults" ".txt"
	if "!is_ext!"=="0" (goto :md_defaults)
	for %%F in ("!defaults!") do (set "defaults_name=%%~nxF")
	if not exist "!defaults!" (
		call :error_message_light Path to "!defaults_name!" does not refer to an extisting .txt file.
		goto :md_defaults
	)
) else (if not exist "!defaults!" (goto :md_defaults))
:skip_md_defaults
call :is_ext "config" ".txt"
if "!is_ext!"=="0" (
	:md_config
	if "!md_config_asked!"=="" (
		echo.
		call :error_message_light Path to the config .txt file is invalid.
		echo If you don't have or want to use a config file,
		echo just use a blank .txt or something, I guess.
		call :confirm_n "Do you have a config .txt file to use? (Y/N): " "0nf2 1y5" "1" "confirm_n"
		if not "!confirm_n!"=="1" (goto :skip_md_config)
		set "md_config_asked=1"
	)
	set "config="
	title !title_default_og! !title_prompting!
	set /p "config=Path to config .txt is invalid. Please provide path to the config file: "
	title !title_default!
	call :is_ext "config" ".txt"
	if "!is_ext!"=="0" (goto :md_config)
	for %%F in ("!config!") do (set "config_name=%%~nxF")
	if not exist "!config!" (
		call :error_message_light Path to "!config_name!" does not refer to an extisting .txt file.
		goto :md_config
	)
) else (if not exist "!config!" (goto :md_config))
:skip_md_config
REM Extract file name and extension from full path, if provided
for %%F in ("!config!") do (set "config_name=%%~nxF")
for %%F in ("!defaults!") do (set "defaults_name=%%~nxF")

REM Echo default and config files for bugtesting.
REM echo defaults file is !defaults_name!
REM echo config file is !config_name!

REM Validate existence of aforementioned file
set "defaults_counter=0"
if exist "!defaults!" (
	title !title_default_og! is reading "!defaults_name!"...
	echo Reading contents of "!defaults_name!".
	REM Load and read defaults file line by line
	for /f "usebackq delims=" %%L in ("!defaults!") do (
		set "line=%%L"
		REM Skip blank lines
		if not "!line!"=="" (
			REM Skip lines starting with #, ;, and //
			echo !line! | findstr /r "^# ^; ^//" >nul
			if errorlevel 1 (
				REM Split lines into setting and value by " " delimiter
				for /f "tokens=1,* delims= " %%A in ("!line!") do (
					set "default_setting=%%A"
					set "default_value=%%B"
					call :strip_quotes "default_value"
					set "default_value=!strip_quotes!"
					set "%%A_set=1"
					set "!default_setting!=!default_value!"
					call :table_row_color
					if "!default_value!"=="" (
						echo "!format_table_row!!default_setting!!format_reset!" set to default of !format_table_row!UNDEFINED!format_reset! ^(meaning, it's disabled^).
					) else (
						echo "!format_table_row!!default_setting!!format_reset!" set to default of "!format_table_row!!default_value!!format_reset!".
					)
					set /a defaults_counter+=1
				)
			)
		)
	)
	title !title_default!
	echo.
	if !defaults_counter! EQU 0 (echo No settings have been read from "!defaults_name!".
	) else if !defaults_counter! EQU 1 (echo 1 setting loaded from "!defaults_name!".
	) else if !defaults_counter! GEQ 2 (echo !defaults_counter! settings loaded from "!defaults_name!".)
	echo Finished defining default values for settings defined in "!defaults_name!".
	echo.
)
REM Validate existence of aforementioned file
set "config_counter=0"
set "overwritten_counter=0"
if exist "!config!" (
	title !title_default_og! is reading "!config_name!"...
	echo Reading contents of "!config_name!".
	REM Load and read config file line by line
	for /f "usebackq delims=" %%L in ("!config!") do (
		set "line=%%L"
		REM Skip blank lines
		if not "!line!"=="" (
			REM Skip lines starting with #, ;, and //
			echo !line! | findstr /r "^# ^; ^//" >nul
			if errorlevel 1 (
				REM Split lines into setting and value by " " delimiter
				for /f "tokens=1,* delims= " %%A in ("!line!") do (
					set "configed_setting=%%A"
					set "configed_value=%%B"
					call :strip_quotes "configed_value"
					set "configed_value=!strip_quotes!"
					set "%%A_set=2"
					if defined %%A (set /a overwritten_counter+=1)
					set "!configed_setting!=!configed_value!"
					call :table_row_color
					if "!configed_value!"=="" (
						echo "!format_table_row!!configed_setting!!format_reset!" set to !format_table_row!UNDEFINED!format_reset! ^(meaning, it's disabled^).
					) else (
						echo "!format_table_row!!configed_setting!!format_reset!" set to "!format_table_row!!configed_value!!format_reset!".
					)
					set /a config_counter+=1
				)
			)
		)
	)
	title !title_default!
	echo.
	if !config_counter! EQU 0 (echo No settings have been read from "!config_name!".
	) else if !config_counter! EQU 1 (echo 1 setting loaded from "!config_name!".
	) else if !config_counter! GEQ 2 (echo !config_counter! settings loaded from "!config_name!".)
	echo Finished defining configured values for settings defined in "!config_name!".
	echo.
	if !overwritten_counter! EQU 0 (echo No settings in "!defaults_name!" have been overwritten by "!config_name!".
	) else if !overwritten_counter! EQU 1 (echo 1 setting in "!defaults_name!" overwritten by "!config_name!". (
	) else if !overwritten_counter! GEQ 2 (echo !config_counter! settings in "!defaults_name!" overwritten by "!config_name!".)
)
if not "!advanced_mode!" GEQ "1" (
	set "__tip_file_ext=.json"
	set "__lang_file_ext=.json"
	for %%S in (
		"__tip_file_ext"
		"__lang_file_ext"
	) do (
		set "%%~S_set=4"
	)
)
if not "!advanced_mode!" GEQ "2" (
	set "__tip_folder_name=tips"
	set "__lang_folder_name=lang"
	for %%S in (
		"__tip_folder_name"
		"__lang_folder_name"
	) do (
		set "%%~S_set=4"
	)
)
goto :Section_Verify_Settings

if 1==2 (
:Section_Logic
echo.
echo ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
echo ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
echo.!format_section_title!
echo                                           ██┐      ██████┐  ██████┐ ██┐ ██████┐
echo                                           ██│     ██┌───██┐██┌────┘ ██│██┌────┘
echo                                           ██│     ██│   ██│██│  ███┐██│██│     
echo                                           ██│     ██│   ██│██│   ██│██│██│     
echo                                           ███████┐└██████┌┘└██████┌┘██│└██████┐
echo                                           └──────┘ └─────┘  └─────┘ └─┘ └─────┘!format_reset!
echo.
echo                                                         (Highly.)
echo                                                         ─────────
echo.

REM ================================ Variable Definition ================================
REM ==================== Terms ====================
REM __tip_folder_name [valid path to potential folder and \ or any valid string]
set "TFol=!__tip_folder_name!"
REM __lang_folder_name [valid path to potential folder and \ or any valid string]
set "LFol=!__lang_folder_name!"
REM __tip_file_list [path to existing .txt / blank]
set "TFiLiP=!__tip_file_list_path!"
set "TFiLiN=!__tip_file_list_name!"
REM __namespace_overwrite [valid path to potential folder and \ or any valid string]
set "NaSpN=!__namespace_overwrite_name!"
set "NaSpP=!__namespace_overwrite_path!"
REM ==================== Entry Files ====================
REM __tip_file_rep_space [any valid string]
set "TFiReSp=!__tip_file_rep_space!"
REM __tip_file_prefix [any valid string / blank]
set "TFiPre=!__tip_file_prefix!"
REM __tip_file_suffix [any valid string / blank]
set "TFiSuf=!__tip_file_suffix!"
REM __tip_file_dupes [ask / keep / replace]
set "TFiDupe=!__tip_file_dupes!"
REM __tip_file_reformat [true / false]
set "TFiRefo=!__tip_file_reformat!"
REM __tip_file_template [path to existing .txt / blank]
set "TFiTeP=!__tip_file_template_path!"
set "TFiTeN=!__tip_file_template_name!"
REM __tip_file_ext [any valid string]
set "TFiExt=!__tip_file_ext!"
REM ==================== Output File ====================
REM __lang_file_name [any valid string]
REM __lang_file_ext [any valid string]
set "LFi=!__lang_file_name!!__lang_file_ext!
REM __lang_file_template [path to existing .txt]
set "LFiTeP=!__lang_file_template_path!"
set "LFiTeN=!__lang_file_template_name!"
REM ==================== Keys ====================
REM __tip_key_prefix [any valid string / blank]
set "TKeyPre=!__tip_key_prefix!"
REM __tip_key_suffix [any valid string / blank]
set "TKeySuf=!__tip_key_suffix!"
REM __custom_title_key [any valid string / blank]
set "CTKey=!__custom_title_key!"
REM ==================== General ====================
REM __batch_file [path to existing .txt / blank]
set "BaFiP=!__batch_file_path!"
set "BaFiN=!__batch_file_name!"
REM __open_output_folder [true / false]
set "OpOuFo=!__open_output_folder!"
REM So if Tip File Reformat is enabled, then the script doesn't check any of the file names or file-fixes in the Tips Folder,
REM all it does is make a list of those files and replaces them based on the template file and the key-fixes.
REM I don't think there'd be an easy way to do that while preserving the original key-fixes. (Honestly though, would you even want them?)

if "!verbose_logic!" GEQ "1" (
echo ==================== Terms ====================
echo TFol is "!__tip_folder_name!"
echo LFol is "!__lang_folder_name!"
echo TFiLiP is "!__tip_file_list_path!"
echo TFiLiN is "!__tip_file_list_name!"
echo NaSpP is "!__namespace_overwrite_path!"
echo NaSpN is "!__namespace_overwrite_name!"
echo ==================== Entry Files ====================
echo TFiReSp is "!__tip_file_rep_space!"
echo TFiPre is "!__tip_file_prefix!"
echo TFiSuf is "!__tip_file_suffix!"
echo TFiDupe is "!__tip_file_dupes!"
echo TFiRefo is "!__tip_file_reformat!" & REM Not done yet. When enabled, even when a tip list is provided, replaces the contents of all files (what? surely there's more to this)
echo TFiTeP is "!__tip_file_template_path!"
echo TFiTeN is "!__tip_file_template_name!"
echo TFiExt is "!__tip_file_ext!"
echo ==================== Output File ====================
echo LFi is "!__lang_file_name!!__lang_file_ext!"
echo LFiTeP is "!__lang_file_template_path!"
echo LFiTeN is "!__lang_file_template_name!"
echo ==================== Keys ====================
echo TKeyPre is "!__tip_key_prefix!"
echo TKeySuf is "!__tip_key_suffix!"
echo CTKey is "!__custom_title_key!"
echo ==================== General ====================
echo BaFiP is "!__batch_file_path!" & REM Not done yet
echo BaFiN is "!__batch_file_name!" & REM Not done yet
echo OpOuFo is "!__open_output_folder!"
)

REM
REM ======================================== More Term Definition ========================================

if not defined NaSpP (
	if defined TFiLiP (
		for %%A in ("!TFiLiP!") do (
			set "NaSpN=%%~nA"
			set "NaSpP=%%~dpnA"
		)
	) else (call :error_message_severe Both __namespace_overwrite and __tip_file_list are undefined! The script cannot proceed!)
)

set "TFolP=!NaSpP!\!TFol!" & REM Create Tip Folder Path variable and mkdir if not exist
if not exist "!TFolP!\" (mkdir "!TFolP!")
set "LFolP=!NaSpP!\!LFol!" & REM Create Lang Folder Path variable and mkdir if not exist
if not exist "!LFolP!\" (mkdir "!LFolP!")
set "LFiP=!LFolP!\!LFi!"
set "LFiP_temp=!LFolP!\!__lang_file_name!_temp!__lang_file_ext!"

if defined TFiLiP (
echo.
echo !format_subsection!══════════════════════════════════════════════════ Entry File Creation ═════════════════════════════════════════════════!format_reset!

REM Read every line in the TipFileListPath and create a TipFile file based on that line's string, plus the file-fixes.
set "title_default=!title_default_og! is checking the contents of the "!__tip_folder_name!" folder..."
for /f "usebackq delims=" %%L in ("!TFiLiP!") do (
	set "line=%%~L"
	set "line=!line: =%TFiReSp%!"
	call :make_valid_name "line" 1
	for %%T in ("!line!") do (
		set "Tip=%%~T"
		set "TFiN=!TFiPre!!Tip!!TFiSuf!!TFiExt!"
		set "TFiP=!TFolP!\!TFiN!"
		set "TipKey=!TKeyPre!!Tip!!TKeySuf!"
		call :TipFile_conflict "!TFiP!" "!TFiPre!!Tip!!TFiSuf!" "!TFiExt!"
	)
)
set "title_default=!title_default_og!"
title !title_default_og!
)

if /i "!TFiRefo:~0,1!"=="t" (
echo.
echo !format_subsection!══════════════════════════════════════════════════ Entry File Reformat ═════════════════════════════════════════════════!format_reset!

for /r "%TFolP%" %%F in (*%TFiExt%) do (
	set "TFiN=%%~nxF"
	set "TFiP=%%~fF"
	echo Reformatting the contents of "!TFiN!".
	title !title_default_og! is reformatting the contents of "!TFiN!"..."
	call :Get_tip_key "TFiP"
	break>"!TFiP!"
	call :Output_TFiTe_lines
)
)

echo.
echo !format_subsection!═════════════════════════════════════════════════ Output File Creation ═════════════════════════════════════════════════!format_reset!

del "!LFiP_temp!" 2>nul
REM Check if LangFile already exists.
:LangFilePath_exists
if exist "!LFiP!" (
if /i not "!TFiDupe:~0,1!"=="r" (
	echo.
	echo "!LFi!" already exists
	call :confirm_n "Do you want to replace it? (Y/N): " "0nf2 1yt" "1" "LFiP_exists"
	if /i not "!LFiP_exists!"=="1" (
		call :confirm_n "Would you like to provide a new name? (Y/N): " "0nf2 1yt" "1" "LFiP_exists"
		if /i "!LFiP_exists!"=="1" (
			title !title_default_og! !title_prompting!
			set "LFiP_exists="
			set /p "LFiP_exists=Provide new name: "
			if "!LFiP_exists!"=="" (call :error_message_light It is inadvisable to create a file with no name. & goto :LangFilePath_exists)
			title !title_default!
			call :make_valid_name "LFiP_exists"
			set "LFi=!LFiP_exists!!__lang_file_ext!"
			set "LFiP=!LFolP!\!LFi!"
			set "__lang_file_name=!LFiP_exists!"
			goto :LangFilePath_exists
		) else (
			title !title_default! is asking you...
			echo What was the point of running the script if not to update the lang file^?
			pause>nul
			echo So I^'ll ask again...
			pause>nul
			title !title_default! 
			goto :LangFilePath_exists
		)
	)
))

set /a LFi_lines=0 & set "Tips_Section=0"
for /f "usebackq delims=" %%L in ("%LFiTeP%") do (
	set "line=%%~L"
	if "!line!"=="<Tips>" (call :Lang_template_fill_count & set "Tips_Section=1")
	if "!line!"=="<Final_Tip>" (set "Tips_Section=1")
	if "!line!"=="</Final_Tip>" (set "Tips_Section=1")
	if "!Tips_Section!"=="0" (set /a LFi_lines+=1)
	if "!line!"=="<Final_Tip>" (set "Tips_Section=0")
	if "!line!"=="</Tips>" (set "Tips_Section=0")
	if "!line!"=="</Final_Tip>" (set "Tips_Section=0")
)
set /a LFi_lines=!LFi_lines!
if "!ui_color!"=="0" (
	call :Per_line_progress_bar_set !LFi_lines! 242 241 165 97 214 214
) else (
	call :Per_line_progress_bar_set !LFi_lines! 197 15 31 22 198 12
)

set "Tips_Section=0"
title !title_default_og! is writing to "!__lang_file_name!_temp!__lang_file_ext!"...
REM Read template file line by line.
for /f "usebackq delims=" %%L in ("%LFiTeP%") do (
	set "line=%%~L"
	if "!line!"=="<Tips>" (call :Lang_template_fill & set "Tips_Section=1")
	if "!line!"=="<Final_Tip>" (set "Tips_Section=1")
	if "!line!"=="</Final_Tip>" (set "Tips_Section=1")
	if "!Tips_Section!"=="0" (
		call :Per_line_progress_bar Read template file line by line.
		call echo !line!>>"!LFiP_temp!"
		call echo !PLPB!  !format_reset!!line!
	)
	if "!line!"=="<Final_Tip>" (set "Tips_Section=0")
	if "!line!"=="</Tips>" (set "Tips_Section=0")
	if "!line!"=="</Final_Tip>" (set "Tips_Section=0")
)
title !title_default_og!

del "!LFiP!" 2>nul
rename "!LFiP_temp!" "!LFi!"
echo.
echo Created "!LFi!".
title !title_default!

if /i "!OpOuFo:~0,1!"=="t" (
	echo Opening path to "!LFi!"...
	%SystemRoot%\explorer.exe "!LFolP!"
)

echo.
echo !format_subsection!═════════════════════════════════════════════════════════ DONE ═════════════════════════════════════════════════════════!format_reset!
pause
pause
pause
goto :END

if "!BaFiP!"=="" (
	echo Batch mode is disabled.
) else (
    echo Batch mode is enabled.
	echo batch mode logic goes here
)

REM By default, the script generates a namespace folder in the same folder it exists, and the tips and lang folders inside that one.
REM The name of the namespace folder should, by default, be the name of the tips_list.txt, but this should be overwriteable, and if there is no tips_list.txt, the script needs to ask for the namespace folder's path.
	REM So, the user gives tips_list.txt, and the script asks if they want to give the resulting folder a different namespace? Why?
		REM I mean we can implement the feature for testing and just leave it out in the final version. It'd be annoying having to constantly rename the same tips_list.txt over and over.
		REM Script should have two different dialogues for asking to rename (for development) and provide a name (for final without tips_list.txt).
REM Additionally, (for some reason) the user should have the ability to individually choose where the tips and lang folders+files are generated.
REM And if both of those paths are defined, then the script should no longer generate a namespace folder based on tips_list.txt, nor should it ask the user to name the namespace folder.

) & REM End of Section_Logic

if 1==2 (
echo.!format_section_title!
echo ██┐      ██████┐  ██████┐ ██┐ ██████┐    ██┐     ██┐██████┐ ██████┐  █████┐ ██████┐ ██┐   ██┐
echo ██│     ██┌───██┐██┌────┘ ██│██┌────┘    ██│     ██│██┌──██┐██┌──██┐██┌──██┐██┌──██┐└██┐ ██┌┘
echo ██│     ██│   ██│██│  ███┐██│██│         ██│     ██│██████┌┘██████┌┘███████│██████┌┘ └████┌┘ 
echo ██│     ██│   ██│██│   ██│██│██│         ██│     ██│██┌──██┐██┌──██┐██┌──██│██┌──██┐  └██┌┘  
echo ███████┐└██████┌┘└██████┌┘██│└██████┐    ███████┐██│██████┌┘██│  ██│██│  ██│██│  ██│   ██│   
echo └──────┘ └─────┘  └─────┘ └─┘ └─────┘    └──────┘└─┘└─────┘ └─┘  └─┘└─┘  └─┘└─┘  └─┘   └─┘   !format_reset!
echo.
echo A section containing functions that were really only built with the intent to work in the
echo Logic section and nowhere else.
echo.

:TipFile_conflict "path"
REM               1-- path [in] - The path
if "!verbose_func!" GEQ "1" (echo ":TipFile_conflict" function called.)
REM Read every line in the TipFileListPath and create a TipFile file based on that line's string, plus the file-fixes.
REM set "fc_path=%~1"
REM set "fc_base=%~2"
REM set "fc_extension=%~3"
set "TFiP=!TFolP!\!TFiN!"
if exist "!TFiP!" (
	if /i "!TFiDupe:~0,1!"=="a" (
		if not "!TipFile_conflict_default!"=="1" (
			echo "!TFiN!" already exists.
			echo You can:
			echo     ^(1^). !format_underline!R!format_reset!eplace the original file
			echo     ^(2^). !format_underline!K!format_reset!eep the original file
			echo     ^(3^). !format_underline!M!format_reset!anually rename the new file
			echo     ^(4^). !format_underline!A!format_reset!utomatically rename the new file
			call :confirm_n "What do you want to do?: " "1r 2k 3m 4a" "1" "TipFile_conflict"
			if not "!TipFile_conflict_asked!"=="1" (
				echo.
				echo Would you like to keep this choice for all future potential file conflicts for
				echo the rest of this script's opperation? ^(You will only be asked once.^)
				call :confirm_n "(Y/N): " "0nf2 1yt" "1"
				if /i "!confirm_n!"=="1" (set "TipFile_conflict_default=1")
				set "TipFile_conflict_asked=1"
			)
		)
		       if "!TipFile_conflict:~0,1!"=="0" (
			goto :TipFile_conflict_replace
		) else if "!TipFile_conflict:~0,1!"=="1" (
			goto :TipFile_conflict_keep
		) else if "!TipFile_conflict:~0,1!"=="2" (
			title !title_default_og! !title_prompting!
			set /p "TipFile_conflict=Please provide new name: "
			title !title_default_og!
			call :make_valid_name "TipFile_conflict"
			set "TFiN=!TFiPre!!TipFile_conflict!!TFiSuf!!TFiExt!"
			REM This goto might result in the breaking of this section of the script.
			goto :TipFile_conflict
		) else if "!TipFile_conflict:~0,1!"=="3" (
			title !title_default_og! is renaming "!TFiN!"...
			set "TFi_counter=1"
			:TFi_counter_loop
			if exist "!TFolP!\!TFiN!" (
				set "TFiN=!TFiPre!!Tip!!TFiSuf!_!TFi_counter!!TFiExt!"
				set /a TFi_counter+=1
				REM This go to might result in the breaking of this section of the script.
				goto :TFi_counter_loop
			) else (
				call :Output_TFiTe_lines
				echo "!TFiN!" Has been automatically named and created.
				goto :TipFile_conflict_end
			)
		) else (call :error_message_moderate TipFile_conflict, "!TipFile_conflict!" is invalid.)
	) else if /i "!TFiDupe:~0,1!"=="k" (
		:TipFile_conflict_keep
		title !title_default_og! is keeping "!TFiN!".
		echo "!TFiN!" already exists. Keeping it.
		goto :TipFile_conflict_end
	) else if /i "!TFiDupe:~0,1!"=="r" (
		:TipFile_conflict_replace
		title !title_default_og! is replacing "!TFiN!"...
		del "!TFiP!"
		call :Output_TFiTe_lines
		echo Replaced "!TFiN!".
		goto :TipFile_conflict_end
		)
	) else (call :error_message_moderate TFiDupe, "!TFiDupe!" is invalid.)
) else (
	title !title_default_og! is creating "!TFiN!"...
	echo "!TFiN!" does not yet exist. Creating it.
	call :Output_TFiTe_lines
)
:TipFile_conflict_end
goto :EOF

:Output_TFiTe_lines
if "!verbose_func!" GEQ "1" (echo ":Output_TFiTe_lines" function called for !TFiN!.)
for /f "tokens=1,* usebackq delims=0123456789" %%L in (`find /n /v "" ^< "!TFiTeP!"`) do (
	set "line=%%~M"
	>> "!TFiP!" call echo(!line:~1!)
)
goto :EOF

:Lang_template_fill
if "!verbose_func!" GEQ "1" (echo ":Lang_template_fill" function called.)
for /r "%TFolP%" %%Z in (*%TFiExt%) do (set "LTF_final_file=%%~nZ")
for /r "%TFolP%" %%F in (*%TFiExt%) do (
	set "LTF_file=%%~fF"
	set "LTF_file_name=%%~nxF"
	call :Get_tip_key "LTF_file"
	if not "%%~nF"=="!LTF_final_file!" (
		for /f "usebackq delims=" %%L in ("%LFiTeP%") do (
			set "line=%%~L"
			if "!line!"=="</Tips>" (set "start=0")
			if "!start!"=="1" (
				call :Per_line_progress_bar Lang_template_fill
				call echo !line!>>"!LFiP_temp!"
				call echo !PLPB!  !format_reset!!line!
			)
			if "!line!"=="<Tips>" (set "start=1")
		)
	)
)
goto :EOF

:Lang_template_fill_count
if "!verbose_func!" GEQ "2" (echo ":Lang_template_fill_count" function called.)
for /r "%TFolP%" %%Z in (*%TFiExt%) do (set "LTFC_final_file=%%~nZ")
for /r "%TFolP%" %%F in (*%TFiExt%) do (
	set "LTFC_file=%%~fF"
	set "LTFC_file_name=%%~nxF"
	if not "%%~nF"=="!LTFC_final_file!" (
		for /f "usebackq delims=" %%L in ("%LFiTeP%") do (
			set "line=%%~L"
			if "!line!"=="</Tips>" (set "start=0")
			if "!start!"=="1" (
				set /a LFi_lines+=1
			)
			if "!line!"=="<Tips>" (set "start=1")
		)
	)
)
goto :EOF

:Per_line_progress_bar_set line_number
if "!verbose_func!" GEQ "1" (echo ":Per_line_progress_bar_set" function called.)
set /a line_number=%~1
set /a start_R=%~2
set /a start_G=%~3
set /a start_B=%~4
set /a end_R=%~5
set /a end_G=%~6
set /a end_B=%~7
set "start_RGB=[48;2;!start_R!;!start_G!;!start_B!m
set "end_RGB=[48;2;!end_R!;!end_G!;!end_B!m
REM echo !start_RGB!start_RGB is %~2;%~3;%~4!format_reset!
REM echo !end_RGB!end_RGB is %~5;%~6;%~7!format_reset!
set /a fencepost=!line_number!-1
set /a step_R=((!end_R!-!start_R!)*1000000)/!fencepost!
set /a step_G=((!end_G!-!start_G!)*1000000)/!fencepost!
set /a step_B=((!end_B!-!start_B!)*1000000)/!fencepost!
REM echo step_R is !step_R!
REM echo step_G is !step_G!
REM echo step_B is !step_B!
set /a counter_R=0
set /a counter_G=0
set /a counter_B=0
set /a PLBP_R=0
set /a PLBP_G=0
set /a PLBP_B=0
set /a PLPB_called=0
goto :EOF
:Per_line_progress_bar
if "!verbose_func!" GEQ "2" (echo ":Per_line_progress_bar" function called by "%*".)
set /a PLPB_R=(!start_R!+(!step_R!*!PLPB_called!)/1000000)
set /a PLPB_G=(!start_G!+(!step_G!*!PLPB_called!)/1000000)
set /a PLPB_B=(!start_B!+(!step_B!*!PLPB_called!)/1000000)
REM echo RGB is !PLPB_R! !PLPB_G! !!PLPB_B!
set "PLPB=[48;2;!PLPB_R!;!PLPB_G!;!PLPB_B!m"
REM echo PLPB_called is !PLPB_called!
set /a PLPB_called+=1
goto :EOF

:Get_tip_key "variable_name"
REM         1-- variable_name [in] - The file from which you're taking the tip.
set "GTK_input=!%~1!"
if "!verbose_func!" GEQ "1" (echo Get_tip_key function called for "!%~1!".)
for /f "usebackq delims=" %%L in ("!GTK_input!") do (
	if not "!captured!"=="1" (
		set "line=%%~L"
		REM Find the "text" section.
		echo !line! | findstr /i /c:"\"text\"" >nul
		if not errorlevel 1 (set "found_text_section=1")
		REM If text section found, find "translate".
		if "!found_text_section!"=="1" (
			echo !line! | findstr /i /c:"\"translate\"" >nul
			if not errorlevel 1 (
				for /f "tokens=2 delims=:" %%T in ("!line!") do (
					set "TipKey=%%~T"
					set "TipKey=!TipKey:,=!"
					set "TipKey=!TipKey:"=!"
					set "TipKey=!TipKey:~1!"
					set "captured=1"
					set "found_text_section="
				)
			)
		)
	)
)
set "captured="
goto :EOF

) & REM End of Section_Logic_Library

if 1==2 (
:Section_Functions_Library
echo.!format_section_title!
echo ███████┐██┐   ██┐███┐   ██┐ ██████┐████████┐██┐ ██████┐ ███┐   ██┐███████┐    ██┐     ██┐██████┐ ██████┐  █████┐ ██████┐ ██┐   ██┐
echo ██┌────┘██│   ██│████┐  ██│██┌────┘└──██┌──┘██│██┌───██┐████┐  ██│██┌────┘    ██│     ██│██┌──██┐██┌──██┐██┌──██┐██┌──██┐└██┐ ██┌┘
echo █████┐  ██│   ██│██┌██┐ ██│██│        ██│   ██│██│   ██│██┌██┐ ██│███████┐    ██│     ██│██████┌┘██████┌┘███████│██████┌┘ └████┌┘ 
echo ██┌──┘  ██│   ██│██│└██┐██│██│        ██│   ██│██│   ██│██│└██┐██│└────██│    ██│     ██│██┌──██┐██┌──██┐██┌──██│██┌──██┐  └██┌┘  
echo ██│     └██████┌┘██│ └████│└██████┐   ██│   ██│└██████┌┘██│ └████│███████│    ███████┐██│██████┌┘██│  ██│██│  ██│██│  ██│   ██│   
echo └─┘      └─────┘ └─┘  └───┘ └─────┘   └─┘   └─┘ └─────┘ └─┘  └───┘└──────┘    └──────┘└─┘└─────┘ └─┘  └─┘└─┘  └─┘└─┘  └─┘   └─┘   !format_reset!
echo.
echo                              If you see this in your console window, something horrible has happened.
echo.

:strip_quotes "variable_name" "strip_quotes" -- Removes all double-quotes from a string with an optional output
REM           1-- variable_name [in]     - Name of the variable whose contents will have all double-quotes removed.
REM           2-- strip_quotes  [in,out] - Variable name to be used to return the processed string.
if "!verbose_func!" GEQ "1" (echo ":strip_quotes" function called for "%~1"=="!%~1!".)
if "!verbose_func!" GEQ "2" (echo Other incoming args are: "%~2" = "!%~2!")
set "strip_quotes=!%~1!"
if not "!strip_quotes!"=="" (
	set "strip_quotes=!strip_quotes:"=!"
)
if not "%~2"=="" (set "%~2=!strip_quotes!")
if "!verbose_func!" GEQ "2" (echo ":strip_quotes" function exiting.)
if "!verbose_func!" GEQ "2" (echo Outgoing vars are: "strip_quotes" = "!strip_quotes!", "%~2" = "!%~2!")
goto :EOF

:replace_space "variable_name" "replacewith" "replace_space" -- Replaces spaces with a defined string and optional output
REM            1-- variable_name [in]     - Name of the variable whose spaces are being replaced.
REM            2-- replacewith   [in]     - Character(s) taking the place of spaces.
REM            3-- replace_space [in,out] - Variable name to be used to return the processed string.
if "!verbose_func!" GEQ "1" (echo ":replace_space" function called.)
set "replace_space=%~1"
set "replace_space=!replace_space: =%~2!"
set 
if not "%~3"=="" (set "%~3=!replace_space!")
goto :EOF

:is_ext "variable_name" ".extension" "is_ext" -- Checks if string held by provided variable name could (1) or couldn't be (0) a file of the speciified extension. If not, appends it.
REM     1-- variable_name [in]     - Name of the variable whose path is to be processed.
REM     2-- .extension    [in]     - File extension name to be checked.
REM     3-- is_ext        [in,out] - Variable name to be used to return whether string could (1) or couldn't be (0) a file of the speciified extension.
if "!verbose_func!" GEQ "1" (echo ":is_ext" function called for "%~1"=="!%~1!".)
if "!verbose_func!" GEQ "2" (echo Other incoming args are: "%~2"=="!%~2!", "%~3"=="!%~3!")
set "is_ext=1"
REM Define variables
set "extcheck=!%~1!"
set "ext=%~2"
call :strip_quotes "extcheck" "extcheck"
REM Check if path is blank
if "!extcheck!"=="" (
	call :error_message_light Path cannot be blank for "%~1".
	set "is_ext=0" & goto :EOF
)
if "!ext!"=="" (
	call :error_message_light File extension not provided for "%~1".
	set "is_ext=0" & goto :EOF
)
REM Check for invalid characters (: and \ are allowed in case user provides a full path)
set "extcheck_temp=!extcheck!"
set "extcheck_temp=!extcheck_temp:>=_!"
set "extcheck_temp=!extcheck_temp:<=_!"
call :replace_asterisks extcheck_temp "_" 1
set "extcheck_temp=!extcheck_temp:?=_!"
set "extcheck_temp=!extcheck_temp:|=_!"
set "extcheck_temp=!extcheck_temp:/=_!"
set "extcheck_temp=!extcheck_temp:"=_!"
if not "!extcheck!"=="!extcheck_temp!" (set "is_ext=0" & goto :is_ext_invchar)
REM Add period to extension if doesn't already exist
if not "!ext:~0,1!"=="." (set "ext=.!ext!")
REM Check if path and extension match
call :strLen ext
set "extchecklen=extcheck:~-!len!"
if not "!%extchecklen%!"=="!ext!" (
	set "extcheck=!extcheck!!ext!"
)
REM call :error_message_light Provided path does not refer to a !ext! file.
REM set "is_ext=0" & goto :EOF
REM Check if provided path refers to a folder
if exist "!extcheck!\*" (
	call :error_message_light Provided path points to a folder, not a file.
	set "is_ext=0" & goto :EOF
)
set "%~1=!extcheck!"
set "is_ext=1"
if not "%~3"=="" (set "%~3=!is_ext!")
goto :EOF
:is_ext_invchar
set "is_ext_invchar=* ? < >  | " /"
call :error_message_light The path for "%~1", "!%~1!" is invalid.
echo "Path cannot contain any of the following characters: !is_ext_invchar!"
goto :EOF

:is_valid_path "variable_name" "is_valid_path" -- Checks if provided path is valid (1) or invalid (0).
REM            1-- variable_name [in]     - Name of the variable whose contents are being checked for validity
REM            2-- is_valid_path [in,out] - Variable name to be used to return whether string is valid (1) or invalid (0).
if "!verbose_func!" GEQ "1" (echo ":is_valid_path" function called for "%~1"=="!%~1!".)
set "is_valid_path=1"
REM Define variables
set "pathcheck=!%~1!"
call :strip_quotes "pathcheck" "pathcheck"
REM Check if path is blank
if "!pathcheck!"=="" (
	call :error_message_light Path cannot be blank for "%~1".
	set "is_valid_path=0"
	goto :EOF
)
REM Check for invalid characters (: \ and space are allowed because you can't have a path without them)
set "pathcheck_temp=!pathcheck!"
set "pathcheck_temp=!pathcheck_temp:>=_!"
set "pathcheck_temp=!pathcheck_temp:<=_!"
call :replace_asterisks pathcheck_temp "_" 1
set "pathcheck_temp=!pathcheck_temp:?=_!"
set "pathcheck_temp=!pathcheck_temp:|=_!"
set "pathcheck_temp=!pathcheck_temp:/=_!"
set "pathcheck_temp=!pathcheck_temp:"=_!"
if not "!pathcheck!"=="!pathcheck_temp!" (set "is_valid_path=0" & goto :is_ext_invchar)
REM Check against protected names
REM Set "fullpath" to incoming arg
for %%A in ("!pathcheck!") do (set "fullpath=%%~A")
REM Remove trailing backslash if present
if "!fullpath:~-1!"=="\" (set "fullpath=!fullpath:~0,-1!")
REM Iterate through each folder in path
:loop_is_valid_path_protected
if not "!fullpath!"=="" (
	for %%F in ("!fullpath!") do (
		set "foldername=%%~nxF"
		for /f "tokens=1,* delims=." %%B in ("!foldername!") do (set "base_name=%%B" & set "extension=.%%C")
		for %%R in (CON PRN AUX NUL COM1 COM2 COM3 COM4 COM5 COM6 COM7 COM8 COM9 LPT1 LPT2 LPT3 LPT4 LPT5 LPT6 LPT7 LPT8 LPT9) do (
			if /i "!base_name!"=="%%R" (
				call :error_message_light The specified path includes a folder named, "!base_name!!extension!". "!base_name!" is a protected name in Windows OS and cannot be used.
				set "is_valid_path=0" & goto :EOF
			)
		)
		set "fullpath=%%~dpF"
		if "!fullPath:~-1!"=="\" (set "fullpath=!fullPath:~0,-1!")
		if not "!fullPath:~-1!"==":" (
			if not "!fullPath!"=="" (goto :loop_is_valid_path_protected)
		)
	)
)
set "is_valid_path=1"
if not "%~2"=="" (set "%~2=!is_valid_path!")
goto :EOF

:make_valid_name "variable_name" auto-accept "output_var" -- Checks and modifies any potentially invalid file / folder name into a valid one (for the case of the Tips mod, meaning spaces and cap letters aren't allowed)
REM              1-- variable_name     [in,out] - Name of the variable whose contents are to be made valid, returned as the original variable name itself.
REM              2-- auto-accept (0/1) [in]     - When set to 1, automatically accepts any changes made to incoming strings.
REM              2-- output_var        [in,out] - For checking whether or not a name is valid. When set, does not replace incoming variable.
if "!verbose_func!" GEQ "1" (echo ":make_valid_name" function called for "%~1"=="!%~1!", with auto-accept set to "%~2".)
REM Defining variables
set "make_valid_name=!%~1!"
set "auto_accept=%~2"
REM Check if name is blank
if "!make_valid_name!"=="" (
	call :error_message_light Name cannot be blank for "%~1".
	title !title_default_og! !title_prompting!
	set /p %~1="Provide new name: "
	title !title_default!
	goto :make_valid_name
)
REM Replace invalid characters with _
set "make_valid_name=!make_valid_name:>=_!"
set "make_valid_name=!make_valid_name:<=_!"
set "make_valid_name=!make_valid_name:|=_!"
set "make_valid_name=!make_valid_name:\=_!"
set "make_valid_name=!make_valid_name:/=_!"
set "make_valid_name=!make_valid_name::=_!"
call :replace_asterisks make_valid_name "_" 1
set "make_valid_name=!make_valid_name:?=_!"
set "make_valid_name=!make_valid_name:"=_!"
set "make_valid_name=!make_valid_name: =_!"
REM Check against protected names
REM Extract the base name (remove extension)
for /f "tokens=1,* delims=." %%B in ("!make_valid_name!") do (
	set "base_name=%%B"
	set "extension=%%C"
	if not "extension"=="" (set "extension=.%%C")
)
REM Compare base_name against protected names
for %%R in (CON PRN AUX NUL) do (
	if /i "!base_name!"=="%%R" (
		set "base_name=___"
		set "make_valid_name=!base_name!!extension!"
	)
)
for %%R in (COM1 COM2 COM3 COM4 COM5 COM6 COM7 COM8 COM9 LPT1 LPT2 LPT3 LPT4 LPT5 LPT6 LPT7 LPT8 LPT9) do (
	if /i "!base_name!"=="%%R" (
		set "base_name=____"
		set "make_valid_name=!base_name!!extension!"
	)
)
REM Convert capital letters to lower-case letters
call :toLower "make_valid_name"
REM Alert user of changes and ask if they'd like to keep or change the name
if not "!auto_accept!"=="1" (
	if not "!%~1!"=="!make_valid_name!" (
		:make_valid_name_again
		if "!verbose_func!" GEQ "1" (echo ":make_valid_name_again" sub-function called.)
		set "make_valid_name_again="
		echo.
		echo Provided name included invalid characters or strings.
		echo This issue has been resolved automatically.
		echo "!%~1!" has been changed to "!make_valid_name!".
		call :confirm_n "Are you ok with this change? (Y/N): " "0nf2 1yt" "1" "make_valid_name_again"
		if /i not "!make_valid_name_again!"=="1" (
			call :confirm_n "Would you like to provide a new name? (Y/N): " "0nf2 1yt" "1" "make_valid_name_again"
			if /i "!make_valid_name_again!"=="1" (
				title !title_default_og! !title_prompting!
				set /p %~1="Provide new name: "
				title !title_default!
				goto :make_valid_name
			) else (echo I^'ll ask again then. & pause & goto :make_valid_name_again)
		)
	)
) else if not "!%~3!"=="" (
	if not "!%~1!"=="!make_valid_name!" (
		call :error_message_light "!%~1!" has been changed to "!make_valid_name!".
	)
)
REM Set input variable to valid alternate
if "%~3"=="" (
	set "%~1=!make_valid_name!"
) else (
	set "%~3=!make_valid_name!"
)
goto :EOF

:mvn_win "variable_name" auto-accept -- Checks and modifies any potentially invalid file / folder name into a valid one.
REM              1-- variable_name     [in,out] - Name of the variable whose contents are to be made valid, returned as the original variable name itself.
REM              2-- auto-accept (0/1) [in]     - When set to 1, automatically accepts any changes made to incoming strings.
if "!verbose_func!" GEQ "1" (echo ":mvn_win" function called for "%~1"=="!%~1!", with auto-accept set to "%~2".)
set "mvn_win=!%~1!"
set "auto_accept=%~2"
REM Check if name is blank
if "!mvn_win!"=="" (
	call :error_message_light Name cannot be blank for "%~1".
	title !title_default_og! !title_prompting!
	set /p "%~1=Provide new name: "
	title !title_default!
	goto :mvn_win
)
REM Replace invalid characters with _
set "mvn_win=!mvn_win:>=_!"
set "mvn_win=!mvn_win:<=_!"
set "mvn_win=!mvn_win:|=_!"
set "mvn_win=!mvn_win:\=_!"
set "mvn_win=!mvn_win:/=_!"
set "mvn_win=!mvn_win::=_!"
call :replace_asterisks mvn_win "_" 1
set "mvn_win=!mvn_win:?=_!"
set "mvn_win=!mvn_win:"=_!"
REM Check against protected names
REM Extract the base name (remove extension)
for /f "tokens=1,* delims=." %%B in ("!mvn_win!") do (set "base_name=%%B" & set "extension=.%%C")
REM Compare base_name against protected names
for %%R in (CON PRN AUX NUL) do (
	if /i "!base_name!"=="%%R" (
		set "base_name=___"
		set "mvn_win=!base_name!!extension!"
	)
)
for %%R in (COM1 COM2 COM3 COM4 COM5 COM6 COM7 COM8 COM9 LPT1 LPT2 LPT3 LPT4 LPT5 LPT6 LPT7 LPT8 LPT9) do (
	if /i "!base_name!"=="%%R" (
		set "base_name=____"
		set "mvn_win=!base_name!!extension!"
	)
)
REM Alert user of changes and ask if they'd like to keep or change the name
if not "!auto_accept!"=="1" (
if not "!%~1!"=="!mvn_win!" (
	:mvn_win_again
	set "mvn_win_again="
	echo.
	echo Provided name included invalid characters or strings.
	echo This issue has been resolved automatically.
	echo "!%~1!" has been changed to "!mvn_win!".
	call :confirm_n "Are you ok with this change? (Y/N): " "0nf2 1yt" "1" "mvn_win_again"
	if /i not "!mvn_win_again!"=="1" (
		call :confirm_n "Would you like to provide a new name? (Y/N): " "0nf2 1yt" "1" "mvn_win_again"
		if /i "!mvn_win_again:~0,1!"=="y" (
			title !title_default_og! !title_prompting!
			set /p "%~1=Provide new name: "
			title !title_default!
			goto :mvn_win
		) else (echo I^'ll ask again then. & pause & goto :mvn_win_again)
	)
)) else if not "!%~1!"=="!mvn_win!" (call :error_message_light "!%~1!" has been changed to "!mvn_win!".)
REM Set input variable to valid alternate
set "%~1=!mvn_win!"
goto :EOF

:replace_asterisks "variable_name" "replacewith" "auto-assign" "replace_asterisks" -- replaces asterisks in a string with a defined character
REM                1-- variable_name     [in,out] - Name of the variable whose contents are having its asterisks replaced
REM                2-- replacewith       [in]     - Character(s) the asterisks will be replaced with
REM                3-- auto-assign       [in]     - Controls whether variable_name is automatically defined as "replace_asterisks". 1 to enable
REM                 -- replace_asterisks [out]    - Output variable
REM Source https://stackoverflow.com/a/11685376
if "!verbose_func!" GEQ "1" (echo ":replace_asterisks" function called for "%~1"=="!%~1!".)
set replace_asterisks=!%~1!
call :strLen "replace_asterisks" len
for /l %%x in (0,1,%len%) do (
	if not "!replace_asterisks:~%%x,1!"=="" (
		if "!replace_asterisks:~%%x,1!"=="*" (
			set /a plusone=%%x+1
			for /l %%y in (!plusone!, 1, !plusone!) do (
				set replace_asterisks=!replace_asterisks:~0,%%x!%~2!replace_asterisks:~%%y!
			)
		)
	)
)
if "%~3"=="1" (set "%~1=!replace_asterisks!")
if not "%~4"=="" (set "%~4=!replace_asterisks!")
REM echo input var, "%~1" is now "!%~1!"
REM if "%~4"=="" (echo output var, "replace_asterisks" is now "!replace_asterisks!"
REM ) else (echo output var, "%~4" is now "!%~4!")
REM pause
goto :EOF

:strLen "variable_name" "len" -- returns the length of a string
REM     1-- variable_name [in]  - Name of the variable whose contents are being measured for length
REM      -- len           [out] - Variable to be used to return the string length
REM source https://www.dostips.com
if "!verbose_func!" GEQ "1" (echo ":strLen" function called for "%~1"=="!%~1!".)
set "str=A!%~1!" & rem keep the A up front to ensure we get the length and not the upper bound (it also avoids trouble in case of empty string)
set "len=0"
for /L %%a in (12,-1,0) do (
	set /a "len|=1<<%%a"
	for %%b in (!len!) do (
		if "!str:~%%b,1!"=="" (
			set /a "len&=~1<<%%a"
		)
	)
)
if "%~2" neq "" (set /a %~2=!len!)
goto :EOF

:toLower "variable_name" -- converts uppercase character to lowercase
REM      1-- variable_name [in,out] - Name of the variable whose string is to be converted
REM source https://www.dostips.com
if "!verbose_func!" GEQ "1" (echo ":toLower" function called for "%~1"=="!%~1!".)
if not defined %~1 (EXIT /b)
for %%a in ("A=a" "B=b" "C=c" "D=d" "E=e" "F=f" "G=g" "H=h" "I=i"
            "J=j" "K=k" "L=l" "M=m" "N=n" "O=o" "P=p" "Q=q" "R=r"
            "S=s" "T=t" "U=u" "V=v" "W=w" "X=x" "Y=y" "Z=z" "Ä=ä"
            "Ö=ö" "Ü=ü") do (
	set "%~1=!%~1:%%~a!"
)
goto :EOF

:lTrim "string" "char" -- strips spaces (or other characters) from the beginning of a string
REM    1-- string [in,out] - string variable to be trimmed
REM    2-- char   [in,opt] - character to be trimmed, default is space
REM source https://www.dostips.com
if "!verbose_func!" GEQ "1" (echo ":lTrim" function called.)
call set "string=%%%~1%%" & REM I have no idea why there are so many percents here. May god have mercy on my soul if I desire to use this function.
set "charlist=%~2"
if not defined charlist (set "charlist= ")
for /f "tokens=* delims=%charlist%" %%a in ("%string%") do set "string=%%a"
if not "%~1"=="" (set "%~1=%string%")
goto :EOF

:unset_settings -- Checks if every user-set variable has been read in the defaults file.
REM             -- unset_settings [out] - Returns 1 if there's even a single unset variable, otherwise, 0
if "!verbose_func!" GEQ "1" (echo ":unset_settings" function called.)
set "unset_settings=0"
if "!force_unset!"=="1" (echo. & echo [DEBUG]: "force_unset" enabled & echo.)
echo ^(This section only verifies that the below settings are
echo or aren't present in the defaults / config files.
echo Just because a setting is green does not mean it is valid.^)
echo.
for %%S in (
"__tip_folder_name"
"__lang_folder_name"
"__tip_file_list"
"__namespace_overwrite"
"__tip_file_rep_space"
"__tip_file_prefix"
"__tip_file_suffix"
"__tip_file_dupes"
"__tip_file_reformat"
"__tip_file_template"
"__tip_file_ext"
"__lang_file_name"
"__lang_file_ext"
"__lang_file_template"
"__tip_key_prefix"
"__tip_key_suffix"
"__custom_title_key"
"__batch_file"
"__open_output_folder"
) do (
	if "!force_unset!"=="1" (set "%%~S_set=0")
	if "!%%~S_set!"=="1" (call :bullet_s "%%~S" has been set by "!defaults_name!".)
	if "!%%~S_set!"=="2" (call :bullet_s "%%~S" has been set by "!config_name!".)
	if "!%%~S_set!"=="3" (call :bullet_s "%%~S" has been set / altered by the script / user.)
	if "!%%~S_set!"=="4" (if "!advanced_mode!" GEQ "1" (call :bullet_s "%%~S" is hard-coded by script as "!%%~S!".))
	if not "!%%~S_set!" GEQ "1" (
		call :bullet_f !format_fg_error!"%%~S" has not been set.!format_reset!
		set /a unset_settings=unset_settings+1
	)
)
goto :EOF

:processing_md -- Ensures that if invalid strings or paths go in, the user has to make them valid before they come out.
REM             1-- variable_name           [in] - Name of the variable to be defined
REM             2-- input type (-1/0/1/2)   [in] - (-1) [passthrough] (0) [any valid string] (1) [path to extisting .ext] (2) [path to existing folder]
REM             3-- .extension              [in] - File extension name to be checked
REM             4-- pmd_msg_set             [in] - Custom message to used to query user for input
REM             5-- pmd_msg_success         [in] - Custom message to echo upon successful completion of the function
REM             6-- pmd_msg_blank           [in] - Custom message to echo for when input is left blank. Used in combo with allow blank input.
REM             7-- allow blank input (0/1) [in] - Whether the variable is (1) or isn't (0) allowed to be blank
if "!verbose_processing_md!" GEQ "1" (echo ":processing_md" function called for "%~1"=="!%~1!".)
if "!verbose_processing_md!" GEQ "2" (
echo.
echo [DEBUG] Verifying variable definitions before any are set.
echo ===== Start echoing var values =====
echo pmd_val_original is !pmd_val_original!
echo pmd_var_name is     !pmd_var_name!
echo pmd_input_type is   !pmd_input_type!
echo pmd_ext is          !pmd_ext!
echo pmd_msg_set is      !pmd_msg_set!
echo pmd_msg_success is  !pmd_msg_success!
echo pmd_msg_blank is    !pmd_msg_blank!
echo pmd_allow_blank is  !pmd_allow_blank!
echo ===== Done echoing var values =====
echo.
)
REM Define variables
set "pmd_val_original=!%~1!"
set "pmd_var_name=%~1"
set "pmd_input_type=%~2"
set "pmd_ext=%~3"
set "pmd_msg_set=!%~4!"
set "pmd_msg_success=pmd_msg_success"
set "pmd_msg_blank=!%~6!"
set "pmd_allow_blank=%~7"
if "!verbose_processing_md!" GEQ "2" (
echo.
echo [DEBUG] Telling user what the variables are after being set.
echo "pmd_var_name" is "!pmd_var_name!".
       if "!pmd_input_type!"=="0" (echo "pmd_input_type" is "0" is [any valid string].
) else if "!pmd_input_type!"=="1" (echo "pmd_input_type" is "1" is [any existing file].
) else if "!pmd_input_type!"=="2" (echo "pmd_input_type" is "2" is [valid path to potential folder and \ or any valid string].
) else if "!pmd_input_type!"=="-1" (echo "pmd_input_type" is "-1" is [passthrough].
) else (echo "pmd_input_type", "!pmd_input_type!" is outside of expected range, -1 to 2.)
echo "pmd_ext" is "!pmd_ext!".
       if "!pmd_allow_blank!"=="0" (echo "pmd_allow_blank" is "0", meaning blank entry is NOT allowed.
) else if "!pmd_allow_blank!"=="1" (echo "pmd_allow_blank" is "1", meaning blank entry IS allowed.
) else (echo "pmd_allow_blank", "!pmd_allow_blank!" is outside of expected range, 0-1.)
)
if "!%pmd_var_name%_set!"=="" (echo. & echo !format_2sub2section!────────────────────────────────────────────────────────────!format_reset!)
REM General script for all input types
if "!verbose_processing_md!" GEQ "1" (echo "%pmd_var_name%_set" is "!%pmd_var_name%_set!" & echo "!pmd_var_name!" defined as "!%~1!")
if not "!%pmd_var_name%_set!" GEQ "1" (
	:processing_md_restart
	echo.
	call :bullet_f Setting: "!pmd_var_name!" is unset.
	echo !format_underline!Description:!format_reset!!format_reset!
	call :Variable_Descriptions "!pmd_var_name!"
	set "%~1="
	if not "!pmd_msg_set!"=="" (
		title !title_default_og! !title_prompting!
		set /p "%~1=!pmd_msg_set!"
		title !title_default!
	) else (
		title !title_default_og! !title_prompting!
		set /p "%~1=Provide desired value for this setting: "
		title !title_default!
	)
)
call :strip_quotes "%~1"
set "%~1=!strip_quotes!"
set "pmd_var_value=!%~1!"
REM If blank input is allowed, check if blank, and exit if so.
if "!pmd_var_value!"=="" (
	if "!pmd_allow_blank!"=="1" (
		if "!pmd_msg_blank!"=="" (
			call :bullet_s !pmd_var_name! will be disabled / left blank.
		) else (
			call :bullet_s !pmd_msg_blank!
		)
		goto :processing_md_success
	) else if "!pmd_msg_blank!"=="" (
		call :error_message_light !pmd_var_name! has been left blank. Blank entry isn't allowed for this setting.
	) else (
		call :error_message_light !pmd_msg_blank!
	)
	goto :processing_md_restart
)
REM Check what kind of inputs are allowed / what the script is looking for.
if "!pmd_input_type!"=="0" (
	if "!verbose_processing_md!" GEQ "1" (echo [any valid string])
	call :make_valid_name "!pmd_var_name!"
	set "pmd_var_value=!%~1!"
	goto :processing_md_success
) else if "!pmd_input_type!"=="1" (
	if "!verbose_processing_md!" GEQ "1" (echo [path to extisting .ext])
	REM Remove leading backslash if user accidentally puts it there, looking for a subfolder (otherwise, script assumes dir:\var_value).
	if "!pmd_var_value:~0,1!"=="\" (
		set "pmd_var_value=!pmd_var_value:~1!"
	)
	call :is_ext "!pmd_var_name!" "!pmd_ext!"
	REM Dynamically set variable_name for cases in which a full path is provided (for easier reading).
	for %%A in ("!pmd_var_value!") do (set "!pmd_var_name!_name=%%~nxA" & set "!pmd_var_name!_path=%%~fA")
	if "!is_ext!"=="0" (
		call :error_message_light "!%pmd_var_name%_name!" does not refer to a valid path or "!pmd_ext!" file. & REM "call" can't be used here or it'd double any carets in the error message, potentially leading to user confusion on error. Though it doesn't affect the functioning of the script.
		goto :processing_md_restart
	) else if not exist "!pmd_var_value!" (
		call :error_message_light "!%pmd_var_name%_name!" could not be located.
		goto :processing_md_restart
	) else (
		goto :processing_md_success
	)
) else if "!pmd_input_type!"=="2" (
REM Why in god's name am I keeping this as part of pmd?
REM When am I ever going to need this functionality again?
REM ...If I plan on making it so that the "tips" and "lang" folders can be renamed?
REM Shut up.
	if "!verbose_processing_md!" GEQ "1" (echo [valid path to potential folder and \ or any valid string])
	REM Remove leading backslash if user accidentally puts it there, looking for a subfolder (otherwise, script assumes dir:\var_value).
	if "!pmd_var_value:~0,1!"=="\" (
		set "pmd_var_value=!pmd_var_value:~1!"
	)
	if not exist "!pmd_var_value!" (
		if "!verbose_processing_md!" GEQ "1" (echo !pmd_var_name! is a name, invalid name/path, or nonexistent path.)
		call :is_valid_path "pmd_var_value"
		if "!is_valid_path!"=="0" (
			echo.
			call :error_message_light The string provided:
			echo "!pmd_var_value!"
			echo Contains invalid characters, strings, or has otherwise been marked as
			echo incapable of being a valid folder path / name.
			echo Would you like to try again^? Otherwise, the string will have its invalid
			echo characters and / or strings automatically removed.
			echo If it was intended to be a path, it will only be treated as a folder name.
			call :confirm_n "Would you like to try again? (Y/N): " "0nf2 1yt"
			if "!confirm_n!"=="1" (goto :processing_md_restart)
			call :make_valid_name "pmd_var_value"
			if "!verbose_processing_md!" GEQ "1" (echo Invalid name/path has been made into a valid name.)
			for %%A in ("!pmd_var_value!") do (set "!pmd_var_name!_name=%%~nxA" & set "!pmd_var_name!_path=%%~fA")
			goto :processing_md_success
		) else (
			if "!verbose_processing_md!" GEQ "1" (echo !pmd_var_name! could be a valid path ^(name or nonexistent path^).)
			for %%A in ("!pmd_var_value!") do (set "!pmd_var_name!_name=%%~nxA" & set "!pmd_var_name!_part_path=%%~dpA")
			echo !pmd_var_value! | findstr /i /r /c:"^[a-z]:\\\\" >nul
			if not errorlevel 1 (
				if "!verbose_processing_md!" GEQ "1" (echo !pmd_var_name! is a nonexistent ^(but valid^) path.)
				call :make_valid_name "%pmd_var_name%_name"
				set "!pmd_var_name!_path=!%pmd_var_name%_part_path!!%pmd_var_name%_name!"
				goto :processing_md_success
			) else (
				if "!verbose_processing_md!" GEQ "1" (echo !pmd_var_name! is just a name.)
				call call :make_valid_name "%pmd_var_name%_name"
				set "!pmd_var_name!_path=!%pmd_var_name%_part_path!!%pmd_var_name%_name!"
				goto :processing_md_success
			)
		)
	) else (
		call :is_valid_path "pmd_var_value"
		if "!is_valid_path!"=="1" (
			if "!verbose_processing_md!" GEQ "1" (echo !pmd_var_name! is an existing path ^(file or folder^).)
			for %%A in ("!pmd_var_value!") do (set "!pmd_var_name!_name=%%~nxA" & set "!pmd_var_name!_part_path=%%~dpA")
			call :make_valid_name "%pmd_var_name%_name" 1 "mvn_output"
			if "!%pmd_var_name%_name!"=="!mvn_output!" (
				if "!verbose_processing_md!" GEQ "1" (echo The final part of %pmd_var_name%_name, "!%pmd_var_name%_name!" is "Tips" mod compatible.)
				if exist "!pmd_var_value!\*" (
					if "!verbose_processing_md!" GEQ "1" (echo Provided path points to an existing folder.)
					if "!%pmd_var_name%_name!"=="" (
						call :error_message_light Looks like the script made your path blank when it wasn't supposed to be. Restarting.
						goto :processing_md_restart
					)
					call :make_valid_name "%pmd_var_name%_name"
					set "!pmd_var_name!_path=!%pmd_var_name%_part_path!!%pmd_var_name%_name!"
					goto :processing_md_success
				) else (
					call :error_message_light Provided path points to an existing file, not a folder.
					goto :processing_md_restart
				)
			) else (call :error_message_light The final part of %pmd_var_name%, "!%pmd_var_name%_name!" is NOT "Tips" mod compatible. It should look like this: "!mvn_output!" & goto :processing_md_restart)
		)  else (goto :processing_md_restart)
	)
	if "!verbose_processing_md!" GEQ "1" (echo %pmd_var_name%_name has been set to !%pmd_var_name%_name! & echo %pmd_var_name%_part_path has been set to !%pmd_var_name%_part_path! & echo %pmd_var_name%_path has been set to !%pmd_var_name%_path!)
) else if "!pmd_input_type!"=="-1" (
	if "!verbose_processing_md!" GEQ "1" (echo [passthrough])
) else (
	call :error_message_moderate Invalid input type "!pmd_input_type!" has been set for !pmd_var_name! in the Verify Settings Section. Only acceptable options are -1, 0, 1, and 2.
	goto :EOF
)
:processing_md_success
REM This is where the pmd_msg_success would be echoed... if setting it before calling processing_md didn't turn the variables in the message into strings when it's turned into an argument.
REM If a success message had !var! and var was set to "shit" before being changed by the function, then it's still going to be referenced as "shit" in the argument.
	REM (Maybe this could be useful somehow? Not for me, but, you know.)
REM However, it should be possible to "call echo !pmd_msg_success!" to "force a second expansion"... but then call is gonna double any carets, and I just don't want to have to deal with that.
if "!verbose_processing_md!" GEQ "2" (echo Entry val was "!pmd_val_original!". Final val is "!pmd_var_value!".)
if not "!pmd_val_original!"=="!pmd_var_value!" (set "!pmd_var_name!_set=3")
if "!%pmd_var_name%_set!"=="" (set "!pmd_var_name!_set=3")
if "!verbose_processing_md!" GEQ "1" (echo "%pmd_var_name%_set" is "!%pmd_var_name%_set!" & echo "!pmd_var_name!" defined as "!pmd_var_value!" & echo End of ":processing_md" function.)
REM Send settings not found in defaults file to defaults file when "new_manual_defaults" is enabled.
REM Unless they're set to [passthrough], in which case, they call the :new_manual_defaults function from the Verify Settings section.
REM Also unless they're __tip_file_ext or __lang_file_ext, because they undergo some processing after :pmd to ensure they start with a period.
if not "!pmd_input_type!"=="-1" (
if not "!pmd_var_name!"=="__tip_file_ext" (
if not "!pmd_var_name!"=="__lang_file_ext" (
		call :new_manual_defaults "!pmd_var_name!"
)))
goto :EOF

:new_manual_defaults "variable_name" -- Echoes every setting into a "New Defaults" file, only if the user asks for it.
REM                                      Also consider making this a toggle in case the user wants to make multiples of these from within the script.
if "!verbose_func!" GEQ "1" (echo ":new_manual_defaults" function called with "%~1"=="!%~1!".)
if "!verbose_func!" GEQ "1" (echo "new_defaults"=="!new_defaults!".)
REM Send var_name and var_value to defaults file when "new_manual_defaults" is enabled.
if "!new_manual_defaults!"=="1" (
	echo %~1 "!%~1!">> "!new_defaults_path!"
)
if "!%~1_set!"=="3" (
	set /a set_settings+=1
	echo ^(!set_settings!/!unset_settings!^) settings defined by user.
)
goto :EOF

:confirm_n "set_message" "opts" "prompt" "confirm_n" -- Allows dev to set custom message and n-many options for confirmation, starting from 0.
REM        1-- set_message  [in]     - The message dialogue that queries the user for an input.
REM        2-- opts         [in]     - Space-separated option groups. Example: "1a 2b 3c"
REM        3-- prompt (0/1) [in]     - Optional output variable name.
REM        3-- confirm_n    [in,out] - Optional output variable name.
REM Potential future args: "check first n characters"
if "!verbose_func!" GEQ "1" (echo ":confirm_n" function called.)
set "confirm_n="
set "user_input="
set "set_message=%~1"
set "opts=%~2"
set "opts=!opts:,= !"
set "prompt=%~3"
if not "!prompt!"=="0" (
	title !title_default_og! !title_prompting!
	set /p "user_input=!set_message!"
	title !title_default!
) else (set "user_input=%~1")
if "!user_input!"=="" (
	if not "!prompt!"=="0" (
		goto :confirm_n
	) else (
		call :error_message_moderate No input provided for ":confirm_n" & goto :EOF
	)
)
set "counter=0"
REM Split opts by comma and loop over each.
for %%O in (!opts!) do (
	set "opt=%%O"
	call :confirm_n_check_match "!user_input!" "!opt!" "!counter!"
	set /a counter=counter+1
)
REM Check if match was found.
if defined confirm_n (
	if not "%~4"=="" (set "%~4=!confirm_n!")
	goto :EOF
) else (
	if "!prompt!"=="1" (
		call :error_message_light Invalid input: "!user_input!"
	) else (
		call :error_message_moderate Invalid input: "!user_input!"
		goto :EOF
	)
	goto :confirm_n
)
:confirm_n_check_match
if "!verbose_func!" GEQ "1" (echo ":confirm_n_check_match" sub-function called.)
REM                    1-- user input     [in]  - Input recieved from user to query.
REM                    2-- current option [in]  - String of characters being checked for this iteration of the for loop.
REM                    3-- counter        [out] - Number of times this function has been called, starting at 0.
set "user_input=%~1"
echo !user_input:~0,1! | findstr /i /r "^[%~2]" >nul
if not errorlevel 1 (set "confirm_n=%~3")
goto :EOF

:bullet_s
if "!verbose_func!" GEQ "2" (echo ":bullet_s" function called.)
echo  !format_success!O!format_reset! %*
goto :EOF
:bullet_f
if "!verbose_func!" GEQ "2" (echo ":bullet_f" function called.)
echo  !format_error!X!format_reset! %*
goto :EOF

:table_row_color
if "!verbose_func!" GEQ "2" (echo ":table_row_color" function called. "ui_color"=="!ui_color!")
if not defined trc_flop (set "trc_flop=0")
if "!ui_color!"=="" (
	goto :trc_dark
) else if "!ui_color!"=="0" (
	:trc_light
	if "!trc_flop!"=="0" (
		set "trc_flop=1"
		set "format_table_row=[48;2;192;242;242m!fg_black!"
	) else (
		set "trc_flop=0"
		set "format_table_row=[48;2;180;222;222m!fg_black!"
	)
) else if "!ui_color!"=="1" (
	:trc_dark
	if "!trc_flop!"=="0" (
		set "trc_flop=1"
		set "format_table_row=[38;2;0;255;255m"
	) else (
		set "trc_flop=0"
		set "format_table_row=[38;2;32;205;205m"
	)
)
goto :EOF

:error_message_severe
if "!verbose_func!" GEQ "2" (echo ":error_message_severe" function called.)
title !title_default! is Experiencing a Severe Error^^!
color 4f
echo.
echo ===============================
echo  ERROR^^! (SEVERE)
echo  %*
echo  Stopping script.
echo ===============================
echo.
pause
pause
pause
goto :bluescreen "%*"
title !title_default!
exit /b

:error_message_moderate
if "!verbose_func!" GEQ "2" (echo ":error_message_moderate" function called.)
title !title_default! is Experiencing an Error.
echo.
echo ===============================
echo !format_error!ERROR^^!!format_reset!
echo %*
echo ===============================
echo.
pause
title !title_default!
goto :EOF

:error_message_light
if "!verbose_func!" GEQ "2" (echo ":error_message_light" function called.)
title !title_default! is Warning You...
echo !format_warning!WARNING:!format_reset! %*
title !title_default!
goto :EOF
) & REM End of Section_Functions_Library

if 1==2 (
:Section_Verify_Settings
echo.
echo ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
echo ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
echo.!format_section_title!
echo     ██┐   ██┐███████┐██████┐ ██┐███████┐██┐   ██┐    ███████┐███████┐████████┐████████┐██┐███┐   ██┐ ██████┐ ███████┐
echo     ██│   ██│██┌────┘██┌──██┐██│██┌────┘└██┐ ██┌┘    ██┌────┘██┌────┘└──██┌──┘└──██┌──┘██│████┐  ██│██┌────┘ ██┌────┘
echo     ██│   ██│█████┐  ██████┌┘██│█████┐   └████┌┘     ███████┐█████┐     ██│      ██│   ██│██┌██┐ ██│██│  ███┐███████┐
echo     └██┐ ██┌┘██┌──┘  ██┌──██┐██│██┌──┘    └██┌┘      └────██│██┌──┘     ██│      ██│   ██│██│└██┐██│██│   ██│└────██│
echo      └████┌┘ ███████┐██│  ██│██│██│        ██│       ███████│███████┐   ██│      ██│   ██│██│ └████│└██████┌┘███████│
echo       └───┘  └──────┘└─┘  └─┘└─┘└─┘        └─┘       └──────┘└──────┘   └─┘      └─┘   └─┘└─┘  └───┘ └─────┘ └──────┘!format_reset!
echo.
echo                                               This is where the fun begins.
echo                                               ─────────────────────────────
echo.

call :unset_settings
if "!verbose_func!" GEQ "1" (
	echo new_manual_defaults_set is !new_manual_defaults_set!
	echo unset_settings is !unset_settings!
)
set /a set_settings=0

REM This section could be compacted by making each "else if" "if" statements, each letter one placed before its corresponding number, whose sole purpose is to change the y/n to a 1/0.
REM Then the final "if" statement could just be triggered if the value isn't 1 or 0.
REM However, this means that we might not have my wonderful 1 and 0 puns, which I'd prefer to keep.
REM Look for a version of this done in __tip_file_dupes in the Verify Settings section.
if "!unset_settings!" GEQ "1" (
	if not "!new_manual_defaults_set!" GEQ "1" (
		:unset_settings_restart
		set "new_manual_defaults="
		echo.
		if "!unset_settings!"=="1" (
			echo !unset_settings! setting is missing from "!defaults_name!" and / or "!config_name!".
		) else (
			echo !unset_settings! settings are missing from "!defaults_name!" and / or "!config_name!".
		)
		echo As a result, you will be asked to manually provide the values for any missing setting^(s^).
		title !title_default_og! !title_prompting!
		set /p new_manual_defaults="Would you like to the values you provide here to be assigned to a new default file? (Y/N): "
		set "new_manual_defaults_set=3"
		title !title_default!
	)
)
if "!new_manual_defaults_set!" GEQ "1" (
	if "!new_manual_defaults!"=="1" (
		echo.
		echo Input registered as "!new_manual_defaults:~0,1!" for "enab!new_manual_defaults:~0,1!ed".
		echo Each value assigned here will be listed in a new defaults file.
		echo ^(Including settings already set in "!defaults_name!" and "!config_name!".^)
		set "new_manual_defaults=1"
	) else if /i "!new_manual_defaults:~0,1!"=="y" (
		echo.
		echo Input registered as "!new_manual_defaults:~0,1!" for "!new_manual_defaults:~0,1!es".
		echo Each value assigned here will be listed in a new defaults file.
		echo ^(Including settings already set in "!defaults_name!" and "!config_name!".^)
		set "new_manual_defaults=1"
	) else if "!new_manual_defaults!"=="0" (
		echo.
		echo Input registered as "!new_manual_defaults:~0,1!" for "n!new_manual_defaults:~0,1!t enabed".
		echo Each value assigned here will only count towards the current opperation of the script.
		set "new_manual_defaults=0"
	) else if /i "!new_manual_defaults:~0,1!"=="n" (
		echo.
		echo Input registered as "!new_manual_defaults:~0,1!" for "!new_manual_defaults:~0,1!o".
		echo Each value assigned here will only count towards the current opperation of the script.
		set "new_manual_defaults=0"
	) else if /i "!new_manual_defaults:~0,1!"=="2" (
		echo.
		echo How did you know^?
		set "new_manual_defaults=0"
	) else (
		call :error_message_light Invalid input, "!new_manual_defaults!" provided. Please type "Y" for "Yes" or "N" for "No".
		set "new_manual_defaults=restart"
		goto :unset_settings_restart
	)
) else (
	echo.
	echo !format_fg_success!All settings in this script have been matched and set with those in the
	echo "!defaults_name!" and "!config_name!" files.!format_reset!
)
REM Establish name of the New Manual Defaults file for the :new_manual_defaults function
if "!new_manual_defaults!"=="1" (
	set "new_defaults_base=_QueefLatina"
	set "new_defaults_ext=.txt"
	set "new_defaults_folder=New Defaults"
	mkdir "!new_defaults_folder!"
	set "new_defaults_path=!new_defaults_folder!\!new_defaults_base!!new_defaults_ext!"
	:new_defaults_loop
	if exist "!new_defaults_path!" (
		set "nd_counter=1"
		set "new_defaults_path=!new_defaults_folder!\!new_defaults_base! (!nd_counter!)!new_defaults_ext!"
		set /a nd_counter=nd_counter+1
		goto :new_defaults_loop
	)
)

set "title_default=!title_default_og! is verifying settings..."
title !title_default!
REM ==================== Terms ====================
REM __tip_folder_name [valid path to potential folder and \ or any valid string]
REM __lang_folder_name [valid path to potential folder and \ or any valid string]
REM __tip_file_list [path to existing .txt / blank]
REM __namespace_overwrite [valid path to potential folder and \ or any valid string]
REM ==================== Entry Files ====================
REM __tip_file_rep_space [any valid string]
REM __tip_file_prefix [any valid string / blank]
REM __tip_file_suffix [any valid string / blank]
REM __tip_file_dupes [ask / keep / replace]
REM __tip_file_reformat [true / false]
REM __tip_file_template [path to existing .txt]
REM __tip_file_ext [any valid string]
REM ==================== Output File ====================
REM __lang_file_name [any valid string]
REM __lang_file_ext [any valid string]
REM __lang_file_template [path to existing .txt]
REM ==================== Keys ====================
REM __tip_key_prefix [any valid string / blank]
REM __tip_key_suffix [any valid string / blank]
REM __custom_title_key [any valid string / blank]
REM ==================== General ====================
REM __batch_file [path to existing .txt / blank]
REM __open_output_folder [true / false]

echo.
echo !format_subsection!════════════════════════════════════════════════════════ TERMS ═════════════════════════════════════════════════════════!format_reset!
if "!advanced_mode!" GEQ "2" (
REM __tip_folder_name [valid path to potential folder and \ or any valid string]
	set "pmd_msg_set=Provide the name of the folder that will be used to identify or hold the entry file(s) (recommended: "tips"): "
	set "pmd_msg_blank=Name of entries folder cannot be blank."
	call :processing_md "__tip_folder_name" 2 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 0
	if not "!__tip_folder_name!"=="" (
		call :bullet_s The folder in which the entry files are / will go is called, "!__tip_folder_name!".
	)
REM __lang_folder_name [valid path to potential folder and \ or any valid string]
	set "pmd_msg_set=Provide the name of the folder that will be used to identify or hold the output file (recommended: "lang"): "
	set "pmd_msg_blank=Name of output folder cannot be blank."
	call :processing_md "__lang_folder_name" 2 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 0
	if not "!__lang_folder_name!"=="" (
		call :bullet_s The folder in which the output file is / will go is called, "!__lang_folder_name!".
	)
)
REM __tip_file_list [path to existing .txt / blank]
REM should we change it to... if not defined "!__namespace_overwrite!" ()
	set "pmd_msg_set=Provide the path of the desired .txt list file, or leave blank to disable possibility for file creation / overwriting in the "!__tip_folder_name!" folder: "
	set "pmd_msg_blank=File creation / overwriting in the "!__tip_folder_name!" folder disabled."
	call :processing_md "__tip_file_list" 1 ".txt" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 1
	if not "!__tip_file_list!"=="" (
		call :bullet_s "!__tip_file_list_name!" located.
	)

REM __namespace_overwrite [valid path to potential folder and \ or any valid string]
	if not "!__tip_file_list!"=="" (
		set "pmd_msg_set=Please provide the the name that will be used to create / identify the namespace folder, or leave blank to have the namespace folder be named after !__tip_file_list_name!: "
		set "pmd_msg_blank=Namespace overwrite left blank. Namespace folder will be named after "!__tip_file_list_name!"."
		call :processing_md "__namespace_overwrite" 2 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 1
	) else (
		set "pmd_msg_set=Please provide the the path of the namespace folder whose contents you wish to alter / replace: "
		set "pmd_msg_blank=Path cannot be blank."
		call :processing_md "__namespace_overwrite" 2 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 0
	)
	if not "!__namespace_overwrite!"=="" (
		call :bullet_s Namespace overwrite success message.
	)
echo.
echo !format_subsection!═════════════════════════════════════════════════════ ENTRY FILES ══════════════════════════════════════════════════════!format_reset!
REM __tip_file_rep_space [any valid string]
	set "pmd_msg_set=Provide the character or characters that will be used to replace spaces when creating files in the "!__tip_folder_name!" folder: "
	set "pmd_msg_blank=Spaces will be deleted when preparing to create / replace files in the "!__tip_folder_name!" folder."
	call :processing_md "__tip_file_rep_space" 0 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 1
	if not "!__tip_file_rep_space!"=="" (
		call :bullet_s The character / characters that will be used to replace spaces when creating files in
		echo    the "!__tip_folder_name!" folder will be "!__tip_file_rep_space!".
	)
REM __tip_file_prefix [any valid string / blank]
	set "pmd_msg_set=Provide the string that will be added to the beginning of every created file name: "
	set "pmd_msg_blank=__tip_file_prefix blank message"
	call :processing_md "__tip_file_prefix" 0 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 1
	if not "!__tip_file_prefix!"=="" (
		call :bullet_s The string that will be added to the beginning of every created file name will be "!__tip_file_prefix!".
	)
REM __tip_file_suffix [any valid string / blank]
	set "pmd_msg_set=Provide the string that will be added to the end of every created file name: "
	set "pmd_msg_blank=__tip_file_suffix blank message"
	call :processing_md "__tip_file_suffix" 0 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 1
	if not "!__tip_file_suffix!"=="" (
		call :bullet_s The string that will be added to the end of every created file name will be "!__tip_file_suffix!".
	)
REM __tip_file_dupes [ask / keep / replace]
	:md__tip_file_dupes
	set "pmd_msg_set=Select your preferred option: "
	set "pmd_msg_blank=Entry left blank. User will be asked for all file conflicts."
	call :processing_md "__tip_file_dupes" -1 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 1
	if "!__tip_file_dupes!"=="" (set "__tip_file_dupes=ask")
	if "!__tip_file_dupes:~0,1!"=="1" (set "__tip_file_dupes=ask")
	if "!__tip_file_dupes:~0,1!"=="a" (
		call :bullet_s Any conflicting files will always be automatically kept.
		set "__tip_file_dupes=ask"
		if not defined __tip_file_dupes_set (set "__tip_file_dupes_set=3")
	)
	if "!__tip_file_dupes:~0,1!"=="2" (set "__tip_file_dupes=keep")
	if "!__tip_file_dupes:~0,1!"=="k" (
		call :bullet_s Any conflicting files will always be automatically kept.
		set "__tip_file_dupes=keep"
		if not defined __tip_file_dupes_set (set "__tip_file_dupes_set=3")
	)
	if "!__tip_file_dupes:~0,1!"=="3" (set "__tip_file_dupes=replace")
	if "!__tip_file_dupes:~0,1!"=="r" (
		call :bullet_s All conflicting files will automatically be replaced.
		set "__tip_file_dupes=replace"
		if not defined __tip_file_dupes_set (set "__tip_file_dupes_set=3")
	)
	if /i not "!__tip_file_dupes:~0,1!"=="a" (
	if /i not "!__tip_file_dupes:~0,1!"=="k" (
	if /i not "!__tip_file_dupes:~0,1!"=="r" (
		call :error_message_light __tip_file_dupes set to unexpected value of "!__tip_file_dupes!". Only "Ask", "Keep", or "Replace" are accepted.
		set "__tip_file_dupes_set="
		goto :md__tip_file_dupes
	)))
	call :new_manual_defaults "__tip_file_dupes"
REM __tip_file_reformat [true / false]
	:md__tip_file_reformat
	set "pmd_msg_set=True or False?: "
	set "pmd_msg_blank=Can't be nothing. Gotta be True or False."
	call :processing_md "__tip_file_reformat" -1 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 0
	echo !__tip_file_reformat:~0,1! | findstr /i /r "^[0fn]" >nul
	if not errorlevel 1 (
		call :bullet_s __tip_file_reformat is "!__tip_file_reformat!" meaning "False".
		if not defined __tip_file_reformat_set (set "__tip_file_reformat_set=3")
		set "__tip_file_reformat=false"
	) else (
		echo !__tip_file_reformat:~0,1! | findstr /i /r "^[1ty]" >nul
		if not errorlevel 1 (
			call :bullet_s __tip_file_reformat is "!__tip_file_reformat!" meaning "True".
			if not defined __tip_file_reformat_set (set "__tip_file_reformat_set=3")
			set "__tip_file_reformat=true"
		) else (
			call :error_message_light __tip_file_reformat set to unexpected value, "!__tip_file_reformat!". Only "True" or "False" are accepted.
			set "__tip_file_reformat_set="
			goto :md__tip_file_reformat
		)
	)
	call :new_manual_defaults "__tip_file_reformat"
REM __tip_file_template [path to existing .txt]
	set "pmd_msg_set=__tip_file_template: "
	set "pmd_msg_blank=__tip_file_template blank"
	call :processing_md "__tip_file_template" 1 ".txt" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 0
	if not "!__tip_file_template!"=="" (
		call :bullet_s "!__tip_file_template_name!" located.
	)
REM __tip_file_ext [any valid string]
if "!advanced_mode!" GEQ "1" (
	set "pmd_msg_set=Provide the extension for the entry file(s) belonging to the "!__tip_folder_name!" folder (with or without a . ) (recommended: ".json"): "
	set "pmd_msg_blank=Although it would be possible to create a file/files without providing an extension, it is not recommended."
	call :processing_md "__tip_file_ext" 0 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 0
	if not "!__tip_file_ext:~0,1!"=="." (
		set "__tip_file_ext=.!__tip_file_ext!"
	)
	if not "!__tip_file_ext!"=="" (
		call :bullet_s The all entry files extensions will be marked as "!__tip_file_ext!".
	)
	call :new_manual_defaults "__tip_file_ext"
)
echo.
echo !format_subsection!═════════════════════════════════════════════════════ OUTPUT FILE ══════════════════════════════════════════════════════!format_reset!

REM __lang_file_name [any valid string]
	set "pmd_msg_set=Provide the name of the output file belonging to the "!__lang_folder_name!" folder: "
	set "pmd_msg_blank=Why would you want to create an output file that doesn't have a name? What's wrong with you?"
	call :processing_md "__lang_file_name" 0 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 0
	if not "!__lang_file_name!"=="" (
		call :bullet_s The output file will be named "!__lang_file_name!".
	)
REM __lang_file_ext [any valid string]
if "!advanced_mode!" GEQ "1" (
	set "pmd_msg_set=Provide the extension for the output file belonging to the "!__lang_folder_name!" folder (with or without a . ) (recommended: ".json"): "
	set "pmd_msg_blank=Although it would be possible to create a file without providing an extension, it is not recommended."
	call :processing_md "__lang_file_ext" 0 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 0
	if not "!__lang_file_ext:~0,1!"=="." (
		set "__lang_file_ext=.!__lang_file_ext!"
	)
	if not "!__lang_file_ext!"=="" (
		call :bullet_s The output file's extension will be "!__lang_file_ext!".
	)
	call :new_manual_defaults "__lang_file_ext"
)
REM __lang_file_template [path to existing .txt]
	set "pmd_msg_set=Provide the path to the lang template .txt file: "
	set "pmd_msg_blank=If no lang template is provided, the resulting output file will be empty."
	call :processing_md "__lang_file_template" 1 ".txt" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 0
	if not "!__lang_file_template!"=="" (
		call :bullet_s "!__lang_file_template_name!" located.
	)

echo.
echo !format_subsection!════════════════════════════════════════════════════ REFERENCE KEYS ════════════════════════════════════════════════════!format_reset!

REM __tip_key_prefix [any valid string / blank]
	set "pmd_msg_set=Provide the string that can be added to the beginning of every created reference key: "
	set "pmd_msg_blank=A prefix can no longer be applied to the start of every created reference key."
	call :processing_md "__tip_key_prefix" 0 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 1
	if not "!__tip_key_prefix!"=="" (
		call :bullet_s The string that can be added to the beginning of every created reference key will be "!__tip_key_prefix!".
	)
REM __tip_key_suffix [any valid string / blank]
	set "pmd_msg_set=Provide the string that can be added to the end of every created reference key: "
	set "pmd_msg_blank=A suffix can no longer be applied to the start of every created reference key."
	call :processing_md "__tip_key_suffix" 0 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 1
	if not "!__tip_key_suffix!"=="" (
		call :bullet_s The string that can be added to the end of every created reference key will be "!__tip_key_suffix!".
	)
REM __custom_title_key [any valid string / blank]
	set "pmd_msg_set=Provide the string that: "
	set "pmd_msg_blank=Created / replaced entry files will not be assigned a custom title reference key."
	call :processing_md "__custom_title_key" 0 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 1
	if not "!__custom_title_key!"=="" (
		call :bullet_s Custom title key referenced by all created files in the namespace folder will be "!__custom_title_key!". 
		echo    ^(Check your "!__tip_file_template_name!" file to make sure this is correct.^)
	)

echo.
echo !format_subsection!═══════════════════════════════════════════════════════ GENERAL ════════════════════════════════════════════════════════!format_reset!
REM __batch_file [path to existing .txt / blank]
	set "pmd_msg_set=Provide the path of the desired .txt batch file, or leave blank to disable batch mode: "
	set "pmd_msg_blank=Batch mode disabled"
	call :processing_md "__batch_file" 1 ".txt" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 1
	if not "!__batch_file!"=="" (
		call :bullet_s "!__batch_file_name!" located.
	)
REM __open_output_folder [true / false]
	:md__open_output_folder
	set "pmd_msg_set=At the end of the script's opperation, would you like to open the folder in which "!__lang_file_name!!__lang_file_ext!" is generated? (Y/N): "
	set "pmd_msg_blank="__open_output_folder" cannot be left blank."
	call :processing_md "__open_output_folder" -1 "" "pmd_msg_set" "pmd_msg_success" "pmd_msg_blank" 0
	echo !__open_output_folder:~0,1! | findstr /i /r "^[0fn2]" >nul
	if not errorlevel 1 (
		call :bullet_s __open_output_folder is "!__open_output_folder!" meaning "False".
		if not defined __open_output_folder_set (set "__open_output_folder_set=3")
		set "__open_output_folder=false"
	) else (
		echo !__open_output_folder:~0,1! | findstr /i /r "^[1ty]" >nul
		if not errorlevel 1 (
			call :bullet_s __open_output_folder is "!__open_output_folder!" meaning "True".
			if not defined __open_output_folder_set (set "__open_output_folder_set=3")
			set "__open_output_folder=true"
		) else (
			call :error_message_light __open_output_folder set to unexpected value, "!__open_output_folder!". Only "True" or "False" are accepted.
			set "__open_output_folder_set="
			goto :md__open_output_folder
		)
	)
	call :new_manual_defaults "__open_output_folder"

echo.
echo !format_subsection!═════════════════════════════════════════════════════════ DONE ═════════════════════════════════════════════════════════!format_reset!

echo.
echo Finished verifying settings.
set "title_default=!title_default_og!"
title !title_default!
:Section_Verify_Settings_end
goto :Section_Logic
) & REM End of Section_Verify_Settings

if 1==2 (
REM ██┐   ██┐ █████┐ ██████┐ ██┐ █████┐ ██████┐ ██┐     ███████┐                              
REM ██│   ██│██┌──██┐██┌──██┐██│██┌──██┐██┌──██┐██│     ██┌────┘                              
REM ██│   ██│███████│██████┌┘██│███████│██████┌┘██│     █████┐                                
REM └██┐ ██┌┘██┌──██│██┌──██┐██│██┌──██│██┌──██┐██│     ██┌──┘                                
REM  └████┌┘ ██│  ██│██│  ██│██│██│  ██│██████┌┘███████┐███████┐                              
REM   └───┘  └─┘  └─┘└─┘  └─┘└─┘└─┘  └─┘└─────┘ └──────┘└──────┘                              
REM                                                                                           
REM ██████┐ ███████┐███████┐ ██████┐██████┐ ██┐██████┐ ████████┐██┐ ██████┐ ███┐   ██┐███████┐
REM ██┌──██┐██┌────┘██┌────┘██┌────┘██┌──██┐██│██┌──██┐└──██┌──┘██│██┌───██┐████┐  ██│██┌────┘
REM ██│  ██│█████┐  ███████┐██│     ██████┌┘██│██████┌┘   ██│   ██│██│   ██│██┌██┐ ██│███████┐
REM ██│  ██│██┌──┘  └────██│██│     ██┌──██┐██│██┌───┘    ██│   ██│██│   ██│██│└██┐██│└────██│
REM ██████┌┘███████┐███████│└██████┐██│  ██│██│██│        ██│   ██│└██████┌┘██│ └████│███████│
REM └─────┘ └──────┘└──────┘ └─────┘└─┘  └─┘└─┘└─┘        └─┘   └─┘ └─────┘ └─┘  └───┘└──────┘
:Variable_Descriptions "variable name" -- Desc
if "!verbose_func!" GEQ "1" (echo ":Variable_Descriptions" function called for "%~1".)
if "%~1"=="__tip_folder_name" (
	echo   This is the name of the folder in which the entry file^(s^) will go.
	echo   The Tips mod will not recognize this folder if it is called anything other than "tips".
	echo   I do not know why I made this a setting you can change.
	goto :EOF
) else if "%~1"=="__lang_folder_name" (
	echo   This is the name of the folder in which the output file will go.
	echo   The Tips mod will not recognize this folder if it is called anything other than "lang".
	echo   I do not know why I made this a setting you can change.
	goto :EOF
) else if "%~1"=="__tip_file_list" (
	echo   The "tip file list" refers to a .txt file that contains the names of:
	echo     1. Files that will be created
	echo     2. Files that will be modified
	goto :EOF
) else if "%~1"=="__namespace_overwrite" (
	echo   The "namespace" is the folder in which your:
	echo     "!__tip_folder_name!" and
	echo     "!__lang_folder_name!" folders can be found.
	echo   It's also the folder that the "Tips" mod references when loading your tips in-game.
	echo   By default, the namespace folder is automatically named after the file given to the "__tip_file_list" setting,
	echo   but, if you'd like to overwrite that name, this is the setting to change to do that.
	echo   If no "__tip_file_list" file is provided, you will be required to provide a path to the namspace folder,
	echo   otherwise, the "!__tip_folder_name!" and "!__lang_folder_name!" folders can't be found by this script.
	goto :EOF

) else if "%~1"=="__tip_file_rep_space" (
	echo   This character / characters will be used to replace any spaces when creating the files based on the names listed in
	echo   the "!__tip_file_list_name!" file.
	echo   ^(This is because the Tips mod can have difficulty when working with spaces and upper-case letters.^)
	goto :EOF
) else if "%~1"=="__tip_file_prefix" (
	echo   This string will be added to the beginning of every file name when creating the files based on the names listed in
	echo   the "!__tip_file_list_name!" file.
	goto :EOF
) else if "%~1"=="__tip_file_suffix" (
	echo   This string will be added to the end of every file name when creating the files based on the names listed in
	echo   the "!__tip_file_list_name!" file.
	goto :EOF
) else if "%~1"=="__tip_file_dupes" (
	echo   If there are any file conflicts, do you want to:
	echo     ^(1^). !format_underline!A!format_reset!sk if file conflicts should be kept or replaced
	echo     ^(2^). !format_underline!K!format_reset!eep all existing files
	echo     ^(3^). !format_underline!R!format_reset!eplace all existing files
	goto :EOF
) else if "%~1"=="__tip_file_template" (
	echo   Provide the path to a .txt file which contains a template layout that may automatically fill the
	echo   files listed in the __tip_file_list and / or the "!__tip_folder_name!" folder.
	REM also do versions for if __namespace_overwrite is set and maybe others?
	goto :EOF
) else if "%~1"=="__tip_file_reformat" (
	echo   If you do not have access to a .txt list of all entry files, do you want to replace the format of every file in
	echo   the "!__tip_folder_name!" folder by making use of the "!__tip_file_template_name!" file^?
	goto :EOF
) else if "%~1"=="__tip_file_ext" (
	echo   This is the file extension for all entry files.
	echo   The Tips mod will not recognize any file extension other than .json-s.
	echo   I do not know why I made this a setting you can change.
	goto :EOF

) else if "%~1"=="__lang_file_name" (
	echo   The resulting name of the final output file, depends on what language you will be using.
	echo   For example: "en_us" for US English, "en_uk" for British English.
	echo   Go to https://minecraft.wiki/w/Language for a list of all the
	echo   locale codes that Minecraft ^(and, by extension, the "Tips" mod^) uses.
	goto :EOF
) else if "%~1"=="__lang_file_ext" (
	echo   This is the file extension for the output file.
	echo   The Tips mod will not recognize any file extension other than .json-s.
	echo   I do not know why I made this a setting you can change.
	goto :EOF
) else if "%~1"=="__lang_file_template" (
	echo   Provide the path to a .txt file which contains a template layout that may automatically fill the
	echo   contents of the output file, "!__lang_file_name!!__lang_file_ext!".
	goto :EOF

) else if "%~1"=="__tip_key_prefix" (
	echo      This string can be added to the beginning of every tip's key name when filling entry files based on the
	echo      contents of the "!__tip_file_template_name!" file.
	goto :EOF
) else if "%~1"=="__tip_key_suffix" (
	echo   This string can be added to the end of every tip's key name when filling entry files based on the
	echo   contents of the "!__tip_file_template_name!" file.
	goto :EOF
) else if "%~1"=="__custom_title_key" (
	echo   Unless set as blank, this string will:
	echo     Be used as a reference key for a custom title in the entry file^(s^) based on the contents of
	echo     the "!__tip_file_template_name!" file.
	echo     Be used as a reference key for a custom title in the resulting output language file.
	echo   If set as blank, a title reference key will not be generated for entry files in the "!__tip_folder_name!" folder,
	echo   nor in "!__lang_file_name!!__lang_file_ext!", and the default "Tips" mod title will be used instead.
	goto :EOF

) else if "%~1"=="__batch_file" (
	echo   The batch file is a .txt file containing the names / paths of multiple other .txt files
	echo   that will be used to generate new or modify existing files belonging to multiple namespaces.
	echo   In order for this feature to work, all matching namespace folders must be in the same location as this .bat file.
	goto :EOF
) else if "%~1"=="__open_output_folder" (
	echo   Whether or not the path to the !format_highlight!output file!format_reset!, "!__lang_file_name!!__lang_file_ext!"
	echo   is opened in a new File Explorer window.
	goto :EOF
) else (
	call :error_message_moderate This is the "Variable_Descriptions" section speaking. The variable name used, "%~1" cannot be found.
	goto :EOF
)
) & REM End of Variable_Descriptions

:colorlib
REM Colour help provided by:
	REM https://stackoverflow.com/a/69924820
	REM https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit
	REM https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/color
set "fg_black=[30m"
set "fg_red=[31m"
set "fg_green=[32m"
set "fg_yellow=[33m"
set "fg_blue=[34m"
set "fg_magenta=[35m"
set "fg_cyan=[36m"
set "fg_white=[37m"

set "fg_bright_black=[90m"
set "fg_bright_red=[91m"
set "fg_bright_green=[92m"
set "fg_bright_yellow=[93m"
set "fg_bright_blue=[94m"
set "fg_bright_magenta=[95m"
set "fg_bright_cyan=[96m"
set "fg_bright_white=[97m"

set "bg_black=[40m"
set "bg_red=[41m"
set "bg_yellow=[43m"
set "bg_green=[42m"

set "bg_bright_yellow=[103m"
set "bg_bright_green=[102m"
set "bg_bright_white=[107m"

set "fg_bluescreen_white=[48;2;0;0;170;38;2;255;255;255m"
set "fg_bluescreen_grey=[48;2;0;0;170;38;2;170;170;170m"
set "bg_bluescreen_grey=[48;2;170;170;170;38;2;0;0;170m"
if "!ui_color!"=="" (
	goto :Dark_Mode
) else if "!ui_color!"=="0" (
	:Light_Mode
	set "format_section_title=!fg_black!"
	set "format_subsection=!fg_black!"
	set "format_2sub2section=!fg_black!"
	set "format_fg_error=!fg_red!"
	set "format_fg_success=[38;2;0;100;0m"
	set "format_error=!bg_red!!fg_bright_white!"
	set "format_success=[48;2;50;150;50m!fg_bright_white!"
	set "format_default=!bg_bright_white!!fg_black!"
	set "format_warning=[48;2;242;220;32m!fg_black!"
	set "format_highlight=[48;2;242;220;32m!fg_black!"
) else if "!ui_color!"=="1" (
	:Dark_Mode
	set "format_section_title=!fg_bright_green!"
	set "format_subsection=!fg_bright_yellow!"
	set "format_2sub2section=!fg_yellow!"
	set "format_fg_error=!fg_bright_red!"
	set "format_fg_success=[38;2;0;255;0m"
	set "format_error=!bg_red!!fg_bright_white!"
	set "format_success=!bg_green!!fg_bright_white!"
	set "format_default=!bg_black!!fg_bright_white!"
	set "format_warning=[48;2;200;150;0m!fg_bright_white!"
	set "format_highlight=[38;2;255;255;64m"
)

set "format_underline=[4m"
set "format_reset=[0m!format_default!"
goto :EOF

:debugs
REM Function verbosity:
set "verbose_func=0" & REM (0-2) Sets the minimum for all "verbose_func" variables to itself. (not yet implemented 20250613)
set "verbose_processing_md=0" & REM (0-2)
set "verbose_confirm_n=0" & REM (0,1)
set "verbose_logic=0" & REM (0,1)
REM call :verbose_func
REM Debug settings
set "force_unset=0" & REM (0,1) Forcibly sets all "var_set" variables to 0 in the ":unset_settings" function.
set "advanced_mode=0" & REM (0,2) Enables setting tips+lang folder names, plus their files' extensions.
REM Titles
set "title_default_og=MindeKing's "Tips" mod Auto-Lang Tool"
set "title_default=!title_default_og!"
set "title_loading=is Loading..."
set "title_prompting=is Prompting You..."
set "title_bluescreen=Critical Error^!"
goto :EOF

if 1==2 (
:verbose_func
set 
)

:bluescreen
REM color 1f
title !title_bluescreen!
echo !fg_bluescreen_white!
mode con: cols=80 lines=25
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
REM   0------------------------------------------------------------------------------0
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                     !bg_bluescreen_grey! Windows !fg_bluescreen_white!
echo.
echo      An error has occurred. To continue:
echo.
echo      Press Enter to exit the script, or
echo.
echo      Press CTRL^+ALT^+DEL to restart your computer. if you do this,
echo      you will lose any unsaved information in all open applications.
echo.
echo      Error: %*
echo.
echo                            Press any key to continue !fg_bluescreen_grey!_!fg_bluescreen_white!
echo.
echo.
echo.
echo.
REM   0------------------------------------------------------------------------------0
pause>nul
exit /b

:END
title Success^^!
color a0
echo ======================
echo.
echo.
echo.
echo End of script reached.
echo.
echo.
echo.
echo ======================
pause
color
title
exit /b
