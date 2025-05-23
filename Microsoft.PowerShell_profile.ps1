$env:__COMPAT_LAYER = "RunAsInvoker"

$ErrorActionPreference = "SilentlyContinue"

$Host.UI.RawUI.WindowTitle = "~" # or "$location"

$username = $env:USERNAME
$pcname = hostname

#+--------------+
#| Remove alias | 
#+--------------+

if (Test-Path Alias:cd) { Remove-Item Alias:cd }
if (Test-Path Alias:ls) { Remove-Item Alias:ls }
if (Test-Path Alias:pwd) { Remove-Item Alias:pwd }
if (Test-Path Alias:mkdir) { Remove-Item Alias:mkdir }
if (Test-Path Alias:history) { Remove-Item Alias:history }

#+---------------+
#| Custom prompt |
#+---------------+

function prompt {
    
    $lastStatus = $?
    
    $location = (Get-Location).Path -replace "C:\\Users\\$env:USERNAME", "~"
    
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $adminLabel = if ($isAdmin) { "[96m[0m  " } else { "" }

    $status= if ($lastStatus) { "[92m✔[0m" } else { "[91m✘[0m" }
    
    return "$status $adminLabel[92m$username[0m@$pcname [92m$($location)[0m> "
}

#+-----------------+
#| Custom function |
#+-----------------+

function reload {
    . $PROFILE
}

function history {
    Get-Content (Get-PSReadlineOption).HistorySavePath
}

function reload-explorer {
    if (Get-Process -Name explorer -ErrorAction SilentlyContinue) 
    {Stop-Process -Name "explorer"}
    
    else
    {Start-Process -FilePath "explorer.exe"}
}

function toggle-errmsg {
    if ($ErrorActionPreference -eq 'SilentlyContinue') {
        $global:ErrorActionPreference = 'Continue'
    } else {
        $global:ErrorActionPreference = 'SilentlyContinue'
    }
    Write-Output "ErrorActionPreference is now set to '$ErrorActionPreference'"
}

#CUM - Clear Used Memory

function cum {
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    [GC]::Collect()

    Get-Process | ForEach-Object {
        try {
            $_.MinWorkingSet = 64KB
            $_.MaxWorkingSet = 256KB
        } catch {
            Write-Verbose "Failed to clear processes $($_.Name): $_"
        }
    }
    
    Write-Output "RAM cleaned"
}

function bsod {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[93m⚠ Administrator rights required[0m"
        return
    }
    else {
        taskkill.exe /f /im "svchost.exe"
    }
}

#+---------------------+
#| Function from linux |
#+---------------------+

function reboot {shutdown.exe /f /r /t 0}
function poweroff {shutdown.exe /f /s /t 0}

function whoami{Write-Output $env:USERNAME}

function uname {
    Get-CimInstance Win32_OperatingSystem | ForEach-Object {
        "$($_.Caption) $($_.Version) $($_.OSArchitecture)"
    }
}

function pkill {
    param (
        [string]$processName
    )
    taskkill.exe /f /im "$processName.exe"
}

function cd {
    param (
        [string]$path = $null
    )

    if (-not $Path) {
        Set-Location $env:userprofile
    } else {
        Set-Location $path
    }
}

function grep {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Word,

        [Parameter(Position = 1)]
        [string]$File,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$InputObject
    )

    begin {
        if ($File -and -not (Test-Path $File)) {
            Write-Error "Файл '$File' не найден."
            return
        }
        $pattern = [Regex]::Escape($Word)
    }

    process {
        $lines = @()

        if ($File) {
            $lines = Get-Content $File
        }
        elseif ($InputObject) {
            $lines = $InputObject
        }

        foreach ($line in $lines) {
            if ($line -match $pattern) {
                $highlighted = $line -replace $pattern, "[91m$Word[0m"
                Write-Host $highlighted
            }
        }
    }
}


