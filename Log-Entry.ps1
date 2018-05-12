<#
.Synopsis
	Log-Entry
.Description
	A PowerShell framework for sophisticated logging
.Notes
	Author:    Ronald Bode
	Version:   02.01.05
	Created:   2009-03-18
	Modified:  2018-05-12
.Link
	https://github.com/iRon7/Log-Entry
#>

[CmdletBinding()] Param()

Function Main {
	LogFile .\Test.log					# Redirect the log file location (Optional)
	Log -Color Yellow "Examples:"
	Log "Several examples that usually aren't displayed by Write-Host:" $NotSet @() @(@()) @(@(), @()) @($Null)
	Log -Indent 1 "Note 1: An empty string:" "" "isn't displayed by Log-Entry either (as you do not want every comment quoted)."
	Log -Indent 2 "In case you want to reveal a (possible) empty string, use -QuoteString:" -NoNewline; Log -QuoteString ""
	Log -Indent 1 "Note 2: An empty array embedded in another array:" @(@()) "is flattened by PowerShell (and not Write-Log)."
	Log -Indent 2 "To prevent this use a comma in front of the embbed array: " @(,@())
	Log "A hashtable:" @{one = 1; two = 2; three = 3}
	Log "A recursive hashtable:" @{one = @{one = @{one = 1; two = 2; three = 3}; two = 2; three = 3}; two = 2; three = 3} -Expand -Depth:9
	Log "Character array:" "Hallo World".ToCharArray()
	Log-Verbose "The following line produces a error which is captured in the log file:"
	$File = Log "File:" (Get-ChildItem "C:\NoSuchFile.txt" -ErrorAction SilentlyContinue)
	Log-Verbose "The switch -FlushErrors prevents the error being logged:"
	$File = Log "File:" (Get-ChildItem "C:\NoSuchFile.txt" -ErrorAction SilentlyContinue) -FlushErrors
	Log -Color Magenta "Below are two inline log examples (the object preceding the ""?"" is returned):"
	$Height = Log "Height:" 3 ? "Inch"
	$Width  = Log "Width:"  4 ? "Inch"
	Log-Verbose "Or one display/log line spread over multiple code lines:"
	Log "Periphery:" -NoNewline
	$Periphery = Log (2 * $Height + 2 * $Width) ? -Color Green -NoNewline
	Log "Inch"
	Log-Debug "Password:" $Password "(This will not be shown and captured unless the common -Debug argument is supplied)"
}

# ------------------------------------- Global --------------------------------
Function Global:ConvertTo-Text([Alias("Value")]$O, [Int]$Depth = 9, [Switch]$Type, [Switch]$Expand, [Int]$Strip = -1, [String]$Prefix, [Int]$i) {
	Function Iterate($Value, [String]$Prefix, [Int]$i = $i + 1) {ConvertTo-Text $Value -Depth:$Depth -Strip:$Strip -Type:$Type -Expand:$Expand -Prefix:$Prefix -i:$i}
	$NewLine, $Space = If ($Expand) {"`r`n", ("`t" * $i)} Else{$Null}
	If ($O -eq $Null) {$V = '$Null'} Else {
		$V = If ($O -is "Boolean")  {"`$$O"}
		ElseIf ($O -is "String") {If ($Strip -ge 0) {'"' + (($O -Replace "[\s]+", " ") -Replace "(?<=[\s\S]{$Strip})[\s\S]+", "...") + '"'} Else {"""$O"""}}
		ElseIf ($O -is "DateTime") {$O.ToString("yyyy-MM-dd HH:mm:ss")} 
		ElseIf ($O -is "ValueType" -or ($O.Value.GetTypeCode -and $O.ToString.OverloadDefinitions)) {$O.ToString()}
		ElseIf ($O -is "Xml") {(@(Select-XML -XML $O *) -Join "$NewLine$Space") + $NewLine}
		ElseIf ($i -gt $Depth) {$Type = $True; "..."}
		ElseIf ($O -is "Array") {"@(", @(&{For ($_ = 0; $_ -lt $O.Count; $_++) {Iterate $O[$_]}}), ", ", ")"}
		ElseIf ($O.GetEnumerator.OverloadDefinitions) {"@{", @(ForEach($_ in $O.Keys) {Iterate $O.$_ "$_ = "}), "; ", "}"}
		ElseIf ($O.PSObject.Properties -and !$O.value.GetTypeCode) {"{", @(ForEach($_ in $O.PSObject.Properties | Select -Exp Name) {Iterate $O.$_ "$_`: "}), "; ", "}"}
		Else {$Type = $True; "?"}}
	If ($Type) {$Prefix += "[" + $(Try {$O.GetType()} Catch {$Error.Remove($Error[0]); "$Var.PSTypeNames[0]"}).ToString().Split(".")[-1] + "]"}
	"$Space$Prefix" + $(If ($V -is "Array") {
		$V[0] + $(If ($V[1]) {
			If ($NewLine) {$V[2] = $NewLine}
			$NewLine + ($V[1] -Join $V[2]) + $NewLine + $Space
		} Else {""}) + $V[3]
	} Else {$V})
}; Set-Alias CText ConvertTo-Text -Scope:Global -Description "Convert value to readable text"

