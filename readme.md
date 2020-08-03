# About
Swytch is a script allowing to switch windows in Sway (www.swaywm.org).
Furthermore, it allows to send any sway command for a selected window to swaymsg.

The following programs are invoked:
- rofi (https://github.com/davatorium/rofi)
- jq (https://stedolan.github.io/jq/)
- gawk (https://www.gnu.org/software/gawk/)
- rigrep (https://github.com/BurntSushi/ripgrep)

# Installation
1. Install the programs listed above.
2. Clone this repository or, alternatively, download only swytch.sh
3. Make swytch.sh executable by running "chmod +x swytch.sh" in the folder where the file is located
4. Configure the execution of swytch.sh in sway's configuration file. For example, adding the line
   ```
    bindsym ALT+Tab exec [path to swytch.sh]
   ```
   with the path to the script (without brackets) will launch the window switcher by pressing Alt+Tab.

   By default, Swytch focuses the selected window by sending the `focus` command for the selected window via swaymsg.  
   However, Swytch allows to pass another sway command than `focus` to swaymsg. 
   In order to do so, pass the desired command as an argument when executing Swytch. For example,
   ```
   bindsym ALT+Tab exec [path to swytch.sh] kill
   ```
   will kill the selected window instead of focusing it.

   You can learn about available sway commands via the respective sway manpage:
   ```
   man 5 sway
   ```
5. Reload Sway to make the changes effective

# Usage
See https://github.com/davatorium/rofi for the general usage of rofi.  
In a nutshell, simply select the desired Window using the arrow keys or by typing a part of it's name and press enter.  
The window list has the form:  
```
[Workpace name][* if window is active] [application id] [window name] [window id]
```
The workspace names are colored in order to help noticing which windows are on the same workspaces quickly.
