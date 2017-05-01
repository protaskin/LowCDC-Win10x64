:: createcat.bat is a batch file that automatically creates a catalog file for
:: the lowcdc.sys driver package, creates a test certificate, adds the
:: certificate to the corresponding certificate stores, signs the catalog file
:: and verifies it.
::
::  (c) Copyright 2016-2017 Artyom Protaskin <a.protaskin@gmail.com>
::
:: Licensed under GNU General Public License version 2 (see LICENSE file).

@echo off

:: Checking if the user has administrator privileges
:: See http://stackoverflow.com/a/11995662 for more information

echo Administrator privileges are required. Detecting privileges...

net session >nul 2>&1
if %errorLevel% == 0 (
    echo Success: Administrator privileges are confirmed.
) else (
    echo Error: The available privileges are not adequate for the current operation.
    goto end
)


set DriverDir=%~dp0
set DriverDir=%DriverDir:~0,-1%
set CatFilePath=%DriverDir%\lowcdc.cat

:: The name of a test certificate
set CertName=Artyom Protaskin CA

:: Set to 0 if you already have a test certificate added to the corresponding certificate stores
set CreateCert=1

:: The path to the file that will contain a copy of the created test certificate
set CertCopyFilePath=%DriverDir%\certcopy.cer

@echo on

:: Creating a catalog file for the driver package
cd /D %ProgramFiles(x86)%\Windows Kits\10\Bin\x86
Inf2Cat /driver:"%DriverDir%" /os:10_X64

cd ..\x64
if %CreateCert% equ 1 (
    if not exist "%CertCopyFilePath%" (
        :: Creating a test certificate
        MakeCert -r -pe -ss CA -n "CN=%CertName%" "%CertCopyFilePath%"

        :: Adding the test certificate to the Trusted Root CA certificate store
        CertMgr /add "%CertCopyFilePath%" /s /r localMachine root

        :: Adding the test certificate to the Trusted Publishers certificate store 
        CertMgr /add "%CertCopyFilePath%" /s /r localMachine trustedpublisher
    )
)

:: Test-signing the catalog file
SignTool sign /v /s CA /n "%CertName%" /t http://timestamp.verisign.com/scripts/timstamp.dll "%CatFilePath%"

:: Verifying the signature of the test-signed catalog file
SignTool verify /v /pa "%CatFilePath%"

cd /D %DriverDir%

:end
pause
