# Anytype Global Search   
# Install   
## Binary file   
The binary file **GlobalSearchExample** is compiled to run under Ubuntu 25.04 on Intel hardware. I have no idea if it will run on anything else.   
## Pascal Source   
I use [Free Pascal](https://www.freepascal.org/) and the [Lazarus IDE](https://www.lazarus-ide.org/) as my development platform. I learned Pascal too many years ago, and am now relearning the modern flavour, so this code might not be too pretty.   
Anyone familiar with compiling will be able to get the main code and supporting unit compiled I am sure.   
### GlobalSearchExample.lpr   
The main program source.   
### anytypeapicalls.pas   
A Pascal unit file that is the beginnings of a library to implement all the Anytype API. For now it implements a minimum I needed to get this example doing what I wanted.   
# Execution   
## Port Redirection   
I found that I had trouble talking to the Anytype API locally without first setting up a port redirect using [socat](https://packages.debian.org/sid/socat).   
I use the following command line   
`$ socat -d TCP4-LISTEN:31009,fork,bind=192.168.1.10 TCP4:127.0.0.1:31009`   
where `192.168.1.10` is the IP Address of my local machine.   
## Environment Variables   
### ANYTYPE\_TOKEN   
This is your API Key. Include the text 'Bearer ' at the beginning. I use the command   
`$ export ANYTYPE\_TOKEN="Bearer SM/ … U="`   
where `SM/ … U=` would be replaced with your API key.   
### ANYTYPE\_URL   
This is the IP Address and other prefix stuff for the API call. I use the command   
`$ ANYTYPE\_URL="http://192.168.1.10:31009/v1/"`   
Where `192.168.1.10` would be replaced with your machine's IP Address.   
## Parameters   
### -h Help   
Prints some brief help text to screen   
### -s Spaces   
List the Space Names discovered prior to displaying search results   
### -v Verbose   
Verbose mode. By Default, object Name and Snippet values are truncated at 200 characters. This parameter increases that to ~32K   
### -q Quiet   
Quiet mode - suppresses the display of the version number   
### Other text   
Any other text is considered to be the text you wish to search for. For search text containing spaces. "enclose the text in double quotes".
If no Search Text is entered on the command line, the program will prompt for entry. You can still use the "" at the prompt to enter a search containing spaces.
# Output   
Note that pagination is not supported. Search shows only the first 1000 matches (i.e. a single call to the Search API with the maximum allowable rows). At this time no sorting is implemented.   
## Heading Line   
Consists of four pipe separated fields, something like   
`17 \| Music Days \| Page \| mySpace`   
The first column is the result number, starting at 0 to a maximum 999. "17" in this example.   
The second column is the Object Name, truncated to 200 characters unless the -v parameter is used. "Music Days" in this example.   
The third column is the Object Type. "Page" in this example.   
The fourth and final column is the name of the Space in which the object resides. "mySpace" in this example.   
## Detail   
Following the Heading line is the contents of the 'snippet' attribute, truncated to 200 characters unless the -v parameter is used.   
