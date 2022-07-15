@echo off
FOR /F "TOKENS=1,2,3,4,5 DELIMS=/: " %%A IN ('echo %DATE% %TIME%') DO (
SET dd=%%A
SET m=%%B
SET yyyy=%%C
SET hh=%%D
set mm=%%E
)

:: Input Org name and Ticket number
::SET /p OrgName="Enter name of the organization:  "
SET /p TicketNo="Enter the support ticket number:  "
::SET LOGROOT=C:\temp\%TicketNo%_%OrgName%_LOGS_%dd%-%m%-%yyyy%-%hh%-%mm%
SET LOGROOT=C:\temp\%TicketNo%_%ComputerName%_LOGS_%dd%-%m%-%yyyy%-%hh%-%mm%

echo. 
echo.

:: Check if log directory exists, if yes, delete it. Then create the log directory
echo Step 1: Creating log collection directory
if exist "%LOGROOT%" (
  rmdir /s /q "%LOGROOT%"
  )

mkdir "%LOGROOT%"

echo.

echo Step 2: Exporting event logs and VSS status
wevtutil export-log System "%LOGROOT%\%COMPUTERNAME%_System.evtx"
wevtutil export-log Application "%LOGROOT%\%COMPUTERNAME%_Application.evtx"
wevtutil export-log Security "%LOGROOT%\%COMPUTERNAME%_Security.evtx"
vssadmin list writers > "%LOGROOT%\%COMPUTERNAME%_VSSWriters.txt"
vssadmin list providers > "%LOGROOT%\%COMPUTERNAME%_VSSProviders.txt"

echo. 
echo Step 3: Fetching System Info and installed application reports
echo This may take some time. Please do not close this window . . . .

::msinfo32 /nfo %LOGROOT%\MSINFO32.nfo
systeminfo > %LOGROOT%\"system.txt"
ipconfig /all > %LOGROOT%\"Network Info.txt"
wmic qfe get Hotfixid > "%LOGROOT%\%COMPUTERNAME%_Hotfixes.txt"
fltmc > "%LOGROOT%\%COMPUTERNAME%_FLTMC.txt"
fltmc instances > "%LOGROOT%\%COMPUTERNAME%_FLTMC_Instances.txt"
wmic logicaldisk get name,Caption,Description,DeviceID,FileSystem,Size,FreeSpace,DriveType,VolumeName >> "%LOGROOT%\%COMPUTERNAME%_wmic_volumes.txt"
fsutil volume list >> "%LOGROOT%\%COMPUTERNAME%_fsutil_volumes.txt"
wmic diskdrive list >> "%LOGROOT%\%COMPUTERNAME%_Wmic_diskdrive_list.txt"
schtasks /query /fo CSV >> "%LOGROOT%\%COMPUTERNAME%_schedtasks.csv"
gpresult /Z >> "%LOGROOT%\%COMPUTERNAME%_gpresults.txt"
tasklist /svc >> "%LOGROOT%\%COMPUTERNAME%_Tasklist.txt"
netstat -anob >> "%LOGROOT%\%COMPUTERNAME%_netstatout.txt
set >> "%LOGROOT%\%COMPUTERNAME%_SET.txt
echo %PATH% >> "%LOGROOT%\%COMPUTERNAME%_PATH.txt"
wmic product get InstallDate,Name,Vendor,Version >> "%LOGROOT%\%COMPUTERNAME%_InstalledApps.txt"

::fsutil usn queryjournal c: >> %LOGROOT%\"usn_journal_C.txt"

echo. 

echo Step 4: Collecting Druva Logs
:: Files and folders excluded from collection
echo \USMT\ >> %LOGROOT%\exclusion.txt
echo \amd64\ >> %LOGROOT%\exclusion.txt
echo amd64.zip >> %LOGROOT%\exclusion.txt
echo \CDC\ >> %LOGROOT%\exclusion.txt
echo \inSyncHC\ >> %LOGROOT%\exclusion.txt
echo \inSyncRHC\ >> %LOGROOT%\exclusion.txt
echo \mapilc\ >> %LOGROOT%\exclusion.txt
echo .ipkg >> %LOGROOT%\exclusion.txt
echo .msi >> %LOGROOT%\exclusion.txt
echo .smdb >> %LOGROOT%\exclusion.txt

:: Collecting Druva Logs for inSync
IF EXIST C:\inSync4 ( mkdir "%LOGROOT%\inSync4" && xcopy C:\inSync4 "%LOGROOT%\inSync4" /EXCLUDE:%LOGROOT%\exclusion.txt /E /C /I /Y > nul)
IF EXIST C:\ProgramData\Druva ( mkdir "%LOGROOT%\ProgramData\Druva" && xcopy "C:\ProgramData\Druva" "%LOGROOT%\ProgramData\Druva" /EXCLUDE:%LOGROOT%\exclusion.txt /E /C /I /Y > nul)
del /f %LOGROOT%\exclusion.txt

echo. 

echo Step 5: Zip the log directory in %LOGROOT%.zip
if exist "%LOGROOT%.zip" (
  del /f "%LOGROOT%.zip"
  )

powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('%LOGROOT%', '%LOGROOT%.zip'); }"

if exist "%LOGROOT%" (
  rmdir /s /q "%LOGROOT%"
  )

echo Please upload the log directory on https://upload.druva.com referring to the support ticket number %TicketNo%

echo.
echo.
pause
