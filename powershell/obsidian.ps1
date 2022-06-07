$obsidian_config = Get-Content -Path 'C:\Users\olaf\Documents\HomeLab\.obsidian\config' -raw | ConvertFrom-Json

$obsidian_config.pluginEnabledStatus
$obsidian_config.pdfExportSettings
$obsidian_config.enabledPlugins
$obsidian_config.hotkeys
$obsidian_config.foldHeading
$obsidian_config.newFileLocation
$obsidian_config.showUnsupportedFiles
$obsidian_config.cssTheme

$obsidian_config.hotkeys.'workspace:export-pdf' 