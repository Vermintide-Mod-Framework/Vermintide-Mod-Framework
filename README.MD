<p align="center">
  <a href="#welcome-to-the-vermintide-mod-framework-vmf-repository">
    <img
      alt="Vermintide Mod Framework"
      src="https://github.com/Vermintide-Mod-Framework/Vermintide-Mod-Framework/blob/master/assets/vmf_logo_black.png"
      width="600"
    />
  </a>
</p>
<p align="center">
  <a href="https://travis-ci.com/Vermintide-Mod-Framework/Vermintide-Mod-Framework">
    <img
      alt="Build Status"
      src="https://travis-ci.com/Vermintide-Mod-Framework/Vermintide-Mod-Framework.svg?branch=master"
      width="100"
    />
  </a>
</p>


## Welcome to the Vermintide Mod Framework (VMF) Repository!

The Vermintide Mod Framework is an open-source, community-run framework of modules that provides enhanced modding capabilities and support. The framework is designed to be both independent and lightweight; making no changes to gameplay on its own.

Mods created for the project may utilize:

* Mod options
* Shared function hooks
* Chat commands
* Keybinds
* Mutator support (for now available only in Vermintide 1)
* Network calls
* QHD+ UI re-scaling
* Rewritten, lightweight mod functions
* An on-event call system

The Vermintide Mod Framework originally started in Warhammer End Times: Vermintide as an unofficial modding platform. In the time since, VMF has been rewritten and redesigned with contributions from many unique members of the community; culminating in this unified project made for the arrival of official mod support.

For more information, check out **[the framework's wiki pages](https://github.com/Vermintide-Mod-Framework/Vermintide-Mod-Framework/wiki)**.


## Building the Framework

### Prerequisites:

- To start, you should be subscribed to the VMF Beta in Steam Workshop. (**[Warhammer End Times - Vermintide](https://steamcommunity.com/sharedfiles/filedetails/?id=1500136933)** or **[Warhammer: Vermintide 2](https://steamcommunity.com/sharedfiles/filedetails/?id=1500112422)**, depending on which version you want to compile)
- You should also install **[Vermintide Mod Builder (VMB)](https://github.com/Vermintide-Mod-Framework/Vermintide-Mod-Framework/wiki/Get-Vermintide-Mod-Builder)**.


### Building Steps:

1. Navigate to your VMB directory. Let's assume it's unpacked into a folder named `vermintide-mod-builder`.
2. Create a folder inside `vermintide-mod-builder` (we'll call it `vermintide-mod-framework`) and **[clone](https://git-scm.com/docs/git-clone)** in the VMF repository's contents.
3. Open a console/Command Prompt/PowerShell window inside your `vermintide-mod-builder` directory and use the following VMB command: `vmb build vmf -f vermintide-mod-framework -g [1|2]`, where the number after `-g` indicates the target Vermintide game.


You can find more VMB mod-building information in the **[Vermintide Mod Builder documentation](https://github.com/Vermintide-Mod-Framework/Vermintide-Mod-Builder/blob/master/README.md)**.
