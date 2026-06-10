# rebuild_and_deploy.ps1
# This script compiles Java sources and synchronizes files to the Tomcat deployment directory.

$ErrorActionPreference = "Stop"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "Rebuilding and Deploying Project..." -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# 1. Setup classes directory in the workspace
$classesDir = "src/main/webapp/WEB-INF/classes"
if (-not (Test-Path $classesDir)) {
    New-Item -ItemType Directory -Path $classesDir -Force | Out-Null
}

# 2. Compile Java source files
Write-Host "Compiling Java sources..." -ForegroundColor Green
$javaFiles = Get-ChildItem -Path "src/main/java" -Recurse -Filter "*.java" | ForEach-Object { $_.FullName }

if ($javaFiles.Count -eq 0) {
    Write-Error "No Java source files found!"
}

# Compilation command using Tomcat core servlet libraries
$classpath = "c:\tomcat\tomcat\lib\servlet-api.jar;c:\tomcat\tomcat\lib\jsp-api.jar;src/main/webapp/WEB-INF/lib/*"
javac -d $classesDir -classpath $classpath $javaFiles

Write-Host "Compilation successful!" -ForegroundColor Green

# 3. Synchronize to Tomcat deployment directory
$deployDir = "c:\tomcat\tomcat\webapps\ai_object_detection_system"
Write-Host "Deploying files to $deployDir..." -ForegroundColor Green

if (-not (Test-Path $deployDir)) {
    New-Item -ItemType Directory -Path $deployDir -Force | Out-Null
}

# Copy JSPs, assets, WEB-INF (with classes and libs) recursively
Copy-Item -Path "src/main/webapp/*" -Destination $deployDir -Recurse -Force

# Copy detect.py and ai_model folder
Copy-Item -Path "detect.py" -Destination $deployDir -Force
Copy-Item -Path "ai_model" -Destination $deployDir -Recurse -Force

Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan

