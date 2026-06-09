:<<"::CMDLITERAL"
@ECHO OFF
SETLOCAL
SET "ZIP_PROJECT_SCRIPT_DIR=%~dp0"
SET "PS1_FILE=%TEMP%\zip-project-%RANDOM%-%RANDOM%.ps1"

FOR /F "tokens=1 delims=:" %%i IN ('findstr /n /c:"# PowerShell starts here" "%~f0"') DO SET "PS_SKIP=%%i"
IF NOT DEFINED PS_SKIP (
  ECHO Failed to locate embedded PowerShell payload. 1>&2
  EXIT /B 1
)

more +%PS_SKIP% "%~f0" > "%PS1_FILE%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1_FILE%" %*
SET "EXIT_CODE=%ERRORLEVEL%"
del "%PS1_FILE%" >nul 2>nul
EXIT /B %EXIT_CODE%
::CMDLITERAL

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}"
ORIGINAL_PATH="${PATH}"

say() {
    printf '%s\n' "$*" >&2
}

die() {
    say "Error: $*"
    exit 1
}

usage() {
    cat <<EOF
Usage:
  Unix:    sh ./zip-project.cmd
  Windows: .\zip-project.cmd

Creates a ZIP archive containing tracked and non-ignored project files.
Ignored build output such as build/, .gradle/, out/, and similar files are excluded.

The script asks for:
  - first name
  - last name
  - index number

Enter the index in the usual form such as 123/2026.
The ZIP file uses 123-2026 because "/" cannot appear in a file name.
EOF
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

normalize_component() {
    component="$(printf '%s' "$1" | tr -d '\r')"
    component="$(printf '%s' "$component" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    [ -n "$component" ] || die "Input cannot be empty."

    component="$(printf '%s' "$component" | tr -s '[:space:]' '_' | sed 's|/|-|g' | tr '\\:*?"<>|' '_')"
    printf '%s\n' "$component"
}

prompt_value() {
    prompt_text="$1"
    printf '%s: ' "$prompt_text" >&2
    IFS= read -r input_value || die "Failed to read input."
    normalize_component "$input_value"
}

build_archive_name() {
    first_name="$(prompt_value "First name")"
    last_name="$(prompt_value "Last name")"
    index_number="$(prompt_value "Index number")"

    printf '%s_%s_%s.zip\n' "$first_name" "$last_name" "$index_number"
}

confirm_overwrite() {
    archive_path="$1"

    [ ! -e "$archive_path" ] && return 0

    printf 'File "%s" already exists. Overwrite? [y/N]: ' "$(basename "$archive_path")" >&2
    IFS= read -r reply || return 1

    case "$reply" in
        y | Y | yes | YES) return 0 ;;
        *) return 1 ;;
    esac
}

main() {
    command_exists git || die "Git is required."
    command_exists zip || die "zip is required."

    case "${1:-}" in
        -h | --help)
            usage
            exit 0
            ;;
    esac

    [ "$#" -eq 0 ] || die "This script does not accept file-name arguments. Run it and answer the prompts."

    archive_name="$(build_archive_name)"
    archive_path="${PROJECT_DIR}/${archive_name}"

    if ! confirm_overwrite "$archive_path"; then
        die "Archive creation cancelled."
    fi

    temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t zip-project)"
    trap 'rm -rf "${temp_dir}"' EXIT HUP INT TERM

    temp_archive_path="${temp_dir}/${archive_name}"
    file_list_path="${temp_dir}/files.list"

    rm -f "${archive_path}"
    git -C "${PROJECT_DIR}" ls-files -z --cached --others --exclude-standard > "${file_list_path}"

    if [ ! -s "${file_list_path}" ]; then
        die "No project files found to archive."
    fi

    (
        cd "${PROJECT_DIR}"
        xargs -0 zip -q "${temp_archive_path}" < "${file_list_path}"
    )

    mv "${temp_archive_path}" "${archive_path}"
    trap - EXIT HUP INT TERM
    rm -rf "${temp_dir}"

    say "Created ${archive_path}"
}

