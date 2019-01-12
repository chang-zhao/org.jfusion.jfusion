@echo off
SET FULLPATH=%~dp0
SET PLUGIN_DIR="%FULLPATH%components\com_jfusion\plugins"
setlocal enableextensions

:START
IF NOT EXIST administrator echo JFusion files not found. goto end

echo Looking for required commands...
IF NOT EXIST c:\WINDOWS\system32\7za.exe (
	echo "7za.exe does not exist!  Please see create_release_readme.txt".
	goto end
)
IF NOT EXIST c:\WINDOWS\system32\sed.exe (
	echo "sed.exe does not exist! Please see create_release_readme.txt". 
	goto end
)
@git.exe>nul
IF ERRORLEVEL 2 (
	echo "Git client not installed!  Please see create_release_readme.txt". 
	goto end
)

SET REVISION=Unknown
SET TIMESTAMP=Unknown

for /f "tokens=*" %%a in ( 'git rev-parse HEAD' ) do ( set REVISION=%%a )
call :GetTimeStamp TIMESTAMP

cls
echo Choices:
echo 1 - Create Main Packages
echo 2 - Create Plugin and Module Packages
echo 3 - Create All Packages
echo 4 - Delete Main Packages
echo 5 - Delete Plugin and Module Packages
echo 6 - Delete All Packages
set /p useraction=Choose a number(1-6):
set action=%useraction:~0,1%


IF "%action%"=="6" goto CLEAR_ALL
IF "%action%"=="5" goto CLEAR_PACKAGES
IF "%action%"=="4" goto CLEAR_MAIN
IF "%action%"=="3" goto CREATE_ALL
IF "%action%"=="2" goto CREATE_PACKAGES
IF "%action%"=="1" goto CREATE_MAIN
echo Invalid Choice
goto start

:CLEAR_ALL
echo Clearing All Packages
goto CLEAR_MAIN
goto CLEAR_PACKAGES
goto end

:CLEAR_PACKAGES
echo Remove module and plugin packages
del "%FULLPATH%administrator\components\com_jfusion\packages\*.zip"
IF "%action%"=="5" goto end

:CLEAR_MAIN
echo Remove main packages
del *.zip
IF "%action%"=="4" goto end

:CREATE_ALL
goto create_packages
goto create_main
goto end

:CREATE_PACKAGES
del "%FULLPATH%administrator\components\com_jfusion\packages\*.zip"

echo Create the new packages for the plugins and module

call :CreatePackage modules\mod_jfusion_activity\* administrator\components\com_jfusion\packages\jfusion_mod_activity.zip mod_jfusion_activity
call :CreatePackage modules\mod_jfusion_login\* administrator\components\com_jfusion\packages\jfusion_mod_login.zip mod_jfusion_login
call :CreatePackage modules\mod_jfusion_whosonline\* administrator\components\com_jfusion\packages\jfusion_mod_whosonline.zip mod_jfusion_whosonline
call :CreatePackage modules\mod_jfusion_user_activity\* administrator\components\com_jfusion\packages\jfusion_mod_user_activity.zip mod_jfusion_user_activity

call :CreatePackage plugins\authentication\* administrator\components\com_jfusion\packages\jfusion_plugin_auth.zip
call :CreatePackage plugins\user\* administrator\components\com_jfusion\packages\jfusion_plugin_user.zip
call :CreatePackage plugins\search\* administrator\components\com_jfusion\packages\jfusion_plugin_search.zip
call :CreatePackage plugins\content\* administrator\components\com_jfusion\packages\jfusion_plugin_content.zip
call :CreatePackage plugins\system\jfusion.* administrator\components\com_jfusion\packages\jfusion_plugin_system.zip


echo "create the jfusion plugin packages"

call :CreatePackage components\com_jfusion\plugins\dokuwiki pluginpackages\jfusion_dokuwiki.zip
call :CreatePackage components\com_jfusion\plugins\efront pluginpackages\jfusion_efront.zip
call :CreatePackage components\com_jfusion\plugins\elgg pluginpackages\jfusion_elgg.zip
call :CreatePackage components\com_jfusion\plugins\gallery2 pluginpackages\jfusion_gallery2.zip
call :CreatePackage components\com_jfusion\plugins\joomla_ext pluginpackages\jfusion_joomla_ext.zip
call :CreatePackage components\com_jfusion\plugins\joomla_int pluginpackages\jfusion_joomla_int.zip
call :CreatePackage components\com_jfusion\plugins\magento pluginpackages\jfusion_magento.zip
call :CreatePackage components\com_jfusion\plugins\mediawiki pluginpackages\jfusion_mediawiki.zip
call :CreatePackage components\com_jfusion\plugins\moodle pluginpackages\jfusion_moodle.zip
call :CreatePackage components\com_jfusion\plugins\mybb pluginpackages\jfusion_mybb.zip
call :CreatePackage components\com_jfusion\plugins\oscommerce pluginpackages\jfusion_oscommerce.zip
call :CreatePackage components\com_jfusion\plugins\phpbb3 pluginpackages\jfusion_phpbb3.zip
call :CreatePackage components\com_jfusion\plugins\prestashop pluginpackages\jfusion_prestashop.zip
call :CreatePackage components\com_jfusion\plugins\smf pluginpackages\jfusion_smf.zip
call :CreatePackage components\com_jfusion\plugins\smf2 pluginpackages\jfusion_smf2.zip
call :CreatePackage components\com_jfusion\plugins\universal pluginpackages\jfusion_universal.zip
call :CreatePackage components\com_jfusion\plugins\vbulletin pluginpackages\jfusion_vbulletin.zip
call :CreatePackage components\com_jfusion\plugins\wordpress pluginpackages\jfusion_wordpress.zip


