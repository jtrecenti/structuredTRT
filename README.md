# structuredTRT

<!-- badges: start -->
<!-- badges: end -->

## Sobre o Pacote

O pacote `structuredTRT` contém os dados e código de replicação para o artigo sobre avaliação de modelos de linguagem para extração estruturada de informações em sentenças trabalhistas. Este pacote permite reproduzir todas as análises apresentadas no artigo.

## Instalação

Você pode instalar a versão de desenvolvimento do `structuredTRT` a partir do [GitHub](https://github.com/jtrecenti/structuredTRT) com:

```r
# install.packages("pak")
pak::pak("jtrecenti/structuredTRT")
```

## Estrutura do Repositório

### Scripts de Processamento (`data-raw/`)

O diretório `data-raw/` contém os scripts necessários para reproduzir todo o pipeline de processamento dos dados, executados na seguinte ordem:

#### `0_load.R`
Carrega e prepara os documentos textuais das sentenças trabalhistas a partir dos arquivos baixados do sistema Jus.BR. Este script:
- Lê os metadados dos processos da pasta `cpopg/`
- Filtra documentos cujo nome contém o termo "sentença"
- Remove documentos com erros de requisição, arquivos PDF e documentos muito grandes
- Elimina documentos duplicados
- Calcula o número de tokens de cada documento usando tiktoken
- Gera o conjunto de dados `sentencas`, salvo em `data/sentencas.rda`

#### `1_extract.R`
Executa a extração de informações estruturadas dos documentos usando múltiplos modelos de linguagem. Este script:
- Define a lista de 17 modelos a serem avaliados, distribuídos entre 5 provedores (Anthropic, Google, Grok, Groq, OpenAI)
- Para cada combinação de documento e modelo, chama a função `analisar_processo()` que:
  - Carrega o prompt de extração (`inst/prompts/prompt.md`)
  - Envia o texto da sentença para o modelo via API
  - Salva a resposta em formato JSON na pasta `data-raw/runs/`
- Gera um total de 10.880 extrações (640 documentos × 17 modelos)

#### `2_structure.R`
Estrutura as respostas em texto livre dos modelos em dados tabulares válidos. Este script:
- Lê todos os arquivos JSON gerados na etapa de extração
- Utiliza o modelo Google Gemini 2.5 Flash (com temperatura zero) para identificar e extrair blocos JSON válidos das respostas
- Converte as respostas estruturadas em um formato tabular padronizado
- Salva os resultados intermediários em `data-raw/da_arqs_estruturado.rds` e `data-raw/da_parsed.rds`

#### `3_0_evaluate.R`
Avalia o desempenho dos modelos e calcula métricas de custo. Este script:
- Carrega os dados estruturados das etapas anteriores
- Padroniza os nomes dos modelos e provedores
- Calcula os custos de processamento para cada modelo com base nas taxas de tokens de entrada e saída
- Combina todas as informações em um único conjunto de dados
- Gera o conjunto de dados final `da_report`, salvo em `data/da_report.rda`

#### `3_1_manual.R`
Cria uma base de referência manual (*gold standard*) para validação dos resultados. Este script:
- Seleciona uma amostra aleatória de 20 sentenças classificadas como dentro do escopo pelo modelo Gemini 2.5 Pro
- Realiza validação manual das extrações, corrigindo erros e ajustando classificações
- Gera o conjunto de dados `gabarito_manual`, salvo em `data/gabarito_manual.rda`

#### `4_report.qmd`
Gera o relatório final em formato HTML com todas as análises e visualizações apresentadas no artigo. Este arquivo Quarto:
- Carrega o conjunto de dados `da_report`
- Calcula métricas de acurácia, precisão, recall e F1 para cada modelo
- Compara os modelos com a base de referência (Gemini 2.5 Pro e validação manual)
- Gera tabelas e gráficos de desempenho vs custo
- Produz o relatório completo com metodologia, resultados e conclusões

## Conjunto de Dados `da_report`

O conjunto de dados `da_report` é o principal objeto de análise do pacote e contém todas as extrações realizadas pelos modelos de linguagem. Ele possui as seguintes características:

### Estrutura

- **Dimensões**: 10.880 observações (640 documentos × 17 modelos)
- **Variáveis principais**:
  - `path`: Caminho do arquivo JSON original da extração
  - `provider`: Provedor do modelo (Anthropic, Google, Grok, Groq, OpenAI)
  - `model`: Nome do modelo utilizado
  - `cost`: Custo de processamento em dólares (USD)
  - `output_json_valid`: Indicador booleano se o JSON gerado é válido

### Variáveis de Escopo

- `escopo`: Indicador booleano se o documento é uma sentença de mérito
- `fora_escopo_motivo`: Justificativa textual quando o documento está fora do escopo

### Variáveis de Decisão (quando `escopo = TRUE`)

- `gratuidade_pedida`: Solicitação de gratuidade judiciária pelo autor (sim/não)
- `gratuidade_concedida`: Deferimento da gratuidade judiciária (sim/não)
- `julgamento_final`: Resultado global da sentença (procedente/parcialmente_procedente/improcedente)
- `valor_condenacao`: Valor total da condenação em reais (numérico)
- `percentual_sucumbencia`: Percentual de sucumbência aplicado (numérico)
- `custas`: Valor das custas processuais em reais (numérico)
- `observacao`: Campo para anotações adicionais
- `pedidos`: Lista de pedidos estruturados (coluna de listas), contendo para cada pedido:
  - `categoria`: Classificação do pedido entre 14 categorias predefinidas
  - `breve_descricao`: Descrição textual do pedido
  - `decisao_pedido`: Resultado do pedido (procedente/improcedente)

### Categorias de Pedidos

As categorias de pedidos disponíveis são:
- `horas_extras`
- `adicional_periculosidade`
- `adicional_insalubridade`
- `ferias`
- `verbas_rescisorias`
- `reconhecimento_vinculo`
- `13_salario`
- `aviso_previo`
- `multas_fgts`
- `danos_morais`
- `recolhimento_fgts`
- `justa_causa`
- `honorarios_advogado`
- `outro`

## Uso

Após instalar o pacote, você pode carregar os dados e reproduzir as análises:

```r
library(structuredTRT)

# Carregar o conjunto de dados principal
data(da_report)

# Explorar a estrutura dos dados
str(da_report)

# Verificar distribuição por provedor
table(da_report$provider)

# Filtrar apenas documentos dentro do escopo
da_report_escopo <- da_report[da_report$escopo == TRUE, ]

# Reproduzir o relatório completo
# (requer que os scripts em data-raw tenham sido executados)
# rmarkdown::render("data-raw/4_report.qmd")
```

## Modelos Avaliados

O pacote avalia 17 modelos de linguagem distribuídos entre 5 provedores:

- **Anthropic** (2 modelos): `claude-sonnet-4-5-20250929`, `claude-haiku-4-5-20251001`
- **Google** (2 modelos): `gemini-2.5-flash`, `gemini-2.5-pro`
- **Grok, via Open Router** (1 modelo): `x-ai/grok-4.1-fast`
- **Groq** (8 modelos): `llama-3.1-8b-instant`, `llama-3.3-70b-versatile`, `openai/gpt-oss-120b`, `openai/gpt-oss-20b`, `meta-llama/llama-4-maverick-17b-128e-instruct`, `meta-llama/llama-4-scout-17b-16e-instruct`, `moonshotai/kimi-k2-instruct-0905`, `qwen/qwen3-32b`
- **OpenAI** (4 modelos): `gpt-4.1-nano`, `gpt-4.1-mini`, `gpt-4.1`, `gpt-5.1`

## Dependências

O pacote utiliza principalmente:
- `ellmer`: Para interação com APIs de modelos de linguagem
- `dplyr`, `tidyr`: Para manipulação de dados
- `ggplot2`: Para visualizações
- `jsonlite`: Para parsing de JSON
- `stringr`: Para manipulação de strings

## Licença

Este pacote está licenciado sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## Citação

Se você usar este pacote em sua pesquisa, por favor cite o artigo correspondente (referência a ser adicionada).

## Contato

Para questões ou problemas, abra uma issue no [GitHub](https://github.com/jtrecenti/structuredTRT/issues).
