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

#!/bin/bash

# Obtain the avaliable windows' workspaces, names and IDs as strings
windows=$(
swaymsg -t get_tree | jq -r '[recurse(.nodes[]?)|recurse(.floating_nodes[]?)|select(.type=="workspace")| . as $workspace | recurse(.nodes[]?)|select(.type=="con" and .name!=null)|{workspace: $workspace.name, name: .name, id: .id}]|sort_by(.workspace, .name)[]|.workspace + " " + .name + "  " + (.id|tostring)'
)

# Select window with rofi, obtaining ID of selected window
selected=$(echo "$windows" | rofi -dmenu -i -p "Window" | awk '{print $NF}')

# Tell sway to focus said window
if [ ! -z "$selected" ]
then
    swaymsg [con_id="$selected"] focus
fi
