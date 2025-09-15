
<#PSScriptInfo

.VERSION 0.1

.GUID d32bf2ce-f3e6-4909-958d-d80c28bf9f8f

.AUTHOR June Castillote

.COMPANYNAME

.COPYRIGHT

.TAGS "Office 365","Microsoft 365 Group","Unified Group","Group Member","Group Owner"

.LICENSEURI https://github.com/junecastillote/Unified-Group-Member-List-Extractor/blob/main/LICENSE

.PROJECTURI https://github.com/junecastillote/Unified-Group-Member-List-Extractor

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<#

.DESCRIPTION
 PowerShell script to list members and owners of Microsoft 365 groups and optionally export to CSV

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory, ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    $Group,

    [Parameter()]
    [string]
    $OutCSV
)

begin {
    $validType = @('System.String', 'Deserialized.Microsoft.Exchange.Data.Directory.Management.UnifiedGroupBase')
    $groupObjectCollection = [System.Collections.Generic.List[System.Object]]@()
}
process {

    foreach ($item in $group) {
        $groupObjectCollection.Add($item)
    }


}
end {
    $result = @()
    foreach ($item in $groupObjectCollection) {
        $inputType = $item.psobject.TypeNames[0]

        if ($validType -notcontains $inputType.ToString()) {
            Write-Error "The input object type of [$($inputType)] is not valid. Only [System.String] and [Deserialized.Microsoft.Exchange.Data.Directory.Management.UnifiedGroupBase] types are accepted."
            continue
        }
        else {

        }

        if ($inputType -eq 'System.String') {
            try {
                $groupObject = Get-UnifiedGroup -Identity $item -ErrorAction Stop
            }
            catch {
                Write-Error $_.Exception.Message
                continue
            }
        }

        if ($inputType -eq 'Deserialized.Microsoft.Exchange.Data.Directory.Management.UnifiedGroupBase') {
            $groupObject = $item
        }

        Write-Verbose "Processing $($groupObject.DisplayName)..."

        $groupMemberCollection = @(get-unifiedGroupLinks -Identity $groupObject -LinkType Members | Select-Object DisplayName, PrimarySmtpAddress, @{n = 'MemberType'; e = { 'Member' } })
        $groupOwnerCollection = @(get-unifiedGroupLinks -Identity $groupObject -LinkType Owners | Select-Object DisplayName, PrimarySmtpAddress, @{n = 'MemberType'; e = { 'Owner' } })
        $members = @($groupMemberCollection + $groupOwnerCollection)
        $groupType = $(
            if ($groupObject.ResourceProvisioningOptions -eq 'Team') { 'Team' } else { 'Group' }
        )

        if ($members.Count -gt 0) {
            for ($i = 0; $i -lt $members.Count; $i++) {
                $member = $members[$i]
                $result += [pscustomobject](
                    [ordered]@{
                        GroupName        = $groupObject.DisplayName
                        GroupEmail       = $groupObject.PrimarySmtpAddress
                        GroupType        = $groupType
                        GroupMemberTotal = $members.Count
                        MemberName       = $member.DisplayName
                        MemberEmail      = $member.PrimarySmtpAddress
                        MemberType       = $member.MemberType
                    }
                )
            }
        }
        else {
            $result += [pscustomobject](
                [ordered]@{
                    GroupName        = $groupObject.DisplayName
                    GroupEmail       = $groupObject.PrimarySmtpAddress
                    GroupType        = $groupType
                    GroupMemberTotal = 0
                    MemberName       = ''
                    MemberEmail      = ''
                    MemberType       = ''
                }
            )
        }
    }
    if ($OutCSV) {
        try {
            $result | Export-Csv -Path $OutCSV -Confirm:$false -Force -NoTypeInformation -ErrorAction Stop
        }
        catch {
            Write-Error $_.Exception.Message
            return $result
        }
    }
    else {
        return $result
    }
}









