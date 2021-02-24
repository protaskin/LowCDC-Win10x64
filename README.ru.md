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

0. Скачайте [последний релиз](https://github.com/protaskin/LowCDC-Win10x64/releases) LowCDC-Win10x64 и распакуйте содержимое архива куда-нибудь на вашем компьютере.

1. Найдите драйвер `usbser.sys`, входящий в состав 64-разрядной версии Windows 7. Расположение файла на установочном диске Windows 7 с интегрированным пакетом обновления SP1 `\Sources\install.wim\Windows\System32\DriverStore\FileRepository\mdmcpq.inf_amd64_neutral_fbc4a14a6a13d0c8\usbser.sys`. Номер версии драйвера, которым пользуюсь я — 6.1.7601.17514. Скопируйте файл в директорию с файлами LowCDC-Win10x64 — директорию пакета драйвера — под именем `usbser61.sys`, чтобы избежать возможной замены встроенного драйвера Windows 10.

2. Установите [Windows 10 SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk/) и [Windows Driver Kit (WDK)](https://docs.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk) с одним номером версии. Убедитесь, что утилита `Inf2Cat.exe` присутствует в директории `\Program Files (x86)\Windows Kits\10\Bin\%Version%\x86`, а утилиты `MakeCert.exe`, `CertMgr.exe`, `SignTool.exe` — в директории `\Program Files (x86)\Windows Kits\10\Bin\%Version%\x64`. Обратите внимание, что более ранние установки наборов средств разработки не включали номер версии в пути к исполняемым файлам утилит.

   Существует метод, проверенный с версией 10.0.19041.685 Windows 10 SDK и WDK, который позволяет установить в основном необходимое ПО. Выберите загрузку для установки на другом компьютере вместо установки наборов средств разработки. По завершении загрузки запустите `Windows SDK for Windows Store Apps Tools-x86_en-us.msi`, `Windows SDK Signing Tools-x86_en-us.msi` и `Windows Driver Kit Binaries-x86_en-us.msi` из директорий `Installers`.

3. [Включите опцию запуска TESTSIGNING](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/the-testsigning-boot-configuration-option), перезагрузите компьютер. В правом нижнем углу должен отображаться водяной знак, включающий в себя надпись Test Mode, номера версии и сборки Windows. **Будьте осторожны, используя компьютер в режиме Test Mode: Windows загрузит драйверы, подписанные любым сертификатом.**

4. [Создайте каталог для пакета драйвера](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/creating-a-catalog-file-for-a-pnp-driver-package).

5. [Создайте сертификат](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/creating-test-certificates).

6. [Установите его в соответствующие хранилища сертификатов](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/using-certmgr-to-install-test-certificates-on-a-test-computer).

7. [Подпишите каталог пакета драйвера](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/test-signing-a-driver-package-s-catalog-file).

## Использование createcat.bat

Для автоматизации шагов с 4-го по 7-й включительно создан пакетный файл createcat.bat.

createcat.bat не требует какой-либо настройки и готов к использованию. Вы можете изменить имя сертификата (переменная `CertName`), а также использовать уже установленный сертификат (измените имя сертификата и установите переменную `CreateCert=0`).

1. Запустите `createcat.bat` с правами администратора (необязательно запускать из командной строки).

2. Введите номер версии Windows 10 SDK и WDK, если он включен в путь к исполняемым файлам утилит.

3. Изучите вывод. Ниже приведен результат успешного выполнения.

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
