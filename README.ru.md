# LowCDC-Win10x64

Данный репозиторий содержит почти все необходимое (за исключением драйвера usbser.sys, на который распространяется действие лицензионного соглашения Windows 7) для установки драйвера lowcdc.sys на 64-битную редакцию Windows 10. Драйвер lowcdc.sys публикуется в неизменном виде, исходные коды доступны на сайте автора.

# Почему драйвер lowcdc.sys не устанавливается на Windows 10?

1. Инсталляционный скрипт lowcdc.inf не содержит необходимых секций (SourceDisksNames, SourceDisksFiles), отсутствует подписанный каталог драйвера (.cat-файл).

2. [В Windows 10 драйвер последовательного интерфейса через USB — usbser.sys — был переписан](http://blogs.msdn.com/b/usbcoreblog/archive/2015/07/29/what-is-new-with-serial-in-windows-10.aspx), что привело к невозможности его совместного использования с lowcdc.sys.

3. [Начиная с Windows 10 можно использовать только драйверы, подписанные сертификатом с расширенной проверкой (EV), прошедшие проверку Hardware Certification Kit, а затем подписанные в Windows Hardware Dev Center Dashboard](http://blogs.msdn.com/b/windows_hardware_certification/archive/2015/04/01/driver-signing-changes-in-windows-10.aspx).

# Подготовка ОС и драйвера к установке

1. Найдите драйвер `usbser.sys`, входящий в состав 64-битной редации Windows 7. Расположение файла на установочном диске Windows 7 с интегрированным пакетом обновления SP1 `\Sources\install.wim\Windows\System32\DriverStore\FileRepository\mdmcpq.inf_amd64_neutral_fbc4a14a6a13d0c8\usbser.sys`. Версия драйвера, которым воспользовался я — 6.1.7610.17514. Скопируйте файл в директорию драйвера под именем `usbser61.sys`, чтобы избежать замены драйвера Windows 10.

2. Установите [Windows Driver Kit (WDK) 10](https://msdn.microsoft.com/en-us/windows/hardware/dn913721.aspx). В веб-установщике выберите загрузку WDK для установки на другом компьютере, в противном случае установленный WDK не будет содержать утилиту Inf2Cat, предназначенную для генерации каталога драйвера (замечание действительно для версии 10.0.10586.0). После завершения загрузки дистрибутива выполните установку. Убедитесь, что необходимая утилита присутствует по адресу `\Program Files (x86)\Windows Kits\10\Bin\x86\inf2cat.exe`.

3. [Включите опцию запуска TESTSIGNING](https://msdn.microsoft.com/en-us/library/windows/hardware/ff553484(v=vs.85).aspx), перезагрузите компьютер. В правом нижнем углу должен отображаться водяной знак, включающий в себя надпись Test Mode, версии Windows и сборки. Будьте осторожны, используя компьютер в режиме Test Mode: загрузчик ОС и ядро загрузят драйверы, подписанные любым сертификатом. 

4. [Создайте каталог драйвера](https://msdn.microsoft.com/en-us/library/windows/hardware/ff540161(v=vs.85).aspx).

5. [Создайте сертификат](https://msdn.microsoft.com/en-us/library/windows/hardware/ff548693(v=vs.85).aspx), [установите его в соответствующие хранилища сертификатов](https://msdn.microsoft.com/en-us/library/windows/hardware/ff553563(v=vs.85).aspx), [подпишите каталог драйвера](https://msdn.microsoft.com/en-us/library/windows/hardware/ff553470(v=vs.85).aspx).

# Использование createcat.bat

Для автоматизации шагов 4-5 создан пакетный файл createcat.bat.

createcat.bat не требует какой-либо настройки и готов к использованию. Вы можете изменить имя сертификата (константа `CertName`), а также использовать уже установленный сертификат (установите константу `CreateCert=0`).

1. Запустите `createcat.bat` из командной строки, запущенной с правами администратора. 

2. Изучите вывод. Ниже приведен результат успешного выполнения.

<pre>
D:\LowCDC-Win10x64>createcat.bat

D:\LowCDC-Win10x64>cd /D C:\Program Files (x86)\Windows Kits\10\Bin\x86

C:\Program Files (x86)\Windows Kits\10\bin\x86>Inf2Cat /driver:"D:\LowCDC-Win10x64" /os:10_X64
.................................
Signability test complete.

Errors:
None

Warnings:
None

<b>Catalog generation complete.
D:\LowCDC-Win10x64\lowcdc.cat</b>

C:\Program Files (x86)\Windows Kits\10\bin\x86>cd ..\x64

C:\Program Files (x86)\Windows Kits\10\bin\x64>if 1 EQU 1 (if not exist "D:\LowCDC-Win10x64\certcopy.cer" (
MakeCert -r -pe -ss CA -n "CN=Artyom Protaskin CA" "D:\LowCDC-Win10x64\certcopy.cer"
 CertMgr /add "D:\LowCDC-Win10x64\certcopy.cer" /s /r localMachine root
 CertMgr /add "D:\LowCDC-Win10x64\certcopy.cer" /s /r localMachine trustedpublisher
) )
<b>Succeeded</b>
<b>CertMgr Succeeded</b>
<b>CertMgr Succeeded</b>

C:\Program Files (x86)\Windows Kits\10\bin\x64>SignTool sign /v /s CA /n "Artyom Protaskin CA" /t http://timestamp.verisign.com/scripts/timstamp.dll "D:\LowCDC-Win10x64\lowcdc.cat"
The following certificate was selected:
    Issued to: Artyom Protaskin CA
    Issued by: Artyom Protaskin CA
    Expires:   Sun Jan 01 02:59:59 2040
    SHA1 hash: 91E7FC5F14E0AEEE3211E438A01DA07BB9959091

Done Adding Additional Store
<b>Successfully signed: D:\LowCDC-Win10x64\lowcdc.cat</b>

Number of files successfully Signed: 1
Number of warnings: 0
Number of errors: 0

C:\Program Files (x86)\Windows Kits\10\bin\x64>SignTool verify /v /pa "D:\LowCDC-Win10x64\lowcdc.cat"

Verifying: D:\LowCDC-Win10x64\lowcdc.cat
Signature Index: 0 (Primary Signature)
Hash of file (sha1): 0CA6677A0F8F5F7E05B8331DC5C662E9B6ABC24C

Signing Certificate Chain:
    Issued to: Artyom Protaskin CA
    Issued by: Artyom Protaskin CA
    Expires:   Sun Jan 01 02:59:59 2040
    SHA1 hash: 91E7FC5F14E0AEEE3211E438A01DA07BB9959091

The signature is timestamped: Sat Jan 16 08:36:20 2016
Timestamp Verified by:
    Issued to: Thawte Timestamping CA
    Issued by: Thawte Timestamping CA
    Expires:   Fri Jan 01 02:59:59 2021
    SHA1 hash: BE36A4562FB2EE05DBB3D32323ADF445084ED656

        Issued to: Symantec Time Stamping Services CA - G2
        Issued by: Thawte Timestamping CA
        Expires:   Thu Dec 31 02:59:59 2020
        SHA1 hash: 6C07453FFDDA08B83707C09B82FB3D15F35336B1

            Issued to: Symantec Time Stamping Services Signer - G4
            Issued by: Symantec Time Stamping Services CA - G2
            Expires:   Wed Dec 30 02:59:59 2020
            SHA1 hash: 65439929B67973EB192D6FF243E6767ADF0834E4


<b>Successfully verified: D:\LowCDC-Win10x64\lowcdc.cat</b>

Number of files successfully Verified: 1
Number of warnings: 0
Number of errors: 0

C:\Program Files (x86)\Windows Kits\10\bin\x64>cd /D D:\LowCDC-Win10x64
</pre>

После выполнения пакетного файла в директории драйвера появятся подписанный каталог драйвера `lowcdc.cat` и копия созданного сертификата `certcopy.cer`.

Завершение проверки каталога драйвера ошибкой `0x800B0101` означает, что время создания сертификата (системное время компьютера) опережает время подписи (полученное с удаленного сервера).

```
SignTool Error: WinVerifyTrust returned error: 0x800B0101
        A required certificate is not within its validity period when verifying against the current system clock or the timestamp in the signed file.
```

Откройте `lowcdc.cat`, сравните время создания сертификата и время подписи. Устраните несоответствие, изменив системные настройки даты и времени. Запустите `createcat.bat` повторно (внимание, не удаляйте копию сертификата, она используется как индикатор повторного запуска, или установите `CreateCert=0`).

# Сведения об авторах

Драйвер lowcdc.sys разработан [Osamu Tamura](http://www.recursion.jp/prose/avrcdc/).