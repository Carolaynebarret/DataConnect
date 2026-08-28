-- =====================================================================
-- DataConnect Solutions -- Squad 7
-- validacao.sql -- a etapa Validar, feita fora do Colab
-- =====================================================================
--
-- POR QUE ESTE ARQUIVO EXISTE
--
-- Refazer a conta na mesma ferramenta que produziu o numero nao prova nada:
-- se o nosso codigo Python estiver errado, os dois lados erram junto. Estas
-- consultas refazem os mesmos numeros em outra ferramenta e em outra
-- linguagem. Se os dois baterem, o numero e nosso. Se nao baterem, a gente
-- aprendeu alguma coisa e volta para o notebook.
--
-- COMO USAR
--
--   1. Abrir o DB Browser for SQLite
--   2. Arquivo -> Novo banco de dados -> salvar como dataconnect.db
--   3. Arquivo -> Importar -> Tabela a partir de arquivo CSV
--      Importar os CINCO arquivos ORIGINAIS com estes nomes de tabela:
--         dc_projetos.csv      -> dc_projetos
--         dc_apontamentos.csv  -> dc_apontamentos
--         dc_clientes.csv      -> dc_clientes
--         dc_analistas.csv     -> dc_analistas
--         dc_satisfacao.csv    -> dc_satisfacao
--      E os SEIS arquivos limpos que o notebook exporta:
--         projetos_limpo.csv       -> projetos
--         apontamentos_limpo.csv   -> apontamentos
--         clientes_limpo.csv       -> clientes
--         analistas_limpo.csv      -> analistas
--         satisfacao_limpo.csv     -> satisfacao
--         margem_projeto_limpo.csv -> margem_projeto
--      Marcar "a primeira linha contem os nomes das colunas".
--   4. Aba "Executar SQL", colar UM bloco de cada vez e apertar F5.
--   5. Anotar o resultado ao lado do numero do notebook.
--
-- Cada bloco abaixo tem a pergunta em portugues antes da consulta, e a
-- coluna "veredito" ja diz se passou. Onde a coluna existir, o resultado
-- esperado e sempre 'PASSOU'.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. AS LINHAS BATEM COM O ARQUIVO MENOS AS COPIAS?
--    Primeira das quatro contas do passo 10.
-- ---------------------------------------------------------------------
SELECT 'projetos'     AS tabela,
       (SELECT COUNT(*) FROM dc_projetos)                      AS na_origem,
       (SELECT COUNT(DISTINCT projeto_id) FROM dc_projetos)    AS distintos,
       (SELECT COUNT(*) FROM projetos_limpo)                            AS na_limpa,
       CASE WHEN (SELECT COUNT(DISTINCT projeto_id) FROM dc_projetos)
                 = (SELECT COUNT(*) FROM projetos_limpo)
            THEN 'PASSOU' ELSE 'FALHOU' END                       AS veredito
UNION ALL
SELECT 'apontamentos',
       (SELECT COUNT(*) FROM dc_apontamentos),
       (SELECT COUNT(DISTINCT apontamento_id) FROM dc_apontamentos),
       (SELECT COUNT(*) FROM apontamentos_limpo),
       CASE WHEN (SELECT COUNT(DISTINCT apontamento_id) FROM dc_apontamentos)
                 = (SELECT COUNT(*) FROM apontamentos_limpo)
            THEN 'PASSOU' ELSE 'FALHOU' END
UNION ALL
SELECT 'clientes',
       (SELECT COUNT(*) FROM dc_clientes),
       (SELECT COUNT(DISTINCT cliente_id) FROM dc_clientes),
       (SELECT COUNT(*) FROM clientes_limpo),
       CASE WHEN (SELECT COUNT(DISTINCT cliente_id) FROM dc_clientes)
                 = (SELECT COUNT(*) FROM clientes_limpo)
            THEN 'PASSOU' ELSE 'FALHOU' END
UNION ALL
SELECT 'analistas',
       (SELECT COUNT(*) FROM dc_analistas),
       (SELECT COUNT(DISTINCT analista_id) FROM dc_analistas),
       (SELECT COUNT(*) FROM analistas_limpo),
       CASE WHEN (SELECT COUNT(DISTINCT analista_id) FROM dc_analistas)
                 = (SELECT COUNT(*) FROM analistas_limpo)
            THEN 'PASSOU' ELSE 'FALHOU' END
UNION ALL
SELECT 'satisfacao',
       (SELECT COUNT(*) FROM dc_satisfacao),
       (SELECT COUNT(DISTINCT pesquisa_id) FROM dc_satisfacao),
       (SELECT COUNT(*) FROM satisfacao_limpo),
       CASE WHEN (SELECT COUNT(DISTINCT pesquisa_id) FROM dc_satisfacao)
                 = (SELECT COUNT(*) FROM satisfacao_limpo)
            THEN 'PASSOU' ELSE 'FALHOU' END;


