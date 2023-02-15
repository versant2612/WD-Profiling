printf "Claims e Qualificações da WD - Junho 2022\n" > /home/cloud-di/kgtk_WD1.log 2>&1 

printf "START Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1 

export GRAPH_ALIAS=/app/kgtk/data/wikidata/alias.en.tsv.gz >> /home/cloud-di/kgtk_WD1.log 2>&1
export GRAPH_QUALS=/app/kgtk/data/wikidata/qualifiers.tsv.gz >> /home/cloud-di/kgtk_WD1.log 2>&1
export GRAPH_CLAIMS=/app/kgtk/data/wikidata/claims.tsv.gz >> /home/cloud-di/kgtk_WD1.log 2>&1
export GRAPH_LABEL=/app/kgtk/data/wikidata/labels.en.tsv.gz >> /home/cloud-di/kgtk_WD1.log 2>&1

printf "WD1.0 Preparar ambiente %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD1.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_ALIAS --as alias -i $GRAPH_QUALS --as quals -i $GRAPH_CLAIMS --as claims -index none --limit 3 >> /home/cloud-di/kgtk_WD1.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_LABEL --as lab --limit 3 >> /home/cloud-di/kgtk_WD1.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD1.log 2>&1 

printf "WD1.1 Tratar CLAIMS para o conjunto completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug sort -i $GRAPH_CLAIMS -c label \
--output-file /app/kgtk/data/WD1/claims-sorted.tsv.gz >> /home/cloud-di/kgtk_WD1.log 2>&1

export GRAPH_SCLAIMS=/app/kgtk/data/WD1/claims-sorted.tsv.gz >> /home/cloud-di/kgtk_WD1.log 2>&1

printf "WD1.2 Contar Predicados do conjunto completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug unique -i $GRAPH_SCLAIMS --columns label --presorted \
--output-file /app/kgtk/data/WD1/all-claims-pred-counted.tsv >> /home/cloud-di/kgtk_WD1.log 2>&1

export GRAPH_CPRED=/app/kgtk/data/WD1/all-claims-pred-counted.tsv  >> /home/cloud-di/kgtk_WD1.log 2>&1

printf "WD1.3 Contar Qualificadores do conjunto completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug sort -i $GRAPH_QUALS -c label \
--output-file /app/kgtk/data/WD1/quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD1.log 2>&1

export GRAPH_SQUALS=/app/kgtk/data/WD1/quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD1.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug unique -i $GRAPH_SQUALS --columns label --presorted \
--output-file /app/kgtk/data/WD1/all-claims-quals-counted.tsv >> /home/cloud-di/kgtk_WD1.log 2>&1

export GRAPH_CQUALI=/app/kgtk/data/WD1/all-claims-quals-counted.tsv  >> /home/cloud-di/kgtk_WD1.log 2>&1

printf "WD1.4 Contar Qualificadores por Predicado do conjunto completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_CLAIMS --as c --index none -i $GRAPH_QUALS --as quals\
--match 'c: (item)-[p1]->(), quals: (p1)-[q1]->()' \
--order-by 'p1.label, q1.label' \
--return 'p1.label as node1, "quali" as label, q1.label as node2, count(q1.label) as `node2;count_q`' \
-o /app/kgtk/data/WD1/claims-pred-quals-count-sorted.tsv >> /home/cloud-di/kgtk_WD1.log 2>&1

export GRAPH_PQUALS=/app/kgtk/data/WD1/all-claims-pred-quals-count-sorted.tsv  >> /home/cloud-di/kgtk_WD1.log 2>&1

