# LowCDC-Win10x64

This repo aims to provide instructions on how to create a lowcdc.sys driver package for the 64-bit version of Windows 10 and contains almost everything needed (except for the usbser.sys driver because of the limitations of Microsoft Software License Terms) to accomplish this.

The lowcdc.sys driver is developed by Osamu Tamura and published unchanged. The source code is available on [the author's site](#credits).

The following devices are supported:

- AVR-CDC (`USB\VID_16C0&PID_05E1`),

- Digispark (`USB\VID_16D0&PID_087E`).

The master branch can be broken, use tags/releases in order to obtain stable releases.

## Why do existing lowcdc.sys driver packages not install/work on Windows 10?

- The lowcdc.inf installation script does not contain necessary sections (SourceDisksNames, SourceDisksFiles), the driver package does not contain a signed catalog file.

- **[usbser.sys has been completely re-written in Windows 10](https://techcommunity.microsoft.com/t5/microsoft-usb-blog/what-is-new-with-serial-in-windows-10/ba-p/270855) and cannot be used with the current version of the lowcdc.sys.**

- [Beginning with the release of Windows 10, all new Windows 10 kernel mode drivers must be submitted to and digitally signed by the Windows Hardware Developer Center Dashboard portal](https://techcommunity.microsoft.com/t5/windows-hardware-certification/driver-signing-changes-in-windows-10/ba-p/364859).

## Getting Windows and a driver package ready

0. Download [the latest release](https://github.com/protaskin/LowCDC-Win10x64/releases) of LowCDC-Win10x64 and extract the contents somewhere on your computer.

1. Find `usbser.sys` included in the 64-bit version of Windows 7. The file is located in the `\Sources\install.wim\Windows\System32\DriverStore\FileRepository\mdmcpq.inf_amd64_neutral_fbc4a14a6a13d0c8` directory on the installation disk of Windows 7 with integrated SP1. The version number of the driver I use is 6.1.7601.17514. Copy the file to the directory with the LowCDC-Win10x64 files in it—your driver package directory—and rename it to `usbser61.sys` to avoid possible replacement of the Windows 10 in-box driver.

2. Install [Windows 10 SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk/) and [Windows Driver Kit (WDK)](https://docs.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk) with the same version number. Make sure that the `Inf2Cat.exe` tool is located in the `\Program Files (x86)\Windows Kits\10\Bin\%Version%\x86` directory, the `MakeCert.exe`, `CertMgr.exe`, `SignTool.exe` tools are located in the `\Program Files (x86)\Windows Kits\10\Bin\%Version%\x64` directory. Note that earlier installations of the kits did not include a version number in the path to the tools executables.

   There is also a workaround, which has been tested with the 10.0.19041.685 version of Windows 10 SDK and WDK, to install mostly necessary software. Choose to download the kits for installation on a separate computer instead of installing them. When the download is complete, run `Windows SDK for Windows Store Apps Tools-x86_en-us.msi`, `Windows SDK Signing Tools-x86_en-us.msi` and `Windows Driver Kit Binaries-x86_en-us.msi` from the `Installers` directories.

3. [Enable the TESTSIGNING boot configuration option](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/the-testsigning-boot-configuration-option), restart the computer for the change to take effect. When the option for test-signing is enabled, Windows displays a watermark with the text "Test Mode", the version and build numbers of Windows in the lower right-hand corner of the desktop. **Be aware using Windows with the TESTSIGNING boot configuration option, Windows will load drivers that are signed by any certificate.**

4. [Create a catalog file for the driver package](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/creating-a-catalog-file-for-a-pnp-driver-package).

5. [Create a MakeCert test certificate](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/creating-test-certificates).

6. [Install the test certificate to corresponding certificate stores](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/using-certmgr-to-install-test-certificates-on-a-test-computer).

7. [Test-sign the driver package's catalog file](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/test-signing-a-driver-package-s-catalog-file).

8. Delete the private key associated with the test certificate (optional). **Because the test certificate has been added to the Trusted Root CA and Trusted Publishers certificate stores, you must destroy the private key, so that it cannot be reused by an attacker to sign malicious applications.**

## Using createcat.bat

createcat.bat is a batch file that generates a test-signed catalog file for the driver package (performs the steps 4 through 8, inclusive, from the list above).

The batch file does not need any configuration and is ready for use. However you can change the name of a certificate (the `CertName` variable) or use an installed certificate (change the `CertName` variable, set `CreateCert=0`).

1. Run `createcat.bat` with the administrative permissions (it is not necessary to run the batch file in the command prompt).

2. Enter the Windows 10 SDK and WDK version number if included in the path to the tools executables.

3. Examine the output. The text below is the result of a successful execution.

<pre>
D:\LowCDC-Win10x64>createcat.bat
Administrator privileges are required. Detecting privileges...
Success: Administrator privileges are confirmed.

D:\LowCDC-Win10x64>dir "C:\Program Files (x86)\Windows Kits\10\Bin" /A:D
 Volume in drive C is Windows
 Volume Serial Number is FA25-3D99

 Directory of C:\Program Files (x86)\Windows Kits\10\Bin

2021-02-11  01:47    <DIR>          .
2021-02-11  01:47    <DIR>          ..
2021-02-11  01:47    <DIR>          10.0.14393.0
2021-02-11  01:47    <DIR>          10.0.15063.0
2021-02-11  01:47    <DIR>          10.0.16299.0
2021-02-11  01:47    <DIR>          10.0.17134.0
2021-02-11  01:47    <DIR>          10.0.19041.0
2021-02-11  01:47    <DIR>          arm
2021-02-11  01:47    <DIR>          arm64
2021-02-11  01:47    <DIR>          x64
2021-02-11  01:47    <DIR>          x86
               0 File(s)              0 bytes
              11 Dir(s)  14 986 432 512 bytes free

Enter the Windows 10 SDK and WDK version number if included in the path to the tools executables: 10.0.19041.0

D:\LowCDC-Win10x64>cd /D C:\Program Files (x86)\Windows Kits\10\Bin\10.0.19041.0\x86

C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x86>Inf2Cat /driver:"D:\LowCDC-Win10x64" /os:10_X64
.................................
Signability test complete.

Errors:
None

Warnings:
None

<b>Catalog generation complete.
D:\LowCDC-Win10x64\lowcdc.cat</b>

C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x86>cd ..\x64

C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64>if 1 == 1 (if not exist "D:\LowCDC-Win10x64\certcopy.cer" (
MakeCert -r -pe -ss CA -n "CN=createcat.bat autogenerated certificate" "D:\LowCDC-Win10x64\certcopy.cer"
 CertMgr /add "D:\LowCDC-Win10x64\certcopy.cer" /s /r localMachine root
 CertMgr /add "D:\LowCDC-Win10x64\certcopy.cer" /s /r localMachine trustedpublisher
) )
<b>Succeeded</b>
<b>CertMgr Succeeded</b>
<b>CertMgr Succeeded</b>

C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64>SignTool sign /v /s CA /n "createcat.bat autogenerated certificate" /t http://timestamp.digicert.com "D:\LowCDC-Win10x64\lowcdc.cat"
The following certificate was selected:
    Issued to: createcat.bat autogenerated certificate
    Issued by: createcat.bat autogenerated certificate
    Expires:   Sun Jan 01 02:59:59 2040
    SHA1 hash: B0D99616534AE8E6E89CEDABFE9E5B78F774D9A3

Done Adding Additional Store
<b>Successfully signed: D:\LowCDC-Win10x64\lowcdc.cat</b>

Number of files successfully Signed: 1
Number of warnings: 0
Number of errors: 0

C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64>SignTool verify /v /pa "D:\LowCDC-Win10x64\lowcdc.cat"

Verifying: D:\LowCDC-Win10x64\lowcdc.cat

Signature Index: 0 (Primary Signature)
Hash of file (sha1): 65BEB670DE4C9F3B8A5ADF34B232631DBD0D8E8B

Signing Certificate Chain:
    Issued to: createcat.bat autogenerated certificate
    Issued by: createcat.bat autogenerated certificate
    Expires:   Sun Jan 01 02:59:59 2040
    SHA1 hash: B0D99616534AE8E6E89CEDABFE9E5B78F774D9A3

The signature is timestamped: Sat Feb 13 14:41:49 2021
Timestamp Verified by:
    Issued to: DigiCert Assured ID Root CA
    Issued by: DigiCert Assured ID Root CA
    Expires:   Mon Nov 10 03:00:00 2031
    SHA1 hash: 0563B8630D62D75ABBC8AB1E4BDFB5A899B24D43

        Issued to: DigiCert SHA2 Assured ID Timestamping CA
        Issued by: DigiCert Assured ID Root CA
        Expires:   Tue Jan 07 15:00:00 2031
        SHA1 hash: 3BA63A6E4841355772DEBEF9CDCF4D5AF353A297

            Issued to: DigiCert Timestamp 2021
            Issued by: DigiCert SHA2 Assured ID Timestamping CA
            Expires:   Mon Jan 06 03:00:00 2031
            SHA1 hash: E1D782A8E191BEEF6BCA1691B5AAB494A6249BF3


<b>Successfully verified: D:\LowCDC-Win10x64\lowcdc.cat</b>

Number of files successfully Verified: 1
Number of warnings: 0
Number of errors: 0

C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64>cd /D D:\LowCDC-Win10x64
Press any key to continue . . .
</pre>

createcat.bat generates the test-signed catalog file `lowcdc.cat` and creates the `certcopy.cer` file that contains a copy of the certificate.

## Troubleshooting

### Error 0x800B0101

```
SignTool Error: WinVerifyTrust returned error: 0x800B0101
        A required certificate is not within its validity period when verifying against the current system clock or the timestamp in the signed file.
```

Open `lowcdc.cat`, compare the singing time of the catalog file and the value of the certificate's 'valid from'. Adjust the system clock. Run `createcat.bat` again.

## Screenshots

The installed driver in Device Manager.

![Device Manager](http://artyom.protaskin.ru/storage/lowcdc-win10x64/pictures/device-manager-screenshot-v1016.png)

Communication with the MicroProg programmer.

![The MicroProg programmer](http://artyom.protaskin.ru/storage/lowcdc-win10x64/pictures/microprog-screenshot.png)

[Communication with the STK500 compatible programmer](https://github.com/protaskin/LowCDC-Win10x64/issues/1#issuecomment-261777640).

![The AVPISP programmer](http://artyom.protaskin.ru/storage/lowcdc-win10x64/pictures/avrisp-screenshot.png)

## Credits

lowcdc.sys is developed by [Osamu Tamura](http://www.recursion.jp/prose/avrcdc/).
