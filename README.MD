# Building

## Prerequisites
- You should be subscribed to VMF in Steam Workshop [[VT1](https://steamcommunity.com/sharedfiles/filedetails/?id=1289946781), [VT2](https://steamcommunity.com/sharedfiles/filedetails/?id=1369573612)], depending on which version you want to compile.
- You will also need [Vermintide Mod Builder](https://github.com/Vermintide-Mod-Framework/Vermintide-Mod-Builder).

## Building steps:

1. Unpack VMB somewhere. Let's assume, it's unpacked into the folder named `vermintide-mod-builer`.
2. Create a folder inside `vermintide-mod-builer` (we'll call it `vermintide-mod-framework`) and then clone VMF repo into this folder.
3. Open console window inside `vermintide-mod-builer` and use following command to build VMF: `vmb build vmf -f vermintide-mod-framework --ignore-errors -g [1/2]`, where number after `-g` indicates the Vermintide game number for which VMF is built.

You can find more information on how mod building works in Vermintide Mod Builder documentation.