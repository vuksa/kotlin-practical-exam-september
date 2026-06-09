:<<"::CMDLITERAL"
@ECHO OFF
SETLOCAL
SET "RUN_GRADLE_SCRIPT_DIR=%~dp0"
SET "PS1_FILE=%TEMP%\run-gradle-%RANDOM%-%RANDOM%.ps1"

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

REQUIRED_JAVA_VERSION="${JDK_VERSION:-21}"
SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"
PROJECT_DIR="${SCRIPT_DIR}"
GRADLEW_PATH="${PROJECT_DIR}/gradlew"
ORIGINAL_PATH="${PATH}"
# Resolved to a platform-specific default in main() once the OS is known,
# unless the caller exports JDKS_DIR explicitly.
JDKS_DIR="${JDKS_DIR:-}"

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
  Unix:    sh ./run-gradle.cmd [gradle-args...]
  Windows: .\run-gradle.cmd [gradle-args...]

Ensures JDK ${REQUIRED_JAVA_VERSION} is available, then runs the Gradle wrapper with it.

Examples:
  sh ./run-gradle.cmd
  sh ./run-gradle.cmd compileKotlin
  sh ./run-gradle.cmd test
  sh ./run-gradle.cmd test --tests "CountryPortalTest.test - get all presidents"

Environment overrides:
  JDKS_DIR    Install/search directory for managed JDKs (default: ${JDKS_DIR})
  JDK_VERSION Required Java major version (default: ${REQUIRED_JAVA_VERSION})
EOF
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

detect_os() {
    case "$(uname -s)" in
        Linux) printf '%s\n' "linux" ;;
        Darwin) printf '%s\n' "mac" ;;
        *) die "Unsupported operating system: $(uname -s)" ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64 | amd64) printf '%s\n' "x64" ;;
        arm64 | aarch64) printf '%s\n' "aarch64" ;;
        *) die "Unsupported architecture: $(uname -m)" ;;
    esac
}

# Default install/cache location for managed JDKs, chosen so that IntelliJ
# auto-detects it as an SDK (selectable as Project SDK / Gradle JVM).
# Matches IntelliJ's own "Download JDK" target per OS:
#   macOS -> ~/Library/Java/JavaVirtualMachines
#   Linux -> ~/.jdks
default_jdks_dir() {
    case "$1" in
        mac) printf '%s\n' "${HOME}/Library/Java/JavaVirtualMachines" ;;
        *) printf '%s\n' "${HOME}/.jdks" ;;
    esac
}

java_major_version() {
    java_cmd="$1"
    version_line="$("$java_cmd" -version 2>&1 | sed -n '1p')"
    version_string="$(printf '%s\n' "$version_line" | sed -n 's/.*version "\([^"]*\)".*/\1/p')"

    [ -n "$version_string" ] || return 1

    case "$version_string" in
        1.*) printf '%s\n' "$version_string" | cut -d. -f2 ;;
        *) printf '%s\n' "$version_string" | cut -d. -f1 | cut -d- -f1 ;;
    esac
}

matches_required_version() {
    java_cmd="$1"
    [ "$(java_major_version "$java_cmd")" = "$REQUIRED_JAVA_VERSION" ]
}

java_home_matches_required_version() {
    java_home="$1"
    [ -x "${java_home}/bin/java" ] || return 1
    matches_required_version "${java_home}/bin/java"
}

use_java_home() {
    java_home="$1"

    if java_home_matches_required_version "$java_home"; then
        JAVA_HOME="$java_home"
        export JAVA_HOME
        PATH="${JAVA_HOME}/bin:${ORIGINAL_PATH}"
        export PATH
        say "Using JDK ${REQUIRED_JAVA_VERSION} from ${JAVA_HOME}"
        return 0
    fi

    return 1
}

check_current_environment() {
    if [ -n "${JAVA_HOME:-}" ] && use_java_home "$JAVA_HOME"; then
        return 0
    fi

    if command_exists java; then
        java_path="$(command -v java)"
        if matches_required_version "$java_path"; then
            say "Using JDK ${REQUIRED_JAVA_VERSION} from PATH: ${java_path}"
            return 0
        fi
    fi

    return 1
}

