# Antes de rodar:
# 1. É preciso alterar a política de execução para permitir a execução do script:
#    Execute no PowerShell como administrador:
#    Set-ExecutionPolicy Bypass -Scope Process -Force
# 2. Se aparecer erro com instalação existente do Chocolatey:
#    Execute: Remove-Item -Recurse -Force "C:\ProgramData\chocolatey"


try {
    # Passo 1: Verificar se o Chocolatey já está instalado. Se não, instala.
    $chocoPath = Get-Command choco -ErrorAction SilentlyContinue
    if (-not $chocoPath) {
        Write-Host "Chocolatey não encontrado. Instalando o Chocolatey..."
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    } else {
        Write-Host "Chocolatey já está instalado."
    }

    # Verificar se o comando choco está acessível após instalação
    $chocoPath = Get-Command choco -ErrorAction SilentlyContinue
    if (-not $chocoPath) {
        throw "O comando 'choco' ainda não está disponível após a instalação. Verifique se a instalação do Chocolatey foi concluída corretamente."
    }

    # Passo 2: Atualiza o Chocolatey
    Write-Host "Atualizando o Chocolatey..."
    choco upgrade chocolatey -y

    # Passo 3: Instalar os pacotes desejados com Chocolatey
    Write-Host "Instalando pacotes..."

    $packages = @(
        "googlechrome",
        "vlc",
        "foxitreader",
        # "k-lite-codec-pack", # <- Não encontrado no repositório, comentar ou substituir
        "winrar",
        "teamviewer",
        "vscode",
        "git",
        "docker-desktop",
        "postman",
        "dbeaver",
        "nvm",
        "telegram"
    )

    foreach ($pkg in $packages) {
        Write-Host "Instalando $pkg ..."
        choco install $pkg -y
    }

    # Passo 4: Configurações adicionais do Windows
    Write-Host "Realizando configurações adicionais do Windows..."
    # Será necessário para o docker
    wsl --update
    # Adicione comandos aqui se necessário

    Write-Host "`n✅ Script de instalação concluído com sucesso."

} catch {
    Write-Error "`n❌ Ocorreu um erro durante a execução do script:`n$_"
} finally {
    # Restaurar a política de execução original
    Set-ExecutionPolicy $originalExecutionPolicy -Scope Process -Force

    # Passo 5: Limpar arquivos temporários do Chocolatey
    $chocoTempPath = "$env:LOCALAPPDATA\Temp\chocolatey"
    if (Test-Path $chocoTempPath) {
        try {
            Remove-Item -Path $chocoTempPath -Recurse -Force -ErrorAction Stop
            Write-Host "`n🧹 Pasta temporária do Chocolatey removida com sucesso: $chocoTempPath"
        } catch {
            Write-Warning "⚠️ Falha ao remover a pasta temporária: $_"
        }
    } else {
        Write-Host "`nℹ️ Nenhuma pasta temporária do Chocolatey encontrada para remover."
    }
}

# Ao término, caso queira voltar é preciso executar manualmente: ` Set-ExecutionPolicy $originalExecutionPolicy -Scope Process -Force`