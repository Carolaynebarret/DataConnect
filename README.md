# DataConnect

![Linguagem](https://img.shields.io/badge/python-3.10%2B-3776AB?logo=python&logoColor=white)
![Licença](https://img.shields.io/github/license/Carolaynebarret/DataConnect)
![Último commit](https://img.shields.io/github/last-commit/Carolaynebarret/DataConnect)
![Status](https://img.shields.io/badge/status-projeto%20acadêmico-blue)

Projeto de limpeza e análise de dados desenvolvido pelo **Squad 7** durante a
**Residência TIC em Trilhas – Área de Dados com IA**, realizada pela PUC-Rio em
parceria com o **Instituto ECOA**. O repositório reúne os exercícios,
desafios e o projeto final da trilha.

O entregável principal é o notebook [`dataconnect_squad7.ipynb`](dataconnect_squad7.ipynb):
uma base fictícia de projetos, apontamentos de horas, clientes, analistas e
pesquisas de satisfação de uma consultoria de dados chega suja (múltiplos
formatos de data e número, categorias com grafias diferentes, duplicatas,
valores fora de escala) e é diagnosticada, limpa e validada de ponta a ponta,
com cada decisão de tratamento documentada e registrada em log.

> Autoria: Carolayne, Regina, Maxxi e Ingrid.

## Funcionalidades

O notebook implementa um pipeline de limpeza e análise reprodutível:

- **Diagnóstico automatizado** — perfil coluna a coluna (nulos, valores
  distintos, grafias, espaços sobrando) antes de qualquer alteração.
- **Normalização de texto e categorias** — remove espaços redundantes e
  unifica grafias divergentes (acentuação, caixa, pontuação) por meio de uma
  chave de comparação, com conferência manual de cada agrupamento.
- **Parser de números em múltiplos formatos** — reconhece formato brasileiro
  (`61.970,49`) e formato ISO (`124698.57`) valor a valor, evitando o erro
  clássico de multiplicar por 100 ao aplicar uma regra única na coluna.
- **Parser de datas com marcação de ambiguidade** — converte para
  `aaaa-mm-dd`, reconhece datas por extenso e barra, e marca com uma *flag*
  toda data que poderia ser lida como `dd/mm` ou `mm/dd`, resolvendo parte
  delas por coerência (`início <= fim`) quando possível.
- **Tratamento de duplicatas** — separa cópias idênticas (removidas
  automaticamente) de cópias divergentes (marcadas para decisão humana, nunca
  apagadas silenciosamente).
- **Flags de qualidade, não exclusão silenciosa** — horas inválidas,
  contratos fora de escala, datas suspeitas e notas fora da escala são
  marcadas em colunas `flag_*` e mantidas na base, com o critério de
  inclusão/exclusão de cada análise sempre declarado.
- **"Prova real" embutida** — cada etapa termina com asserções (`checar`) que
  interrompem o notebook se uma verificação crítica falhar; o resultado fica
  registrado num placar final.
- **Log de decisões e de uso de IA** — todas as decisões de tratamento
  (`registrar`) e os pedidos feitos a uma IA generativa durante o
  desenvolvimento (o que foi pedido, o que a IA gerou, como foi validado e o
  que precisou ser corrigido) ficam documentados em tabelas exportáveis.
- **Análise de margem e custo por projeto** — cruza apontamentos de horas com
  o custo/hora de cada analista para calcular custo real, margem e
  utilização por projeto, linha de serviço e squad.
- **Testes estatísticos** — usa Mann-Whitney, Kruskal-Wallis, qui-quadrado,
  correlação de Spearman e post-hoc de Tukey (`scipy.stats` e
  `statsmodels`) para checar se as diferenças observadas entre grupos (ex.:
  margem por linha de serviço, atraso por squad) são estatisticamente
  significativas ou podem ser ruído de amostra pequena.
- **Exportação para painel** — gera CSVs de saída (bases limpas, tabela
  analítica por projeto e por cliente) prontos para consumo em uma
  ferramenta de BI.
- **Validação cruzada independente** — [`sql/validacao.sql`](sql/validacao.sql)
  refaz as principais contas em SQL/SQLite, fora do notebook, como segunda
  fonte de verdade sobre os mesmos números.

## Tecnologias usadas

- [Python 3](https://www.python.org/) (notebook desenvolvido e testado com
  Python 3.14 / pandas 3.x, e compatível com Python 3.10+ / pandas 2.x)
- [Jupyter Notebook](https://jupyter.org/) / [Google Colab](https://colab.research.google.com/)
- [pandas](https://pandas.pydata.org/) e [NumPy](https://numpy.org/) — manipulação de dados
- [Matplotlib](https://matplotlib.org/) — visualização
- [SciPy](https://scipy.org/) e [statsmodels](https://www.statsmodels.org/) — testes estatísticos
- [SQLite](https://www.sqlite.org/) (via [DB Browser for SQLite](https://sqlitebrowser.org/)) — validação cruzada em SQL

## Pré-requisitos

- Python 3.10 ou superior, **ou** uma conta Google para abrir o notebook
  diretamente no Colab (não exige instalação local).
- `pip` para instalar as dependências listadas em `requirements.txt`.
- Opcional: [DB Browser for SQLite](https://sqlitebrowser.org/) para rodar a
  validação cruzada em `sql/validacao.sql`.

## Instalação

```bash
git clone https://github.com/Carolaynebarret/DataConnect.git
cd DataConnect
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

## Como executar

O notebook foi escrito para rodar no Google Colab (lendo os arquivos do
Google Drive), mas roda sem alterações de código fora dele — só uma célula
precisa ser ajustada, e isso já está indicado dentro do próprio notebook.

**No Google Colab** (mais simples, sem instalar nada): abra
[`dataconnect_squad7.ipynb`](dataconnect_squad7.ipynb) pelo badge *Open in
Colab* no topo do arquivo, envie os cinco CSVs (`dc_projetos.csv`,
`dc_apontamentos.csv`, `dc_clientes.csv`, `dc_analistas.csv`,
`dc_satisfacao.csv`) para uma pasta no seu Google Drive e ajuste `PASTA` na
célula "Onde estão os arquivos" para apontar para ela.

**Localmente**, com os CSVs em `data/` (como já estão neste repositório):

```bash
jupyter notebook dataconnect_squad7.ipynb
```

Na célula "Onde estão os arquivos", troque:

```python
USAR_DRIVE = True
PASTA = '/content/drive/MyDrive/dados-dataconnect'
```

por:

```python
USAR_DRIVE = False
```

e rode todas as células em ordem — fora do Colab, a própria célula resolve
`PASTA` para `./data`. Ao final, as bases limpas e as tabelas de painel são
exportadas para `data/bases_limpas/`.

## Como rodar as validações

O projeto não usa um framework de testes tradicional (pytest, unittest);
a validação é parte do próprio fluxo de dados, em duas camadas
independentes:

1. **Dentro do notebook** — a seção "8. A prova real" reúne asserções
   (`checar(...)`) que comparam o resultado obtido com o esperado em cada
   etapa; qualquer falha crítica interrompe a execução (`assert`) antes de
   seguir para a análise.
2. **Fora do notebook, em SQL** — [`sql/validacao.sql`](sql/validacao.sql)
   refaz as mesmas contas (linhas batendo com a origem, chaves únicas,
   soma de horas, conversão de valores, integridade referencial etc.) em
   SQLite, importando os CSVs originais e os `*_limpo.csv` exportados pelo
   notebook. Basta abrir os arquivos no DB Browser for SQLite (passo a
   passo no cabeçalho do próprio `.sql`) e rodar os blocos: cada um imprime
   um `veredito` de `PASSOU`/`FALHOU`.

Este repositório foi auditado executando o notebook de ponta a ponta
localmente (com `USAR_DRIVE = False`) e carregando as bases exportadas num
banco SQLite para rodar `sql/validacao.sql`: as 102 células rodaram sem
erros e todos os vereditos, tanto os internos ao notebook quanto os do SQL,
retornaram `PASSOU`.

## Estrutura de pastas

```
DataConnect/
├── dataconnect_squad7.ipynb   # notebook principal: diagnóstico, limpeza, prova real e análise
├── data/                      # bases brutas (entrada) e, após rodar o notebook, bases_limpas/ (saída)
│   ├── dc_projetos.csv        # base bruta: projetos
│   ├── dc_apontamentos.csv    # base bruta: apontamento de horas
│   ├── dc_clientes.csv        # base bruta: clientes
│   ├── dc_analistas.csv       # base bruta: analistas
│   └── dc_satisfacao.csv      # base bruta: pesquisas de satisfação (NPS)
├── sql/
│   └── validacao.sql          # validação cruzada das bases limpas, em SQL/SQLite
├── docs/
│   └── images/                # capturas de tela do projeto (ver README da pasta)
├── arquivo/                   # rascunhos e versões anteriores do notebook, mantidos como histórico
├── requirements.txt
├── LICENSE
└── README.md
```

## Riscos residuais e limitações conhecidas

- O notebook depende do módulo `google.colab` quando `USAR_DRIVE = True`;
  fora do Colab é necessário ajustar essa única célula, como descrito acima.
- Não há suíte de testes automatizados (pytest/unittest) neste repositório —
  a validação é feita pela "prova real" embutida no notebook e pelo script
  SQL independente, descritos na seção anterior.
- A pasta `arquivo/` guarda rascunhos anteriores do desafio, mantidos de
  propósito como histórico do processo (não são o entregável final).
- A célula "10. Registro de uso de IA" tem um campo ("o que corrigimos" da
  etapa Margem) ainda com o texto de preenchimento `[preencher depois de
  rodar]` — ficou pendente de ser concluído pelo squad com o resultado real
  da rodada.

## Roadmap

- [ ] Preencher o campo pendente do registro de uso de IA (etapa "Margem").
- [ ] Adicionar capturas de tela do painel final e do gráfico de diagnóstico
      em `docs/images/` (ver [`docs/images/README.md`](docs/images/README.md)).
- [ ] Publicar o painel de BI alimentado por `painel_projetos.csv` e
      `painel_clientes.csv`.
- [ ] Avaliar automatizar a validação SQL (hoje manual, via DB Browser) em
      um script que rode `sql/validacao.sql` contra um SQLite temporário.

## Contribuição

Este é um projeto acadêmico de squad, desenvolvido para fins de aprendizado
durante a Residência TIC em Trilhas – Área de Dados com IA (PUC-Rio /
Instituto ECOA). Sugestões e correções são bem-vindas via *issues* ou
*pull requests*.

## Licença

Distribuído sob a licença MIT. Veja [`LICENSE`](LICENSE) para mais detalhes.
