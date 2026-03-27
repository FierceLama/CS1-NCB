Import-Module ActiveDirectory

# Automatisch domein DN ophalen (aanbevolen)
$DomainDN = (Get-ADDomain).DistinguishedName

# Root OU
$RootOUName = "knowledgehub"
$RootOU = "OU=$RootOUName,$DomainDN"

# Maak root OU aan als deze niet bestaat
if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$RootOU'" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name $RootOUName -Path $DomainDN -ProtectedFromAccidentalDeletion $true
    Write-Host "Root OU aangemaakt: $RootOUName"
}

# Definieer OU structuur
$OUs = @(
    # Directie
    "OU=Directie,$RootOU",
    "OU=Library Director,OU=Directie,$RootOU",

    # IT & Innovation
    "OU=IT & Innovation,$RootOU",
    "OU=IT & Innovation Coordinator,OU=IT & Innovation,$RootOU",
    "OU=Part-time IT Administrator,OU=IT & Innovation,$RootOU",
    "OU=Network & Security Intern,OU=IT & Innovation,$RootOU",
    "OU=Admin Assistant,OU=IT & Innovation,$RootOU",
    "OU=System Documentation Assistant,OU=IT & Innovation,$RootOU",

    # Operations
    "OU=Operations,$RootOU",
    "OU=Operations Coordinator,OU=Operations,$RootOU",
    "OU=Collection Manager,OU=Operations,$RootOU",
    "OU=Acquisitions Officer,OU=Operations,$RootOU",
    "OU=Front Desk Assistant,OU=Operations,$RootOU",
    "OU=Facility Manager,OU=Operations,$RootOU",

    # Visitors
    "OU=Visitors,$RootOU",
    "OU=Public Users,OU=Visitors,$RootOU",
    "OU=Wi-Fi Users,OU=Public Users,OU=Visitors,$RootOU",
    "OU=Public Terminals,OU=Public Users,OU=Visitors,$RootOU",
    "OU=Visitor Support Desk,OU=Visitors,$RootOU"
)

# Aanmaken van OU's
foreach ($OU in $OUs) {
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OU'" -ErrorAction SilentlyContinue)) {
        $Name = ($OU -split ",")[0] -replace "OU="
        $Path = $OU.Substring($OU.IndexOf(",") + 1)

        New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $true
        Write-Host "OU aangemaakt: $Name"
    }
    else {
        Write-Host "Bestaat al: $OU"
    }
}

Write-Host "OU structuur knowledgehub is volledig aangemaakt."