printf "WD1.5 Agregar alias e label de Predicados e Qualificadores as Contagens do conjunto completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_CPRED --as p -i $GRAPH_LABEL --as lab \
--match 'p: (pred)-[]->(cp)' \
--opt 'lab: (pred)-[]->(pred_name)' \
--return 'pred as node1, "count" as label, cast(cp, integer) as node2, pred_name as `node1;label`' \
-o /app/kgtk/data/WD1/all-pred-count-label.tsv >> /home/cloud-di/kgtk_WD1.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_CQUALI --as qs -i $GRAPH_LABEL --as lab \
--match 'qs: (quali)-[]->(cq)' \
--opt 'lab: (quali)-[]->(quali_name)' \
--return 'quali as node1, "count" as label, cast(cq, integer) as node2, quali_name as `node1;alias`' \
-o /app/kgtk/data/WD1/all-quals-count-label.tsv >> /home/cloud-di/kgtk_WD1.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_CPRED --as p -i $GRAPH_PQUALS  --as pq -i $GRAPH_ALIAS --as a \
--match 'pq: (pred)-[]->(quali {count_q: cq}), p: (pred)-[]->(cp)' \
--opt 'a: (pred)-[]->(pred_name)' --opt '(quali)-[]->(quali_name)' \
--return 'pred, GROUP_CONCAT(DISTINCT pred_name), cast(cp, integer), quali, GROUP_CONCAT(DISTINCT quali_name), cast(cq, integer)' \
-o /app/kgtk/data/WD1/all-pred-quals-count-alias.tsv >> /home/cloud-di/kgtk_WD1.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_CPRED --as p -i $GRAPH_PQUALS  --as pq -i $GRAPH_LABEL --as lab \
--match 'pq: (pred)-[]->(quali {count_q: cq}), p: (pred)-[]->(cp)' \
--opt 'lab: (pred)-[]->(pred_name)' --opt 'lab: (quali)-[]->(quali_name)' \
--return 'pred, pred_name as `node1;label`, cast(cp, integer) as `node1;count`, quali, quali_name as `node2;label`, cast(cq, integer) as `node2;count`' \
-o /app/kgtk/data/WD1/all-pred-quals-count-label.tsv >> /home/cloud-di/kgtk_WD1.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD1.log 2>&1 

printf "WD1.6 Sumarização do processamento %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1

printf "WD1.6a Total Claims %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1
\time --format='Elapsed time: %e seconds' zcat $GRAPH_SCLAIMS | wc -l >> /home/cloud-di/kgtk_WD1.log 2>&1

printf "WD1.6b Total Predicates %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1
\time --format='Elapsed time: %e seconds' cat /app/kgtk/data/WD1/all-pred-count-label.tsv | wc -l  >> /home/cloud-di/kgtk_WD1.log 2>&1

printf "WD1.6c TOP-10 Predicados %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1
\time --format='Elapsed time: %e seconds'  kgtk sort -i /app/kgtk/data/WD1/all-pred-count-label.tsv -c node2 --reverse-columns node2 --numeric-columns node2 / head  >> /home/cloud-di/kgtk_WD1.log 2>&1

printf "WD1.6d Total Qualifications for Claims %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1
\time --format='Elapsed time: %e seconds' zcat GRAPH_SQUALS | wc -l >> /home/cloud-di/kgtk_WD1.log 2>&1

printf "WD1.6e Total Qualifiers %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1
\time --format='Elapsed time: %e seconds' more /app/kgtk/data/WD1/all-quals-count-label.tsv | wc -l >> /home/cloud-di/kgtk_WD1.log 2>&1

printf "WD1.6f TOP-10 Qualifiers %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1
\time --format='Elapsed time: %e seconds' kgtk sort -i /app/kgtk/data/WD1/all-quals-count-label.tsv -c node2 --reverse-columns node2 --numeric-columns node2 / head >> /home/cloud-di/kgtk_WD1.log 2>&1

printf "END Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1 

printf "WD1.7 Gerar conjunto de Claims qualificados para o conjunto completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD1.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_CLAIMS --as claims --index none -i $GRAPH_QUALS --as quals \
--match 'claims: (item)-[p1]->(val_item), quals: (p1)-[q1]->(val_quali)' \
--order-by 'p1.label, q1.label' \
--return 'p1, item, p1.label, val_item, q1, q1.label, val_quali' \
-o /app/kgtk/data/WD1/all-claims-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD1.log 2>&1

