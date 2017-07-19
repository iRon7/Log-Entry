Migrating from Write-Log
========================
The `Log-Entry` framework is the successor of the `Write-Log` framework with a few new features and changes that might require some minor modifications to your script if you migrate from the `Write-Log` framework to the `Log-Entry` framework.

|Write-Log Framework|Log-Entry Framework|Comment|
|-------------------|-------------------|-------|
|`Write-⁠Log`        |`Log-Entry`        |The main function has been renamed from `Write-Log` to `Log-Entry` but the function still has a `Write-Log` alias and a `Log` alias meaning that no modification are required for this change but it is recommended to use either the `Log-Entry` command or simply the `Log` command from now on.
|`Log -File`        |`Set-LogFile`      |Redirecting the log file and its related options `-Preserve <Size>` and `-Divider <String>` (previously called: `-Separator`) is now done with a separated `Set-LogFile` (alias `LogFile`) function.|
|`-Debug`           |`Log-Debug`        |The `-Debug` parameter has moved to a separate `Log-Debug` alias function. The functionality has not changed: no entries are shown or recorded in the log file unless the the common `-Debug` parameter is used.|
|`-Verbose`         |`Log-Verbose`      |The `-Verbose` parameter has moved to a separate `Log-Verbose` alias function. The functionality has slightly changed in comparison to the previous `Log -Verbose` function and the current `Log-Debug` function: all entries are recorded in the log file but no entries are shown unless the the common `-Debug` parameter is used.|
|                   |`-Separator`       |Defines the separator between each entry (default: single space). Note that former `Write-Log -File <FileName> -Separator <String>` has been replaced by `Set-LogFile <FileName> -Divider <String>`|
|`-Prefix`          |`-NoNewline`       |The `-Prefix` parameter has depleted and replaced by the `-NoNewline` parameter. The implementation is similar to `Write-Host` implementation except that it places a separator in front of the following entry (use `-Separator ""` suppresses this feature)|
|`-Delay`           |                   |The `-Delay` parameter has depleted. The `-NoNewline` parameter delays the file write until the next log. ``Log -NoNewline "Following information:`r`n"`` has a similar result.|
|                   |`-BackgroundColor` |The `-BackgroundColor` is added and sets the background color of the displayed entry similar to `Write-Host -BackgroundColor`|
|`-Color`           |`-⁠ForegroundColor` |The `-Color` parameter changed to `-ForegroundColor` to be consistent with `Write-Host -ForegroundColor <Color>` but the `-color` alias for this parameter is still available (no modifications required).|
|                   |`-Strip`           |The `-Strip` feature is new and truncates strings at the given length and removes redundant white space characters if the value supplied is equal or larger than `0`. Set `-Strip -1` prevents truncating and the removal of with space characters. The default value for `log-entry` is `-1`.|
|                   |`-FlushErrors`     |The `-FlushErrors` is new and suppresses any errors that occurred since last log entry.|
|`Log "End"`        |`End-Script"`      |The `End-Script` function (Alias: `End`) is recommended to log the remaining errors and close the log session with the execution time.|

Note that the session header in the log file of the `Log-Entry` framework slightly changed to:

    2017-07-06 	PowerShell version: 5.1.15063.413, process start: 2017-06-29 16:29:56.70
    12:41:32.62	<ScriptName> version: ##.##.##, command line: C:\Users\<User>\<ScriptName>.ps1
