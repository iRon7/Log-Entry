*This article is completely revised 2017-07-18 as the new [`Log-Entry`](https://github.com/iRon7/Log-Entry) solution replaces the former [`Write-Log`](https://github.com/iRon7/Write-Log) solution which will not be further updated. See also: [Migrating from Write-Log](https://github.com/iRon7/Log-Entry/blob/master/Migrating%20from%20Write-Log.md).*


----------
In general, I find that logging is underestimated for Microsoft scripting languages. Not only at design time of a script (or cmdlet) logging comes in handy but when the script gets deployed and something goes wrong you often wish that you had much better logging in place.  
That's why I think that scripting languages as PowerShell (as well as its predecessor VBScript) should actually come with a more sophisticated native logging capabilities than what is available now.

Best practice
-------------

Even before PowerShell existed, I had a similar need for a adequate logging function in VBScript. As a matter of fact, some of the concepts I was using for VBScript, I am still using in PowerShell. Meanwhile, I have extended my logging solution with a whole list of improvements and requirements as I expect a log function to be:

 - Robust and never cause the actual cmdlet to fail unexpectedly (even  
   when e.g. the access to the log file is for some reason denied)

 - Simple to invoke and possibly be used as a   
   `Write-Host` command replacement

 - Resolve all data types and reveal the content

 - Capture unexpected native script errors

 - Capable to pass-through objects for inline logging to minimize additional code lines

 - Have an accurate (10ms) timestamp per entry for performance trouble   
   shooting

 - Standard capturing troubleshooting information like:

  - Script version

  - PowerShell version

  - When it was ran (process start time)

  - How (parameters) and from where (location) it was ran

 - Appended append information to a configurable log file which doesn't grow indefinitely

 - Downwards compatible with PowerShell version 2

Robust
------

If you want to go for a robust logging solution, you probably want to go with the native Start-Transcript cmdlet but you will probably find out that the  `Start-Transcript` lacks features, like timestamps, that you might expect from a proper logging cmdlet. You could go for a 3rd party solution but this usually means extra installation procedures and dependencies.  
So you decide to write it yourself but even the simplest solution where you just write information to a file might already cause an issue in the field: the file might not be accessible. It might even exist but your script is triggered twice and multiple instances run at the same time the log file might be open by one of instances and access is denied from the other instance  (see e.g.: https://stackoverflow.com/questions/5548283/powershell-scheduled-tasks-conflicts). And just at this point, logging should actually help you to troubleshoot what is going on as a repetitive trigger might also cause unexpected behavior in the script itself. For this particular example, the solution I present here buffers the output until it is able to write. But there are a lot more traps in writing a logging cmdlet and correctly formatting the output.

Log-Entry
=========

I have put the whole solution in a [`Log-Entry.ps1` framework](https://github.com/iRon7/Log-Entry/Log-Entry.ps1) consisting out of a  few major parts:

 1. A help header - and a `Main` function template with a few examples
 2. A `My` object that contains some script - and logging definitions
 2. Four functions to control the logging:
   - `Log-Entry` (alias `Log`) to log information and objects
   - `Set-LogFile` (alias `LogFile`) to set the location of the log file
   - `End-Script` (alias `End`) which might be used to nicely close the session
   - `ConvertTo-Text` (alias `CText`) to resolve objects

For the latest [`Log-Entry.ps1`](https://github.com/iRon7/Log-Entry/Log-Entry.ps1) version, see: https://github.com/iRon7/Log-Entry.

Usage
-----

Download the above  [`Log-Entry.ps1` framwork](https://github.com/iRon7/Log-Entry/Log-Entry.ps1) and replace the examples in the `Main {}` function with your own script.  Everywhere you would like to display and log information, use the `Log` command (similar to the `Write-Host` command syntax).  
Run the script and check the log file at: `%Temp%\<ScriptName>.Log`

Syntax
------

For details on the syntax, see: the [readme.md](https://github.com/iRon7/Log-Entry/readme.md) at https://github.com/iRon7/Log-Entry

**Example**

Here are a few commands that show some of the features of the `Log-Entry` framework:

    LogFile .\Test.log					# Redirect the log file location (Optional)
    Log -Color Yellow "Examples:"
    Log "Several examples that usually aren't displayed by Write-Host:" $NotSet @() @(@()) @(@(), @()) @($Null)
    Log -Indent 1 "Note 1: An empty string:" "" "isn't displayed by Log-Entry either (as you usually do not want every comment quoted)."
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
    Log "Below are two inline log examples (the object preceding the ""?"" is returned):"
    $Height = Log "Height:" 3 ? "Inch"
    $Width  = Log "Width:"  4 ? "Inch"
    Log-Verbose "Or one display/log line spread over multiple code lines:"
    Log "Periphery:" -NoNewline
    $Periphery = Log (2 * $Height + 2 * $Width) ? -Color Green -NoNewline
    Log "Inch"
    Log-Debug "Password:" $Password "(This will not be shown and captured unless the common -Debug argument is supplied)"

**Display**

The example commands are displayed in the following format:

[![Display][1]][1]

**Log file**

The example commands record the following information in the log file: 

<!-- language: lang-none -->

    2017-07-13 	PowerShell version: 5.1.15063.483, process start: 2017-07-13 15:39:44
    15:39:46.75	Log-Entry version: 02.00.01, command line: C:\Users\User\Scripts\Log-Entry\Log-Entry.ps1 
    15:39:46.80	Examples:
    15:39:46.94	Several examples that usually aren't displayed by Write-Host: $Null @() @() @(@(), @()) @($Null)
    15:39:46.95			Note 1: An empty string: isn't displayed by Log-Entry either (as you do not want every comment quoted).
    15:39:46.98					In case you want to reveal a (possible) empty string, use -QuoteString: ""
    15:39:47.00			Note 2: An empty array embedded in another array: @() is flattened by PowerShell (and not Write-Log).
    15:39:47.01					To prevent this use a comma in front of the embbed array:  @(@())
    15:39:47.05	A hashtable: @{one = 1, three = 3, two = 2}
    15:39:47.06	A recursive hashtable: @{
               		one = @{
               			one = @{
               				one = 1, 
               				three = 3, 
               				two = 2
               			}, 
               			three = 3, 
               			two = 2
               		}, 
               		three = 3, 
               		two = 2
               	}
    15:39:47.10	Character array: @(H, a, l, l, o,  , W, o, r, l, d)
    15:39:47.11	The following line produces a error which is captured in the log file:
    Error at 51,23: Cannot find path 'C:\NoSuchFile.txt' because it does not exist.
    15:39:47.15	File: $Null
    15:39:47.16	The switch -FlushErrors prevents the error being logged:
    15:39:47.17	File: $Null
    15:39:47.17	Below are two inline log examples (the object preceding the "?" is returned):
    15:39:47.18	Height: 3 Inch
    15:39:47.19	Width: 4 Inch
    15:39:47.19	Or one display/log line spread over multiple code lines:
    15:39:47.20	Periphery: 14 Inch
    15:39:47.27	End (Execution time: 00:00:00.5781145, Process time: 00:00:03.1067112)


  [1]: https://i.stack.imgur.com/GLHU1.png
