#!/usr/bin/env bash
set -x

##### build #####
find . -iname "*.lua" | xargs lua -b || { echo 'LuaJIT parse test failed.' ; exit 1; }