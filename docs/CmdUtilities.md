> ### List of utilities and configurations used on the command-line
I have customized several of those to my own needs. The customizations are part of this repository and are mentioned in other topics.
[This](https://dev.to/_darrenburns/10-tools-to-power-up-your-command-line-4id4) article series (links are the dots at the top of the page) has a nice summary of the Linux/Unix version of many of the tools listed below. 
The installation is either done via Install-Module or [chocolatey](https://chocolatey.org) (Chocolatey installations can be also done through Install-Package see [here](https://www.petri.com/what-is-chocolatey-and-should-i-use-it-in-my-environment)).

| Name | Source | Description | Installation |
| --- | --- | --- | --- |
| z | [GitHub](https://github.com/vincpa/z) | Change directory based on partial matches of previously visited folders | Install-Module -Name z |
| PSFzf | [GitHub](https://github.com/kelleyma49/PSFzf) | PowerShell port of fzf -> Fuzzy finder with integration for PSReadLine | Install-Module -Name PSFzf |
| bat | [GitHub](https://github.com/sharkdp/bat) | View files with syntax highlighting (aliased to cat on my system) | choco install bat -y|
| lf | [GitHub](https://github.com/gokcehan/lf) | Ter
