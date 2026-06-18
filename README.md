# Criware File Scanner & Extractor Tools 🛠️

Este repositório contém uma coleção de scripts em **PowerShell (`.ps1`)** desenvolvidos para automatizar a varredura, identificação (via Magic Number/Assinatura Hexadecimal) e extração em lote de arquivos que utilizam a tecnologia **Criware** (comumente encontrados em jogos).

O foco principal desta coleção é a identificação de contêineres de áudio baseados na assinatura **AFS2** (arquivos `.awb`) e sua subsequente conversão/extração para formatos de áudio legíveis (`.wav`).

---

## Funcionalidades

* **Identificação por Hardware/Magic Number:** O script analisa os primeiros 4 bytes dos arquivos de forma recursiva para encontrar assinaturas válidas da Criware, independentemente da extensão atual do arquivo.
* **Organização Automatizada:** Identifica os arquivos compatíveis e oferece a opção de movê-los e renomeá-los automaticamente para uma pasta centralizada de análise (`DataMining`).
* **Extração Automatizada em Lote:** Lê os metadados dos contêineres encontrados para determinar a quantidade exata de faixas internas e extrai cada stream individualmente.

---

## Descrição dos Scripts

| Script | Função Principal | Saída / Comportamento |
| :--- | :--- | :--- |
| `HashAFS2.ps1` | Varre arquivos maiores que 1MB buscando a assinatura hexadecimal `41465332` (**AFS2**). | Exibe os resultados em tempo real em uma janela interativa (`Out-GridView`). |
| `HashAnalyser.ps1` | Varre recursivamente o diretório em busca de assinaturas **AFS2**, move os arquivos encontrados para uma pasta `DataMining` e adiciona a extensão `.awb` caso estejam sem formato. | Interativo via terminal (pede confirmação antes de mover os arquivos). |
| `Extracter.ps1` | Identifica arquivos `.awb` no diretório local, consulta a quantidade de streams e faz o split de todas as faixas internas. | Gera arquivos de áudio descriptografados `.wav` numerados. |

---

## Pré-requisitos & Dependências

### 1. Permissão de Execução no PowerShell
Por padrão, o Windows bloqueia a execução de scripts externos. Para rodar os scripts deste repositório, abra o PowerShell e execute o comando abaixo para liberar a sessão atual:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
