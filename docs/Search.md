### Searching for files by name and content
> Since this searching for files and folders is something I frequently do, I have created and modified some functions and modules to handle searching for files by name and their content through PowerShell. Searching is done generally done through three different means:

1. Using Everything search [commandline interface](https://www.voidtools.com/downloads/#cli).
2. Using [Lucene](https://lucene.apache.org/).
3. Using [Select-String](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-string?view=powershell-6) or a more performant [F# port](https://devblogs.microsoft.com/fsharpteam/rethinking-findstr-with-f-and-powershell/) of the same
