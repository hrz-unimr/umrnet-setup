# umrnet-setup, university marburg network setup
# Copyright (C) 2010-2014 the umrnet-setup authors, see AUTHORS.txt
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Set compression to lzma (solid)
SetCompressor /FINAL /SOLID lzma

# Set installer name
outFile "..\bin\umrnet-setup-silent.exe"
Name "umrnet-setup"

# Set Windows UAC execution level to administrator
RequestExecutionLevel admin 

# Set installation directory
installDir $TEMP\umrnet-setup

# Function executed on installation success 
Function .onInstSuccess
    # Start umrnet setup batch script
    Exec "$INSTDIR\umrnet-setup-silent.bat"
FunctionEnd

# Start section
section

    # Set user shell context
    SetShellVarContext all

    # Set the installation directory
    setOutPath $INSTDIR

    # Set files that will be included
    file ..\src\*.*
    file ..\*.txt

    # Automatically close installer after finished
    SetAutoClose true
         
sectionEnd
