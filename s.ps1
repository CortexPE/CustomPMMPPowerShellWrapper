[CmdletBinding(PositionalBinding=$false)]
param (
	[string]$php = "",
	[switch]$Loop = $true,
	[switch]$Update = $false,
	[string][Parameter(ValueFromRemainingArguments)]$extraPocketMineArgs
)

if($php -ne ""){
	$binary = $php
}elseif(Test-Path "bin\php\php.exe"){
	$env:PHPRC = ""
	$binary = "bin\php\php.exe"
}else{
	$binary = "php"
}

if($Update){
	echo (" -=====- Updating PocketMine-MP PHAR -=====- ")
	echo ("[*] Getting Latest Build Info")
	(New-Object System.Net.WebClient).DownloadFile("https://jenkins.pmmp.io/job/PocketMine-MP/lastSuccessfulBuild/artifact/build_info.json", "$PSScriptRoot\build_info.json")
	echo ("[*] Parsing Latest Build Info")
	$json = Get-Content -Path "$PSScriptRoot\build_info.json"
	$x = $json | ConvertFrom-Json
	$phar_name = $x.phar_name
	echo ("[*] Downloading Latest Phar")
	$url = "https://jenkins.pmmp.io/job/PocketMine-MP/lastSuccessfulBuild/artifact/" + $phar_name;
	(New-Object System.Net.WebClient).DownloadFile($url, "$PSScriptRoot\PocketMine-MP.phar")
	echo ("[*] Cleaning Up...")
	Remove-Item "$PSScriptRoot\build_info.json"
	echo (" -======- Extracting SRC from PHAR -======- ")
	echo ("[*] Extracting PHAR...")
	$phpcom = "$binary -r `"(new Phar(`'PocketMine-MP.phar`'))->extractTo(getcwd(), null, true);`""
	iex $phpcom
	echo ("[*] Starting PocketMine-MP Server")
}

if(Test-Path "PocketMine-MP.phar"){
	$file = "PocketMine-MP.phar"
}elseif(Test-Path "src\pocketmine\PocketMine.php"){
	$file = "src\pocketmine\PocketMine.php"
}else{
	echo "Couldn't find a valid PocketMine-MP installation"
	pause
	exit 1
}

function StartServer{
	$command = "powershell " + $binary + " " + $file + " " + $extraPocketMineArgs
	iex $command
}

$loops = 0

StartServer

while($Loop){
	if($loops -ne 0){
		echo ("Restarted " + $loops + " times")
	}
	$loops++
	StartServer
}