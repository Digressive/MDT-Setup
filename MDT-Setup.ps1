<#PSScriptInfo

.VERSION 23.06.23

.GUID fbe115c8-16db-441c-805a-5505f93eb012

.AUTHOR Mike Galvin Contact: mike@gal.vin

.COMPANYNAME Mike Galvin

.COPYRIGHT (C) Mike Galvin. All rights reserved.

.TAGS Microsoft Deployment Toolkit Install

.LICENSEURI

.PROJECTURI https://gal.vin/utils/mdt-setup

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES

#>

<#
    .SYNOPSIS
    Install and configure MDT

    .DESCRIPTION
    Installs and configures MDT on a new domain joined server with an internet connection.
    Fixes added from: https://metisit.com/blog/microsoft-deployment-toolkit-mdt-configuration-with-unforeseen-challenges/
#>

## Set up command line switches.
[CmdletBinding()]
Param(
    [switch]$Help,
    [switch]$UpdateCheck)

    Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "
     __   __  ______   _______         _______  _______  _______  __   __  _______     
    |  |_|  ||      | |       |       |       ||       ||       ||  | |  ||       |    
    |       ||  _    ||_     _| ____  |  _____||    ___||_     _||  | |  ||    _  |    
    |       || | |   |  |   |  |____| | |_____ |   |___   |   |  |  |_|  ||   |_| |    
    |       || |_|   |  |   |         |_____  ||    ___|  |   |  |       ||    ___|    
    | ||_|| ||       |  |   |          _____| ||   |___   |   |  |       ||   |        
    |_|   |_||______|   |___|         |_______||_______|  |___|  |_______||___|        
                                                                                       
            Mike Galvin   https://gal.vin                  Version 23.06.23            
      Donate: https://www.paypal.me/digressive            See -help for usage          
"

If ($UpdateCheck)
{
    $ScriptVersion = "23.06.23"
    $RawSource = "https://raw.githubusercontent.com/Digressive/MDT-Setup/main/MDT-Setup.ps1"
    $SourceCheck = Invoke-RestMethod -uri "$RawSource"
    $VerCheck = Select-String -Pattern ".VERSION $ScriptVersion" -InputObject $SourceCheck
    If ($null -eq $VerCheck)
    {
        Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "There is an update available."
        exit
    }

    else {
        Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "This script is up to date."
        exit
    }
}

If ($Help)
{
    Write-Host -Object "Usage:
    From a terminal run: [path\]MDT-Setup.ps1
    Answer the questions, the default option is capitalized. eg. y/N - no (N) is the default.
    You will need to know the following information:
    * Windows version to deploy
    * Windows language
    * Build share path and name
    * Deploy share path and name
    * Time zone name
    * Keyboard locale code and name
    * Windows UI language
    * Windows user language
    * Domain group for MDT Admins
    * Domain user for domain join
    * Domain password for above user
    * Domain name
    * OU for new PC accounts
    * WSUS server information if you want to use it"
    exit
}

