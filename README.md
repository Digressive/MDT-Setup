# MDT-Setup

User configurable MDT setup script

For full change log and more information, [visit my site.](https://gal.vin/utils/mdt-setup/)

MDT-Setup is available from:

* [GitHub](https://github.com/Digressive/MDT-Setup)
* [The Microsoft PowerShell Gallery](https://www.powershellgallery.com/packages/MDT-Setup)

Please consider supporting my work:

* Sign up using [Patreon](https://www.patreon.com/mikegalvin).
* Support with a one-time donation using [PayPal](https://www.paypal.me/digressive).

If you’d like to contact me, please leave a comment, send me a [tweet or DM](https://twitter.com/mikegalvin_), or you can join my [Discord server](https://discord.gg/5ZsnJ5k).

-Mike

## Usage Information

This script will install and configure Microsoft Deployment Toolkit and its prerequisites on a Windows computer with an internet connection. It has been tested on a basic Windows Server 2022 Standard edition virtual machine.

Here is what the script will do:

1. Download the installers for Microsoft Deployment Toolkit, the latest MDT patch, the latest ADK and WinPE for ADK.
2. Silently install all the above.
3. Create an MDT deployment share for OS builds and the folder structure.
4. Download Windows 10 from the Media Creation Tool (this requires some user input).
5. Convert the Windows 10 install ESD to a WIM file for MDT and import it.
6. Create Package folders and Selection Profiles for Windows 10.
7. Import a Task Sequence template and create a build and capture Windows 10 Task Sequence.
8. Set the configuration of CustomSettings.ini for the "Build" share.
9. Do some final configuration of the MDT "Build" share and generate the boot media.
10. Create an MDT deployment share for the deployment of captured OS images and the folder structure.
11. Create Package and Driver folders and Selection Profiles for captured images.
12. Import a Task Sequence template for future deployments. This template has the "total control" driver configuration already baked in.
13. Set the configuration of CustomSettings.ini for the "Deploy" share.
14. Do some final configuration of the MDT "Deploy" share and generate the boot media.

When complete the server will be configured to "build and capture" a Windows 10 image. Once captured a user can then import the image into the Deployment share and create a Task Sequence using the template included.

Some user interaction is still required. For example: importing drivers, adding applications to the build and capture task sequence and other things specific to the images you want to make.

## User Preferences

When you run the script it will ask you a series of questions to customise your installation.

* Windows version and update code (eg. W10-21H2)
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
