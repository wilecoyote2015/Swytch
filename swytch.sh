#!/bin/bash

#    Swytch is a script providing a window switcher for sway using rofi, awk and jq.
#    The script is based on:
#    https://www.reddit.com/r/swaywm/comments/aolf3u/quick_script_for_rofi_alttabbing_window_switcher/
#    Copyright (C) 2019  Björn Sonnenschein
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# obtain command to execute with swaymsg for selected window
if [ -z "$1" ]
then 
    command_=focus
else
    command_=$1
fi

# Obtain the avaliable windows' workspaces, names and IDs as strings
mapfile -t windows < <(
swaymsg -t get_tree | jq -r '[recurse(.nodes[]?)|recurse(.floating_nodes[]?)|select(.type=="workspace")| . as $workspace | recurse(.nodes[]?)|select(.type=="con" and .name!=null)|{workspace: $workspace.name, name: .name, id: .id, focused: .focused}]|sort_by(.workspace, .name)[]|.workspace + if .focused then "* " else "  " end + .name + "  " + (.id|tostring)'
)

# insert workspace markers 
separator_workspaces='-----------------------------------'
windows_separators=()
workspace_previous=''
index_workspace_active=0
num_separators=0
for index_window in "${!windows[@]}"
do 
    window=${windows[$index_window]}
    workspace=${window:0:1}
    if [ "$workspace" != "$workspace_previous" ] && [ ! -z "$workspace_previous" ]
    then
        windows_separators+=($separator_workspaces)
        num_separators=$(($num_separators+1))
    fi
    # obtain index of the active window
    if [ "${window:1:1}" == "*" ]
    then 
        index_workspace_active=$(($index_window+$num_separators))
    fi
    windows_separators+=("$window")
    workspace_previous=$workspace
done

#echo ${windows_separators[@]}

# Select window with rofi, obtaining ID of selected window
selected=$(printf '%s\n' "${windows_separators[@]}" | rofi -dmenu -i -p "$command_" -a "$index_workspace_active" -s -width 80 | awk '{print $NF}')

# Tell sway to focus said window
# todo: do not execute if selected is the separator
if [ ! -z "$selected" ]
then
    swaymsg [con_id="$selected"] "$command_"
fi