else {
    $Begin = Read-Host -Prompt "Would you like to begin the MDT installation process? (y/N)"
    If ($Begin -eq '')
    {
        $Begin = "n"
    }

    If ($Begin -eq "y")
    {
        ## User Preferences

        $WinCode = Read-Host -Prompt "Enter Windows version and update that you will be deploying. This will be used as a unique identifier for MDT. (default: W10-22H2)"
        If ($WinCode -eq '')
        {
            $WinCode = "W10-22H2" ## Windows version and update
        }

        ## Windows Download Preferences
        ## If you already have your own Windows source files then you should import that to the Build share as an OS
        $ConvertESD = Read-Host -Prompt "Do you want to download and convert the Windows image to a WIM? (y/N)"
        If ($ConvertESD -eq '')
        {
            $ConvertESD = "n" ## Set this to "y" to have the script download Windows and convert the ESD to a WIM for MDT
        }

        If ($ConvertESD -eq "y")
        {
            $WinVer = Read-Host -Prompt "Do you want to deploy Windows 11? (y/N)"
            If ($WinVer -eq '')
            {
                $WinVer = "n"
            }

            $LangCode = Read-Host -Prompt "Enter the language code of the Windows download (default: en-gb)"
            If ($LangCode -eq '')
            {
                $LangCode = "en-gb" ## The language of the Windows to download. Example: en-US
            }
        }

        ## Share names and paths
        $MdtBuildShare = Read-Host -Prompt "Enter the local path of the Build share (default: C:\BuildShare)"
        If ($MdtBuildShare -eq '')
        {
            $MdtBuildShare = "C:\BuildShare" ## Local path of the Build share
        }

        $MdtBuildShareName = Read-Host -Prompt "Enter the share name of the Build share (default: BuildShare$)"
        If ($MdtBuildShareName -eq '')
        {
            $MdtBuildShareName = "BuildShare$" ## Share name of the Build share
        }

        $MdtDepShare = Read-Host -Prompt "Enter the local path of the Deployment share (default: C:\DeployShare)"
        If ($MdtDepShare -eq '')
        {
            $MdtDepShare = "C:\DeployShare" ## Local path of the Deployment share
        }

        $MdtDepShareName = Read-Host -Prompt "Enter the share name of the Deployment share (default: DeployShare$)"
        If ($MdtDepShareName -eq '')
        {
            $MdtDepShareName = "DeployShare$" ## Share name of the Deployment share
        }

        ## Preferences for Deployment share CustomSettings.ini
        $TZName = Read-Host -Prompt "Enter the time zone name (default: GMT Standard Time)"
        If ($TZName -eq '')
        {
            $TZName = "GMT Standard Time"## The time zone for Windows
        }

        $KbLocaleCode = Read-Host -Prompt "Enter the keyboard locale code for Windows (default: 0809:00000809)"
        If ($KbLocaleCode -eq '')
        {
            $KbLocaleCode = "0809:00000809" ## The keyboard locale for Windows
        }

        $UILang = Read-Host -Prompt "Enter the locale for the Windows deployment (default: en-GB)"
        If ($UILang -eq '')
        {
            $UILang = "en-GB" ## The UI locale for Windows
            $UsrLocale = "en-GB" ## The user locale for Windows
            $KbLocaleName = "en-GB" ## The keyboard locale name for Windows
        }

        $MDTAdminGrp = Read-Host -Prompt "Enter the domain group to be used for MDT administrators (eg. mdt-admins)"
        $DomainUsr = Read-Host -Prompt "Enter the domain user to be used to add a PC to the domain - this user should be a member of the MDT Admins domain group (eg. mdt_admin)"
        $DomainPwrd = Read-Host -Prompt "Enter the password of the user above (eg. p@ssw0rD)"
        $DomainName = Read-Host -Prompt "Enter the domain of the user above (eg. contoso.com)"
        $OU = Read-Host -Prompt "Enter the full AD path for newly imaged PCs (eg. OU=PCs,DC=contoso,DC=com)"

        $UseWSUS = Read-Host -Prompt "Do you want to use a WSUS server? (y/N)"
        If ($UseWSUS -eq '')
        {
            $UseWSUS = "n"
        }

        If ($UseWSUS -eq "y")
        {
            $WSUSServer = Read-Host -Prompt "Enter the name and port of the WSUS server to use (eg. Wsus-Server:8530)"
        }

        Write-Host -Object ""
        Write-Host -Object "Configuration Summary:
        Windows version and update code: $WinCode
        Download and convert Windows ESD: $ConvertESD"
        If ($ConvertESD -eq "y")
        {
            Write-Host -Object "        Windows language to download : $LangCode"
        }

        Write-Host -Object "        Build share path: $MdtBuildShare
        Build share name: $MdtBuildShareName
        Deploy share path: $MdtDepShare
        Deploy share name: $MdtDepShareName
        Time zone name: $TZName
        Keyboard locale code: $KbLocaleCode
        Keyboard locale name: $KbLocaleName
        Windows UI language: $UILang
        Windows user language: $UsrLocale
        Domain group for MDT permissions: $MDTAdminGrp
        Domain user for domain join: $DomainUsr
        Domain password for above user: $DomainPwrd
        Domain name: $DomainName
        OU for new PC account: $OU
        Use WSUS server: $UseWSUS"
        If ($UseWSUS -eq "y")
        {
            Write-Host -Object "        WSUS server name and port: $WSUSServer"
        }

        $Ready = Read-Host -Prompt "Are you ready to begin the process? (eg. y/N)"
        If ($Ready -eq '')
        {
            $Ready = "n"
        }

        ## URLs - shouldn't have to change these until MSFT release new versions
        $MdtSrc = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi" ## MDT main package
        $MdtExe = "MicrosoftDeploymentToolkit_x64.msi"
        $AdkSrc = "https://go.microsoft.com/fwlink/?linkid=2196127" ## ADK Win 11 22H2
        $AdkExe = "adksetup.exe"
        $AdkPeSrc = "https://go.microsoft.com/fwlink/?linkid=2196224" ## ADK PE Add-on Win 11 22H2
        $AdkPeExe = "adkwinpesetup.exe"
        $MdtPatchSrc = "https://download.microsoft.com/download/3/0/6/306AC1B2-59BE-43B8-8C65-E141EF287A5E/KB4564442/MDT_KB4564442.exe" ## MDT Patch
        $MdtPatchExe = "MDT_KB4564442.exe"

        If ($WinVer -eq "y")
        {
            $MctSrc = "https://go.microsoft.com/fwlink/?linkid=2156295" ## Media Creation Tool for Windows 11
            $MctExe = "MediaCreationToolW11.exe"
        }

        else {
            $MctSrc = "https://go.microsoft.com/fwlink/?LinkId=691209" ## Media Creation Tool for Windows 10
            $MctExe = "MediaCreationTool22H2.exe"
        }

        If ($ConvertESD -eq "y")
        {
            ## Download OS
            Write-Host "Downloading Windows iso"
            Invoke-WebRequest -uri $MctSrc -Outfile "$PSScriptRoot\$MctExe"
            If ((Test-Path -Path "$PSScriptRoot\$MctExe") -eq $false)
            {
                Write-host "$MctExe failed to download"
            }

            Write-Host "The Media Creation tool requires user interaction."
            Write-Host ""
            Write-Host "        * Use this key to download your Windows iso: NPPR9-FWDCX-D2C8J-H872K-2YT43"
            Write-Host "        * Choose 'Create installation media' and then the 'ISO file' option to download an iso file."
            Write-Host "        * Please save the Windows iso file to the same folder that contains this script, otherwise things will fail."
            Write-Host "        * Make a note of the file name of the Windows iso file, you'll need it for the next step."
            Write-Host ""
            Start-Process $PSScriptRoot\$MctExe -ArgumentList "/Eula Accept /Retail /MediaArch x64 /MediaLangCode $LangCode /MediaEdition Enterprise" -Wait

            If ($ConvertESD -eq "y")
            {
                $WinFileName = Read-Host -Prompt "Enter the name of the Windows iso file that you downloaded (default: windows.iso)"
                If ($WinFileName -eq '')
                {
                    $WinFileName = "Windows.iso" ## The name of the Windows iso that will be downloaded via Media Creation Tool
                }

                If ((Test-Path -Path "$PSScriptRoot\$WinFileName") -eq $false)
                {
                    Write-host "$WinFileName not found."
                }
            }
        }

        If ($Ready -eq "y")
        {
            ##
            ## Start Process
            ##
            ## Downloads
            Write-Host "You can go and make a coffee now."
            Write-Host ""
            Write-Host "Downloading Installers"
            Invoke-WebRequest -uri $MdtSrc -Outfile "$PSScriptRoot\$MdtExe"
            If ((Test-Path -Path "$PSScriptRoot\$MdtExe") -eq $false)
            {
                Write-host "$MdtExe failed to download"
            }
            else {
                Write-host "$MdtExe downloaded"
            }

            Invoke-WebRequest -uri $AdkSrc -Outfile "$PSScriptRoot\$AdkExe"
            If ((Test-Path -Path "$PSScriptRoot\$AdkExe") -eq $false)
            {
                Write-host "$AdkExe failed to download"
            }
            else {
                Write-host "$AdkExe downloaded"
            }

            Invoke-WebRequest -uri $AdkPeSrc -Outfile "$PSScriptRoot\$AdkPeExe"
            If ((Test-Path -Path "$PSScriptRoot\$AdkPeExe") -eq $false)
            {
                Write-host "$AdkPeExe failed to download"
            }
            else {
                Write-host "$AdkPeExe downloaded"
            }

            Invoke-WebRequest -uri $MdtPatchSrc -Outfile "$PSScriptRoot\$MdtPatchExe"
            If ((Test-Path -Path "$PSScriptRoot\$MdtPatchExe") -eq $false)
            {
                Write-host "$MdtPatchExe failed to download"
            }
            else {
                Write-host "$MdtPatchExe downloaded"
            }

            ## Installs
            Write-Host "Installing ADK"
            try {
                Start-Process $PSScriptRoot\adksetup.exe -ArgumentList "/features OptionId.DeploymentTools OptionId.ICDConfigurationDesigner OptionId.ImagingAndConfigurationDesigner OptionId.UserStateMigrationTool /q" -Wait
            }
            catch {
                Write-host "ADK failed to install"
            }

            Write-Host "Installing ADK-WinPE"
            try {
                Start-Process $PSScriptRoot\adkwinpesetup.exe -ArgumentList "/features + /q" -Wait
            }
            catch {
                Write-host "ADK-WinPE failed to install"
            }

            Write-Host "Installing MDT"
            try {
                Start-Process msiexec -ArgumentList "/i $PSScriptRoot\MicrosoftDeploymentToolkit_x64.msi /qn" -Wait
            }
            catch {
                Write-host "MDT failed to install"
            }

            Write-Host "Installing MDT Patch KB4564442"
            try {
                Start-Process $PSScriptRoot\MDT_KB4564442.exe -ArgumentList "-q -extract:$PSScriptRoot\MDT_KB4564442" -Wait
            }
            catch {
                Write-host "MDT Patch KB4564442 failed to extract"
            }

            ## Copying files to the MDT install folder
            Copy-Item -Path "$PSScriptRoot\MDT_KB4564442\x64\*" -Destination "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x64"
            Copy-Item -Path "$PSScriptRoot\MDT_KB4564442\x86\*" -Destination "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates\Distribution\Tools\x86"

            ## WinPE x86 Fix
            New-Item -ItemType Directory -Path "$env:ProgramFiles (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs" | Out-Null

            ## Scripting Error Fix
            Rename-Item -Path "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates\Unattend_PE_x64.xml" -NewName "Unattend_PE_x64_backup.xml"
            Add-Content -Path "$env:ProgramFiles\Microsoft Deployment Toolkit\Templates\Unattend_PE_x64.xml" -Value '<unattend xmlns="urn:schemas-microsoft-com:unattend">
            <settings pass="windowsPE">
            <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
            <Display>
            <ColorDepth>32</ColorDepth>
            <HorizontalResolution>1024</HorizontalResolution>
            <RefreshRate>60</RefreshRate>
            <VerticalResolution>768</VerticalResolution>
            </Display>
            <RunSynchronous>
            <RunSynchronousCommand wcm:action="add">
            <Description>Lite Touch PE</Description>
            <Order>1</Order>
            <Path>reg.exe add "HKLM\Software\Microsoft\Internet Explorer\Main" /t REG_DWORD /v JscriptReplacement /d 0 /f</Path>
            </RunSynchronousCommand>
            <RunSynchronousCommand wcm:action="add">
            <Description>Lite Touch PE</Description>
            <Order>2</Order>
            <Path>wscript.exe X:\Deploy\Scripts\LiteTouch.wsf</Path>
            </RunSynchronousCommand>
            </RunSynchronous>
            </component>
            </settings>
            </unattend>
            '

            ## Import MDT PowerShell
            Import-Module "$env:ProgramFiles\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"

            ## Build Share
            ## Create Build Share
            Write-Host "Creating Build Share"
            New-Item -Path "$MdtBuildShare" -ItemType Directory | Out-Null
            New-SmbShare -Name "$MdtBuildShareName" -Path "$MdtBuildShare" -FullAccess Administrators | Out-Null
            New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "$MdtBuildShare" -Description "MDT Build Share" -NetworkPath "\\$env:ComputerName\$MdtBuildShareName" | Add-MDTPersistentDrive | Out-Null

            If ($ConvertESD -eq "y")
            {
                ## Copy Source Files
                Write-Host "Copying Windows source files"
                Mount-DiskImage -ImagePath "$PSScriptRoot\$WinFileName" -NoDriveLetter | Out-Null
                Copy-Item -Path \\.\CDROM1\ -Destination $PSScriptRoot\$WinCode -Recurse
                Dismount-DiskImage -ImagePath "$PSScriptRoot\$WinFileName" | Out-Null

                ## Convert ESD to WIM
                Write-Host "Converting ESD to WIM"
                DISM /export-image /SourceImageFile:$PSScriptRoot\$WinCode\sources\install.esd /SourceIndex:3 /DestinationImageFile:$PSScriptRoot\$WinCode\sources\install.wim /Compress:max /CheckIntegrity
                Remove-Item -Path $PSScriptRoot\$WinCode\sources\install.esd -Force
            }

            ## Add to MDT
            New-Item -Path "DS001:\Operating Systems\$WinCode" -ItemType Directory | Out-Null

            If ($ConvertESD -eq "y")
            {
                Write-Host "Importing Windows to MDT"
                Import-MDTOperatingSystem -Path "DS001:\Operating Systems\$WinCode" -SourcePath $PSScriptRoot\$WinCode -DestinationFolder "$WinCode" | Out-Null
                $WimFiles = Get-ChildItem -Path "DS001:\Operating Systems\$WinCode\*.wim"
                ForEach ($WimFile in $WimFiles)
                {
                    Rename-Item -Path "DS001:\Operating Systems\$WinCode\*.wim" -NewName "$WinCode.wim"
                }
            }

            ## Packages and Selection Profiles
            Write-Host "Creating selection profile"
            New-Item -Path "DS001:\Packages\$WinCode" -ItemType Directory | Out-Null
            New-Item -Path "DS001:\Selection Profiles" -enable "True" -Name "$WinCode" -Comments "" -Definition "<SelectionProfile><Include path=`"Packages\$WinCode`" /></SelectionProfile>" -ReadOnly "False" | Out-Null

            ## New TS From Template
            Write-Host "Downloading Build Task Sequence template"
            Invoke-WebRequest -uri "https://raw.githubusercontent.com/Digressive/MDT-Files/master/MDT-Templates/Client-Build-Template.xml" -Outfile "$MdtBuildShare\Templates\Client-Build-Template.xml"

            If ($ConvertESD -eq "y")
            {
                Write-Host "Creating Build Task Sequence"
                Import-MdtTaskSequence -Path "DS001:\Task Sequences" -Name "Build $WinCode" -Template "Client-Build-Template.xml" -Comments "" -ID "$WinCode" -Version "1.0" -OperatingSystemPath "DS001:\Operating Systems\$WinCode\$WinCode.wim" -FullName "user" -OrgName "org" -HomePage "about:blank" | Out-Null
            }

            ## MDT configuration
            ## Build share CustomSettings.ini
            Write-Host "Backing up original CustomSettings.ini"
            Rename-Item -Path $MdtBuildShare\Control\CustomSettings.ini -NewName CustomSettings-OgBackup.ini
            Write-Host "Creating custom CustomSettings.ini"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "[Settings]"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "Priority=Default"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "Properties=MyCustomProperty"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value ""
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "[Default]"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "OSInstall=Y"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SkipCapture=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SkipAdminPassword=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SkipProductKey=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SkipComputerBackup=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SkipBitLocker=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SkipLocaleSelection=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SkipTimeZone=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SkipDomainMembership=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SkipSummary=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SkipFinalSummary=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SkipComputerName=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SkipUserData=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value ""
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "_SMSTSORGNAME=Build Share"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "_SMSTSPackageName=%TaskSequenceName%"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "DoCapture=YES"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "ComputerBackupLocation=\\$env:ComputerName\$MdtBuildShareName\Captures"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value 'BackupFile=%TaskSequenceID%_#year(date) & "-" & month(date) & "-" & day(date) & "-" & hour(time) & "-" & minute(time)#.wim'
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SLShare=\\$env:ComputerName\$MdtBuildShareName\Logs\#year(date) & `"-`" & month(date) & `"-`" & day(date) & `"_`" & hour(time) & `"-`" & minute(time)#"
            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "SLShareDynamicLogging=\\$env:ComputerName\$MdtBuildShareName\DynamicLogs\#year(date) & `"-`" & month(date) & `"-`" & day(date) & `"_`" & hour(time) & `"-`" & minute(time)#"

            If ($UseWSUS -eq "y")
            {
                Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "WSUSServer=http://$WsusServer"
            }

            Add-Content -Path $MdtBuildShare\Control\CustomSettings.ini -Value "FinishAction=SHUTDOWN"

            ## Change MDT config to disable x86 support for boot media
            Write-Host "Configuring MDT"
            $XMLContent = Get-Content "$MdtBuildShare\Control\Settings.xml"
            $XMLContent = $XMLContent -Replace '<SupportX86>True</SupportX86>','<SupportX86>False</SupportX86>'
            $XMLContent | Out-File "$MdtBuildShare\Control\Settings.xml"

            ## Update Build share to generate boot media
            Write-Host "Updating Build share and generating boot media"
            Update-MDTDeploymentShare -path "DS001:" -Force | Out-Null

            ## Deployment Share
            ## Create Deployment Share
            Write-Host "Creating Deployment Share"
            New-Item -Path "$MdtDepShare" -ItemType Directory | Out-Null
            New-SmbShare -Name "$MdtDepShareName" -Path "$MdtDepShare" -FullAccess Administrators | Out-Null
            New-PSDrive -Name "DS002" -PSProvider "MDTProvider" -Root "$MdtDepShare" -Description "MDT Deploy Share" -NetworkPath "\\$env:ComputerName\$MdtDepShareName" | Add-MDTPersistentDrive | Out-Null

            ## Packages, Drivers and Selection Profiles
            Write-Host "Creating selection profiles, package and driver folder structure"
            New-Item -Path "DS002:\Packages\$WinCode" -ItemType Directory | Out-Null
            New-Item -Path "DS002:\Selection Profiles" -enable "True" -Name "$WinCode" -Comments "" -Definition "<SelectionProfile><Include path=`"Packages\$WinCode`" /></SelectionProfile>" -ReadOnly "False" | Out-Null
            New-Item -Path "DS002:\Out-of-Box Drivers\Microsoft Corporation" -ItemType Directory | Out-Null
            New-Item -Path "DS002:\Out-of-Box Drivers\Microsoft Corporation\Virtual Machine" -ItemType Directory | Out-Null
            New-Item -Path "DS002:\Out-of-Box Drivers\VMware, Inc." -ItemType Directory | Out-Null
            New-Item -Path "DS002:\Out-of-Box Drivers\VMware, Inc.\VMwareVirtual Platform" -ItemType Directory | Out-Null
            New-Item -Path "DS002:\Out-of-Box Drivers\WinPE" -ItemType Directory | Out-Null
            New-Item -Path "DS002:\Selection Profiles" -enable "True" -Name "WinPE" -Comments "" -Definition "<SelectionProfile><Include path=`"Out-of-Box Drivers\WinPE`" /></SelectionProfile>" -ReadOnly "False" | Out-Null

            ## New TS From Template
            Write-Host "Downloading Deploy Task Sequence template"
            Invoke-WebRequest -uri "https://raw.githubusercontent.com/Digressive/MDT-Files/master/MDT-Templates/Client-Deploy-Template.xml" -Outfile "$MdtDepShare\Templates\Client-Deploy-Template.xml"

            ## Deploy share CustomSettings.ini
            Write-Host "Backing up original CustomSettings.ini"
            Rename-Item -Path $MdtDepShare\Control\CustomSettings.ini -NewName CustomSettings-OgBackup.ini
            Write-Host "Creating custom CustomSettings.ini"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "[Settings]"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "Priority=Model, Default, SetOSD"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "Properties=OSDPrefix"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value ""
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "[Virtual Machine]"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "OSDComputerName=%TaskSequenceID%"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value ""
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "[Default]"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "_SMSTSORGNAME=Deploy"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "_SMSTSPackageName=%TaskSequenceName%"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value ""
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "; MDT deployment settings"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "OSInstall=Y"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SkipCapture=YES"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SkipAdminPassword=YES"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SkipProductKey=YES"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SkipComputerBackup=YES"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SkipBitLocker=YES"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value ""
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "; Locale and screen res"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "TimeZoneName=$TZName"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "KeyboardLocale=$KbLocaleCode"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "UILanguage=$UILang"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "UserLocale=$UsrLocale"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "KeyboardLocale=$KbLocaleName"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "BitsPerPel=32"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "VRefresh=60"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "XResolution=1"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "YResolution=1"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "HideShell=YES"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value ""
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "; Join Domain"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "JoinDomain=$DomainName"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "DomainAdmin=$DomainUsr"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "DomainAdminDomain=$DomainName"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "DomainAdminPassword=$DomainPwrd"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "MachineObjectOU=$OU"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value ""
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "; Other Settings"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SkipUserData=YES"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SkipDomainMembership=YES"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SkipLocaleSelection=YES"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SkipTimeZone=YES"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SkipSummary=YES"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SkipFinalSummary=YES"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "FinishAction=SHUTDOWN"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SLShare=\\$env:ComputerName\$MdtDepShareName\Logs\#year(date) & `"-`" & month(date) & `"-`" & day(date) & `"_`" & hour(time) & `"-`" & minute(time)#"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "SLShareDynamicLogging=\\$env:ComputerName\$MdtDepShareName\DynamicLogs\#year(date) & `"-`" & month(date) & `"-`" & day(date) & `"_`" & hour(time) & `"-`" & minute(time)#"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value ""

            If ($UseWSUS -eq "y")
            {
                Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "WSUSServer=http://$WsusServer"
            }

            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "; this line intentionally left blank"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value "; this line intentionally left blank"
            Add-Content -Path $MdtDepShare\Control\CustomSettings.ini -Value ""

            ## Change MDT config to disable x86 support for boot media
            ## And set the WinPE selection profile for the drivers
            Write-Host "Configuring MDT"
            $XMLContent = Get-Content "$MdtDepShare\Control\Settings.xml"
            $XMLContent = $XMLContent -Replace '<SupportX86>True</SupportX86>','<SupportX86>False</SupportX86>'
            $XMLContent = $XMLContent -Replace '<Boot.x64.SelectionProfile>All Drivers and Packages</Boot.x64.SelectionProfile>','<Boot.x64.SelectionProfile>WinPE</Boot.x64.SelectionProfile>'
            $XMLContent | Out-File "$MdtDepShare\Control\Settings.xml"

            ## Update Deploy share to generate boot media
            Write-Host "Updating Deploy share and generating boot media"
            Update-MDTDeploymentShare -path "DS002:" -Force | Out-Null

            ## Set Permissions
            Write-Host "Setting Share Permissions"
            Grant-SmbShareAccess -Name $MdtBuildShareName -AccountName "$DomainName\$MDTAdminGrp" -AccessRight Full -Force | Out-Null
            Grant-SmbShareAccess -Name $MdtDepShareName -AccountName "$DomainName\$MDTAdminGrp" -AccessRight Full -Force | Out-Null

            Write-Host "Setting File Permissions"
            icacls "$MdtBuildShare" /grant $DomainName\$MDTAdminGrp':(OI)(CI)(F)'
            icacls "$MdtDepShare" /grant $DomainName\$MDTAdminGrp':(OI)(CI)(F)'

            Write-Host "Finished!"
        }
    }
}

## End