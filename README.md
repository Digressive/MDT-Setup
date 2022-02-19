# MDT-Setup

This script will install and configure Microsoft Deployment Toolkit and its prerequisites on a Windows computer with an internet connection. It has been tested on a basic Windows Server 2022 Standard edition virtual machine.

Here is what the script will do:

1. Download the installers for Microsoft Deployment Toolkit, the latest MDT patch, and the latest ADK and WinPE for ADK.
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
12. Import a Task Sequence template for future deployments. This template has the "total control" driver configuration already "baked in".
13. Set the configuration of CustomSettings.ini for the "Deploy" share.
14. Do some final configuration of the MDT "Deploy" share and generate the boot media.

The server is now configured to "build and capture" a Windows 10 image. Once captured a user can then import the image into the Deployment share and create a Task Sequence using the template included.
Some user interaction is still required. For example: importing drivers, adding applications to the build and capture task sequence and other things specific to the images you want to make.

## User Preferences

At the top of the script are several variables that can be configured by the user to customise the MDT setup for their environment. If left as they are the script should run just fine.

## Support

For full change log and more information, [visit my site.](https://gal.vin/utils/i-haven't-done-this-yet)

Please consider supporting my work:

* Sign up [using Patreon.](https://www.patreon.com/mikegalvin)
* Support with a one-time payment [using PayPal.](https://www.paypal.me/digressive)

Join the [Discord](http://discord.gg/5ZsnJ5k) or Tweet me if you have questions: [@mikegalvin_](https://twitter.com/mikegalvin_)

-Mike