Function Global:ConvertTo-Text1([Alias("Value")]$O, [Int]$Depth = 9, [Switch]$Type, [Switch]$Expand, [Int]$Strip = -1, [String]$Prefix, [Int]$i) {
	Function Iterate($Value, [String]$Prefix, [Int]$i = $i + 1) {ConvertTo-Text $Value -Depth:$Depth -Strip:$Strip -Type:$Type -Expand:$Expand -Prefix:$Prefix -i:$i}
	$NewLine, $Space = If ($Expand) {"`r`n", ("`t" * $i)} Else{"", ""}
	If ($O -eq $Null) {$V = '$Null'} Else {
		$V = If ($O -is "Boolean")  {"`$$O"}
		ElseIf ($O -is "String") {If ($Strip -ge 0) {'"' + (($O -Replace "[\s]+", " ") -Replace "(?<=[\s\S]{$Strip})[\s\S]+", "...") + '"'} Else {"""$O"""}}
		ElseIf ($O -is "DateTime") {$O.ToString("yyyy-MM-dd HH:mm:ss")} 
		ElseIf ($O -is "ValueType" -or ($O.Value.GetTypeCode -and $O.ToString.OverloadDefinitions)) {$O.ToString()}
		ElseIf ($O -is "Xml") {(@(Select-XML -XML $O *) -Join "$NewLine$Space") + $NewLine}
		ElseIf ($i -gt $Depth) {$Type = $True; "..."}
		ElseIf ($O -is "Array") {"@(", @(&{For ($_ = 0; $_ -lt $O.Count; $_++) {Iterate $O[$_]}}), ")"}
		ElseIf ($O.GetEnumerator.OverloadDefinitions) {"@{", (@(ForEach($_ in $O.Keys) {Iterate $O.$_ "$_ = "}) -Join "; "), "}"}
		ElseIf ($O.PSObject.Properties -and !$O.value.GetTypeCode) {"{", (@(ForEach($_ in $O.PSObject.Properties | Select -Exp Name) {Iterate $O.$_ "$_`: "}) -Join "; "), "}"}
		Else {$Type = $True; "?"}}
	If ($Type) {$Prefix += "[" + $(Try {$O.GetType()} Catch {$Error.Remove($Error[0]); "$Var.PSTypeNames[0]"}).ToString().Split(".")[-1] + "]"}
	"$Space$Prefix" + $(If ($V -is "Array") {$V[0] + $(If ($V[1]) {$NewLine + ($V[1] -Join ", $NewLine") + "$NewLine$Space"} Else {""}) + $V[2]} Else {$V})
}; Set-Alias CText ConvertTo-Text -Scope:Global -Description "Convert value to readable text"

