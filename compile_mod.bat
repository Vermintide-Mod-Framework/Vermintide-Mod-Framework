"./bin/stingray_win64_dev_x64.exe" --compile-for win32 --source-dir vmf_source --data-dir TEMP/compile --bundle-dir TEMP/bundle
copy TEMP\bundle\*. "C:\Programs (x86)\Steam\steamapps\common\Warhammer End Times Vermintide\bundle\mods"
pause