function wc {
    param (
        [Parameter(Mandatory=$true)]
        [string]$file
    )
    $content = Get-Content -Path $file -Raw
    $lines = Get-Content -Path $file
    $words = $content -split '\s+' | Where-Object { $_ -ne "" }
    $bytes = (Get-Item -Path $file).Length

    Write-Output "Words: $($words.Count), Lines: $($lines.Count), Bytes: $($bytes)"
    }

function touch {
    param (
        [string]$filename
    )
    New-Item $filename
}


function ls {
    param (
        [string]$folderpath = (Get-Location).Path,  # Путь к папке, по умолчанию — текущая
        [switch]$a,  # Показать скрытые файлы (-a)
        [switch]$r,  # Рекурсивный просмотр (-r)
        [switch]$d   # Только директории (-d)
    )

    # Формируем параметры для Get-ChildItem
    $params = @{ Path = $folderpath }
    if ($a) { $params.Force = $true }
    if ($r) { $params.Recurse = $true }
    if ($d) { $params.Directory = $true }

    # Получаем список элементов
    $items = Get-ChildItem @params

    # Настройки отображения
    $cols = 4  # Количество колонок
    $rows = [math]::Ceiling($items.Count / $cols)  # Количество строк
    $colWidth = 25  # Ширина одной колонки
    $maxWidth = [Console]::WindowWidth  # Максимальная ширина экрана

    # Возвращает длину строки без учёта ANSI-кодов (цвета)
    function Get-PlainLength($s) { ($s -replace "\[[\d;]*m", '').Length }

    # Обрезает строку до нужной длины, не ломая ANSI-цвета, и добавляет суффикс (например, "...")
    function Truncate-WithAnsi($s, $maxLen, $suffix) {
        $plain = $s -replace "\[[\d;]*m", ''
        if ($plain.Length -le $maxLen) { return $s }
        $maxPlainLen = $maxLen - $suffix.Length
        $res = ''; $plainCount = 0; $ansi = $false
        foreach ($c in $s.ToCharArray()) {
            if ($c -eq "") { $ansi = $true }  # Начало ANSI-кода
            if (-not $ansi -and $plainCount -ge $maxPlainLen) { break }
            if (-not $ansi) { $plainCount++ }
            $res += $c
            if ($ansi -and $c -eq "m") { $ansi = $false }  # Конец ANSI-кода
        }
        return $res + $suffix
    }

    # Проходим по строкам и колонкам
    for ($i = 0; $i -lt $rows; $i++) {
        $line = ''
        for ($j = 0; $j -lt $cols; $j++) {
            $idx = $i + $j * $rows  # Индекс текущего элемента
            if ($idx -lt $items.Count) {
                $item = $items[$idx]
                if ($item.PSIsContainer) {
                    # Это директория: добавим цвет и слэш
                    $nameRaw = $item.Name + '/'
                    $nameColored = "[96m$nameRaw[0m"  # Голубой
                    $pad = $colWidth - (Get-PlainLength $nameColored)
                    if ($pad -gt 0) { $nameColored += ' ' * $pad }
                    else { $nameColored = Truncate-WithAnsi $nameColored $colWidth '..[0m/' }
                } else {
                    # Это файл
                    $nameRaw = $item.Name
                    $pad = $colWidth - $nameRaw.Length
                    if ($pad -gt 0) { $nameColored = $nameRaw + (' ' * $pad) }
                    else { $nameColored = Truncate-WithAnsi $nameRaw $colWidth '...' }
                }
                $line += $nameColored
            }
        }
        # Если строка слишком длинная — обрезаем
        if ((Get-PlainLength $line) -gt $maxWidth) {
            $line = Truncate-WithAnsi $line $maxWidth '...'
        }
        Write-Output $line
    }
}


function mkdir {
    param (
        [string]$name
    )
    New-Item -Path $name -Type Directory | Out-Null
}

function pwd { (Get-Location).Path }    