Function Global:Log-Entry {
	Param(
		$0, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15,	# PSv2 doesn't support PositionalBinding
		[ConsoleColor]$BackgroundColor, [Alias("Color")][ConsoleColor]$ForegroundColor, [String]$Separator = " ", [Switch]$NoNewline,
		[Int]$Indent = 0, [Int]$Strip = 80, [Switch]$QuoteString, [Int]$Depth = 1, [Switch]$Expand, [Switch]$Type, [Switch]$FlushErrors
	)
	$Noun = ($MyInvocation.InvocationName -Split "-")[-1]
	Function IsQ($Item) {If ($Item -is [String]) {$Item -eq "?"} Else {$False}}
	$Arguments = $MyInvocation.BoundParameters
	If (!$My.Log.ContainsKey("Location")) {Set-LogFile "$Env:Temp\$($My.Name).log"}
	If (!$My.Log.ContainsKey("Buffer")) {
		$My.Log.ProcessStart = Get-Date ((Get-Process -id $PID).StartTime); $My.Log.ScriptStart = Get-Date
		$My.Log.Buffer  = (Get-Date -Format "yyyy-MM-dd") + " `tPowerShell version: $($PSVersionTable.PSVersion), process start: " + (ConvertTo-Text $My.Log.ProcessStart) + "`r`n"
		$My.Log.Buffer += (Get-Date -Format "HH:mm:ss.ff") + "`t$($My.Name) version: $($My.Version), command line: $($My.Path) $($My.Arguments)`r`n"}
	If ($FlushErrors) {$My.Log.ErrorCount = $Error.Count} ElseIf (!$My.Log.ContainsKey("ErrorCount")) {$My.Log.ErrorCount = 0}
	While ($My.Log.ErrorCount -lt $Error.Count) {
		$Err = $Error[$Error.Count - ++$My.Log.ErrorCount]
		$My.Log.Buffer += @("`r`n")[!$My.Log.Inline] + "Error at $($Err.InvocationInfo.ScriptLineNumber),$($Err.InvocationInfo.OffsetInLine): $Err`r`n"}
	If ($My.Log.Inline) {$Items = @("")} Else {$Items = @()}
	For ($i = 0; $i -le 15; $i++) {
		If ($Arguments.ContainsKey("$i")) {$Argument = $Arguments.Item($i)} Else {$Argument = $Null}
		If ($i) {
			$Text = ConvertTo-Text $Value -Type:$Type -Depth:$Depth -Strip:$Strip -Expand:$Expand
			If ($Value -is [String] -And !$QuoteString) {$Text = $Text -Replace "^""" -Replace """$"}
		} Else {$Text = $Null}
		If (IsQ($Argument)) {$Value} Else {If (IsQ($Value)) {$Text = $Null}}
		If ($Text) {$Items += $Text}
		If ($Arguments.ContainsKey("$i")) {$Value = $Argument} Else {Break}
	}
	If ($Arguments.ContainsKey("0") -And ($Noun -ne "Debug" -or $Script:Debug)) {
		$Tabs = "`t" * $Indent; $Line = $Tabs + (($Items -Join $Separator) -Replace "`r`n", "`r`n$Tabs")
		If (!$My.Log.Inline) {$My.Log.Buffer += (Get-Date -Format "HH:mm:ss.ff") + "`t$Tabs"}
		$My.Log.Buffer += $Line -Replace "`r`n", "`r`n           `t$Tabs"
		If ($Noun -ne "Verbose" -or $Script:Verbose) {
			$Write = "Write-Host `$Line" + $((Get-Command Write-Host).Parameters.Keys | Where {$Arguments.ContainsKey($_)} | ForEach {" -$_`:`$$_"})
			Invoke-Command ([ScriptBlock]::Create($Write))
		}
	} Else {$NoNewline = $False}
	$My.Log.Inline = $NoNewline
	If (($My.Log.Location -ne "") -And $My.Log.Buffer -And !$NoNewline) {
		If ((Add-content $My.Log.Location $My.Log.Buffer -ErrorAction SilentlyContinue -PassThru).Length -gt 0) {$My.Log.Buffer = ""}
	}
}; Set-Alias Write-Log Log-Entry -Scope:Global
Set-Alias Log          Log-Entry -Scope:Global -Description "Displays and records cmdlet processing details in a file"
Set-Alias Log-Debug    Log-Entry -Scope:Global -Description "By default, the debug log entry is not displayed and not recorded, but you can display it by changing the common -Debug parameter."
Set-Alias Log-Verbose  Log-Entry -Scope:Global -Description "By default, the verbose log entry is not displayed, but you can display it by changing the common -Verbose parameter."

Function Global:Set-LogFile([Parameter(Mandatory=$True)][IO.FileInfo]$Location, [Int]$Preserve = 100e3, [String]$Divider = "") {
	$MyInvocation.BoundParameters.Keys | ForEach {$My.Log.$_ = $MyInvocation.BoundParameters.$_}
	If ($Location) {
		If ((Test-Path($Location)) -And $Preserve) {
			$My.Log.Length = (Get-Item($Location)).Length 
			If ($My.Log.Length -gt $Preserve) {									# Prevent the log file to grow indefinitely
				$Content = [String]::Join("`r`n", (Get-Content $Location))
				$Start = $Content.LastIndexOf("`r`n$Divider`r`n", $My.Log.Length - $Preserve)
				If ($Start -gt 0) {Set-Content $Location $Content.SubString($Start + $Divider.Length + 4)}
			}
			If ($My.Log.Length -gt 0) {Add-content $Location $Divider}
		}
	}
}; Set-Alias LogFile Set-LogFile -Scope:Global -Description "Redirects the log file to a custom location"

Function End-Script([Switch]$Exit, [Int]$ErrorLevel) {
	Log "End" -NoNewline
	Log ("(execution time: " + ((Get-Date) - $My.Log.ScriptStart) + ", process time: " + ((Get-Date) - $My.Log.ProcessStart) + ")")
	If ($Exit) {Exit $ErrorLevel} Else {Break Script}
}; Set-Alias End End-Script -Scope:Global -Description "Logs the remaining entries and errors and end the script"

$Error.Clear()
Set-Variable -Option ReadOnly -Force My @{
	File = Get-ChildItem $MyInvocation.MyCommand.Path
	Contents = $MyInvocation.MyCommand.ScriptContents
	Log = @{}
}
If ($My.Contents -Match '^\s*\<#([\s\S]*?)#\>') {$My.Help = $Matches[1].Trim()}
[RegEx]::Matches($My.Help, '(^|[\r\n])\s*\.(.+)\s*[\r\n]|$') | ForEach {
	If ($Caption) {$My.$Caption = $My.Help.SubString($Start, $_.Index - $Start)}
	$Caption = $_.Groups[2].ToString().Trim()
	$Start = $_.Index + $_.Length
}
$My.Title = $My.Synopsis.Trim().Split("`r`n")[0].Trim()
$My.Id = (Get-Culture).TextInfo.ToTitleCase($My.Title) -Replace "\W", ""
$My.Notes -Split("\r\n") | ForEach {$Note = $_ -Split(":", 2); If ($Note.Count -gt 1) {$My[$Note[0].Trim()] = $Note[1].Trim()}}
$My.Path = $My.File.FullName; $My.Folder = $My.File.DirectoryName; $My.Name = $My.File.BaseName
$My.Arguments = (($MyInvocation.Line + " ") -Replace ("^.*\\" + $My.File.Name.Replace(".", "\.") + "['"" ]"), "").Trim()
$Script:Debug = $MyInvocation.BoundParameters.Debug.IsPresent; $Script:Verbose = $MyInvocation.BoundParameters.Verbose.IsPresent
$MyInvocation.MyCommand.Parameters.Keys | Where {Test-Path Variable:"$_"} | ForEach {
	$Value = Get-Variable -ValueOnly $_
	If ($Value -is [IO.FileInfo]) {Set-Variable $_ -Value ([Environment]::ExpandEnvironmentVariables($Value))}
}

Main
End	
