printf "Claims potencialmente controversos da WD - Junho 2022\n" > /home/cloud-di/kgtk_WD3.log 2>&1 

printf "INICIO Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1 

export GRAPH_ALIAS=/app/kgtk/data/wikidata/alias.en.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1
export GRAPH_QUALS=/app/kgtk/data/wikidata/qualifiers.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1
export GRAPH_CLAIMS=/app/kgtk/data/wikidata/claims.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1
export GRAPH_LABEL=/app/kgtk/data/wikidata/labels.en.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

export GRAPH_CPRED=/app/kgtk/data/WD1/all-claims-pred-counted.tsv  >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.0 Preparar ambiente %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD3.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_ALIAS --as alias -i $GRAPH_QUALS --as quals -i $GRAPH_CLAIMS --as claims -index none --limit 3 >> /home/cloud-di/kgtk_WD3.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_LABEL --as lab -i GRAPH_CPRED --as cp --limit 3 >> /home/cloud-di/kgtk_WD3.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD3.log 2>&1 

printf "WD3.1 Selecionar CLAIMS potencialmente controversos do conjunto completo e gerar grafo filtrado %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

## \time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_CLAIMS --as claims --index none --multi 2 \
## --match 'claims: (item)-[p1]->(value1 {wikidatatype: dt}), (item)-[p2]->(value2)' \
## --where 'value1 < value2 and p1.label = p2.label and dt != "external-id" and dt != "wikibase-property"' \
## --return 'distinct p1, item, p1.label, value1, p2, item, p2.label, value2' \
## -o /app/kgtk/data/WD3/filtered-claims.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.2 Remover duplicatas do grafo filtrado %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

## zcat /app/kgtk/data/WD3/filtered-claims.tsv.gz | sort -u > /app/kgtk/data/WD3/filtered-claims-sorted-uniq.tsv  >> /home/cloud-di/kgtk_WD3.log 2>&1

export GRAPH_F1=/app/kgtk/data/WD3/filtered-claims-sorted-uniq.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1
export GRAPH_F1=/app/kgtk/data/my-tsv/filtered-claims-sorted-uniq.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.3 Contar Predicados do conjunto filtrado %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug sort -i $GRAPH_F1 -c label \
--output-file /app/kgtk/data/WD3/filtered-pred-sorted.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

export GRAPH_SORT=/app/kgtk/data/WD3/filtered-pred-sorted.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug unique -i $GRAPH_SORT --columns label --presorted \
--output-file /app/kgtk/data/WD3/filtered-pred-count-sorted.tsv

export GRAPH_FPRED=/app/kgtk/data/WD3/filtered-pred-count-sorted.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_FPRED --as fpred -i $GRAPH_LABEL --as lab \
--match 'fpred: (pred)-[]->(cp)' \
--opt 'lab: (pred)-[]->(pred_name)' \
--return 'pred as node1, "count" as label, cast(cp, integer) as node2, pred_name as `node1;label`' \
-o /app/kgtk/data/WD3/filtered-pred-count-label.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_FPRED --as fpred -i $GRAPH_ALIAS --as a \
--match 'fpred: (pred)-[]->(cp)' \
--opt 'a: (pred)-[]->(pred_name)' \
--return 'pred as node1, "count" as label, cast(cp, integer) as node2, GROUP_CONCAT(pred_name) as `node1;alias`' \
-o /app/kgtk/data/WD3/filtered-pred-count-alias.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk query -i $GRAPH_F1 --as f1  --index none --limit 3 >> /home/cloud-di/kgtk_WD3.log 2>&1 
\time --format='Elapsed time: %e seconds' kgtk query --show-cache >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.4 Separar claims SEM qualificadores do conjunto filtrado %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_F1 --as f1 --index none -i $GRAPH_QUALS --as quals \
--match 'f1: (item)-[p1]->(value1)' \
--opt 'quals: (p1)-[q1]->()' \
--where: 'q1 is null'  \
--order-by 'p1.label, item' \
--return 'distinct p1, item, p1.label, value1' \
-o /app/kgtk/data/WD3/filtered-claims-without-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

export GRAPH_F11=/app/kgtk/data/WD3/filtered-claims-without-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.5 Contar Predicados do conjunto controversos SEM qualificadores %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug unique -i $GRAPH_F11 --columns label --presorted \
--output-file /app/kgtk/data/WD3/filtered-claims-without-quals-counted.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