main "$@"
exit $?

:CMDSCRIPT
# PowerShell starts here
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ArchiveArgs
)

$ErrorActionPreference = "Stop"

$ProjectDir = if ($env:ZIP_PROJECT_SCRIPT_DIR) { $env:ZIP_PROJECT_SCRIPT_DIR } else { Split-Path -Parent $MyInvocation.MyCommand.Path }

function Say {
    param([string]$Message)

    [Console]::Error.WriteLine($Message)
}

function Fail {
    param([string]$Message)

    throw $Message
}

function Show-Usage {
    @"
Usage:
  Unix:    sh ./zip-project.cmd
  Windows: .\zip-project.cmd

Creates a ZIP archive containing tracked and non-ignored project files.
Ignored build output such as build/, .gradle/, out/, and similar files are excluded.

The script asks for:
  - first name
  - last name
  - index number

Enter the index in the usual form such as 123/2026.
The ZIP file uses 123-2026 because "/" cannot appear in a file name.
"@ | Write-Output
}

function Normalize-Component {
    param([string]$Value)

    $normalized = $Value.Trim()
    if ([string]::IsNullOrWhiteSpace($normalized)) {
        Fail "Input cannot be empty."
    }

    $normalized = $normalized -replace '\s+', '_'
    $normalized = $normalized -replace '/', '-'
    return ($normalized -replace '[\\:*?"<>|]', '_')
}

function Read-Value {
    param([string]$Prompt)

    $inputValue = Read-Host $Prompt
    return Normalize-Component $inputValue
}

function Build-ArchiveName {
    $firstName = Read-Value "First name"
    $lastName = Read-Value "Last name"
    $indexNumber = Read-Value "Index number"
    return "$firstName" + "_" + "$lastName" + "_" + "$indexNumber.zip"
}

function Confirm-Overwrite {
    param([string]$ArchivePath)

    if (-not (Test-Path $ArchivePath -PathType Leaf)) {
        return $true
    }

    $reply = Read-Host "File ""$([System.IO.Path]::GetFileName($ArchivePath))"" already exists. Overwrite? [y/N]"
    return $reply -match '^(?i:y|yes)$'
}

if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
    Fail "Git is required."
}

if ($ArchiveArgs -and $ArchiveArgs.Count -gt 0) {
    switch ($ArchiveArgs[0]) {
        "-h" { Show-Usage; exit 0 }
        "--help" { Show-Usage; exit 0 }
        default { Fail "This script does not accept file-name arguments. Run it and answer the prompts." }
    }
}

$archiveName = Build-ArchiveName
$archivePath = Join-Path $ProjectDir $archiveName

if (-not (Confirm-Overwrite $archivePath)) {
    Fail "Archive creation cancelled."
}

$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("zip-project-" + [guid]::NewGuid().ToString("N"))
$tempArchivePath = Join-Path $tempDir $archiveName
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

try {
    if (Test-Path $archivePath -PathType Leaf) {
        Remove-Item -Path $archivePath -Force
    }

    $files = (& git -C $ProjectDir ls-files --cached --others --exclude-standard) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    if (-not $files -or $files.Count -eq 0) {
        Fail "No project files found to archive."
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zipArchive = [System.IO.Compression.ZipFile]::Open($tempArchivePath, [System.IO.Compression.ZipArchiveMode]::Create)

    try {
        foreach ($relativePath in $files) {
            $fullPath = Join-Path $ProjectDir $relativePath
            if (Test-Path $fullPath -PathType Leaf) {
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                    $zipArchive,
                    $fullPath,
                    $relativePath.Replace('\', '/'),
                    [System.IO.Compression.CompressionLevel]::Optimal
                ) | Out-Null
            }
        }
    }
    finally {
        $zipArchive.Dispose()
    }

    Move-Item -Path $tempArchivePath -Destination $archivePath -Force
    Say "Created $archivePath"
}
finally {
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force
    }
}
