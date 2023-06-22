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


# todo: first, query all existing workspaces from sway and build color dict, so that
#   all workspaces always get the same color, even if no windows at some workspace in between exists.

# obtain command to execute with swaymsg for selected window
if [ -z "$1" ]
then 
    command_=focus
else
    command_=$1
fi

# TODO: is XDG_CURRENT_DESKTOP the appropriate variable?
# TODO: style and DRY
if [ "$XDG_CURRENT_DESKTOP" == "Sway" ]
then
# Obtain the avaliable windows' workspaces, names and IDs as strings
	#mapfile -t windows < <(
	# TODO: fix sway
	function make_array_windows {
	  	declare -A result=(
    	$(swaymsg -t get_tree | jq -r '[
    	    recurse(.nodes[]?)
    	    |recurse(.floating_nodes[]?)
    	    |select(.type=="workspace")
    	    | . as $workspace | recurse(.nodes[]?)
    	    |select(.type=="con" and .name!=null)
    	    |sort_by($workspace.name, .name)[]
    	    |."'"$1"
    	))
    	return result
	}

elif [ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]
then
  # TODO: how to return array from function?
#  function make_array_windows {
#      # Read the JSON array into a variable
#      json=$(hyprctl clients -j)
#
#      # Extract the desired values using jq and save them in an array
#      mapfile -t result < <(echo "$json" | jq -r 'sort_by(.workspace.name)[] | select(.workspace.id != -1) | '$1'')
#
#      # Print the array elements (for debugging)
#      printf '%s\n' "${result[@]}"
#  }

  id_active=$(hyprctl activewindow -j | jq -r ".address")

  # TODO: instead of calling jq for each variable, build some array of dicts
  json=$(hyprctl clients -j)
  mapfile -t names < <(echo "$json"  | jq -r 'sort_by(.workspace.name)[] | select(.workspace.id != -1) | .title')
  mapfile -t classes < <(echo "$json"  | jq -r 'sort_by(.workspace.name)[] | select(.workspace.id != -1) | .class')
  mapfile -t ids < <(echo "$json"  | jq -r 'sort_by(.workspace.name)[] | select(.workspace.id != -1) | .address')
  mapfile -t workspaces < <(echo "$json"  | jq -r 'sort_by(.workspace.name)[] | select(.workspace.id != -1) | .workspace.name')

fi


# get window list to display
windows_separators=()
colors=(blue green orange red magenta)
workspace_previous=''
index_workspace_active=0
index_window_last_active=0
num_separators=0
index_color=0
bold=1
for index_window in "${!ids[@]}"
do 
    # todo: consider arbitraty workspace name length by separating by space instead of simply taking first argument.
    workspace=${workspaces[$index_window]}
    title=${names[$index_window]}
    class=${classes[$index_window]}
    id=${ids[$index_window]}

    if [ "${id}" == "${id_active}" ]
    then
        index_window_last_active=("${index_window}")
    fi

    # obtain index of the active window
    if [ "${id}" == "${id_active}" ]
    then 
        index_workspace_active=$(($workspace))
    fi

    window=("$workspace^$class^$title")
    windows_separators+=("${window}")
done

# FIXME: active window display does not work correctly!!

## column spacing
mapfile -t windows_separators_spaced < <(printf '%s\n' "${windows_separators[@]}" | column -s^ -t)

windows_separators_formatted=()
for index_window in "${!ids[@]}"
do
    # todo: consider arbitraty workspace name length by separating by space instead of simply taking first argument.
    window=${windows_separators_spaced[$index_window]}
    workspace=${workspaces[$index_window]}

    # if window has different workspace than previous, use next color. Cycle through colors
    if [ "$workspace" != "$workspace_previous" ] && [ ! -z "$workspace_previous" ]
    then
        index_color=$index_color+1
    fi

    if (($index_color == ${#colors[@]}))
    then
        index_color=0
    fi

    if (( $bold == 1))

    then
        window_formatted=("<b><span foreground=\"${colors[$index_color]}\">${window}</span></b>")
    else
    	  window_formatted=("${window}")
    fi
#    icon=$(echo -e "aap\0icon\x1ffirefox\n")
    icon="\0icon\x1ffirefox\n"
    window_formatted_w_icon="${window_formatted}${icon}"
    windows_separators_formatted+=("${window_formatted_w_icon}")
    workspace_previous=$workspace
done



windows_formatted_str=$(printf '%s' "${windows_separators_formatted[@]}")
echo $windows_formatted

if [ -z "$monitor_id" ]
then
	idx_selected=$(echo -en $windows_formatted_str |  rofi -dmenu -i -p "$command_" -a "$index_workspace_active" -format i -selected-row "$index_window_last_active" -no-custom -s -width 80 -lines 30 -markup-rows -show-icons )
else
  echo sdfdasf
	idx_selected=$(echo -en $windows_formatted_str |  rofi  -monitor $monitor_id -dmenu -i -p "$command_" -a "$index_workspace_active" -format i -selected-row "$index_window_last_active" -no-custom -s -width 80 -lines 30 -markup-rows -show-icons )
fi

# if no entry selected (e.g. user exitted with escape), end
if [ -z "$idx_selected" ]
then
    exit 1
fi
id_selected=${ids[$idx_selected]}
workspace_selected=${workspaces[$idx_selected]}


if [ "$XDG_CURRENT_DESKTOP" == "Sway" ]
  then
  ### unmaximize all maximized windows on the workspace of the selected window
  # Obtain the avaliable windows' workspaces, names and IDs as strings
  # TODO: FIX this for current code!
  mapfile -t ids_windows_maximized < <(
  swaymsg -t get_tree | jq -r '[
      recurse(.nodes[]?)
      |recurse(.floating_nodes[]?)
      |select(.type=="workspace")
      | . as $workspace | recurse(.nodes[]?)
      |select(.type=="con" and .name!=null and .fullscreen_mode==1 and $workspace.name=="'"$workspace_selected"'")
      |{workspace: $workspace.name, name: .name, id: .id, focused: .focused, app_id: .app_id}]
      |sort_by(.workspace, .name)[]
      |(.id|tostring)'
  )

  # unmaximize the maximized windows that are not the selected one
  for id_window_maximized in "${ids_windows_maximized[@]}"
  do
      if [ "$id_window_maximized" != "$id_selected" ]
      then
          swaymsg "[con_id=$id_window_maximized] fullscreen disable"
      fi
  done

  # Tell sway to focus said window
  if [ ! -z "$id_selected" ]
  then
      swaymsg "[con_id=$id_selected] $command_"
  fi
elif [ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]

then
  # TODO: also handle maximized windows?
  hyprctl dispatch focuswindow address:$id_selected
fi