export GRAPH_FPRED1=/app/kgtk/data/WD3/filtered-claims-without-quals-counted.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.6 Agregar alias e label de Predicados ao conjunto controversos SEM qualificadores %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_FPRED1 --as fp1 -i $GRAPH_CPRED --as cp -i $GRAPH_ALIAS --as alias \
--match 'fp1: (pred)-[]->(count_1), cp: (pred)-[]->(count_2)' \
--opt 'alias: (pred)-[]->(pred_name)' \
--return 'pred, "count" as label, cast(count_1, integer) as node2, cast(count_2, integer) as `node1;all-count`, GROUP_CONCAT(pred_name) as `node1;alias`' \
-o /app/kgtk/data/WD3/filtered-claims-without-quals-counted-alias.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_FPRED1 --as fp1 -i $GRAPH_CPRED --as cp -i $GRAPH_LABEL --as lab \
--match 'fp1: (pred)-[]->(count_1), cp: (pred)-[]->(count_2)' \
--opt 'lab: (pred)-[]->(pred_name)' \
--return 'pred, "count" as label, cast(count_1, integer) as node2, cast(count_2, integer) as `node1;all-count`, pred_name as `node1;label`' \
-o /app/kgtk/data/WD3/filtered-claims-without-quals-counted-label.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.7 Separar claims COM qualificadores do conjunto controversos %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_F1 --as f1 --index none -i $GRAPH_QUALS --as quals \
--match 'f1: (item)-[p1]->(value1), quals: (p1)-[]->()' \
--order-by 'p1.label, item' \
--return 'distinct p1, item, p1.label, value1' \
-o /app/kgtk/data/WD3/filtered-claims-with-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

export GRAPH_F12=/app/kgtk/data/WD3/filtered-claims-with-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.8 Contar Predicados do conjunto controversos COM qualificadores %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug unique -i $GRAPH_F12 --columns label --presorted \
--output-file /app/kgtk/data/WD3/filtered-claims-with-quals-counted.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

export GRAPH_FPRED2=/app/kgtk/data/WD3/filtered-claims-with-quals-counted.tsv  >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.9 Agregar alias e label de Predicados do conjunto controversos COM qualificadores %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_FPRED2 --as fp2 -i $GRAPH_CPRED --as cp -i $GRAPH_ALIAS --as alias \
--match 'fp2: (pred)-[]->(count_1), cp: (pred)-[]->(count_2)' \
--opt 'alias: (pred)-[]->(pred_name)' \
--return 'pred, "count" as label, cast(count_1, integer) as node2, cast(count_2, integer) as `node1;all-count`, GROUP_CONCAT(pred_name) as `node1;alias`' \
-o /app/kgtk/data/WD3/filtered-claims-with-quals-counted-alias.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_FPRED2 --as fp2 -i $GRAPH_CPRED --as cp -i $GRAPH_LABEL --as lab \
--match 'fp2: (pred)-[]->(count_1), cp: (pred)-[]->(count_2)' \
--opt 'lab: (pred)-[]->(pred_name)' \
--return 'pred, "count" as label, cast(count_1, integer) as node2, cast(count_2, integer) as `node1;all-count`, pred_name as `node1;label`' \
-o /app/kgtk/data/WD3/filtered-claims-with-quals-counted-label.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.10 Contar Qualificadores do conjunto controversos %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_F12 --as f12 --index none -i $GRAPH_QUALS --as quals \
--match 'f12: (item)-[p1]->(), quals: (p1)-[q1]->(value1)' \
--order-by 'q1.label, item' \
--return 'distinct q1, p1 as node1, q1.label, value1' \
-o /app/kgtk/data/WD3/filtered-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

export GRAPH_QF12=/app/kgtk/data/WD3/filtered-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug unique -i $GRAPH_QF12 --columns label --presorted \
--output-file /app/kgtk/data/WD3/filtered-quals-counted.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.11 Agregar alias e label de Qualificadores do conjunto controversos %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

export GRAPH_FQUAL=/app/kgtk/data/WD3/filtered-quals-counted.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_FQUAL --as qs -i $GRAPH_ALIAS --as a \
--match 'qs: (quali)-[]->(cq)' --opt 'a: (quali)-[]->(quali_name)' \
--return 'quali as node1, "count" as label, cast(cq, integer) as node2, quali_name as `node1;alias`' \
-o /app/kgtk/data/WD3/filtered-quals-count-alias.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_FQUAL --as qs -i $GRAPH_LABEL --as lab \
--match 'qs: (quali)-[]->(cq)' --opt 'lab: (quali)-[]->(quali_name)' \
--return 'quali as node1, "count" as label, cast(cq, integer) as node2, GROUP_CONCAT(quali_name) as `node1;label`' \
-o /app/kgtk/data/WD3/filtered-quals-count-label.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.12 Contar Predicados_Qualificadores do conjunto controversos COM qualificadores %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_F12 --as f12 --index none -i $GRAPH_QUALS --as quals \
--match 'f12: (item)-[p1]->(), quals: (p1)-[q1]->()' \
--order-by 'p1.label, q1.label' \
--return 'p1.label as node1, "quali" as label, q1.label as node2, count(q1.label) as `node2;count_q`' \
-o /app/kgtk/data/WD3/filtered-pred-with-quals-count-sorted.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

