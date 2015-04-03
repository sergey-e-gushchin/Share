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
            -DisplayName 'Персонал' `
            -Description "Персонал отдела $(Get-ITGGroupDescription $OUDistinguishedName)" `
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

Function Get-ITGGroupDescription {
    param (
        [parameter(
            Mandatory = $true
            , ValueFromPipeline = $true
            , ValueFromPipelineByPropertyName = $true
        )]
        $OUName
        )
        process {
        $name = Get-ADOrganizationalUnit `
              -Identity $OUName
              ;
        $Description = $Name.name;
        return $Description;
    }
}