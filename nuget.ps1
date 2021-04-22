param ([string] $TargetName, [string] $TargetDir, [string] $ApiKey, [string]$Suffix = "")

# versioning info
$VERSION = "$(Get-Date -UFormat "%Y.%m%d").$($env:GITHUB_RUN_NUMBER)$($Suffix)"
$WORKINGDIR = Get-Location

# nuget restore
nuget locales all -clear
nuget restore

# build files
Write-Output "Building $TargetName Version $VERSION"
dotnet build -c Release /p:PackageVersion=$VERSION

# pack into nuget files with the suffix if we have one
Write-Output "Publishing $TargetName Version $VERSION"
dotnet pack ".\$TargetDir" -o $WORKINGDIR -c Release -p:PackageVersion=$VERSION -p:Version=$VERSION

# recursively push all nuget files created
Get-ChildItem -Path $WORKINGDIR -Filter *.nupkg -Recurse -File -Name | ForEach-Object {
    dotnet nuget push $_ --api-key $ApiKey --source https://api.nuget.org/v3/index.json --force-english-output
}