-- ---------------------------------------------------------------------
-- 2. SOBROU ALGUMA CHAVE REPETIDA?
--    O equivalente ao indice unico: se sobrasse uma, o banco recusaria.
--    Todas as linhas tem que dar 0.
-- ---------------------------------------------------------------------
SELECT 'projetos' AS tabela, COUNT(*) AS chaves_repetidas,
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END AS veredito
  FROM (SELECT projeto_id FROM projetos_limpo GROUP BY projeto_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'apontamentos', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END
  FROM (SELECT apontamento_id FROM apontamentos_limpo
         GROUP BY apontamento_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'clientes', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END
  FROM (SELECT cliente_id FROM clientes_limpo GROUP BY cliente_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'analistas', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END
  FROM (SELECT analista_id FROM analistas_limpo
         GROUP BY analista_id HAVING COUNT(*) > 1)
UNION ALL
SELECT 'satisfacao', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END
  FROM (SELECT pesquisa_id FROM satisfacao_limpo
         GROUP BY pesquisa_id HAVING COUNT(*) > 1);


-- ---------------------------------------------------------------------
-- 3. NENHUMA CATEGORIA FICOU FORA DA LISTA?
--    Segunda das quatro contas. Quantas grafias tinha antes, quantas
--    categorias temos agora, e se sobrou algum vazio.
-- ---------------------------------------------------------------------
SELECT 'tipo_servico' AS coluna,
       (SELECT COUNT(DISTINCT tipo_servico) FROM dc_projetos) AS grafias_antes,
       (SELECT COUNT(DISTINCT tipo_servico) FROM projetos_limpo)       AS categorias_agora,
       (SELECT COUNT(*) FROM projetos_limpo
         WHERE tipo_servico IS NULL OR TRIM(tipo_servico) = '')  AS ficaram_vazias
UNION ALL
SELECT 'status',
       (SELECT COUNT(DISTINCT status) FROM dc_projetos),
       (SELECT COUNT(DISTINCT status) FROM projetos_limpo),
       (SELECT COUNT(*) FROM projetos_limpo WHERE status IS NULL OR TRIM(status) = '')
UNION ALL
SELECT 'atividade',
       (SELECT COUNT(DISTINCT atividade) FROM dc_apontamentos),
       (SELECT COUNT(DISTINCT atividade) FROM apontamentos_limpo),
       (SELECT COUNT(*) FROM apontamentos_limpo
         WHERE atividade IS NULL OR TRIM(atividade) = '')
UNION ALL
SELECT 'setor',
       (SELECT COUNT(DISTINCT setor) FROM dc_clientes),
       (SELECT COUNT(DISTINCT setor) FROM clientes_limpo),
       (SELECT COUNT(*) FROM clientes_limpo WHERE setor IS NULL OR TRIM(setor) = '')
UNION ALL
SELECT 'squad (analistas)',
       (SELECT COUNT(DISTINCT squad) FROM dc_analistas),
       (SELECT COUNT(DISTINCT squad) FROM analistas_limpo),
       (SELECT COUNT(*) FROM analistas_limpo WHERE squad IS NULL OR TRIM(squad) = '');

-- E a lista das categorias finais, para conferir com o olho:
SELECT tipo_servico, COUNT(*) AS projetos
  FROM projetos_limpo GROUP BY tipo_servico ORDER BY projetos DESC;


-- ---------------------------------------------------------------------
-- 4. NENHUM APONTAMENTO FICOU SEM PROJETO OU SEM PESSOA?
--    Terceira das quatro contas, e nos dois sentidos.
-- ---------------------------------------------------------------------
SELECT 'apontamento sem projeto' AS verificacao, COUNT(*) AS casos,
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END AS veredito
  FROM apontamentos_limpo a
  LEFT JOIN projetos_limpo p ON p.projeto_id = a.projeto_id
 WHERE p.projeto_id IS NULL
UNION ALL
SELECT 'apontamento sem analista', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END
  FROM apontamentos_limpo a
  LEFT JOIN analistas_limpo n ON n.analista_id = a.analista_id
 WHERE n.analista_id IS NULL
UNION ALL
SELECT 'projeto sem cliente', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END
  FROM projetos_limpo p
  LEFT JOIN clientes_limpo c ON c.cliente_id = p.cliente_id
 WHERE c.cliente_id IS NULL
UNION ALL
SELECT 'pesquisa sem projeto', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END
  FROM satisfacao_limpo s
  LEFT JOIN projetos_limpo p ON p.projeto_id = s.projeto_id
 WHERE p.projeto_id IS NULL
UNION ALL
SELECT 'projeto sem nenhum apontamento', COUNT(*), 'olhar, nao e erro'
  FROM projetos_limpo p
  LEFT JOIN apontamentos_limpo a ON a.projeto_id = p.projeto_id
 WHERE a.projeto_id IS NULL;

-- ---------------------------------------------------------------------
-- 5. A SOMA DAS HORAS BATE?
--    Quarta das quatro contas. Sao DOIS totais, e eles nao sao a mesma
--    coisa: o de controle inclui as linhas marcadas, o de analise nao.
--    Confundir os dois foi o erro do nosso rascunho anterior.
-- ---------------------------------------------------------------------
SELECT 'total de controle (com as marcadas)' AS recorte,
       ROUND(SUM(horas), 1) AS horas, COUNT(*) AS lancamentos
  FROM apontamentos_limpo
UNION ALL
SELECT 'base de analise (sem as marcadas, D4)',
       ROUND(SUM(horas), 1), COUNT(*)
  FROM apontamentos_limpo
 WHERE flag_hora_invalida IN ('False', '0', 'false')
UNION ALL
SELECT 'diferenca: o que a decisao D4 tira',
       ROUND((SELECT SUM(horas) FROM apontamentos_limpo)
             - (SELECT SUM(horas) FROM apontamentos_limpo
                 WHERE flag_hora_invalida IN ('False', '0', 'false')), 1),
       (SELECT COUNT(*) FROM apontamentos_limpo
         WHERE flag_hora_invalida IN ('True', '1', 'true'));


-- ---------------------------------------------------------------------
-- 6. O VALOR DO CONTRATO FOI CONVERTIDO CERTO?
--    Este e o bloco mais importante do arquivo. Ele compara o texto do
--    arquivo original com o numero da base limpa, linha a linha.
--    Se alguma linha aparecer aqui com diferenca grande, a conversao
--    esta errada. Foi assim que descobrimos o erro de cem vezes.
-- ---------------------------------------------------------------------
SELECT p.projeto_id,
       b.valor_contrato AS como_veio_no_arquivo,
       p.valor_contrato AS como_ficou,
       CASE
         WHEN b.valor_contrato IS NULL OR TRIM(b.valor_contrato) = ''
              THEN 'vazio na origem'
         -- formato brasileiro: tem virgula
         WHEN INSTR(b.valor_contrato, ',') > 0 THEN 'formato BR'
         -- formato ISO: tem ponto e nao tem virgula
         WHEN INSTR(b.valor_contrato, '.') > 0 THEN 'formato ISO'
         ELSE 'inteiro'
       END AS formato_na_origem
  FROM projetos_limpo p
  JOIN dc_projetos b ON b.projeto_id = p.projeto_id
 ORDER BY p.valor_contrato DESC
 LIMIT 15;

-- E o teste que pega o erro de cem vezes de uma vez so:
-- para o formato ISO, o numero limpo tem que ser IGUAL ao texto da origem.
SELECT COUNT(*) AS iso_convertidos_errado,
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU: erro de 100x' END AS veredito
  FROM projetos_limpo p
  JOIN dc_projetos b ON b.projeto_id = p.projeto_id
 WHERE INSTR(b.valor_contrato, '.') > 0
   AND INSTR(b.valor_contrato, ',') = 0
   AND ABS(CAST(b.valor_contrato AS REAL) - p.valor_contrato) > 0.01;

-- Quantos valores de cada formato conviviam na coluna:
SELECT CASE
         WHEN valor_contrato IS NULL OR TRIM(valor_contrato) = '' THEN 'vazio'
         WHEN INSTR(valor_contrato, ',') > 0 THEN 'formato BR (virgula)'
         WHEN INSTR(valor_contrato, '.') > 0 THEN 'formato ISO (ponto)'
         ELSE 'inteiro'
       END AS formato,
       COUNT(*) AS linhas
  FROM dc_projetos
 GROUP BY formato ORDER BY linhas DESC;


-- ---------------------------------------------------------------------
-- 7. A RECEITA TOTAL BATE?
--    O total de controle inclui tudo que esta na base, inclusive o
--    contrato fora de escala. Os recortes de analise vem depois.
-- ---------------------------------------------------------------------
SELECT 'tudo que esta na base (controle)' AS recorte,
       COUNT(*) AS projetos, ROUND(SUM(valor_contrato), 2) AS receita
  FROM projetos_limpo
UNION ALL
SELECT 'sem o contrato fora de escala (D2)', COUNT(*), ROUND(SUM(valor_contrato), 2)
  FROM projetos_limpo WHERE flag_contrato_extremo IN ('False', '0', 'false')
UNION ALL
SELECT 'sem extremo e sem os sem contrato (D2+D3)', COUNT(*),
       ROUND(SUM(valor_contrato), 2)
  FROM projetos_limpo
 WHERE flag_contrato_extremo IN ('False', '0', 'false')
   AND valor_contrato IS NOT NULL
UNION ALL
SELECT 'so concluidos (D2+D3+D5)', COUNT(*), ROUND(SUM(valor_contrato), 2)
  FROM projetos_limpo
 WHERE flag_contrato_extremo IN ('False', '0', 'false')
   AND valor_contrato IS NOT NULL
   AND status = 'Concluído';


-- ---------------------------------------------------------------------
-- 8. AS DATAS ESTAO TODAS NO MESMO FORMATO, E NA ORDEM CERTA?
--    Passo 7: todas em aaaa-mm-dd. E o teste de sanidade do mentor:
--    inicio <= fim previsto e inicio <= fim real.
-- ---------------------------------------------------------------------
SELECT 'data fora do formato aaaa-mm-dd' AS verificacao, COUNT(*) AS casos,
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END AS veredito
  FROM projetos_limpo
 WHERE (data_inicio       IS NOT NULL AND data_inicio       NOT GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*')
    OR (data_fim_prevista IS NOT NULL AND data_fim_prevista NOT GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*')
    OR (data_fim_real     IS NOT NULL AND TRIM(data_fim_real) <> ''
        AND data_fim_real NOT GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]*')
UNION ALL
SELECT 'fim previsto antes do inicio, sem estar marcado', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END
  FROM projetos_limpo
 WHERE data_fim_prevista < data_inicio
   AND flag_data_suspeita IN ('False', '0', 'false')
UNION ALL
SELECT 'fim real antes do inicio, sem estar marcado', COUNT(*),
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END
  FROM projetos_limpo
 WHERE data_fim_real <> '' AND data_fim_real < data_inicio
   AND flag_data_suspeita IN ('False', '0', 'false');

-- Quantas datas ficaram marcadas como ambiguas em cada coluna.
-- Estas sao as que a gente NAO conseguiu provar, e estao declaradas.
SELECT 'data_inicio'       AS coluna, COUNT(*) AS ambiguas FROM projetos_limpo
 WHERE data_inicio_ambigua IN ('True', '1', 'true')
UNION ALL
SELECT 'data_fim_prevista', COUNT(*) FROM projetos_limpo
 WHERE data_fim_prevista_ambigua IN ('True', '1', 'true')
UNION ALL
SELECT 'data_fim_real', COUNT(*) FROM projetos_limpo
 WHERE data_fim_real_ambigua IN ('True', '1', 'true')
UNION ALL
SELECT 'apontamentos.data', COUNT(*) FROM apontamentos_limpo
 WHERE data_ambigua IN ('True', '1', 'true');


-- ---------------------------------------------------------------------
-- 9. O VAZIO ESPERADO ESTA SEPARADO DO VAZIO PROBLEMATICO?
--    Ponto que o mentor levantou por e-mail: data_fim_real vazia em
--    projeto que nao terminou NAO e inconsistencia, e o dado correto.
--    Misturar os dois infla a contagem de problemas.
-- ---------------------------------------------------------------------
SELECT status,
       COUNT(*) AS projetos,
       SUM(CASE WHEN data_fim_real IS NULL OR TRIM(data_fim_real) = ''
                THEN 1 ELSE 0 END) AS sem_data_de_entrega
  FROM projetos_limpo
 GROUP BY status;

-- O caso que seria problema de verdade: concluido e sem data de entrega.
SELECT COUNT(*) AS concluido_sem_data_de_entrega,
       CASE WHEN COUNT(*) = 0 THEN 'PASSOU' ELSE 'FALHOU' END AS veredito
  FROM projetos_limpo
 WHERE status = 'Concluído'
   AND (data_fim_real IS NULL OR TRIM(data_fim_real) = '');


-- ---------------------------------------------------------------------
-- 10. O CUSTO POR PROJETO REPRODUZ?
--     A regra dos tres numeros, em SQL. Escolha tres projeto_id do
--     notebook e compare o custo linha a linha.
--     Troque os ids abaixo pelos que o notebook usou.
-- ---------------------------------------------------------------------
SELECT a.projeto_id,
       COUNT(*)                                AS lancamentos,
       ROUND(SUM(a.horas), 2)                  AS horas,
       ROUND(SUM(a.horas * n.custo_hora), 2)   AS custo_calculado_aqui,
       ROUND(m.custo_real, 2)                  AS custo_do_notebook,
       CASE WHEN ABS(SUM(a.horas * n.custo_hora) - m.custo_real) < 0.01
            THEN 'PASSOU' ELSE 'FALHOU' END    AS veredito
  FROM apontamentos_limpo a
  JOIN analistas_limpo n      ON n.analista_id = a.analista_id
  JOIN margem_projeto_limpo m ON m.projeto_id  = a.projeto_id
 WHERE a.flag_hora_invalida IN ('False', '0', 'false')
   AND a.projeto_id IN ('PRJ0002', 'PRJ0003', 'PRJ0004')
 GROUP BY a.projeto_id, m.custo_real;


-- ---------------------------------------------------------------------
-- 11. A PERGUNTA 1 DA RENATA, EM SQL
--     Qual linha de servico da dinheiro e qual nao da.
--
--     Repare que somamos receita e custo ANTES de dividir. Media de
--     percentual nao e percentual do total, e esse era o erro que a
--     aula avisou que ia nos pegar.
--
--     O universo esta declarado no WHERE, e o mesmo texto vai na
--     legenda do grafico no painel.
-- ---------------------------------------------------------------------
SELECT tipo_servico,
       COUNT(*)                                          AS projetos,
       ROUND(SUM(valor_contrato), 2)                     AS receita,
       ROUND(SUM(custo_real), 2)                         AS custo,
       ROUND(SUM(valor_contrato) - SUM(custo_real), 2)   AS margem_rs,
       ROUND(100.0 * (SUM(valor_contrato) - SUM(custo_real))
             / SUM(valor_contrato), 1)                   AS margem_pct
  FROM margem_projeto_limpo
 WHERE status = 'Concluído'
   AND flag_contrato_extremo IN ('False', '0', 'false')
   AND valor_contrato IS NOT NULL
 GROUP BY tipo_servico
 ORDER BY margem_pct ASC;

-- A mesma conta do jeito ERRADO, para ver a diferenca com os proprios
-- olhos. Nao use este numero: ele esta aqui so como aviso.
SELECT tipo_servico,
       ROUND(AVG(100.0 * (valor_contrato - custo_real) / valor_contrato), 1)
         AS media_das_margens_NAO_USE,
       ROUND(100.0 * (SUM(valor_contrato) - SUM(custo_real))
             / SUM(valor_contrato), 1) AS margem_correta
  FROM margem_projeto_limpo
 WHERE status = 'Concluído'
   AND flag_contrato_extremo IN ('False', '0', 'false')
   AND valor_contrato IS NOT NULL
 GROUP BY tipo_servico
 ORDER BY margem_correta ASC;


-- ---------------------------------------------------------------------
-- 12. O TAMANHO DAS NOSSAS DECISOES, EM DINHEIRO
--     Quanto cada decisao de nivel vermelho vale. E o que vai para o
--     slide "o que ficou de fora": decisao sem custo declarado e so
--     opiniao.
-- ---------------------------------------------------------------------
SELECT 'D2: contrato fora de escala' AS decisao,
       COUNT(*) AS linhas,
       ROUND(SUM(valor_contrato), 2) AS reais_fora_da_analise
  FROM projetos_limpo WHERE flag_contrato_extremo IN ('True', '1', 'true')
UNION ALL
SELECT 'D3: projetos sem valor de contrato', COUNT(*), NULL
  FROM projetos_limpo WHERE valor_contrato IS NULL
UNION ALL
SELECT 'D4: horas marcadas fora do custo',
       (SELECT COUNT(*) FROM apontamentos_limpo
         WHERE flag_hora_invalida IN ('True', '1', 'true')),
       (SELECT ROUND(SUM(a.horas * n.custo_hora), 2)
          FROM apontamentos_limpo a JOIN analistas_limpo n ON n.analista_id = a.analista_id
         WHERE a.flag_hora_invalida IN ('True', '1', 'true'))
UNION ALL
SELECT 'D5: projetos fora do universo de margem', COUNT(*),
       ROUND(SUM(valor_contrato), 2)
  FROM projetos_limpo WHERE status <> 'Concluído';


-- =====================================================================
-- FIM
--
-- Se todos os vereditos disserem PASSOU e os totais dos blocos 5, 7 e 11
-- baterem com o notebook, a base esta validada em duas ferramentas
-- diferentes e o numero e nosso.
--
-- Se algum nao bater, o certo e voltar para o notebook: o SQL aqui e a
-- segunda opiniao, nao a verdade.
-- =====================================================================