export GRAPH_FPRED3=/app/kgtk/data/WD3/filtered-pred-with-quals-count-sorted.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.13 Agregar label e alias de Predicados e Qualificadores aos Contadores do conjunto controversos %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_FPRED3 --as fp3 -i $GRAPH_FPRED2 --as fp2 -i $GRAPH_ALIAS --as alias \
--match 'fp3: (pred)-[]->(quali {count_q: cq}), fp2: (pred)-[]->(cp)' \
--opt 'alias: (pred)-[]->(pred_name)' --opt 'alias: (quali)-[]->(quali_name)' \
--return 'distinct pred, "quali" as label, quali as node2, cast(cp, integer) as `node1;count`, GROUP_CONCAT(pred_name) as `node1;alias`, cast(cq, integer) as `node2;count`, GROUP_CONCAT(quali_name) as `node2;alias`' \
-o /app/kgtk/data/WD3/filtered-pred-with-quals-counted-alias.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_FPRED3 --as fp3 -i $GRAPH_FPRED2 --as fp2 -i $GRAPH_LABEL --as lab \
--match 'fp3: (pred)-[]->(quali {count_q: cq}), fp2: (pred)-[]->(cp)' \
--opt 'lab: (pred)-[]->(pred_name)' --opt 'lab: (quali)-[]->(quali_name)' \
--return 'distinct pred, "quali" as label, quali as node2, cast(cp, integer) as `node1;count`, pred_name as `node1;alias`, cast(cq, integer) as `node2;count`, quali_name as `node2;alias`' \
-o /app/kgtk/data/WD3/filtered-pred-with-quals-counted-label.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14 Sumarização do processamento %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14a Total Claims potencialmente controversos %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
cat $GRAPH_F1 | wc -l >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14b Total Predicates encontrados em Claims potencialmente controversos %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
cat $GRAPH_FPRED | wc -l  >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14c TOP-10 Predicados encontrados em Claims potencialmente controversos %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
\time --format='Elapsed time: %e seconds'  kgtk sort -i /app/kgtk/data/WD3/filtered-pred-count-label.tsv -c node2 --reverse-columns node2 --numeric-columns node2 / head  >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14d Total Claims potencialmente controversos não qualificados %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
zcat $GRAPH_F11 | wc -l >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14e Total Predicates encontrados em Claims potencialmente controversos não qualificados %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
cat $GRAPH_FPRED1 | wc -l  >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14f TOP-10 Predicados encontrados em Claims potencialmente controversos não qualificados %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
\time --format='Elapsed time: %e seconds'  kgtk sort -i /app/kgtk/data/WD3/filtered-claims-without-quals-counted-label.tsv -c node2 --reverse-columns node2 --numeric-columns node2 / head  >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14g Total Claims potencialmente controversos e qualificados %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
zcat $GRAPH_F12 | wc -l >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14h Total Predicates encontrados em Claims potencialmente controversos e qualificados %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
cat $GRAPH_FPRED2 | wc -l  >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14i TOP-10 Predicados encontrados em Claims potencialmente controversos e qualificados %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
\time --format='Elapsed time: %e seconds'  kgtk sort -i /app/kgtk/data/WD3/filtered-claims-with-quals-counted-label.tsv -c node2 --reverse-columns node2 --numeric-columns node2 / head  >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14j Total Qualifications for Claims potencialmente controversos %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
zcat $GRAPH_QF12 | wc -l >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14k Total Qualifiers encontrados em Claims potencialmente controversos %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
cat $GRAPH_FQUAL | wc -l >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.14l TOP-10 Qualifiers encontrados em Claims potencialmente controversos %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
\time --format='Elapsed time: %e seconds' kgtk sort -i /app/kgtk/data/WD3/filtered-quals-count-label.tsv -c node2 --reverse-columns node2 --numeric-columns node2 / head >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "FIM Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1 



