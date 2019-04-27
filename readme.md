# About
Swytch is a script allowing to switch windows in Sway (www.swaywm.org).
The following programs are invoked:
- rofi (https://github.com/davatorium/rofi)
- jq (https://stedolan.github.io/jq/)
- gawk (https://www.gnu.org/software/gawk/)

# Installation
1. Install the programs listed above.
2. Clone this repository or, alternatively, download only swytch.sh
3. Make swytch.sh executable by running "chmod +x swytch.sh" in the folder where the file is located
4. Configure the execution of swytch.sh in sway's configuration file. For example, adding the line
```
 bindsym ALT+Tab exec [path to swytch.sh]
```
with the path to the script (without brackets) will launch the window switcher by pressing Alt+Tab.
5. Reload Sway to make the changes effective

# Usage
See https://github.com/davatorium/rofi for the general usage of rofi.  
In a nutshell, simply select the desired Window using the arrow keys or by typing a part of it's name.  
The window list has the form:  
```
[Workpace name][* if window is active] [window name] [window id]
```
