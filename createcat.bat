:: createcat.bat is a batch file that automatically creates a catalog file for
:: the lowcdc.sys driver package, creates a test certificate, adds the
:: certificate to the corresponding certificate stores, signs the catalog file
:: and verifies it.
::
::  (c) Copyright 2016-2021 Artyom Protaskin <a.protaskin@gmail.com>
::
:: Licensed under GNU General Public License version 2 (see LICENSE file).

@echo off
setlocal EnableDelayedExpansion

set ErrorScheme=[97m[41m
set NormalScheme=[0m

:: Checking if the user has administrator privileges
:: See http://stackoverflow.com/a/11995662 for more information

echo Administrator privileges are required. Detecting privileges...

net session >nul 2>&1
if %ErrorLevel% == 0 (
    echo Success: Administrator privileges are confirmed.
) else (
    echo %ErrorScheme%Error: The available privileges are not adequate for the current operation.%NormalScheme%
    goto end
)


:: Appending a version number if entered
set KitsBinDir=%ProgramFiles(x86)%\Windows Kits\10\Bin

echo on
dir "%KitsBinDir%" /A:D
@echo off
echo.

set /p Version=Enter the Windows 10 SDK and WDK version number if included in the path to the tools executables: || set "Version="
if not "%Version%" == "" (
    set "KitsBinDir=%KitsBinDir%\%Version%"
    if not exist !KitsBinDir! (
        echo %ErrorScheme%Error: The directory !KitsBinDir! does not exist.%NormalScheme%
        goto end
    )
)


set DriverDir=%~dp0
set DriverDir=%DriverDir:~0,-1%
set CatFilePath=%DriverDir%\lowcdc.cat

:: The name of a test certificate
set CertName=createcat.bat autogenerated certificate

:: Set to 0 if you already have a test certificate added to the corresponding certificate stores
set CreateCert=1

:: The path to the file that will contain a copy of the created test certificate
set CertCopyFilePath=%DriverDir%\certcopy.cer

echo on

:: Creating a catalog file for the driver package
cd /D %KitsBinDir%\x86
Inf2Cat /driver:"%DriverDir%" /os:10_X64

cd ..\x64
if %CreateCert% == 1 (
    if not exist "%CertCopyFilePath%" (
        :: Creating a test certificate
        MakeCert -r -pe -ss CA -n "CN=%CertName%" -eku 1.3.6.1.5.5.7.3.3 "%CertCopyFilePath%"

        :: Adding the test certificate to the Trusted Root CA certificate store
        CertMgr /add "%CertCopyFilePath%" /s /r localMachine root

        :: Adding the test certificate to the Trusted Publishers certificate store
        CertMgr /add "%CertCopyFilePath%" /s /r localMachine trustedpublisher
    )
)

:: Test-signing the catalog file
SignTool sign /v /s CA /n "%CertName%" /t http://timestamp.digicert.com "%CatFilePath%"

:: Verifying the signature of the test-signed catalog file
SignTool verify /v /pa "%CatFilePath%"

cd /D %DriverDir%

:end
@pause
