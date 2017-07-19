Version |Date      |Author      |Comments
--------|----------|------------|--------
00.00.01|2009-03-18|Ronald Bode |Initial release
00.xx.xx|          |Ronald Bode |Assiosated with other cmdlets
01.00.00|2017-05-31|Ronald Bode |Prepared for publication
01.00.01|2017-05-31|Ronald Bode |Added `-Strip` option for large embedded strings
01.00.02|2017-05-31|Ronald Bode |First public release
01.00.03|2017-06-11|Ronald Bode |Fixed: separator not included when log is redirected
01.00.04|2017-06-11|Ronald Bode |Fixed: error with exotic value types
        |          |            |Fixed: value of system.byte is not shown
01.00.05|2017-06-22|Ronald Bode |Fixed: errors due to missing or incorrect help header
01.00.06|2017-06-25|Ronald Bode |Fixed `Log-Debug` and `Log-Verbose` (`CmdletBinding` was missing)
02.01.00|2017-06-25|Ronald Bode |Major release change
        |          |            |Renamed solution to `Log-Entry` (formerly called `Write-Log`)
        |          |            |`Set-LogFile` (alias `LogFile`) function.
        |          |            |The `-Debug` parameter has moved to a separate `Log-Debug` alias function.
        |          |            |The `-Verbose` parameter has moved to a separate `Log-Verbose` alias function.
        |          |            |The `-Prefix` parameter has depleted and replaced by the `-NoNewline` parameter.
        |          |            |The `-Delay` parameter has depleted.
        |          |            |Added `-BackgroundColor`
        |          |            |The `-Color` parameter changed to `-ForegroundColor`
        |          |            |Added `-Strip` feature is new and truncates strings at the given length and removes redundant white spaces
        |          |            |Added `-FlushErrors` is new and suppresses any errors that occurred since last log entry.
        |          |            |Added `End-Script` function (Alias: `End`) to log the remaining errors and close the log session
