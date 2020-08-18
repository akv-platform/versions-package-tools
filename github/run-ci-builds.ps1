param (
    [Parameter(Mandatory)] [string] $RepositoryOwner,
    [Parameter(Mandatory)] [string] $RepositoryName,
    [Parameter(Mandatory)] [string] $AccessToken,
    [Parameter(Mandatory)] [string] $EventType,
    [Parameter(Mandatory)] [string] $ToolVersions,
    [Parameter(Mandatory)] [bool] $PublishReleases
)

Import-Module (Join-Path $PSScriptRoot "github-api.psm1")

function Queue-Builds {
    param (
        [Parameter(Mandatory)] [object] $GitHubApi,
        [Parameter(Mandatory)] [string] $ToolVersions,
        [Parameter(Mandatory)] [string] $EventType,
        [Parameter(Mandatory)] [bool] $PublishReleases
    )
        
    $eventPayload = @{
        PublishReleases = $PublishReleases
    }
    
    $ToolVersions.Split(',') | ForEach-Object { 
        $version = $_.Trim()
        $eventPayload.ToolVersion = $version
        
        Write-Host "Queue build for $version..."
        $GitHubApi.DispatchWorkflow($EventType, $eventPayload)
    }
}

$gitHubApi = Get-GitHubApi -AccountName $RepositoryOwner -ProjectName $RepositoryName -AccessToken $AccessToken

Write-Host "Versions to build: $ToolVersions"
Queue-Builds -GitHubApi $gitHubApi `
             -ToolVersions $ToolVersions `
             -EventType $EventType `
             -PublishReleases $PublishReleases 