echo "create the new packages for the Magento Integration"

call :CreatePackage modules\mod_jfusion_magecart\* side_projects\magento\jfusion_mod_magecart.zip mod_jfusion_magecart
call :CreatePackage modules\mod_jfusion_mageselectblock\* side_projects\magento\jfusion_mod_mageselectblock.zip mod_jfusion_mageselectblock
call :CreatePackage modules\mod_jfusion_magecustomblock\* side_projects\magento\jfusion_mod_magecustomblock.zip mod_jfusion_magecustomblock
call :CreatePackage plugins\system\magelib.* side_projects\magento\jfusion_plugin_magelib.zip magelib

IF "%action%"=="2" goto end

:CREATE_MAIN

echo Prepare the files for packaging
md tmp
md tmp\admin
c:\windows\system32\xcopy /E /C /V /Y "%FULLPATH%administrator\components\com_jfusion\*.*" "%FULLPATH%\tmp\admin" > NUL
c:\windows\system32\xcopy /E /C /V /Y "%FULLPATH%pluginpackages\*.*" "%FULLPATH%tmp\admin\packages\" > NUL
del "%FULLPATH%tmp\admin\jfusion.xml"

md tmp\admin\language
c:\windows\system32\xcopy /E /C /V /Y "%FULLPATH%administrator\language\en-GB\*.*" "%FULLPATH%tmp\admin\language\en-GB\" > NUL

md tmp\front
c:\windows\system32\xcopy /E /C /V /Y /EXCLUDE:%FULLPATH%exclude.txt "%FULLPATH%components\com_jfusion\*.*" "%FULLPATH%tmp\front" > NUL

md tmp\front\language
c:\windows\system32\xcopy /E /C /V /Y "%FULLPATH%language\en-GB\*.*" "%FULLPATH%tmp\front\language\en-GB\" > NUL

copy "%FULLPATH%administrator\components\com_jfusion\jfusion.xml" "%FULLPATH%tmp" /V /Y > NUL
copy "%FULLPATH%administrator\components\com_jfusion\install.jfusion.php" "%FULLPATH%tmp" /V /Y > NUL
copy "%FULLPATH%administrator\components\com_jfusion\uninstall.jfusion.php" "%FULLPATH%tmp" /V /Y > NUL

echo Update the revision number

echo Revision set to %REVISION%
echo Timestamp set to %TIMESTAMP%
call :CreateXml %FULLPATH%tmp\jfusion

echo Create the new master package

del %FULLPATH%*.zip

7za a "%FULLPATH%jfusion_package.zip" .\tmp\* -xr!*.svn* > NUL

RMDIR "%FULLPATH%tmp" /S /Q

echo Create a ZIP containing all files to allow for easy updates
chdir %FULLPATH%
7za a "%FULLPATH%jfusion_files.zip" administrator components language modules plugins -r -xr!*.svn* > NUL
IF "%action%"=="1" goto end

:end
echo Complete
pause>nul

:GetTimeStamp
	setlocal enableextensions
	for /f %%x in ('wmic path win32_utctime get /format:list ^| findstr "="') do (
		set %%x)
	set /a z=(14-100%Month%%%100)/12, y=10000%Year%%%10000-z
	set /a ut=y*365+y/4-y/100+y/400+(153*(100%Month%%%100+12*z-3)+2)/5+Day-719469
	set /a ut=ut*86400+100%Hour%%%100*3600+100%Minute%%%100*60+100%Second%%%100
endlocal & set "%1=%ut%" & goto :EOF

:CreatePackage
	setlocal enableextensions

	SET TARGETPATH=%1
	SET TARGETDEST=%2
	SET XMLFILE=%3

	IF "%3" == "" SET XMLFILE=jfusion

	md %FULLPATH%tmppackage

	c:\windows\system32\xcopy /S /E /C /V /Y "%FULLPATH%%TARGETPATH%" "%FULLPATH%tmppackage" > NUL

	call :CreateXml %FULLPATH%tmppackage\%XMLFILE%

	7za a "%FULLPATH%%TARGETDEST%" %FULLPATH%tmppackage\* -xr!*.svn* > NUL

	RMDIR "%FULLPATH%tmppackage" /S /Q
endlocal & goto :EOF

:CreateXml
	setlocal enableextensions
	SET FILE=%1

	move "%FILE%.xml" "%FILE%.tmp" >nul
	c:\WINDOWS\system32\sed.exe "s/<revision>\$revision\$<\/revision>/<revision>%REVISION%<\/revision>/g" "%FILE%.tmp" > "%FILE%.xml"
	move "%FILE%.xml" "%FILE%.tmp" >nul
	c:\WINDOWS\system32\sed.exe "s/<timestamp>\$timestamp\$<\/timestamp>/<timestamp>%TIMESTAMP%<\/timestamp>/g" "%FILE%.tmp" > "%FILE%.xml"

	del %FILE%.tmp
endlocal & goto :EOF
