*This repository replaces the former [`Write-Log`](https://github.com/iRon7/Write-Log) solution which will not be further updated. See also: [Migrating from Write-Log](https://github.com/iRon7/Log-Entry/blob/master/Migrating%20from%20Write-Log.md).*

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

Framework
=========

I have put the whole solution in a framework consisting few major parts:

 1. A framework including a help header - and a `Main` function template with a few examples
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


----------
Log-Entry
---------

The `Log-Entry` function (Alias `Write-Log`) displays and records cmdlet processing details in a file.  In general, the `Log-Entry` (or just `Log`) function everywhere were the `Write-Host` command is used. The difference is that with the `Log-Entry` command the information is not only written to the host but also captured with a time stamp in a log file.  
By default, the log file resides at <code>%temp%\\<i>&lt;ScriptName&gt;</i>.log</code> which depends on the account used:

|Account       |Location|
|--------------|--------|
|*&lt;User&gt;*|<code>C:\Users\\<i>&lt;User&gt;</i>\AppData\Local\Temp\\<i>&lt;ScriptName&gt;</i>.log</code>|
|System        |<code>C:\Windows\Temp\\<i>&lt;ScriptName&gt;</i>.log</code>|

The log file location can be redirected with the `Set-LogFile` command.

**Syntax**

    Log-Entry [<Object>] [[-BackgroundColor] <ConsoleColor>] [[-ForegroundColor] <ConsoleColor>] [[-Separator] <String>] [-NoNewline] [[-Indent]<Int32>] [[-Strip] <Int32>] [-QuoteString] [[-Depth] <Int32>] [-Expand] [-Type] [-FlushErrors] [<CommonParameters>]

|Parameter                        |Description|
|---------------------------------|-----------|
|`<Object>`                       |The object(s) displayed and recorded to the log file.|
|`-⁠BackgroundColor <ConsoleColor>`|Specifies the background color. The acceptable values for this parameter are: `Black`, `DarkBlue`, `DarkGreen`, `DarkCyan`, `DarkRed`, `DarkMagenta`, `DarkYellow`, `Gray`, `DarkGray`, `Blue`, `Green`, `Cyan`, `Red`, `Magenta`, `Yellow` and `White`.|
|`-ForegroundColor <ConsoleColor>`|Specifies the text color. The acceptable values for this parameter are: `Black`, `DarkBlue`, `DarkGreen`, `DarkCyan`, `DarkRed`, `DarkMagenta`, `DarkYellow`, `Gray`, `DarkGray`, `Blue`, `Green`, `Cyan`, `Red`, `Magenta`, `Yellow` and `White`.|
|`-Separator <String>`            |Specifies a separator string to the output between objects displayed on the console and written to the log file.|
|`-NoNewline`                     |Specifies that the content displayed in the console and written in the log file does not end with a newline character. Note that the implementation is similar to `Write-Host` implementation except that it places a separator in front of the following entry (use `-Separator ""` suppress this feature)|
|`-Indent <Int32>`                |# Specifies the indent (number of tabs) preceded to the outpute. Default: no tabs.|
|`-Strip <int32>`                 |Truncates strings at the given length and removes redundant white space characters if the value supplied is equal or larger than `0`. Set `-Strip -1` prevents truncating and the removal of with space characters. The default value `Log-Entry` is `80`.|
|`-QuoteString`                   |Quote bare strings. (strings embedded in object will always be quoted.)|
|`-Depth <int32>`                 |The maximal number of recursive iterations to reveal embedded objects. The default depth for `Log-Entry` is `1`.|
|`-Expand`                        |Expands embedded objects over multiple lines for better readability.|
|`-Type`                          |Explicitly reveals the type of the object by adding `[<Type>]` in front of the objects.|
|`-FlushErrors`                   |Suppresses any errors that occurred since last log entry|

**Examples**

Here are a few commands that show some of the features of the `Log-Entry` framework:

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

**Display**

The example commands are displayed in the following format:

[![Display][1]][1]

**Log file**

The example commands record the following information in the log file: 


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

**Complex objects**

`Log-Entry` can also help you to discover complex objects (at run time), e.g.:

    Log "Volatile Environment:" (Get-Item "HKCU:\Volatile Environment") -Expand
    Log "WinNT user object:" ([ADSI]"WinNT://./$Env:Username") -Depth 5 -Expand
    Log "The 'My' object, used by the Log-Entry engine, contains this:" $My -Expand


----------
Set-LogFile
-----------

The `Set-LogFile` function (Alias: `LogFile`) redirects the log file to a different location (the default location is: <code>%temp%\<i>&lt;ScriptName&gt;</i>.log</code>). Each time a script starts logging, a new session will be created in the log file.   
Each log file session starts with:

<code><i>&lt;yyyy-MM-dd&gt;</i>  PowerShell version: <i>&lt;PowerShell version&gt;</i>, process start: <i>&lt;yyyy-MM-dd HH:mm:ss&gt;</i></code>  
<code><i>&lt;HH:mm:ss.ff&gt;</i> Log-Entry version: <i>&lt;script version&gt;</i>, command line: <i>&lt;command line&gt;</i></code>

Log file sessions are separated by a divider which is by default an empty line. Each time a new session is started, the size of the log file is checked. If the log file is larger then the file size to preserve, all *complete* sessions are removed from the start of the log file preserving at least 100Kb (default).

**Syntax**

    Set-LogFile [-File] <String> [[-Preserve] <Int32>] [[-Divider] <String>] [<CommonParameters>]

|Parameter             |Description|
|----------------------|-----------|
|`-Location <FileInfo>`|The location of the log file.|
|`-Preserve <Int32>`   |Size to preserve. The default is 100Kb. To prevent log file truncating, set`-Preserve 0`.|
|`-Divider <String>`   |Divider between sessions. The default is an empty line|

**Note**

Empty lines (with a zero length) can usually not be logged because spaces and tabs are attached to newlines to align the information with the rest of the contents. 

----------
End-Script
----------

The `End-Script` function (Alias: `End`) is not required although it is recommended as it logs the remaining errors and terminates the log file with the following information:

<code><i>&lt;HH:mm:ss.ff&gt;</i>	End (Execution time: <i>&lt;dd:HH:mm:ss.fffffff&gt;</i>, Process time: <i>&lt;dd:HH:mm:ss.fffffff&gt;</i>)</code>

**Syntax**

    Set-LogFile [-Exit] [[-ErrorLEvel] <Int32>] [<CommonParameters>]

|Parameter            |Description|
|---------------------|-----------|
|`-Exit`              |Exits the host console.|
|`-ErrorLevel <Int32>`|Returns an `ErrorLevel` (only when `-Exit`).|


----------
ConvertTo-Text
--------------

The `ConvertTo-Text` function (Alias `CText`) recursively converts PowerShell object to readable text this includes hash tables, custom objects and revealing type details (like `$Null` vs an empty string).

**Syntax**

    ConvertTo-Text [<Object>] [[-Depth] <int>] [[-Strip] <int>] <string>] [-Expand] [-Type]