find_jdk_in_directory() {
    search_dir="$1"

    [ -d "$search_dir" ] || return 1

    for candidate in "$search_dir"/*; do
        [ -e "$candidate" ] || continue

        use_java_home "$candidate" && return 0
        use_java_home "$candidate/Contents/Home" && return 0
    done

    return 1
}

check_known_install_locations() {
    find_jdk_in_directory "${JDKS_DIR}" && return 0
    find_jdk_in_directory "${HOME}/.gradle/jdks" && return 0

    case "${OS}" in
        mac)
            find_jdk_in_directory "${HOME}/.jdks" && return 0

            if [ -x /usr/libexec/java_home ]; then
                mac_java_home="$(/usr/libexec/java_home -v "${REQUIRED_JAVA_VERSION}" 2>/dev/null || true)"
                if [ -n "$mac_java_home" ] && use_java_home "$mac_java_home"; then
                    return 0
                fi
            fi

            find_jdk_in_directory "/Library/Java/JavaVirtualMachines" && return 0
            ;;
        linux)
            find_jdk_in_directory "/usr/lib/jvm" && return 0
            ;;
    esac

    return 1
}

require_command() {
    command_exists "$1" || die "Missing required command: $1"
}

download_file() {
    url="$1"
    destination="$2"

    curl --fail --silent --show-error --location --output "$destination" "$url"
}

fetch_text() {
    url="$1"

    curl --fail --silent --show-error --location "$url"
}

sha256_file() {
    file_path="$1"

    if command_exists sha256sum; then
        sha256sum "$file_path" | awk '{print $1}'
        return 0
    fi

    if command_exists shasum; then
        shasum -a 256 "$file_path" | awk '{print $1}'
        return 0
    fi

    die "Missing checksum tool: expected sha256sum or shasum"
}

resolve_installed_java_home() {
    install_root="$1"

    if [ -x "${install_root}/bin/java" ]; then
        printf '%s\n' "${install_root}"
        return 0
    fi

    if [ -x "${install_root}/Contents/Home/bin/java" ]; then
        printf '%s\n' "${install_root}/Contents/Home"
        return 0
    fi

    return 1
}

install_jdk() {
    require_command curl
    require_command tar

    mkdir -p "${JDKS_DIR}"
    install_root="${JDKS_DIR}/corretto-${REQUIRED_JAVA_VERSION}-${OS}-${ARCH}"

    if [ -d "$install_root" ]; then
        final_java_home="$(resolve_installed_java_home "$install_root" || true)"
        if [ -n "${final_java_home:-}" ] && use_java_home "$final_java_home"; then
            return 0
        fi

        die "Found an existing but unusable installation at ${install_root}. Remove it and rerun the script."
    fi

    temp_dir="$(mktemp -d 2>/dev/null || mktemp -d -t corretto-bootstrap)"
    trap 'rm -rf "${temp_dir}"' EXIT HUP INT TERM

    archive_file="${temp_dir}/jdk.tar.gz"
    extract_dir="${temp_dir}/extract"

    case "${OS}" in
        mac) os_token="macos" ;;
        linux) os_token="linux" ;;
        *) die "Unsupported operating system for Corretto download: ${OS}" ;;
    esac

    archive_name="amazon-corretto-${REQUIRED_JAVA_VERSION}-${ARCH}-${os_token}-jdk.tar.gz"
    download_url="https://corretto.aws/downloads/latest/${archive_name}"
    checksum_url="https://corretto.aws/downloads/latest_sha256/${archive_name}"

    say "Downloading Amazon Corretto ${REQUIRED_JAVA_VERSION} for ${OS}/${ARCH}..."
    download_file "${download_url}" "${archive_file}"
    expected_sha="$(fetch_text "${checksum_url}" | awk '{print $1}')"
    actual_sha="$(sha256_file "${archive_file}")"

    [ "$expected_sha" = "$actual_sha" ] || die "Checksum verification failed for ${archive_file}"

    mkdir -p "${extract_dir}"
    tar -xzf "${archive_file}" -C "${extract_dir}"

    for extracted_root in "${extract_dir}"/*; do
        [ -e "$extracted_root" ] || continue

        if [ -x "${extracted_root}/bin/java" ] || [ -x "${extracted_root}/Contents/Home/bin/java" ]; then
            mv "${extracted_root}" "${install_root}"
            final_java_home="$(resolve_installed_java_home "${install_root}" || true)"
            [ -n "${final_java_home:-}" ] || die "Downloaded archive did not contain a usable JDK"
            use_java_home "${final_java_home}" || die "Installed JDK does not match Java ${REQUIRED_JAVA_VERSION}"
            say "Installed JDK ${REQUIRED_JAVA_VERSION} to ${install_root}"
            trap - EXIT HUP INT TERM
            rm -rf "${temp_dir}"
            return 0
        fi
    done

    die "Downloaded archive did not contain a usable JDK"
}

ensure_jdk() {
    check_current_environment && return 0
    check_known_install_locations && return 0
    install_jdk
}

main() {
    OS="$(detect_os)"
    ARCH="$(detect_arch)"

    if [ -z "${JDKS_DIR}" ]; then
        JDKS_DIR="$(default_jdks_dir "${OS}")"
    fi

    case "${1:-}" in
        -h | --help)
            usage
            exit 0
            ;;
    esac

    [ -x "${GRADLEW_PATH}" ] || die "Expected executable Gradle wrapper at ${GRADLEW_PATH}"

    ensure_jdk

    if [ "$#" -eq 0 ]; then
        set -- compileKotlin
    fi

    say "Running ./gradlew $*"
    exec "${GRADLEW_PATH}" "$@"
}

main "$@"
exit $?

:CMDSCRIPT
# PowerShell starts here
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$GradleArgs
)

$ErrorActionPreference = "Stop"

$RequiredJavaVersion = if ($env:JDK_VERSION) { [int]$env:JDK_VERSION } else { 21 }
$ProjectDir = if ($env:RUN_GRADLE_SCRIPT_DIR) { $env:RUN_GRADLE_SCRIPT_DIR } else { Split-Path -Parent $MyInvocation.MyCommand.Path }
$GradlewPath = Join-Path $ProjectDir "gradlew.bat"
$OriginalPath = $env:Path
$JdksDir = if ($env:JDKS_DIR) { $env:JDKS_DIR } else { Join-Path $env:USERPROFILE ".jdks" }

function Say {
    param([string]$Message)

    [Console]::Error.WriteLine($Message)
}

function Fail {
    param([string]$Message)

    throw $Message
}

function Get-JavaMajorVersion {
    param([string]$JavaCommand)

    $versionLine = & $JavaCommand -version 2>&1 | Select-Object -First 1
    $match = [regex]::Match([string]$versionLine, 'version "([^"]+)"')
    if (-not $match.Success) {
        return $null
    }

    $versionString = $match.Groups[1].Value
    if ($versionString.StartsWith("1.")) {
        return [int]($versionString.Split(".")[1])
    }

    return [int](([regex]::Split($versionString, "[.-]"))[0])
}

function Test-RequiredJavaVersion {
    param([string]$JavaCommand)

    $majorVersion = Get-JavaMajorVersion $JavaCommand
    return $majorVersion -eq $RequiredJavaVersion
}

function Test-JavaHome {
    param([string]$JavaHome)

    if ([string]::IsNullOrWhiteSpace($JavaHome)) {
        return $false
    }

    $javaExecutable = Join-Path $JavaHome "bin\java.exe"
    if (-not (Test-Path $javaExecutable -PathType Leaf)) {
        return $false
    }

    return Test-RequiredJavaVersion $javaExecutable
}

function Use-JavaHome {
    param([string]$JavaHome)

    if (Test-JavaHome $JavaHome) {
        $env:JAVA_HOME = $JavaHome
        $env:Path = "$JavaHome\bin;$OriginalPath"
        Say "Using JDK $RequiredJavaVersion from $JavaHome"
        return $true
    }

    return $false
}

function Test-CurrentEnvironment {
    if ($env:JAVA_HOME -and (Use-JavaHome $env:JAVA_HOME)) {
        return $true
    }

    $javaCommand = Get-Command java.exe -ErrorAction SilentlyContinue
    if ($javaCommand -and (Test-RequiredJavaVersion $javaCommand.Source)) {
        Say "Using JDK $RequiredJavaVersion from PATH: $($javaCommand.Source)"
        return $true
    }

    return $false
}

function Find-JdkInDirectory {
    param([string]$SearchDir)

    if (-not (Test-Path $SearchDir -PathType Container)) {
        return $false
    }

    foreach ($candidate in Get-ChildItem -Path $SearchDir -Directory) {
        if (Use-JavaHome $candidate.FullName) {
            return $true
        }
    }

    return $false
}

function Test-KnownInstallLocations {
    $programFilesX86 = ${env:ProgramFiles(x86)}
    $candidateDirectories = @(
        $JdksDir,
        (Join-Path $env:USERPROFILE ".gradle\jdks"),
        (Join-Path $env:ProgramFiles "Amazon Corretto"),
        (Join-Path $env:ProgramFiles "Java")
    )

    if ($programFilesX86) {
        $candidateDirectories += (Join-Path $programFilesX86 "Amazon Corretto")
        $candidateDirectories += (Join-Path $programFilesX86 "Java")
    }

    foreach ($directory in $candidateDirectories) {
        if ($directory -and (Find-JdkInDirectory $directory)) {
            return $true
        }
    }

    return $false
}

function Get-ArchiveArchitecture {
    switch ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLowerInvariant()) {
        "x64" { return "x64" }
        "arm64" { return "aarch64" }
        default { Fail "Unsupported Windows architecture: $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)" }
    }
}

function Resolve-InstalledJavaHome {
    param([string]$InstallRoot)

    $javaExecutable = Join-Path $InstallRoot "bin\java.exe"
    if (Test-Path $javaExecutable -PathType Leaf) {
        return $InstallRoot
    }

    return $null
}

function Install-Jdk {
    $archiveArchitecture = Get-ArchiveArchitecture
    $installRoot = Join-Path $JdksDir "corretto-$RequiredJavaVersion-windows-$archiveArchitecture"

    if (Test-Path $installRoot -PathType Container) {
        $existingJavaHome = Resolve-InstalledJavaHome $installRoot
        if ($existingJavaHome -and (Use-JavaHome $existingJavaHome)) {
            return
        }

        Fail "Found an existing but unusable installation at $installRoot. Remove it and rerun the script."
    }

    New-Item -ItemType Directory -Force -Path $JdksDir | Out-Null

    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("corretto-bootstrap-" + [guid]::NewGuid().ToString("N"))
    $archiveFile = Join-Path $tempDir "jdk.zip"
    $extractDir = Join-Path $tempDir "extract"
    $archiveName = "amazon-corretto-$RequiredJavaVersion-$archiveArchitecture-windows-jdk.zip"
    $downloadUrl = "https://corretto.aws/downloads/latest/$archiveName"
    $checksumUrl = "https://corretto.aws/downloads/latest_sha256/$archiveName"

    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    New-Item -ItemType Directory -Force -Path $extractDir | Out-Null

    try {
        Say "Downloading Amazon Corretto $RequiredJavaVersion for windows/$archiveArchitecture..."
        Invoke-WebRequest -Uri $downloadUrl -OutFile $archiveFile

        $expectedSha = ((Invoke-WebRequest -Uri $checksumUrl).Content -split '\s+')[0].Trim()
        $actualSha = (Get-FileHash -Algorithm SHA256 -Path $archiveFile).Hash.ToLowerInvariant()

        if ($expectedSha.ToLowerInvariant() -ne $actualSha) {
            Fail "Checksum verification failed for $archiveFile"
        }

        Expand-Archive -Path $archiveFile -DestinationPath $extractDir -Force

        $extractedRoot = Get-ChildItem -Path $extractDir -Directory | Select-Object -First 1
        if (-not $extractedRoot) {
            Fail "Downloaded archive did not contain a usable JDK"
        }

        Move-Item -Path $extractedRoot.FullName -Destination $installRoot

        $installedJavaHome = Resolve-InstalledJavaHome $installRoot
        if (-not $installedJavaHome -or -not (Use-JavaHome $installedJavaHome)) {
            Fail "Installed JDK does not match Java $RequiredJavaVersion"
        }

        Say "Installed JDK $RequiredJavaVersion to $installRoot"
    }
    finally {
        if (Test-Path $tempDir) {
            Remove-Item -Path $tempDir -Recurse -Force
        }
    }
}

function Ensure-Jdk {
    if (Test-CurrentEnvironment) {
        return
    }

    if (Test-KnownInstallLocations) {
        return
    }

    Install-Jdk
}

if (-not (Test-Path $GradlewPath -PathType Leaf)) {
    Fail "Expected Gradle wrapper at $GradlewPath"
}

Ensure-Jdk

if (-not $GradleArgs -or $GradleArgs.Count -eq 0) {
    $GradleArgs = @("compileKotlin")
}

Say ("Running gradlew.bat " + ($GradleArgs -join " "))
& $GradlewPath @GradleArgs
exit $LASTEXITCODE
