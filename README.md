# MDT-Setup

## User configurable MDT setup script

For full change log and more information, [visit my site.](https://gal.vin/utils/mdt-setup/)

MDT-Setup is available from:

* [GitHub](https://github.com/Digressive/MDT-Setup)
* [The Microsoft PowerShell Gallery](https://www.powershellgallery.com/packages/MDT-Setup)

Please consider supporting my work:

* Support with [Github Sponsors](https://github.com/sponsors/Digressive).
* Support with a one-time donation using [PayPal](https://www.paypal.me/digressive).

Please report any problems via the ‘issues’ tab on GitHub.

-Mike

## Features and Requirements

* Designed to be run on Windows Server 2016+
* The script must be run as an administrator.
* Tested with Windows PowerShell 5 (The version of PowerShell included with Windows Server 2016+) and PowerShell 7.
* Tested on Windows Server 2022.

## Usage Information

This script will install and configure Microsoft Deployment Toolkit and its prerequisites on a Windows computer with an internet connection. It has been tested on a basic Windows Server 2022 Standard edition virtual machine.

Here is what the script will do:

1. Download the installers for Microsoft Deployment Toolkit, the latest MDT patch, the latest ADK and WinPE for ADK.
2. Silently install all the above.
3. Create an MDT deployment share(s) and the folder structure.
4. Download Windows 10/11 from the Media Creation Tool (this requires some user input).
5. Convert the Windows 10/11 install ESD to a WIM file for MDT and import it.
6. Create Package folders and Selection Profiles for Windows 10/11.
7. Import Task Sequence templates.
8. Set the configuration of CustomSettings.ini for the share(s).
9. Generate the boot media.
10. Create Package and Driver folders and Selection Profiles.

When complete the server will be configured to be able to deploy a Windows 10/11 image. There is an option to create a "Build and Capture" environment to create a gold image for Windows 10/11. Once captured the image can then be imported into the Deployment share and create a Task Sequence using the template included.

Some user interaction is still required. For example: importing drivers, adding applications and other things specific to the images you want to deploy.

## User Preferences

When you run the script it will ask you a series of questions to customise your installation.

* Windows version and update code (eg. W10-22H2)
* Download and convert Windows ESD, edition, language
* Optional Build share path (eg. C:\BuildShare)
* Optional Build share name (eg. BuildShare$)
* Deploy share path (eg. C:\DeployShare)
* Deploy share name (eg. DeployShare$)
* Time zone name for the deployed image (eg. GMT Standard Time)
* Keyboard locale code for the deployed image (eg. 0809:00000809) Please see [Microsoft Docs for all the input locales](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs?view=windows-11)
* Keyboard locale name for the deployed image (eg. en-GB)
* Windows UI language for the deployed image (eg. en-GB)
* Windows user language for the deployed image (eg. en-GB)
* Domain group for MDT Admins (eg. mdt-admins)
* Domain user for domain join (eg. djoin)
* Domain password for above user (eg. p@ssw0rD)
* Domain name for above user (eg. contoso.com)
* OU for new PC account (eg. OU=PCs,DC=contoso,DC=com)
* WSUS server name and port (eg. WSUS-Srv:8530)

## How to use

Create a folder on a local disk and put the script inside it.

Run From PowerShell:

``` txt
[path to script]\MDT-Setup.ps1
```

This will run the script, user interaction is required to continue.

## Change Log

### 2023-12-10: Version 23.12.10

* Added a leading '0' to the dates in the names of the 'Logs' and 'DyanamicLogs' inside the deployment shares.

### 2023-12-04: Version 23.12.04

* Added option to create a single deployment share for those who do not want to build a gold image.
* Updated Windows 11 Media Creation Tool link to get version 23H2.

### 2023-08-04: Version 23.08.04

* Fixed an issue with the device path of a mounted ISO file being hardcoded. It is now dynamic.

### 2023-07-02: Version 23.07.02

* The latest version of the Windows ADK and Win PE ADK add-on are now installed. Please note that x86 boot media is now not available due to the new ADK not supporting the architecture.
* Added fixes for the latest version of Windows ADK from: [metisit.com](https://metisit.com/blog/microsoft-deployment-toolkit-mdt-configuration-with-unforeseen-challenges)

### 2023-06-23: Version 23.06.23

* Fixed an issue where the Windows ISO file name was hard coded.
* Reordered the process so all the user interaction is done up front. When user interaction is complete, you will be told to go make coffee.
* Cleaned up the output to be more readable.

### 2022-12-02: Version 22.12.02

* Added text notification when there is no update available.

### 2022-11-29: Version 22.11.29

* Added option to check for updates to the script.
* Fixed permissions not being set on the build and deployment shares.
* Script now asks for a domain group to be used for MDT Administrators.

### 2022-10-18: Version 22.10.18

* Added support for Windows 10 22H2

### 2022-09-20: Version 22.09.20

* Removed option to enter a key to download Windows as it isn't really needed. The provided generic key works just fine.
* Removed option to choose the edition of Windows as it will become the version that the user is licensed for when activation occurs.

### 2022-08-16: Version 22.08.16

* Added support for Windows 11
* Streamlined some locale options so the user isn't prompted so much for the same information.

### 2022-07-26: Version 22.07.26

* Initial release
