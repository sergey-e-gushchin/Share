Function New-ITGPersonalGroup {
    [CmdletBinding(
        SupportsShouldProcess = $true
 		, ConfirmImpact = 'Medium'
    )] 
    param (
        [parameter(
            Mandatory = $true
            , ValueFromPipeline = $true
            , ValueFromPipelineByPropertyName = $true
        )]
        [Alias ('DistinguishedName')]
        [System.String] $OUDistinguishedName
    )
    process {
        New-ADGroup `
            -Name 'Персонал' `
            -GroupCategory Security `
            -GroupScope Global `
            -path ( $OUDistinguishedName ) `
            -SamAccountName "Персонал $(Get-ITGOUsamAccountNameSuffix $OUDistinguishedName)" `
            -WhatIf:$WhatIfPreference `
			-Verbose:$VerbosePreference `
        ;
    }
}

[System.Text.RegularExpressions.Regex] $distNameComponent = ` 
    '(?<currentObjectId>(?<type>\w+)=(?<Id>.*?)),(?<parentContainerId>.*)'

Function Get-ITGOUsamAccountNameSuffix {
    param (
        [parameter(
            Mandatory = $true
            , ValueFromPipeline = $true
            , ValueFromPipelineByPropertyName = $true
        )]
        $DistinguishedName
    )
    process {
        $null = $DistinguishedName -match $distNameComponent;
        if ( $Matches['type'] -ne 'OU' ) {
            return '';
        };
        $OU = Get-ADOrganizationalUnit `
            -Identity $DistinguishedName `
            -Properties adminDisplayName
        ;
        $suffix = $OU.name;
        if ( $OU.adminDisplayName ) {
            $suffix = $OU.adminDisplayName
        };
        $parentId = $Matches['parentContainerId'];
        $parentSuffix = Get-ITGOUsamAccountNameSuffix $parentId;
        if ( $parentSuffix ) {
            $suffix = "$parentSuffix-$suffix";
        };
        return $suffix;
    }
} 

# Get-ADOrganizationalUnit -SearchBase 'OU=ФБУ \"Тест-С.-Петербург\",DC=test-csm,DC=nov,DC=ru' -SearchScope Subtree -Filter '*' | New-ITGPersonalGroup -Verbose -WhatIf
