param (
    [Parameter(Mandatory)] [string] $RepositoryOwner,
    [Parameter(Mandatory)] [string] $RepositoryName,
    [Parameter(Mandatory)] [string] $AccessToken,
    [Parameter(Mandatory)] [string] $WorkflowFileName,
    [Parameter(Mandatory)] [string] $WorkflowDispatchRef,
    [Parameter(Mandatory)] [string] $ToolVersions,
    [Parameter(Mandatory)] [string] $PublishReleases
)

Import-Module (Join-Path $PSScriptRoot "github-api.psm1")

function Queue-Builds {
    param (
        [Parameter(Mandatory)] [object] $GitHubApi,
        [Parameter(Mandatory)] [string] $ToolVersions,
        [Parameter(Mandatory)] [string] $WorkflowFileName,
        [Parameter(Mandatory)] [string] $WorkflowDispatchRef,
        [Parameter(Mandatory)] [string] $PublishReleases
    )
        
    $inputs = @{
        PUBLISH_RELEASES = $PublishReleases
    }
    
    $ToolVersions.Split(',') | ForEach-Object { 
        $version = $_.Trim()
        $inputs.VERSION = $version

        Write-Host "Queue build for $version..."
        $GitHubApi.CreateWorkflowDispatch($WorkflowFileName, $WorkflowDispatchRef, $inputs)
    }
}

$gitHubApi = Get-GitHubApi -AccountName $RepositoryOwner -ProjectName $RepositoryName -AccessToken $AccessToken

Write-Host "Versions to build: $ToolVersions"
Queue-Builds -GitHubApi $gitHubApi `
             -ToolVersions $ToolVersions `
             -WorkflowFileName $WorkflowFileName `
             -WorkflowDispatchRef $WorkflowDispatchRef `
             -PublishReleases $PublishReleases 
