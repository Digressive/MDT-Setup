# MDT-Setup

## User configurable MDT setup script

For full change log and more information, [visit my site.](https://gal.vin/utils/mdt-setup/)

MDT-Setup is available from:

* [GitHub](https://github.com/Digressive/MDT-Setup)
* [The Microsoft PowerShell Gallery](https://www.powershellgallery.com/packages/MDT-Setup)

Please consider supporting my work:

* Sign up using [Patreon](https://www.patreon.com/mikegalvin).
* Support with a one-time donation using [PayPal](https://www.paypal.me/digressive).

Please report any problems via the ‘issues’ tab on GitHub.

-Mike

## Features and Requirements

* Designed to be run on Windows Server 2016+
* The script must be run as an administrator.
* Tested with Windows PowerShell 5 (The version of PowerShell included with Windows Server 2022) and PowerShell 7.
* Tested on Windows Server 2022.

## Usage Information

This script will install and configure Microsoft Deployment Toolkit and its prerequisites on a Windows computer with an internet connection. It has been tested on a basic Windows Server 2022 Standard edition virtual machine.

Here is what the script will do:

1. Download the installers for Microsoft Deployment Toolkit, the latest MDT patch, the latest ADK and WinPE for ADK.
2. Silently install all the above.
3. Create an MDT deployment share for OS builds and the folder structure.
4. Download Windows 10/11 from the Media Creation Tool (this requires some user input).
5. Convert the Windows 10/11 install ESD to a WIM file for MDT and import it.
6. Create Package folders and Selection Profiles for Windows 10/11.
7. Import a Task Sequence template and create a build and capture Windows 10/11 Task Sequence.
8. Set the configuration of CustomSettings.ini for the "Build" share.
9. Do some final configuration of the MDT "Build" share and generate the boot media.
10. Create an MDT deployment share for the deployment of captured OS images and the folder structure.
11. Create Package and Driver folders and Selection Profiles for captured images.
12. Import a Task Sequence template for future deployments. This template has the "total control" driver configuration already baked in.
13. Set the configuration of CustomSettings.ini for the "Deploy" share.
14. Do some final configuration of the MDT "Deploy" share and generate the boot media.

When complete the server will be configured to "build and capture" a Windows 10/11 image. Once captured a user can then import the image into the Deployment share and create a Task Sequence using the template included.

Some user interaction is still required. For example: importing drivers, adding applications to the build and capture task sequence and other things specific to the images you want to make.

## User Preferences

When you run the script it will ask you a series of questions to customise your installation.

* Windows version and update code (eg. W10-22H2)
* Download and convert Windows ESD, edition, language
* Build share path (eg. C:\BuildShare)
* Build share name (eg. BuildShare$)
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

## Example

``` txt
[path\]MDT-Setup.ps1
```

This will run the script, user interaction is required to continue.

## Change Log

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
