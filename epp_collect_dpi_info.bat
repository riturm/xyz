@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

REM this command must be run as Administrator
net session /list > NUL
if %ERRORLEVEL% EQU 0 (
    echo You are running this script as Administrator
) else (
    echo Please run this script as Administrator, exiting
    pause
    exit /B 1
)

mkdir %TEMP%\epp_tempdir 2> NUL
cd %TEMP%\epp_tempdir

echo Listing all running processes
tasklist /V /FO CSV > tasklist.csv

echo Listing TCP connections and listening ports
netstat -a -b -n -o -q -p tcp > netstat_tcpconn.txt

echo Saving networking statistics
netstat -e -s > netstat_stats.txt

echo Saving the routing table
netstat -r > netstat_routing.txt

echo Saving WFP filters configuration
netsh wfp show filters > NUL

echo Listing all the installed applications and their versions
echo This command can take several minutes to complete, don't interrupt.
wmic product get /format:csv > installed_software.csv

echo Detecting the proxy settings
netsh winhttp show proxy > proxy_settings.txt

echo.
echo The collected files are at:
echo.
echo     %TEMP%\epp_tempdir
explorer %TEMP%\epp_tempdir
pause