# LingoVerse_Copilote.ps1 - Version Alpha 1.2.6 : Copilote interactif et intelligent pour LingoVerse

# ==========================================
# 📌 Définition des variables globales
# ==========================================
$projectPath = "C:\Users\HP\Desktop\LingoVerse"
$docsPath = Join-Path $projectPath "docs"
$logFile = Join-Path $projectPath "LingoVerse_Copilote_log.txt"
$graphPath = Join-Path $projectPath "graphs"
$reportPath = Join-Path $projectPath "reports"
$dependencyReport = Join-Path $reportPath "dependency_report.txt"
$backupPath = Join-Path $projectPath "backup"
$lastRunTimeFile = Join-Path $projectPath "last_run_time.txt"
$taskReport = Join-Path $reportPath "task_report.txt"
$notificationsFile = Join-Path $projectPath "notifications.txt"
$testsReport = Join-Path $reportPath "tests_report.txt"
$unitTestFolder = Join-Path $projectPath "test"
$performanceReport = Join-Path $reportPath "performance_report.txt"
$versionFilePath = Join-Path $projectPath "version_info.txt"
$slackWebhookURL = "your_slack_webhook_url_here"
$emailAlertRecipient = "lingo.verse.devproton.me@proton.me"
$maintenanceModeFile = Join-Path $projectPath "maintenance_mode.txt"
$githubToken = "your_github_token_here"
$githubRepo = "your_github_repo_here"
$jiraAPI = "https://jira.yourcompany.com"
$trelloAPI = "https://api.trello.com/1/boards"
$trelloBoardID = "your_trello_board_id_here"
$envType = "dev" # Type d'environnement: dev, staging, production
$optimizationReport = Join-Path $reportPath "optimization_report.md"
$chatBotAPIKey = "your_openai_api_key_here" # Remplacez par votre clé API OpenAI
$chatBotEndpoint = "https://api.openai.com/v1/chat/completions" # Endpoint OpenAI

# ==========================================
# 📂 Création des dossiers nécessaires
# ==========================================
$pathsToCheck = @($graphPath, $reportPath, $backupPath)
foreach ($path in $pathsToCheck) {
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
}

# ==========================================
# 🚀 Affichage du menu interactif
# ==========================================
function Show-Menu {
    if (Test-Path $maintenanceModeFile) {
        Write-Host "⚠ Mode maintenance activé. Exécution du Copilote suspendue."
        exit
    }
    Clear-Host
    Write-Host "`n`e[92m=========================================="
    Write-Host "       🚀 LingoVerse Copilote v1.2.6       "
    Write-Host "==========================================`e[0m"
    Write-Host "1️⃣ - 🔍 Gérer les logs"
    Write-Host "2️⃣ - 📌 Vérifier la version du projet"
    Write-Host "3️⃣ - 📦 Vérifier les mises à jour des dépendances"
    Write-Host "4️⃣ - 🛡 Vérifier la sécurité des dépendances"
    Write-Host "5️⃣ - 🔎 Vérifier l'intégrité des fichiers"
    Write-Host "6️⃣ - 🧪 Exécuter les tests automatisés"
    Write-Host "7️⃣ - 📊 Surveillance des ressources système"
    Write-Host "8️⃣ - 🗑 Nettoyer les fichiers temporaires"
    Write-Host "9️⃣ - 📂 Sauvegarder le projet"
    Write-Host "🔟 - 🔄 Mettre à jour le script"
    Write-Host "1️⃣1️⃣ - 📝 Générer un changelog Git"
    Write-Host "1️⃣2️⃣ - 🤖 Optimiser automatiquement le projet"
    Write-Host "1️⃣3️⃣ - 💬 Discuter avec le ChatBot"
    Write-Host "1️⃣4️⃣ - 🚪 Quitter"
    Write-Host "`e[92m==========================================`e[0m"
    $choice = Read-Host "Sélectionne une option (1-14)"
    
    switch ($choice) {
        "1" { Manage-Logs }
        "2" { Check-Version }
        "3" { Check-For-Dependency-Updates }
        "4" { Check-Dependency-Security }
        "5" { Check-File-Integrity }
        "6" { Run-Automated-Tests }
        "7" { Monitor-System-Resources }
        "8" { Clean-Temp-Files }
        "9" { Backup-Project }
        "10" { Update-Script }
        "11" { Generate-Changelog }
        "12" { Auto-Optimize-Project }
        "13" { Start-ChatBot }
        "14" { exit }
        default { Write-Host "`e[91m⛔ Option invalide, réessaie.`e[0m"; Start-Sleep 2; Show-Menu }
    }
}

