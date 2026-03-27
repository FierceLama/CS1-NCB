Import-Module ActiveDirectory

$DomainDN = (Get-ADDomain).DistinguishedName
$RootOU = "OU=knowledgehub,$DomainDN"

# =====================================
# 1️⃣ USERS AANMAKEN
# =====================================

$Users = @(
    @{Name="L.Jansen"; Sam="ljansen"; Title="Library Director"; OU="Directie"},
    @{Name="M.van Dijk"; Sam="mvandijk"; Title="IT & Innovation Coordinator"; OU="IT & Innovation"},
    @{Name="T.Willems"; Sam="twillems"; Title="Part-time IT Administrator"; OU="IT & Innovation"},
    @{Name="K.Noorlander"; Sam="knoorlander"; Title="Network & Security Intern"; OU="IT & Innovation"},
    @{Name="F.Bakker"; Sam="fbakker"; Title="Admin Assistant"; OU="IT & Innovation"},
    @{Name="Y.Peters"; Sam="ypeters"; Title="System Documentation Assistant"; OU="IT & Innovation"},
    @{Name="R.Scholten"; Sam="rscholten"; Title="Operations Coordinator"; OU="Operations"},
    @{Name="S.Koenraad"; Sam="skoenraad"; Title="Collection Manager"; OU="Operations"},
    @{Name="I.Blom"; Sam="iblom"; Title="Acquisitions Officer"; OU="Operations"},
    @{Name="A.Vermeulen"; Sam="avermuelen"; Title="Front Desk Assistant"; OU="Operations"},
    @{Name="P.Hendriks"; Sam="phendriks"; Title="Facility Manager"; OU="Operations"}
)

foreach ($User in $Users) {

    $UserOU = "OU=$($User.OU),$RootOU"

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($User.Sam)'" -ErrorAction SilentlyContinue)) {

        New-ADUser `
            -Name $User.Name `
            -SamAccountName $User.Sam `
            -UserPrincipalName "$($User.Sam)@$(Get-ADDomain).DNSRoot" `
            -Path $UserOU `
            -Title $User.Title `
            -AccountPassword (ConvertTo-SecureString "Welkom123!" -AsPlainText -Force) `
            -Enabled $true

        Write-Host "User aangemaakt: $($User.Name)"
    }
}

# =====================================
# 2️⃣ GLOBAL GROUPS
# =====================================

$GlobalGroups = @(
"GG_LibraryDirector",
"GG_ITCoordinator",
"GG_ITAdmin",
"GG_NetworkIntern",
"GG_AdminAssistant",
"GG_DocAssistant",
"GG_OperationsCoordinator",
"GG_CollectionManager",
"GG_Acquisitions",
"GG_FrontDesk",
"GG_FacilityManager"
)

foreach ($Group in $GlobalGroups) {
    if (-not (Get-ADGroup -Filter "Name -eq '$Group'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $Group -GroupScope Global -GroupCategory Security -Path $RootOU
        Write-Host "Global Group aangemaakt: $Group"
    }
}

# =====================================
# 3️⃣ DOMAIN LOCAL GROUPS
# =====================================

$DLGroups = @(
"DLG_Management_RW",
"DLG_IT_RW",
"DLG_Operations_RW"
)

foreach ($Group in $DLGroups) {
    if (-not (Get-ADGroup -Filter "Name -eq '$Group'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $Group -GroupScope DomainLocal -GroupCategory Security -Path $RootOU
        Write-Host "Domain Local Group aangemaakt: $Group"
    }
}

# =====================================
# 4️⃣ IGDLA KOPPELING
# =====================================

# Users -> Global Groups
Add-ADGroupMember GG_LibraryDirector ljansen
Add-ADGroupMember GG_ITCoordinator mvandijk
Add-ADGroupMember GG_ITAdmin twillems
Add-ADGroupMember GG_NetworkIntern knoorlander
Add-ADGroupMember GG_AdminAssistant fbakker
Add-ADGroupMember GG_DocAssistant ypeters
Add-ADGroupMember GG_OperationsCoordinator rscholten
Add-ADGroupMember GG_CollectionManager skoenraad
Add-ADGroupMember GG_Acquisitions iblom
Add-ADGroupMember GG_FrontDesk avermuelen
Add-ADGroupMember GG_FacilityManager phendriks

# Global -> Domain Local
Add-ADGroupMember DLG_Management_RW GG_LibraryDirector
Add-ADGroupMember DLG_IT_RW GG_ITCoordinator,GG_ITAdmin,GG_NetworkIntern
Add-ADGroupMember DLG_Operations_RW GG_OperationsCoordinator,GG_CollectionManager,GG_Acquisitions,GG_FrontDesk,GG_FacilityManager

Write-Host "IGDLA structuur succesvol toegepast."