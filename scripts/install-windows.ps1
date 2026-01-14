param(
    [ValidateSet('base', 'cli', 'development', 'gui', 'all')]
    [string]$Category = 'all'
)

$PackageMap = @{
    'googlechrome'       = @{ choco = 'google-chrome'; scoop = 'googlechrome'; winget = 'Google.Chrome' }
    'firefox'            = @{ choco = 'firefox'; scoop = 'firefox'; winget = 'Mozilla.Firefox' }
    'vscode'             = @{ choco = 'vscode'; scoop = 'vscode'; winget = 'Microsoft.VisualStudioCode' }
    '7zip'               = @{ choco = '7zip'; scoop = '7zip'; winget = '7zip.7zip' }
    '7-Zip'              = @{ choco = '7zip'; scoop = '7zip'; winget = '7zip.7zip' }
    'wezterm'            = @{ choco = 'wezterm'; scoop = 'wezterm'; winget = 'wez.wezterm' }
    'git'                = @{ choco = 'git'; scoop = 'git'; winget = 'Git.Git' }
    'fzf'                = @{ choco = 'fzf'; scoop = 'fzf'; winget = 'junegunn.fzf' }
    'fd'                 = @{ choco = 'fd'; scoop = 'fd'; winget = 'sharkdp.fd' }
    'ripgrep'            = @{ choco = 'ripgrep'; scoop = 'ripgrep'; winget = 'Microsoft.VisualStudioCode' }
    'bat'                = @{ choco = 'bat'; scoop = 'bat'; winget = 'sharkdp.bat' }
    'eza'                = @{ choco = 'eza'; scoop = 'eza'; winget = 'eza-community.eza' }
    'jq'                 = @{ choco = 'jq'; scoop = 'jq'; winget = 'stedolan.jq' }
    'btop'               = @{ choco = 'btop'; scoop = 'btop'; winget = 'aristocratos.btop' }
    'fastfetch'          = @{ choco = 'fastfetch'; scoop = 'fastfetch'; winget = 'FastfetchTeam.Fastfetch' }
    'tree'               = @{ choco = 'tree'; scoop = 'tree'; winget = 'GnuWin32.Tree' }
    'rsync'              = @{ choco = 'rsync'; scoop = 'rsync'; winget = 'RsyncForWindows.Rsync' }
    'wget'               = @{ choco = 'wget'; scoop = 'wget'; winget = 'GnuWin32.Wget' }
    'curlie'             = @{ choco = 'curlie'; scoop = 'curlie'; winget = 'curlie' }
    'tldr'               = @{ choco = 'tldr'; scoop = 'tldr'; winget = 'tldr-pages.tlrc' }
    'glow'               = @{ choco = 'glow'; scoop = 'glow'; winget = 'charmbracelet.glow' }
    'oh-my-posh'         = @{ choco = 'oh-my-posh'; scoop = 'oh-my-posh'; winget = 'JanDeDobbeleer.OhMyPosh' }
    'zellij'             = @{ choco = 'zellij'; scoop = 'zellij'; winget = 'zellij-org.zellij' }
    'watch'              = @{ choco = 'watch'; scoop = 'watch'; winget = 'MikePopoloski.watch' }
    'coreutils'          = @{ choco = 'coreutils'; scoop = 'coreutils'; winget = 'CoreUtils.CoreUtils' }
    'sed'                = @{ choco = 'sed'; scoop = 'sed'; winget = 'GnuWin32.sed' }
    'neovim'             = @{ choco = 'neovim'; scoop = 'neovim'; winget = 'Neovim.Neovim' }
    'git-delta'          = @{ choco = 'git-delta'; scoop = 'git-delta'; winget = 'dandavison.delta' }
    'difftastic'         = @{ choco = 'difftastic'; scoop = 'difftastic'; winget = 'Wilfred.difftastic' }
    'git-lfs'            = @{ choco = 'git-lfs'; scoop = 'git-lfs'; winget = 'GitLFS.GitLFS' }
    'gh'                 = @{ choco = 'gh'; scoop = 'gh'; winget = 'GitHub.cli' }
    'lazygit'            = @{ choco = 'lazygit'; scoop = 'lazygit'; winget = 'JesseDuffield.lazygit' }
    'awscli'             = @{ choco = 'awscli'; scoop = 'awscli'; winget = 'Amazon.AWSCLI' }
    'aws-vault'          = @{ choco = 'aws-vault'; scoop = 'aws-vault'; winget = '99designs.aws-vault' }
    'shellcheck'         = @{ choco = 'shellcheck'; scoop = 'shellcheck'; winget = 'KoichiSasada.shellcheck' }
    'shfmt'              = @{ choco = 'shfmt'; scoop = 'shfmt'; winget = 'mvdan.shfmt' }
    'watchexec'          = @{ choco = 'watchexec'; scoop = 'watchexec'; winget = 'watchexec.watchexec' }
    'just'               = @{ choco = 'just'; scoop = 'just'; winget = 'casey.just' }
    'lazydocker'         = @{ choco = 'lazydocker'; scoop = 'lazydocker'; winget = 'JesseDuffield.lazydocker' }
    'microsoft-windows-terminal' = @{ choco = 'microsoft-windows-terminal'; scoop = 'windows-terminal'; winget = 'Microsoft.WindowsTerminal' }
    'PowerToys'          = @{ choco = 'powertoys'; scoop = 'powertoys'; winget = 'Microsoft.PowerToys' }
    'AutoHotkey'         = @{ choco = 'autohotkey'; scoop = 'autohotkey'; winget = 'Lexikos.AutoHotkey' }
    'Flameshot'          = @{ choco = 'flameshot'; scoop = 'flameshot'; winget = 'Flameshot.Flameshot' }
    'Obsidian'           = @{ choco = 'obsidian'; scoop = 'obsidian'; winget = 'Obsidian.Obsidian' }
    'bruno'              = @{ choco = 'bruno'; scoop = 'bruno'; winget = 'Bruno.Bruno' }
    'dbeaver'            = @{ choco = 'dbeaver'; scoop = 'dbeaver'; winget = 'DBeaver.DBeaverCE' }
    'db-browser-for-sqlite' = @{ choco = 'db-browser-for-sqlite'; scoop = 'sqlitebrowser'; winget = 'sqlitebrowser.sqlitebrowser' }
    'mongodb-compass'    = @{ choco = 'mongodb-database-tools'; scoop = 'mongodb-compass'; winget = 'MongoDB.Compass' }
    'postman'            = @{ choco = 'postman'; scoop = 'postman'; winget = 'Postman.Postman' }
    'Microsoft-Teams'    = @{ choco = 'microsoft-teams'; scoop = 'teams'; winget = 'Microsoft.Teams' }
    'ChatGPT'            = @{ choco = 'chatgpt'; scoop = 'chatgpt'; winget = 'OpenAI.ChatGPT' }
    'github-desktop'     = @{ choco = 'github-desktop'; scoop = 'github'; winget = 'GitHub.GitHubDesktop' }
    'KeePassXC'          = @{ choco = 'keepassxc'; scoop = 'keepassxc'; winget = 'KeePassXCTeam.KeePassXC' }
    'adb'                = @{ choco = 'adb'; scoop = 'android-tools'; winget = 'Google.PlatformTools' }
    'scrcpy'             = @{ choco = 'scrcpy'; scoop = 'scrcpy'; winget = 'Genymobile.scrcpy' }
    'deskreen'           = @{ choco = 'deskreen'; scoop = 'deskreen'; winget = 'Deskreen.Deskreen' }
    'LocalSend'          = @{ choco = 'localsend'; scoop = 'localsend'; winget = 'LocalSend.LocalSend' }
    'docker-desktop'     = @{ choco = 'docker-desktop'; scoop = 'docker'; winget = 'Docker.DockerDesktop' }
}

