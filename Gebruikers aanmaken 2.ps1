Import-Module ActiveDirectory

$DomainDN = (Get-ADDomain).DistinguishedName
$DNSRoot = (Get-ADDomain).DNSRoot
$RootOUName = "knowledgehub"
$RootOU = "OU=$RootOUName,$DomainDN"

Write-Host "=== START SCRIPT ===" -ForegroundColor Cyan

# =====================================
# 1️⃣ ROOT OU
# =====================================

if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$RootOU'" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name $RootOUName -Path $DomainDN -ProtectedFromAccidentalDeletion $true
    Write-Host "Root OU aangemaakt" -ForegroundColor Green
}

# =====================================
# 2️⃣ SUB OUs
# =====================================

$SubOUs = @(
"Directie",
"IT & Innovation",
"Operations",
"Visitors"
)

foreach ($OU in $SubOUs) {
    $FullPath = "OU=$OU,$RootOU"

    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$FullPath'" -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $OU -Path $RootOU -ProtectedFromAccidentalDeletion $true
        Write-Host "OU aangemaakt: $OU" -ForegroundColor Green
    }
}

# =====================================
# 3️⃣ USERS
# =====================================

$Users = @(
@{Name="L.Jansen"; Sam="ljansen"; Title="Library Director"; OU="Directie"},
@{Name="M.vanDijk"; Sam="mvandijk"; Title="IT & Innovation Coordinator"; OU="IT & Innovation"},
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

    try {
        if (-not (Get-ADUser -Filter "SamAccountName -eq '$($User.Sam)'" -ErrorAction Stop)) {

            New-ADUser `
                -Name $User.Name `
                -SamAccountName $User.Sam `
                -UserPrincipalName "$($User.Sam)@$DNSRoot" `
                -Path $UserOU `
                -Title $User.Title `
                -AccountPassword (ConvertTo-SecureString "TempPass2024!" -AsPlainText -Force) `
                -Enabled $true `
                -ChangePasswordAtLogon $true `
                -ErrorAction Stop

            Write-Host "User aangemaakt: $($User.Name)" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "FOUT bij user: $($User.Name)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }
}

# =====================================
# 4️⃣ GLOBAL GROUPS (GG)
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
        Write-Host "Global Group aangemaakt: $Group" -ForegroundColor Green
    }
}

# =====================================
# 5️⃣ DOMAIN LOCAL GROUPS (DLG)
# =====================================

$DLGroups = @(
"DLG_Management_RW",
"DLG_IT_RW",
"DLG_Operations_RW"
)

foreach ($Group in $DLGroups) {
    if (-not (Get-ADGroup -Filter "Name -eq '$Group'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $Group -GroupScope DomainLocal -GroupCategory Security -Path $RootOU
        Write-Host "Domain Local Group aangemaakt: $Group" -ForegroundColor Green
    }
}

# =====================================
# 6️⃣ IGDLA TOEWIJZING
# =====================================

# Users → Global Groups
Add-ADGroupMember GG_LibraryDirector ljansen -ErrorAction SilentlyContinue
Add-ADGroupMember GG_ITCoordinator mvandijk -ErrorAction SilentlyContinue
Add-ADGroupMember GG_ITAdmin twillems -ErrorAction SilentlyContinue
Add-ADGroupMember GG_NetworkIntern knoorlander -ErrorAction SilentlyContinue
Add-ADGroupMember GG_AdminAssistant fbakker -ErrorAction SilentlyContinue
Add-ADGroupMember GG_DocAssistant ypeters -ErrorAction SilentlyContinue
Add-ADGroupMember GG_OperationsCoordinator rscholten -ErrorAction SilentlyContinue
Add-ADGroupMember GG_CollectionManager skoenraad -ErrorAction SilentlyContinue
Add-ADGroupMember GG_Acquisitions iblom -ErrorAction SilentlyContinue
Add-ADGroupMember GG_FrontDesk avermuelen -ErrorAction SilentlyContinue
Add-ADGroupMember GG_FacilityManager phendriks -ErrorAction SilentlyContinue

# Global Groups → Domain Local Groups
Add-ADGroupMember DLG_Management_RW GG_LibraryDirector -ErrorAction SilentlyContinue
Add-ADGroupMember DLG_IT_RW GG_ITCoordinator,GG_ITAdmin,GG_NetworkIntern -ErrorAction SilentlyContinue
Add-ADGroupMember DLG_Operations_RW GG_OperationsCoordinator,GG_CollectionManager,GG_Acquisitions,GG_FrontDesk,GG_FacilityManager -ErrorAction SilentlyContinue

Write-Host "=== SCRIPT VOLTOOID – IGDLA CORRECT TOEGEPAST ===" -ForegroundColor Cyan