@echo off

REM umrnet-setup, university marburg network setup
REM Copyright (C) 2010-2014 the umrnet-setup authors, see AUTHORS.txt
REM
REM This program is free software: you can redistribute it and/or modify
REM it under the terms of the GNU General Public License as published by
REM the Free Software Foundation, either version 3 of the License, or
REM (at your option) any later version.
REM
REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM GNU General Public License for more details.
REM
REM You should have received a copy of the GNU General Public License
REM along with this program.  If not, see <http://www.gnu.org/licenses/>.

setlocal enableextensions

REM Set working directory to script directory
REM %~dp0 extracts drive and path from batch file,
REM see: http://www.microsoft.com/resources/documentation/windows/xp/all/proddocs/en-us/percent.mspx?mfr=true
pushd %~dp0

REM Add "%SystemRoot%/sysnative" virtual directory to the "%path%" for making 
REM 32-bit processes in 64-bit Windows find some processes that are not part of 
REM Windows Filesystem Redirector, 
REM see http://msdn.microsoft.com/en-us/library/windows/desktop/aa384187%28v=vs.85%29.aspx
REM
REM In our case, in 64-bit Windows the 32-bit installer executable starts a 
REM 32-bit command line, and because "netcfg.exe" is not automatically redireced 
REM to the right 64-bit directory version, "netcfg.exe" seems missing.
REM
REM This problem does not occur in 64-bit command lines, e.g. started via Run->"cmd"
REM
REM Therefore the following workaround:
set path=%path%;%SystemRoot%\sysnative

REM Set command line background and foreground color
color f2

echo ------------------------------------------------------------------------------
echo umrnet-setup, university marburg network setup
echo ------------------------------------------------------------------------------
echo.
echo umrnet-setup configures your LAN- and WLAN-/WiFi-connections in 
echo Windows Vista, Windows 7, Windows 8 and possibly later Windows
echo versions for Philipps University Marburg network.
echo.
echo Copyright (C) 2010-2014 the umrnet-setup authors, see AUTHORS.txt
echo Web site: ^<https://github.org/hrz-unimr/umrnet-setup/^>
echo.
echo umrnet-setup comes with ABSOLUTELY NO WARRANTY. This is free software, and 
echo you are welcome to redistribute it under certain conditions. See the GNU 
echo General Public License Version 3 for details.

echo.

REM Try to install root certificate (Windows Vista and later)
echo Try to install root certificate...
certutil -addstore -enterprise -f Root "deutsche-telekom-root-ca-2.crt"

echo.

REM Try to start service: wireless auto config (Windows Vista and later)
echo Try to configure wlansvc service...
sc config wlansvc start= auto
sc start wlansvc

echo.

REM Try to start service: wireless zero configuration (Windows XP)
echo Try to configure wzcsvc service...
sc config wzcsvc start= auto
sc start wzcsvc

echo.

REM Start service: wired auto config (Windows XP, Windows Vista and later)
echo Try to configure dot3svc service...
sc config dot3svc start= auto
sc start dot3svc

echo.

REM Try to enable all physical network adapters
echo Try to enable all physical network adapters...
wmic path win32_networkadapter where (PhysicalAdapter=True) call enable

echo.

REM Try to import LAN profile into all existing LAN adapters
echo Try to install LAN profile...
netsh lan add profile filename="netsh-profile-lan.xml" interface="*"

echo.

REM Try to import WLAN profiles into all existing WLAN adapters

echo Try to install WLAN profile for students...
netsh wlan add profile filename="netsh-profile-wlan-students.xml" interface="*" user=all

echo.

echo Try to install WLAN profile for staff...
netsh wlan add profile filename="netsh-profile-wlan-staff.xml" interface="*" user=all

echo.

REM Some workarounds for weird settings and weird Windows bugs

REM Workaround for Windows computers that deactivated some LAN interfaces autoconfig
echo Enable LAN auto-configuration...
netsh lan set autoconfig enabled=yes interface="*"

echo.

REM Workaround for Windows computers that don't want to forget wrong settings (some winxp)
echo Reconnect LAN interface...
netsh lan reconnect

echo.

REM Workaround for Windows computers with wrong IP settings
echo Reset interface IP settings...
netsh int ip reset resetlog.txt

echo.

REM Disable Microsoft Link Layer Topology Discovery (LLTD) on all network adapters, because LLTD causes trouble in big networks with network layer 2 security (Microsoft-LLTD-MAC-adresses and too many ARP requests per second)

REM netcfg.exe path is not included in program executed command line's search path (at least on 64 bit systems)
REM The solution is to add "%SystemRoot%\sysnative\" path, see
REM http://serverfault.com/questions/162171/wlbs-exe-command-not-found-when-running-from-a-program-that-calls-the-system-a

echo Uninstall LLTD client protocol driver causing trouble in big networks...
netcfg.exe -u ms_lltdio

echo.

echo Uninstall LLTD server protocol driver causing trouble in big networks...
netcfg.exe -u ms_rspndr

echo.

endlocal