|Parameter     |Description|
|--------------|-----------|
|`<Object>`    |The object (position 0) that should be converted a readable value.|
|`-⁠Depth <int>`|The maximal number of recursive iterations to reveal embedded objects. The default depth for `ConvertTo-Text` is `9`.|
|`-Strip <int>`|Truncates strings at the given length and removes redundant white space characters if the value supplied is equal or larger than `0`. Set `-Strip -1` prevents truncating and the removal of with space characters. The default value for `ConvertTo-Text` is `-1`.|
|`-Expand`     |Expands embedded objects over multiple lines for better readability.|
|`-Type`       |Explicitly reveals the type of the object by adding `[<Type>]` in front of the objects.|

**Examples**

The following command returns a string that describes the object contained by the `$var` variable:

     ConvertTo-Text $Var

The following command returns a string containing `$Null` (rather then an empty string):

    ConvertTo-Text $Null

The following command returns a string containing the hash table as shown in the example (rather then `System.Collections.DictionaryEntry...`):

	ConvertTo-Text @{one = 1; two = 2; three = 3}

The following command returns a string revealing the `WinNT User` object up to a level of 5 deep and expands the embedded object over multiple lines:

    ConvertTo-Text ([ADSI]"WinNT://./$Env:Username") -Depth 5 -Expand

**Notes**

The `ConvertTo-Text` function (alias `CText`)  mainly exists as a helper for the `Log-Entry` function but could be used to e.g. quickly resolve an object without logging: `Write-Host (CText $Var)`.


  [1]: https://i.stack.imgur.com/GLHU1.png
