# test-intake.ps1 - sends one fake prospect to the Proposal Engine webhook.
# Saved as UTF-8 WITH BOM on purpose: Windows PowerShell 5.1 reads files without a BOM
# as Windows-1252, which turns the en dash in "1 000 - 2 000" into a curly quote that
# ends the string early (and mangles every accent).
# Usage (PowerShell, from the folder containing this file):
#   .\test-intake.ps1
# If Windows blocks the script, run once:  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

# --- CONFIG -------------------------------------------------------------------
# Test URL: works while you've clicked "Listen for test event" on the Webhook node.
# For the published workflow, replace "webhook-test" with "webhook".
$Url    = "https://YOUR-N8N-DOMAIN/webhook-test/proposal-intake"
# The secret is read from an environment variable so it never sits in this file
# (and never ends up on GitHub). Set it once per PowerShell window:
#   $env:CWB_INTAKE_SECRET = "your-64-character-secret"
$Secret = $env:CWB_INTAKE_SECRET
if (-not $Secret) {
    Write-Error 'Set $env:CWB_INTAKE_SECRET first (see the comment above).'
    exit 1
}
# ------------------------------------------------------------------------------

$body = @{
    isTest  = $true
    contact = @{
        name    = "Max Verstappen"
        email   = "test@example.com"
        company = "Le Comptoir"
    }
    sector = "Restaurant"
    goal   = "Un site élégant avec des animations pour présenter notre carte et prendre des réservations en ligne."
    needs  = @("Réservation de tables", "Menu multilingue", "Intégration Instagram")
    details = @{
        locations   = 2
        currentSite = $null
    }
    scope = @{
        languages = @("Français", "Anglais")
        budgetRaw = "1 000 – 2 000 DH/mois"
        deadline  = (Get-Date).AddDays(60).ToString("yyyy-MM-dd")
        notes     = "Nous avons déjà des photos professionnelles."
    }
} | ConvertTo-Json -Depth 5

# UTF-8 bytes: without this, PowerShell can mangle accents (é, à) on the way out.
$bytes = [System.Text.Encoding]::UTF8.GetBytes($body)

Invoke-RestMethod -Method Post -Uri $Url `
    -Headers @{ "X-CWB-Secret" = $Secret } `
    -ContentType "application/json; charset=utf-8" `
    -Body $bytes
