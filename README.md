# PS-Profile
this is my powershell settings where I tried to make the linux command functionality a few commands that you might want to use

## What it is doing

1. Command from linux
   - `reboot` - reboot the system
   - `poweroff` - turns off the system
   - `pkill` - kills the process
   - `grep` - shows a line with the word you specify in the file or in the command output.
   - `wc` - shows information about the file how many words how many lines and how many bytes it occupies
   - `uname` - show a summary of the system
   - `ls` - navigates files from the folder where the user is located (this command is also available in regular powershell, but I made it more similar to the linux version).
   - `mkdir` - creates a folder (it is in powershell natively, but I made a similar one for the linux version).
   - `pwd` - to show which package the user is in (it is in powershell in native, but I made it look like the linux version).
   - `toggle-errmsg` - Initially it is written in the config not to display errors, but if you need to see what the reason is you can turn it on and also turn it off again.
   - `cum` - **CUM - Clear Used Memory**, this command clears the RAM
   - `bsod` - the `bsod` command requires administrator privileges 

2. Custom command
   - `history` - shows the entire history of the teams over time
   - `reload-explorer` - restarts explorer or starts it if it is not running
   - `toggle-errmsg` - and initially in the config it is written that there is no error output, but with this command you can enable or disable the output.
   - `cum` - **CUM - Clear Used Memory**,this command clears RAM
   - `bsod` - ⚠ This command requires administrator rights.

## How to install
1. Clone repository 
```bash
git clone https://github.com/MrDarkGoose/PS-Profile.git
```
2. Copy and past to the folder ```C:\Users\white\Documents\WindowsPowerShell```
  - If you don't have a folder, create one.

```bash
mkdir C:\Users\white\Documents\WindowsPowerShell
```