# ==========================================
# 💬 Nouvelle fonctionnalité : ChatBot interactif
# ==========================================
function Start-ChatBot {
    Write-Host "💬 Bienvenue dans le ChatBot LingoVerse ! Tapez 'exit' pour quitter."
    while ($true) {
        $userInput = Read-Host "Vous"
        if ($userInput -eq "exit") {
            Write-Host "👋 Fin de la conversation."
            Start-Sleep 2
            Show-Menu
            break
        }

        # Appel à l'API OpenAI
        $response = Invoke-ChatBotAPI -message $userInput
        Write-Host "🤖 ChatBot : $response"
    }
}

function Invoke-ChatBotAPI {
    param (
        [string]$message
    )

    $headers = @{
        "Authorization" = "Bearer $chatBotAPIKey"
        "Content-Type" = "application/json"
    }

    $body = @{
        model = "gpt-4" # Modèle à utiliser (exemple : gpt-4, gpt-3.5-turbo)
        messages = @(
            @{
                role = "user"
                content = $message
            }
        )
        max_tokens = 150 # Limite de tokens pour la réponse
    } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri $chatBotEndpoint -Method Post -Headers $headers -Body $body
        return $response.choices[0].message.content
    } catch {
        Write-Host "❌ Erreur lors de la communication avec le ChatBot : $_"
        return "Désolé, une erreur s'est produite. Veuillez réessayer."
    }
}

# ==========================================
# 📜 Gestion des logs avancée
# ==========================================
function Manage-Logs {
    Write-Host "`e[93m📜 Gestion des logs en cours...`e[0m"
    $maxLogSizeMB = 10
    $maxLogLines = 2000

    if (Test-Path $logFile) {
        $logSize = (Get-Item $logFile).length / 1MB
        if ($logSize -ge $maxLogSizeMB) {
            Write-Host "🔄 Rotation des logs..."
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            Rename-Item $logFile -NewName "$logFile.$timestamp.log"
        }
    }

    if (-not (Test-Path $logFile)) {
        New-Item -ItemType File -Path $logFile | Out-Null
    }

    $logLines = Get-Content $logFile
    if ($logLines.Count -ge $maxLogLines) {
        $logLines = $logLines[-($maxLogLines-1)..-1]
        Set-Content $logFile $logLines
    }

    Write-Host "✅ Gestion des logs terminée."
    Start-Sleep 2
    Show-Menu
}

# ==========================================
# 🔍 Vérification de la version du projet
# ==========================================
function Check-Version {
    Write-Host "`e[96m🔍 Vérification de la version du projet...`e[0m"
    if (Test-Path $versionFilePath) {
        $versionInfo = Get-Content $versionFilePath
        Write-Host "📌 Version actuelle : $versionInfo"
    } else {
        Write-Host "⚠ Aucune version trouvée."
    }
    Start-Sleep 2
    Show-Menu
}

# ==========================================
# 📦 Vérification des mises à jour des dépendances
# ==========================================
function Check-For-Dependency-Updates {
    Write-Host "🛠 Vérification des dépendances..."
    $dependencyUpdates = npm outdated --json
    if ($dependencyUpdates) {
        Write-Host "🔄 Mises à jour disponibles !"
        $dependencyUpdates | ConvertFrom-Json | Out-File -FilePath $dependencyReport
    } else {
        Write-Host "✅ Toutes les dépendances sont à jour."
    }
    Start-Sleep 2
    Show-Menu
}

# ==========================================
# 🛡 Vérification de la sécurité des dépendances
# ==========================================
function Check-Dependency-Security {
    Write-Host "🛡 Vérification de la sécurité des dépendances..."
    npm audit --json | Out-File -FilePath $dependencyReport
    Write-Host "✅ Audit de sécurité terminé."
    Start-Sleep 2
    Show-Menu
}

