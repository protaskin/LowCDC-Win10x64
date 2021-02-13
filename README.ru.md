# LowCDC-Win10x64

Этот репозиторий стремится предоставить инструкции о том, как создать пакет драйвера lowcdc.sys для 64-разрядной версии Windows 10, и содержит почти все необходимое (за исключением драйвера usbser.sys из-за ограничений лицензионного соглашения Windows 7) для достижения этого.

Драйвер lowcdc.sys разработан Osamu Tamura и публикуется без изменений. Исходные коды доступны на [сайте автора](#сведения-об-авторах).

Поддерживаются следующие устройства:

- AVR-CDC (`USB\VID_16C0&PID_05E1`),

- Digispark (`USB\VID_16D0&PID_087E`).

Используйте теги (tags/releases) для получения стабильных выпусков.

## Почему существующие пакеты драйвера lowcdc.sys не устанавливаются/работают на Windows 10?

- Инсталляционный скрипт lowcdc.inf не содержит необходимых секций (SourceDisksNames, SourceDisksFiles), отсутствует подписанный каталог пакета драйвера (.cat-файл).

- [В Windows 10 драйвер последовательного интерфейса через USB — usbser.sys — был переписан](https://techcommunity.microsoft.com/t5/microsoft-usb-blog/what-is-new-with-serial-in-windows-10/ba-p/270855), что привело к невозможности его совместного использования с lowcdc.sys.

- [Начиная с Windows 10 можно использовать только драйверы, подписанные сертификатом с расширенной проверкой (EV), прошедшие проверку Hardware Certification Kit, а затем подписанные в Windows Hardware Dev Center Dashboard](https://techcommunity.microsoft.com/t5/windows-hardware-certification/driver-signing-changes-in-windows-10/ba-p/364859).

## Подготовка ОС и пакета драйвера к установке

1. Найдите драйвер `usbser.sys`, входящий в состав 64-разрядной версии Windows 7. Расположение файла на установочном диске Windows 7 с интегрированным пакетом обновления SP1 `\Sources\install.wim\Windows\System32\DriverStore\FileRepository\mdmcpq.inf_amd64_neutral_fbc4a14a6a13d0c8\usbser.sys`. Номер версии драйвера, которым пользуюсь я — 6.1.7601.17514. Скопируйте файл в директорию пакета драйвера под именем `usbser61.sys`, чтобы избежать замены драйвера Windows 10.

2. Установите [Windows 10 SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk/) и [Windows Driver Kit (WDK)](https://docs.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk) с одним номером версии. Убедитесь, что утилита `Inf2Cat.exe` присутствует в директории `\Program Files (x86)\Windows Kits\10\Bin\%Version%\x86`, а утилиты `MakeCert.exe`, `CertMgr.exe`, `SignTool.exe` — в директории `\Program Files (x86)\Windows Kits\10\Bin\%Version%\x64`. Обратите внимание, что более ранние установки наборов средств разработки не включали номер версии в пути к исполняемым файлам утилит.

   Существует метод, проверенный с версией 10.0.19041.685 Windows 10 SDK и WDK, который позволяет установить в основном необходимое ПО. Выберите загрузку для установки на другом компьютере вместо установки наборов средств разработки. По завершении загрузки запустите `Windows SDK for Windows Store Apps Tools-x86_en-us.msi`, `Windows SDK Signing Tools-x86_en-us.msi` и `Windows Driver Kit Binaries-x86_en-us.msi` из директорий `Installers`.

3. [Включите опцию запуска TESTSIGNING](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/the-testsigning-boot-configuration-option), перезагрузите компьютер. В правом нижнем углу должен отображаться водяной знак, включающий в себя надпись Test Mode, номера версии и сборки Windows. **Будьте осторожны, используя компьютер в режиме Test Mode: загрузчик ОС и ядро загрузят драйверы, подписанные любым сертификатом.**

4. [Создайте каталог для пакета драйвера](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/creating-a-catalog-file-for-a-pnp-driver-package).

5. [Создайте сертификат](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/creating-test-certificates), [установите его в соответствующие хранилища сертификатов](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/using-certmgr-to-install-test-certificates-on-a-test-computer), [подпишите каталог пакета драйвера](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/test-signing-a-driver-package-s-catalog-file).

## Использование createcat.bat

Для автоматизации шагов 4-5 создан пакетный файл createcat.bat.

createcat.bat не требует какой-либо настройки и готов к использованию. Вы можете изменить имя сертификата (переменная `CertName`), а также использовать уже установленный сертификат (измените имя сертификата и установите переменную `CreateCert=0`).

1. Запустите `createcat.bat` с правами администратора (необязательно запускать из командной строки).

2. Введите номер версии Windows 10 SDK и WDK, если он включен в путь к исполняемым файлам утилит.

3. Изучите вывод. Ниже приведен результат успешного выполнения (слегка устаревший).

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
MakeCert -r -pe -ss CA -n "CN=createcat.bat autogenerated certificate" "D:\LowCDC-Win10x64\certcopy.cer"
 CertMgr /add "D:\LowCDC-Win10x64\certcopy.cer" /s /r localMachine root
 CertMgr /add "D:\LowCDC-Win10x64\certcopy.cer" /s /r localMachine trustedpublisher
) )
<b>Succeeded</b>
<b>CertMgr Succeeded</b>
<b>CertMgr Succeeded</b>

C:\Program Files (x86)\Windows Kits\10\bin\x64>SignTool sign /v /s CA /n "createcat.bat autogenerated certificate" /t http://timestamp.verisign.com/scripts/timstamp.dll "D:\LowCDC-Win10x64\lowcdc.cat"
The following certificate was selected:
    Issued to: createcat.bat autogenerated certificate
    Issued by: createcat.bat autogenerated certificate
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
    Issued to: createcat.bat autogenerated certificate
    Issued by: createcat.bat autogenerated certificate
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

После выполнения пакетного файла в директории пакета драйвера появятся подписанный каталог пакета драйвера `lowcdc.cat` и копия созданного сертификата `certcopy.cer`.

## Устранение проблем

### Ошибка 0x800B0101

Завершение проверки каталога пакета драйвера ошибкой `0x800B0101` означает, что время создания сертификата (системное время компьютера) опережает время подписи (полученное с удаленного сервера).

```
SignTool Error: WinVerifyTrust returned error: 0x800B0101
        A required certificate is not within its validity period when verifying against the current system clock or the timestamp in the signed file.
```

Откройте `lowcdc.cat`, сравните время создания сертификата и время подписи. Устраните несоответствие, изменив системные настройки даты и времени. Запустите `createcat.bat` повторно (внимание, не удаляйте копию сертификата, она используется как индикатор повторного запуска, или установите `CreateCert=0`).

## Скриншоты

Информация об установленном драйвере в диспетчере устройств Windows.

![Диспетчер устройств](http://artyom.protaskin.ru/storage/lowcdc-win10x64/pictures/device-manager-screenshot-v1016.png)

Проверка работы драйвера на примере программатора MicroProg.

![Программатор MicroProg](http://artyom.protaskin.ru/storage/lowcdc-win10x64/pictures/microprog-screenshot.png)

Проверка работы драйвера на [STK500-совместимом программаторе и AVRISP](https://github.com/protaskin/LowCDC-Win10x64/issues/1#issuecomment-261777640).

![Программатор AVRISP](http://artyom.protaskin.ru/storage/lowcdc-win10x64/pictures/avrisp-screenshot.png)

## Сведения об авторах

Драйвер lowcdc.sys разработан [Osamu Tamura](http://www.recursion.jp/prose/avrcdc/).
