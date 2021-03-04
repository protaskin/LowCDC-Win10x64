# LowCDC-Win10x64

Этот репозиторий стремится предоставить инструкции о том, как создать пакет драйвера lowcdc.sys для 64-разрядной версии Windows 10, и содержит почти все необходимое (за исключением драйвера usbser.sys из-за ограничений лицензионного соглашения Windows 7) для достижения этого.

Драйвер lowcdc.sys разработан Osamu Tamura и публикуется без изменений. Исходные коды доступны на [сайте автора](#сведения-об-авторах).

Поддерживаются следующие устройства:

Устройство | ИД оборудования
---------- | -----------------------
AVR-CDC    | `USB\VID_16C0&PID_05E1`
Digispark  | `USB\VID_16D0&PID_087E`

Используйте теги (tags/releases) для получения стабильных выпусков.

## Проблемы с существующими пакетами драйвера lowcdc.sys на Windows 10

- В состав некоторых пакетов драйвера не входит подписанный каталог (.cat-файл). Файл lowcdc.inf может не содержать необходимых секций, таких как SourceDisksNames и SourceDisksFiles.

- [В Windows 10 драйвер последовательного интерфейса через USB — usbser.sys — был переписан](https://techcommunity.microsoft.com/t5/microsoft-usb-blog/what-is-new-with-serial-in-windows-10/ba-p/270855), что привело к невозможности его совместного использования с lowcdc.sys.

- [Начиная с Windows 10 можно использовать только драйверы, подписанные сертификатом с расширенной проверкой (EV), прошедшие проверку Hardware Certification Kit, а затем подписанные в Windows Hardware Dev Center Dashboard](https://techcommunity.microsoft.com/t5/windows-hardware-certification/driver-signing-changes-in-windows-10/ba-p/364859).

## Использование LowCDC-Win10x64

### Подготовка и подпись пакета драйвера

1. Скачайте [последний релиз](https://github.com/protaskin/LowCDC-Win10x64/releases) LowCDC-Win10x64 и распакуйте содержимое архива куда-нибудь на вашем компьютере.

2. Найдите драйвер `usbser.sys`, входящий в состав 64-разрядной версии Windows 7. Расположение файла на установочном диске Windows 7 с интегрированным пакетом обновления SP1 `\Sources\install.wim\Windows\System32\DriverStore\FileRepository\mdmcpq.inf_amd64_neutral_fbc4a14a6a13d0c8\usbser.sys`. Номер версии драйвера, которым пользуюсь я — 6.1.7601.17514. Скопируйте файл в директорию с файлами LowCDC-Win10x64 — директорию пакета драйвера — под именем `usbser61.sys`, чтобы избежать возможной замены встроенного драйвера Windows 10.

3. Установите [Windows 10 SDK](https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk/) и [Windows Driver Kit (WDK)](https://docs.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk) с одним номером версии. Убедитесь, что утилита `Inf2Cat.exe` присутствует в директории `\Program Files (x86)\Windows Kits\10\Bin\%Version%\x86`, а утилиты `MakeCert.exe`, `CertMgr.exe`, `SignTool.exe` — в директории `\Program Files (x86)\Windows Kits\10\Bin\%Version%\x64`. Обратите внимание, что более ранние установки наборов средств разработки не включали номер версии в пути к исполняемым файлам утилит.

   Существует метод, проверенный с версией 10.0.19041.685 Windows 10 SDK и WDK, который позволяет установить в основном необходимое ПО. Выберите загрузку для установки на другом компьютере вместо установки наборов средств разработки. По завершении загрузки запустите `Windows SDK for Windows Store Apps Tools-x86_en-us.msi`, `Windows SDK Signing Tools-x86_en-us.msi` и `Windows Driver Kit Binaries-x86_en-us.msi` из директорий `Installers`.

4. [Создайте каталог для пакета драйвера](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/creating-a-catalog-file-for-a-pnp-driver-package).

5. [Создайте тестовый сертификат](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/creating-test-certificates).

6. [Установите тестовый сертификат в хранилища сертификатов «Доверенные корневые центры сертификации» и «Доверенные издатели» локального компьютера](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/using-certmgr-to-install-test-certificates-on-a-test-computer).

7. [Подпишите каталог пакета драйвера](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/test-signing-a-driver-package-s-catalog-file).

8. Удалите закрытый ключ, связанный с тестовым сертификатом (опционально). **Поскольку тестовый сертификат был добавлен в хранилища сертификатов «Доверенные корневые центры сертификации» и «Доверенные издатели», необходимо уничтожить закрытый ключ, чтобы злоумышленник не мог использовать его для подписи вредоносных приложений.**

### Использование подписанного пакета драйвера

1. [Включите опцию запуска TESTSIGNING](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/the-testsigning-boot-configuration-option), перезагрузите компьютер. В правом нижнем углу должен отображаться водяной знак, включающий в себя надпись Test Mode, номера версии и сборки Windows. **Будьте осторожны, используя компьютер в режиме Test Mode: Windows загрузит драйверы, подписанные любым сертификатом.**

2. Для использования подписанного пакета драйвера на другом компьютере, [установите тестовый сертификат в соответствующие хранилища сертификатов](https://docs.microsoft.com/en-us/windows-hardware/drivers/install/installing-a-test-certificate-on-a-test-computer) с помощью Мастера импорта сертификатов или утилиты CertMgr.

3. Установите пакет драйвера.

## Использование createcat.bat

Пакетный файл createcat.bat предназначен для создания подписанного каталога для пакета драйвера LowCDC-Win10x64, т.е. для выполнения шагов с 4-го по 8-й включительно из секции [Подготовка и подпись пакета драйвера](#подготовка-и-подпись-пакета-драйвера).

createcat.bat не требует какой-либо настройки и готов к использованию. Вы можете изменить имя сертификата (переменная `CertName`), а также использовать уже установленный сертификат (измените имя сертификата и установите переменную `CreateCert=0`).

1. Запустите `createcat.bat` с правами администратора (необязательно запускать из командной строки).

2. Введите номер версии Windows 10 SDK и WDK, если он включен в путь к исполняемым файлам утилит.

3. Изучите вывод. Ниже приведен результат успешного выполнения.

<pre>
D:\LowCDC-Win10x64>createcat.bat
Administrator privileges are required. Detecting privileges...
Success: Administrator privileges are confirmed.

D:\LowCDC-Win10x64>dir "C:\Program Files (x86)\Windows Kits\10\Bin" /a:d
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

D:\LowCDC-Win10x64>cd /d C:\Program Files (x86)\Windows Kits\10\Bin\10.0.19041.0\x86

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

C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64>if 1 == 1 (
MakeCert -r -pe -ss My -n "CN=createcat.bat autogenerated certificate" -sk "createcat.bat autogenerated certificate" -eku 1.3.6.1.5.5.7.3.3 "D:\LowCDC-Win10x64\certcopy.cer"
 CertMgr -add "D:\LowCDC-Win10x64\certcopy.cer" -s -r LocalMachine Root
 CertMgr -add "D:\LowCDC-Win10x64\certcopy.cer" -s -r LocalMachine TrustedPublisher
)
<b>Succeeded
CertMgr Succeeded
CertMgr Succeeded</b>

C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64>SignTool sign /v /s My /n "createcat.bat autogenerated certificate" /t http://timestamp.digicert.com "D:\LowCDC-Win10x64\lowcdc.cat"
The following certificate was selected:
    Issued to: createcat.bat autogenerated certificate
    Issued by: createcat.bat autogenerated certificate
    Expires:   Sun Jan 01 02:59:59 2040
    SHA1 hash: 2F02FA84A9BC0F51901EE66FEC29CC7CCE7B1AF1

Done Adding Additional Store
<b>Successfully signed: D:\LowCDC-Win10x64\lowcdc.cat</b>

Number of files successfully Signed: 1
Number of warnings: 0
Number of errors: 0

C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64>SignTool verify /v /pa "D:\LowCDC-Win10x64\lowcdc.cat"

Verifying: D:\LowCDC-Win10x64\lowcdc.cat

Signature Index: 0 (Primary Signature)
Hash of file (sha1): F3CFE6C188D35D3F90C588C1CBC239396F770326

Signing Certificate Chain:
    Issued to: createcat.bat autogenerated certificate
    Issued by: createcat.bat autogenerated certificate
    Expires:   Sun Jan 01 02:59:59 2040
    SHA1 hash: 2F02FA84A9BC0F51901EE66FEC29CC7CCE7B1AF1

The signature is timestamped: Tue Mar 02 13:08:43 2021
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

C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64>if 1 == 1 (
CertUtil -user -delkey "createcat.bat autogenerated certificate"
 CertMgr -del -c -n "createcat.bat autogenerated certificate" -s -r CurrentUser My
)
  createcat.bat autogenerated certificate
<b>CertUtil: -delkey command completed successfully.
CertMgr Succeeded</b>

C:\Program Files (x86)\Windows Kits\10\bin\10.0.19041.0\x64>cd /d D:\LowCDC-Win10x64
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

Откройте `lowcdc.cat`, сравните время создания сертификата и время подписи. Устраните несоответствие, изменив системные настройки даты и времени. Запустите `createcat.bat` повторно.

## Скриншоты

Информация об установленном драйвере в диспетчере устройств Windows.

![Диспетчер устройств](http://artyom.protaskin.ru/storage/lowcdc-win10x64/pictures/device-manager-screenshot-v1016.png)

Проверка работы драйвера на примере программатора MicroProg.

![Программатор MicroProg](http://artyom.protaskin.ru/storage/lowcdc-win10x64/pictures/microprog-screenshot.png)

Проверка работы драйвера на [STK500-совместимом программаторе и AVRISP](https://github.com/protaskin/LowCDC-Win10x64/issues/1#issuecomment-261777640).

![Программатор AVRISP](http://artyom.protaskin.ru/storage/lowcdc-win10x64/pictures/avrisp-screenshot.png)

## Сведения об авторах

Драйвер lowcdc.sys разработан [Osamu Tamura @ Recursion Co., Ltd.](http://www.recursion.jp/prose/avrcdc/)

## Лицензия

Авторские права 2016-2021 Артём Протаскин

Этот документ доступен по [лицензии Creative Commons «Attribution» («Атрибуция») 4.0 Всемирная](http://creativecommons.org/licenses/by/4.0/).

[![Лицензия Creative Commons](https://i.creativecommons.org/l/by/4.0/88x31.png)](http://creativecommons.org/licenses/by/4.0/)
