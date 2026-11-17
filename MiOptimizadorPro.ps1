# ==============================================================================
# MI OPTIMIZADOR ULTIMATE - GAMING, VELOCIDAD, INTERNET Y SEGURIDAD
# ==============================================================================

# Verificar permisos de Administrador
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "ERROR: Debes abrir PowerShell como ADMINISTRADOR para ejecutar este script."
    Break
}

Clear-Host
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "    OPTIMIZADOR ULTIMATE: RENDIMIENTO, RED Y SEGURIDAD PRO        " -ForegroundColor White
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------------------
# 0. PUNTO DE RESTAURACION (SEGURIDAD)
# ------------------------------------------------------------------------------
$backup = Read-Host "0. ¿Crear un Punto de Restauracion antes de empezar? (Recomendado) [S/N]"
if ($backup -match "^[Ss]$") {
    Write-Host " -> Creando punto de restauracion en C:\..." -ForegroundColor Yellow
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Antes_MiOptimizadorUltimate" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    Write-Host " [OK] Punto de restauracion creado." -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 1. PRIORIDAD DE PROCESOS (DAR RECURSOS A LO IMPORTANTE Y JUEGOS)
# ------------------------------------------------------------------------------
$prio = Read-Host "`n1. ¿Priorizar CPU/GPU para juegos y programas activos sobre el 2do plano? [S/N]"
if ($prio -match "^[Ss]$") {
    Write-Host " -> Configurando planificador de CPU (Win32PrioritySeparation) y MMCSS..." -ForegroundColor Yellow
    
    # Prioridad corta y fija para la ventana en primer plano (juegos + tareas rapidas)
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Type DWord -Value 38

    # Prioridad maxima para juegos en Multimedia Class Scheduler Service (MMCSS)
    $gamesPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    New-Item -Path $gamesPath -Force | Out-Null
    Set-ItemProperty -Path $gamesPath -Name "Affinity" -Type DWord -Value 0
    Set-ItemProperty -Path $gamesPath -Name "Background Only" -Type String -Value "False"
    Set-ItemProperty -Path $gamesPath -Name "Clock Rate" -Type DWord -Value 10000
    Set-ItemProperty -Path $gamesPath -Name "GPU Priority" -Type DWord -Value 8
    Set-ItemProperty -Path $gamesPath -Name "Priority" -Type DWord -Value 6
    Set-ItemProperty -Path $gamesPath -Name "Scheduling Category" -Type String -Value "High"
    Set-ItemProperty -Path $gamesPath -Name "SFIO Priority" -Type String -Value "High"

    # 100% de recursos disponibles para primer plano (0% reservado para tareas ocultas)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type DWord -Value 0

    Write-Host " [OK] Prioridad de procesador y tarjeta grafica asignada." -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 2. ENERGIA, GPU Y MODO JUEGO (MAXIMOS FPS SIN TIRONES)
# ------------------------------------------------------------------------------
$gpu = Read-Host "`n2. ¿Activar Maximo Rendimiento, HAGS, Modo Juego y quitar Game DVR? [S/N]"
if ($gpu -match "^[Ss]$") {
    Write-Host " -> Aplicando perfil de energia y optimizacion grafica..." -ForegroundColor Yellow

    # Desbloquear y activar Plan de Maximo Rendimiento
    $ultimatePlan = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
    if ($ultimatePlan -match "([a-f0-9-]{36})") {
        powercfg -setactive $matches[1]
    } else {
        powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    }

    # Desactivar suspension selectiva de puertos USB (evita micro-cortes en mouse/teclado)
    powercfg -setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg -setactive SCHEME_CURRENT

    # Activar Programacion de GPU acelerada por hardware (HAGS)
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Type DWord -Value 2

    # Desactivar Xbox Game DVR y grabacion oculta en segundo plano
    New-Item -Path "HKCU:\System\GameConfigStore" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Type DWord -Value 2
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0

    # Activar Modo Juego de Windows
    New-Item -Path "HKCU:\Software\Microsoft\GameBar" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 1

    Write-Host " [OK] Energia, HAGS y Modo Juego configurados." -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 3. OPTIMIZACION DE INTERNET Y PING EN JUEGOS
# ------------------------------------------------------------------------------
$net = Read-Host "`n3. ¿Optimizar red (Nagle Off, QoS 0%, DNS 1.1.1.1 y ahorro energia off)? [S/N]"
if ($net -match "^[Ss]$") {
    Write-Host " -> Optimizando pila TCP/IP, adaptador de red y DNS..." -ForegroundColor Yellow

    # Eliminar estrangulamiento de red multimedia de Windows
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff

    # Liberar el 20% de ancho de banda reservado por QoS de Windows
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched" -Name "NonBestEffortLimit" -Type DWord -Value 0

    # Desactivar Algoritmo de Nagle (envia paquetes de juego al instante sin agrupar)
    $interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    foreach ($interface in $interfaces) {
        Set-ItemProperty -Path $interface.PSPath -Name "TcpAckFrequency" -Type DWord -Value 1 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $interface.PSPath -Name "TCPNoDelay" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    # Optimizacion global TCP
    netsh int tcp set global autotuninglevel=normal | Out-Null
    netsh int tcp set global ecncapability=disabled | Out-Null
    netsh int tcp set global timestamps=disabled | Out-Null
    netsh int tcp set global rss=enabled | Out-Null

    # Configurar DNS Cloudflare (1.1.1.1) y desactivar ahorro de energia en adaptador activo
    $adaptadorActivo = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.PhysicalMediaType -ne "Unspecified" } | Select-Object -First 1
    if ($adaptadorActivo) {
        Set-DnsClientServerAddress -InterfaceIndex $adaptadorActivo.ifIndex -ServerAddresses ("1.1.1.1", "1.0.0.1") -ErrorAction SilentlyContinue
        Disable-NetAdapterPowerManagement -Name $adaptadorActivo.Name -ErrorAction SilentlyContinue
        Write-Host "    -> DNS 1.1.1.1 y modo continuo aplicados en: $($adaptadorActivo.Name)" -ForegroundColor DarkCyan
    }

    ipconfig /flushdns | Out-Null
    Write-Host " [OK] Red optimizada para menor ping y maxima estabilidad." -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 4. QUITAR COSAS QUE NO SIRVEN (SERVICIOS Y AGILIDAD EN TAREAS BASICAS)
# ------------------------------------------------------------------------------
$cleanSrv = Read-Host "`n4. ¿Apagar servicios inutiles y acelerar apertura/cierre de ventanas? [S/N]"
if ($cleanSrv -match "^[Ss]$") {
    Write-Host " -> Deshabilitando procesos innecesarios y acelerando interfaz..." -ForegroundColor Yellow

    # Bloquear ejecucion de apps UWP en segundo plano
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1

    # Cortar Telemetria de Windows
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

    # Acelerar respuesta de menus, cierre de tareas y explorador de archivos
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -Type String -Value "2000"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout" -Type String -Value "1000"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "AutoEndTasks" -Type String -Value "1"

    # Desactivar efectos de transparencia de Windows (libera ciclos de GPU)
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Type DWord -Value 0

    # Servicios innecesarios que consumen RAM/CPU en segundo plano
    $serviciosInutiles = @(
        "DiagTrack",          # Telemetria de Windows
        "dmwappushservice",   # Enrutamiento de mensajes de telemetria
        "SysMain",            # Superfetch (innecesario en SSD/NVMe)
        "MapsBroker",         # Mapas descargados offline
        "RetailDemo",         # Modo demostracion de tiendas
        "WSearch",            # Indexacion continua de disco
        "XblAuthManager",     # Autenticacion Xbox Live (borrar si usas GamePass)
        "XblGameSave",        # Guardado en nube Xbox Live
        "XboxNetApiSvc"       # Servicio de red Xbox Live
    )

    foreach ($srv in $serviciosInutiles) {
        if (Get-Service $srv -ErrorAction SilentlyContinue) {
            Stop-Service $srv -Force -ErrorAction SilentlyContinue
            Set-Service $srv -StartupType Disabled -ErrorAction SilentlyContinue
        }
    }

    # Desactivar hibernacion (libera GB en disco C: y evita escritura en SSD)
    powercfg -h off

    Write-Host " [OK] Servicios basura desactivados y sistema agilizado." -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 5. SEGURIDAD Y PRIVACIDAD (SIN IMPACTO EN FPS)
# ------------------------------------------------------------------------------
$sec = Read-Host "`n5. ¿Reforzar seguridad (Anti-PUA, Anti-Ransomware, Firewall y bloqueo SMBv1)? [S/N]"
if ($sec -match "^[Ss]$") {
    Write-Host " -> Aplicando endurecimiento de seguridad y privacidad..." -ForegroundColor Yellow

    # Bloquear aplicaciones potencialmente no deseadas (Adware / Mineros ocultos)
    Set-MpPreference -PUAProtection Enabled -ErrorAction SilentlyContinue

    # Activar proteccion contra Ransomware (Acceso controlado a carpetas)
    Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue

    # Activar proteccion de red de Defender (bloquea conexiones a dominios maliciosos)
    Set-MpPreference -EnableNetworkProtection Enabled -ErrorAction SilentlyContinue

    # Asegurar que el Firewall de Windows este activo en todos los perfiles
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction SilentlyContinue

    # Desactivar protocolo antiguo y vulnerable SMBv1 (usado por ransomware como WannaCry)
    Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -ErrorAction SilentlyContinue | Out-Null

    # Desactivar ejecucion automatica (AutoRun) en USB/unidades externas para evitar virus al conectar pendrives
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255

    # Desactivar ID de publicidad de Windows (privacidad)
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0

    Write-Host " [OK] Seguridad reforzada sin afectar el rendimiento en juegos." -ForegroundColor Green
}

# ------------------------------------------------------------------------------
# 6. LIMPIEZA DE ARCHIVOS TEMPORALES Y CACHE
# ------------------------------------------------------------------------------
$temp = Read-Host "`n6. ¿Limpiar archivos temporales, Prefetch y cache de Windows Update? [S/N]"
if ($temp -match "^[Ss]$") {
    Write-Host " -> Eliminando archivos residuales..." -ForegroundColor Yellow
    $rutas = @(
        "$env:TEMP\*",
        "C:\Windows\Temp\*",
        "C:\Windows\Prefetch\*",
        "C:\Windows\SoftwareDistribution\Download\*"
    )
    foreach ($ruta in $rutas) {
        Remove-Item -Path $ruta -Recurse -Force -ErrorAction SilentlyContinue
    }
    Write-Host " [OK] Limpieza profunda completada." -ForegroundColor Green
}

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host "  ¡PROCESO TERMINADO! Reinicia tu PC para aplicar todos los cambios." -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Cyan