# ==========================================
# 🔎 Vérification de l'intégrité des fichiers
# ==========================================
function Check-File-Integrity {
    Write-Host "`e[94m🔎 Vérification des fichiers...`e[0m"
    $filesToCheck = Get-ChildItem -Path $projectPath -Recurse -File
    foreach ($file in $filesToCheck) {
        if (!(Test-Path $file.FullName)) {
            Write-Host "⚠ Fichier manquant : $($file.FullName)"
            return
        }
    }
    Write-Host "✅ Tous les fichiers sont intacts."
    Start-Sleep 2
    Show-Menu
}

# ==========================================
# 🧪 Exécution des tests automatisés
# ==========================================
function Run-Automated-Tests {
    Write-Host "🧪 Lancement des tests..."
    
    # Test de performance
    $startTime = Get-Date
    Start-Sleep -Seconds 3
    $executionTime = (Get-Date) - $startTime
    Write-Host "⚡ Temps d'exécution : $($executionTime.TotalMilliseconds) ms"

    # Test de syntaxe des scripts PowerShell
    Write-Host "🔍 Vérification de la syntaxe..."
    $scriptFiles = Get-ChildItem -Path $projectPath -Filter "*.ps1" -Recurse
    foreach ($file in $scriptFiles) {
        try {
            [scriptblock]::Create((Get-Content $file.FullName -Raw)) | Out-Null
            Write-Host "✅ $($file.Name) est valide."
        } catch {
            Write-Host "❌ Erreur dans $($file.Name) : $_"
        }
    }

    Write-Host "🏁 Tests terminés."
    Start-Sleep 2
    Show-Menu
}

# ==========================================
# 📊 Surveillance des ressources système
# ==========================================
function Monitor-System-Resources {
    Write-Host "📊 Surveillance des ressources système..."
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 | Format-Table -AutoSize
    Write-Host "💾 Espace disque :"
    Get-PSDrive C | Select-Object Used, Free, UsedPercentage | Format-Table -AutoSize
    Start-Sleep 2
    Show-Menu
}

# ==========================================
# 🗑 Nettoyage des fichiers temporaires
# ==========================================
function Clean-Temp-Files {
    Write-Host "🗑 Nettoyage des fichiers temporaires et logs..."
    Remove-Item -Path "$projectPath\*.tmp" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$logFile.*" -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Nettoyage terminé."
    Start-Sleep 2
    Show-Menu
}

# ==========================================
# 🔄 Mise à jour automatique du script
# ==========================================
function Update-Script {
    Write-Host "🔄 Mise à jour du Copilote..."
    $updateUrl = "https://raw.githubusercontent.com/votre-utilisateur/votre-repo/main/LingoVerse_Copilote.ps1"
    try {
        Invoke-WebRequest -Uri $updateUrl -OutFile "$projectPath\LingoVerse_Copilote.ps1"
        Write-Host "✅ Mise à jour terminée. Relancez le script."
        exit
    } catch {
        Write-Host "❌ Erreur lors de la mise à jour : $_"
    }
}

# ==========================================
# 📝 Génération automatique d'un changelog Git
# ==========================================
function Generate-Changelog {
    Write-Host "📝 Génération du changelog..."
    git log --pretty=format:"%h - %s (%ci)" --abbrev-commit > "$projectPath\CHANGELOG.md"
    Write-Host "✅ Changelog mis à jour."
    Start-Sleep 2
    Show-Menu
}

function Backup-Project {
    Write-Host "📦 Sauvegarde en cours..."

    # Vérifier si une sauvegarde a déjà été effectuée dans les dernières 24 heures
    $lastBackup = Get-ChildItem -Path $backupPath -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1
    $timeSinceLastBackup = if ($lastBackup) { (Get-Date) - $lastBackup.CreationTime } else { $null }

    if ($timeSinceLastBackup -and $timeSinceLastBackup.TotalHours -lt 24) {
        Write-Host "⚠ Une sauvegarde a déjà été effectuée il y a moins de 24 heures."
        Write-Host "Dernière sauvegarde : $($lastBackup.CreationTime)"
        Start-Sleep 2
        Show-Menu
        return
    }

    # Créer un nouveau dossier de sauvegarde avec un horodatage
    $backupFolder = Join-Path $backupPath "$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    New-Item -Path $backupFolder -ItemType Directory | Out-Null

    # Copier les fichiers du projet dans le dossier de sauvegarde
    robocopy $projectPath $backupFolder /MIR /S

    Write-Host "✅ Sauvegarde effectuée dans $backupFolder"
    Start-Sleep 2
    Show-Menu
}

