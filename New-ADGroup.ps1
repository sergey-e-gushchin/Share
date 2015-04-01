$path = 'OU=Новгородский филиал,OU=ФБУ \"Тест-С.-Петербург\",DC=test-csm,DC=nov,DC=ru' ;

$ADGroup = Get-ADGroup `
    -Filter {Name -eq "Персонал"} `
    -SearchScope Subtree `
    -SearchBase $path ;

$GetADOrganizationalUnit = Get-ADOrganizationalUnit `
    -Filter 'OU -notlike "Новгородский филиал"' `
    -SearchScope Subtree `
    -SearchBase $path ;
$targetpath = [string] $GetADOrganizationalUnit.DistinguishedName ;

$NewADGroup = New-ADGroup `
    -Name "Персонал" `
    -GroupCategory Security `
    -GroupScope Global `
    -DisplayName "Персонал" `
    -SamAccountName Users `
    -path $targetpath `
    -PassThru ;
    
if($ADGroup) 
    {
        Write-Host "Группа(ы) уже существует(ют)"
    }
else
    {
        $NewADGroup
        Write-Host "Группа(ы) успешно создана(ы)"
    } 