$Source = (Resolve-Path "$PSScriptRoot\..").Path
$Deploy = "$PSScriptRoot\deploy2.bat"
$DebounceMs = 500

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $Source
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

$timer = New-Object System.Timers.Timer
$timer.Interval = $DebounceMs
$timer.AutoReset = $false

$action = {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Deploying..."
    & cmd /c $Deploy
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Done."
}

Register-ObjectEvent $timer "Elapsed" -Action $action | Out-Null

$onChange = {
    $path = $Event.SourceEventArgs.FullPath
    $ignored = @(".git", "scripts")
    foreach ($part in $ignored) {
        if ($path -like "*\$part\*" -or $path -like "*\$part") { return }
    }
    $timer.Stop()
    $timer.Start()
}

Register-ObjectEvent $watcher "Changed" -Action $onChange | Out-Null
Register-ObjectEvent $watcher "Created" -Action $onChange | Out-Null
Register-ObjectEvent $watcher "Deleted" -Action $onChange | Out-Null
Register-ObjectEvent $watcher "Renamed" -Action $onChange | Out-Null

Write-Host "Watching $Source - press Ctrl+C to stop."
while ($true) { Start-Sleep -Seconds 1 }