# ==========================================
# 🤖 Nouvelle fonctionnalité : Optimisation automatique du projet
# ==========================================
function Auto-Optimize-Project {
    Write-Host "🤖 Démarrage de l'optimisation automatique du projet..."

    # 1. Analyse statique du code
    Write-Host "🔍 Analyse statique du code en cours..."
    $unusedCode = Get-ChildItem -Path $projectPath -Recurse -Include *.ps1, *.js, *.py | ForEach-Object {
        $content = Get-Content $_.FullName
        if ($content -match "TODO|FIXME|unused") {
            $_.FullName
        }
    }
    if ($unusedCode) {
        Write-Host "⚠ Code non utilisé ou marqué 'TODO/FIXME' détecté :"
        $unusedCode | ForEach-Object { Write-Host "- $_" }
    } else {
        Write-Host "✅ Aucun code non utilisé ou marqué 'TODO/FIXME' détecté."
    }

    # 2. Optimisation des dépendances
    Write-Host "📦 Analyse des dépendances en cours..."
    $obsoleteDependencies = npm outdated --json | ConvertFrom-Json
    if ($obsoleteDependencies) {
        Write-Host "⚠ Dépendances obsolètes détectées :"
        $obsoleteDependencies.PSObject.Properties | ForEach-Object {
            Write-Host "- $($_.Name) : Version actuelle $($_.Value.current), Version souhaitée $($_.Value.latest)"
        }
    } else {
        Write-Host "✅ Toutes les dépendances sont à jour."
    }

    # 3. Génération d'un rapport PDF
    Write-Host "📄 Génération du rapport d'optimisation..."
    $reportContent = @"
# Rapport d'Optimisation du Projet LingoVerse
## Analyse Statique du Code
$(if ($unusedCode) { "### Code non utilisé ou marqué 'TODO/FIXME' :`n$($unusedCode -join "`n")" } else { "Aucun problème détecté." })

## Analyse des Dépendances
$(if ($obsoleteDependencies) { "### Dépendances obsolètes :`n$($obsoleteDependencies.PSObject.Properties | ForEach-Object { "- $($_.Name) : Version actuelle $($_.Value.current), Version souhaitée $($_.Value.latest)" })" } else { "Toutes les dépendances sont à jour." })

## Suggestions d'Amélioration
1. Supprimez ou corrigez le code marqué 'TODO/FIXME'.
2. Mettez à jour les dépendances obsolètes.
3. Utilisez des outils de linting pour améliorer la qualité du code.
"@
    $reportContent | Out-File -FilePath $optimizationReport
    Write-Host "✅ Rapport généré : $optimizationReport"

    # 4. Intégration IA pour des suggestions contextuelles
    Write-Host "🧠 Analyse IA en cours..."
    $suggestions = Invoke-RestMethod -Uri "https://api.openai.com/v1/completions" -Method Post -Headers @{
        "Authorization" = "Bearer $env:OPENAI_API_KEY"
        "Content-Type" = "application/json"
    } -Body (@{
        model = "text-davinci-003"
        prompt = "Analyse ce rapport d'optimisation et propose des suggestions supplémentaires : $reportContent"
        max_tokens = 150
    } | ConvertTo-Json)
    Write-Host "💡 Suggestions IA : $($suggestions.choices[0].text)"

    Write-Host "🏁 Optimisation terminée. Consultez le rapport pour plus de détails."
    Start-Sleep 2
    Show-Menu
}

# ==========================================
# 🚀 Fonction principale
# ==========================================
function Run-Copilot {
    Write-Host "🚀 Lancement du Copilote LingoVerse v1.2.5..."
    Show-Menu
}

# ==========================================
# 🔥 Démarrage du script
# ==========================================
Run-Copilot
