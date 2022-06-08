if ($IsLinux) {
    Copy-Item -Path './homelab/vscode/settings.json' -Destination '.../settings.json'
    Copy-Item -Path  './homelab/vscode/keybindings.json' -Destination '.../keybindings.json' -force
    Copy-Item -Path './homelab/vscode/powershell.json' -Destination '...\powershell.json' -force
}
If ($IsWindows) {
   Copy-Item -Path './homelab/vscode/settings.json' -Destination 'C:\Users\olaf\AppData\Roaming\Code\User\settings.json' -Force
   Copy-Item -Path './homelab/vscode/keybindings.json' -Destination 'C:\Users\olaf\AppData\Roaming\Code\User\keybindings.json' -force
   Copy-Item -Path './homelab/vscode/powershell.json' -Destination 'C:\Users\olaf\AppData\Roaming\Code\User\snippets\powershell.json' -force
}