function Install-ChocolateyPackage {
    param([string]$Package)

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey not found. Install with:" -ForegroundColor Yellow
        Write-Host "Set-ExecutionPolicy Bypass -Scope Process; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        return $false
    }

    Write-Host "  [Chocolatey] Installing $Package..." -ForegroundColor Cyan
    choco install $Package -y
    return $?
}

function Install-ScoopPackage {
    param([string]$Package)

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "  [Scoop] not installed. Install with:" -ForegroundColor Yellow
        Write-Host "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser; irm get.scoop.sh | iex"
        return $false
    }

    Write-Host "  [Scoop] Installing $Package..." -ForegroundColor Cyan
    scoop install $Package
    return $?
}

function Install-WingetPackage {
    param([string]$Package)

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "  [Winget] not available" -ForegroundColor Gray
        return $false
    }

    Write-Host "  [Winget] Installing $Package..." -ForegroundColor Cyan
    winget install --id $Package --accept-package-agreements --accept-source-agreements
    return $?
}

function Install-Package {
    param([string]$PackageName)

    $Mapping = $PackageMap[$PackageName]
    if (-not $Mapping) {
        $Mapping = @{ choco = $PackageName; scoop = $PackageName; winget = $PackageName }
    }

    Write-Host "Installing $PackageName..." -ForegroundColor White

    $Success = $false

    if (Install-ChocolateyPackage -Package $Mapping.choco) {
        $Success = $true
    } elseif (Get-Command scoop -ErrorAction SilentlyContinue) {
        if (Install-ScoopPackage -Package $Mapping.scoop) {
            $Success = $true
        }
    }

    if (-not $Success) {
        if (Install-WingetPackage -Package $Mapping.winget) {
            $Success = $true
        }
    }

    if ($Success) {
        Write-Host "  => Installed" -ForegroundColor Green
    } else {
        Write-Host "  => Failed" -ForegroundColor Red
    }

    return $Success
}

$Categories = @('base', 'cli', 'development', 'gui')
if ($Category -ne 'all') {
    $Categories = @($Category)
}

foreach ($Cat in $Categories) {
    $PackageFile = Join-Path $PSScriptRoot "..\packages\windows\$Cat"
    if (-not (Test-Path $PackageFile)) {
        Write-Host "Package file not found: $PackageFile" -ForegroundColor Red
        continue
    }

    Write-Host "`n=== Category: $Cat ===" -ForegroundColor Magenta
    $Packages = Get-Content $PackageFile | Where-Object { $_ -match '^\S+$' }

    foreach ($Pkg in $Packages) {
        Install-Package -PackageName $Pkg
    }
}
