printf "Disputed By e Rank da WD\n" >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "INICIO Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1 

export GRAPH_ALIAS=/app/kgtk/data/wikidata/alias.en.tsv.gz >> /home/cloud-di/kgtk_WD2.log 2>&1
export GRAPH_QUALS=/app/kgtk/data/wikidata/qualifiers.tsv.gz >> /home/cloud-di/kgtk_WD2.log 2>&1
export GRAPH_CLAIMS=/app/kgtk/data/wikidata/claims.tsv.gz >> /home/cloud-di/kgtk_WD2.log 2>&1
export GRAPH_LABEL=/app/kgtk/data/wikidata/labels.en.tsv.gz >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.0 Preparar ambiente %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD2.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_ALIAS --as alias -i $GRAPH_QUALS --as quals -i $GRAPH_CLAIMS --as claims -index none --limit 3 >> /home/cloud-di/kgtk_WD2.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_LABEL --as lab --limit 3 >> /home/cloud-di/kgtk_WD2.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD2.log 2>&1 

printf "WD2.1 Selecionar CLAIMS para o conjunto disputedBy - qualifier P1310 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_CLAIMS --as claims --index none -i $GRAPH_QUALS --as quals \
--match 'claims: (item)-[p1]->(value1), quals: (p1)-[:P1310]->()' \
--order-by 'p1.label, item' \
--return 'distinct p1, item, p1.label, value1' \
-o /app/kgtk/data/WD2/disputedBy-claims-sorted.tsv.gz >> /home/cloud-di/kgtk_WD2.log 2>&1

export GRAPH_SORT=/app/kgtk/data/WD2/disputedBy-claims-sorted.tsv.gz >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.2 Contar Predicados do conjunto disputedBy - qualifier P1310 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug unique -i $GRAPH_SORT --columns label --presorted \
--output-file /app/kgtk/data/WD2/disputedBy-claims-pred-counted.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

export GRAPH_DPRED=/app/kgtk/data/WD2/disputedBy-claims-pred-counted.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.3 Agregar alias e label de Predicados aos Contadores do conjunto disputedBy - qualifier P1310 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_DPRED --as dp -i $GRAPH_ALIAS --as alias \
--match 'dp: (pred)-[]->(cp)' --opt 'alias: (pred)-[]->(pred_name)' \
--return 'pred as node1, "count" as label, cast(cp, integer) as node2, round((cast(cp, real)/1577)*100, 4) as `node1;distribution`, GROUP_CONCAT(DISTINCT pred_name) as `node1;alias`' \
-o /app/kgtk/data/WD2/disputedBy-claims-pred-count-alias.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_DPRED --as dp -i $GRAPH_LABEL --as lab \
--match 'dp: (pred)-[]->(cp)' --opt 'lab: (pred)-[]->(pred_name)' \
--return 'pred as node1, "count" as label, cast(cp, integer) as node2, round((cast(cp, real)/1577)*100, 4) as `node1;distribution`, pred_name as `node1;label`' \
-o /app/kgtk/data/WD2/disputedBy-claims-pred-count-label.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.4 Selecionar CLAIMS para o conjunto preferredRank %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug filter -i $GRAPH_CLAIMS --label rank -p " ; preferred ;  "  \
-o /app/kgtk/data/WD2/preferredRank-claims.tsv.gz >> /home/cloud-di/kgtk_WD2.log 2>&1

export GRAPH_PREF=/app/kgtk/data/WD2/preferredRank-claims.tsv.gz >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.5 Contar Predicados do conjunto preferredRank %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug unique -i $GRAPH_PREF --columns label \
--output-file /app/kgtk/data/WD2/preferredRank-claims-counted.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

export GRAPH_PRANK=/app/kgtk/data/WD2/preferredRank-claims-counted.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.6 Agregar álias e label de Predicados aos Contadores do conjunto preferredRank %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_PRANK --as prc -i $GRAPH_ALIAS --as alias \
--match 'prc: (pred)-[]->(cp)' --opt 'alias: (pred)-[]->(pred_name)' \
--return 'pred as node1, "count" as label, cast(cp, integer) as node2, GROUP_CONCAT(DISTINCT pred_name) as `node1;alias`' \
-o /app/kgtk/data/WD2/preferredRank-claims-pred-count-alias.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_PRANK --as prc -i $GRAPH_LABEL --as lab \
--match 'prc: (pred)-[]->(cp)' --opt 'lab: (pred)-[]->(pred_name)' \
--return 'pred as node1, "count" as label, cast(cp, integer) as node2, pred_name as `node1;label`' \
-o /app/kgtk/data/WD2/preferredRank-claims-pred-count-label.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.8 Selecionar CLAIMS para o conjunto completo com preferred qualifier P7452 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_CLAIMS --as claims --index none -i $GRAPH_QUALS --as quals \
--match 'claims: (item)-[p1]->(value1), quals: (p1)-[:P7452]->()' \
--order-by 'p1.label, item' \
--return 'p1, item, p1.label, value1' \
-o /app/kgtk/data/WD2/preferredRank-pred-P7452-sorted.tsv.gz >> /home/cloud-di/kgtk_WD2.log 2>&1

export GRAPH_SORT=/app/kgtk/data/WD2/preferredRank-pred-P7452-sorted.tsv.gz >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.9 Contar Predicados do conjunto completo com preferred qualifier P7452 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug unique -i $GRAPH_SORT --columns label --presorted \
--output-file /app/kgtk/data/WD2/preferredRank-pred-P7452-counted.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

export GRAPH_PRANK_C=/app/kgtk/data/WD2/preferredRank-pred-P7452-counted.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.10 Agregar alias e label de Predicados aos Contadores do conjunto com preferred qualifier P7452 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_PRANK_C --as prc -i $GRAPH_ALIAS --as alias \
--match 'prc: (pred)-[]->(cp)' --opt 'alias: (pred)-[]->(pred_name)' \
--return 'pred as node1, "count" as label, cast(cp, integer) as node2, GROUP_CONCAT(DISTINCT pred_name) as `node1;alias`' \
-o /app/kgtk/data/WD2/preferredRank-pred-P7452-count-alias.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_PRANK_C --as prc -i $GRAPH_LABEL --as lab \
--match 'prc: (pred)-[]->(cp)' --opt 'lab: (pred)-[]->(pred_name)' \
--return 'pred as node1, "count" as label, cast(cp, integer) as node2, pred_name as `node1;label`' \
-o /app/kgtk/data/WD2/preferredRank-pred-P7452-count-label.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.11 Selecionar CLAIMS para o conjunto completo com deprecated qualifier P2241 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_CLAIMS --as claims --index none -i $GRAPH_QUALS --as quals \
--match 'claims: (item)-[p1]->(value1), quals: (p1)-[:P2241]->()' \
--order-by 'p1.label, item' \
--return 'p1, item, p1.label, value1' \
-o /app/kgtk/data/WD2/deprecatedRank-pred-P2241-sorted.tsv.gz >> /home/cloud-di/kgtk_WD2.log 2>&1

export GRAPH_SORT=/app/kgtk/data/WD2/deprecatedRank-pred-P2241-sorted.tsv.gz >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.12 Contar Predicados do conjunto completo com deprecated qualifier P2241 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug unique -i $GRAPH_SORT --columns label --presorted \
--output-file /app/kgtk/data/WD2/deprecatedRank-pred-P2241-counted.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

export GRAPH_DRANK_C=/app/kgtk/data/WD2/deprecatedRank-pred-P2241-counted.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.13 Agregar álias e label de Predicados aos Contadores do conjunto com deprecated qualifier P2241 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_DRANK_C --as prc -i $GRAPH_ALIAS --as alias \
--match 'prc: (pred)-[]->(cp)' --opt 'alias: (pred)-[]->(pred_name)' \
--return 'pred as node1, "count" as label, cast(cp, integer) as node2, GROUP_CONCAT(DISTINCT pred_name) as `node1;alias`' \
-o /app/kgtk/data/WD2/deprecatedRank-pred-P2241-count-alias.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_DRANK_C --as prc -i $GRAPH_LABEL --as lab \
--match 'prc: (pred)-[]->(cp)' --opt 'lab: (pred)-[]->(pred_name)' \
--return 'pred as node1, "count" as label, cast(cp, integer) as node2, pred_name as `node1;label`' \
-o /app/kgtk/data/WD2/deprecatedRank-pred-P2241-count-label.tsv >> /home/cloud-di/kgtk_WD2.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD2.log 2>&1 

printf "WD2.14 Sumarização do processamento %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.14a Total Claims Disputed By P1310 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1
zcat /app/kgtk/data/WD2/disputedBy-claims-sorted.tsv.gz | wc -l >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.14b TOP-10 Predicados para Disputed By P1310 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1
\time --format='Elapsed time: %e seconds'  kgtk sort -i /app/kgtk/data/WD2/disputedBy-claims-pred-count-label.tsv -c node2 --reverse-columns node2 --numeric-columns node2 / head  >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.14c Total Claims Preferred Rank %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1
kgtk filter -i $GRAPH_CLAIMS --label rank -p " ; preferred ;  "  | wc -l  >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.14d Total Claims Deprecated Rank %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1
kgtk filter -i $GRAPH_CLAIMS --label rank -p " ; deprecated ;  "  | wc -l >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.14e Total Claims Normal Rank %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1
kgtk filter -i $GRAPH_CLAIMS --label rank -p " ; normal ;  "  | wc -l  >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.14f TOP-10 Predicados para Preferred Rank %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1
\time --format='Elapsed time: %e seconds'  kgtk sort -i /app/kgtk/data/WD2/preferredRank-claims-pred-count-label.tsv -c node2 --reverse-columns node2 --numeric-columns node2 / head  >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.14g Total Claims Qualificador Preferred P7452 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1
zcat /app/kgtk/data/WD2/preferredRank-pred-P7452-sorted.tsv.gz | wc -l >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.14h TOP-10 Predicados para Qualificador Preferred P7452 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1
\time --format='Elapsed time: %e seconds'  kgtk sort -i /app/kgtk/data/WD2/preferredRank-pred-P7452-count-label.tsv -c node2 --reverse-columns node2 --numeric-columns node2 / head  >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.14i Total Claims Qualificador Deprecated P2241 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1
zcat /app/kgtk/data/WD2/deprecatedRank-pred-P2241-sorted.tsv.gz | wc -l  >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "WD2.14j TOP-10 Predicados para Qualificador Deprecated P2241 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1
\time --format='Elapsed time: %e seconds'  kgtk sort -i /app/kgtk/data/WD2/deprecatedRank-pred-P2241-count-label.tsv -c node2 --reverse-columns node2 --numeric-columns node2 / head  >> /home/cloud-di/kgtk_WD2.log 2>&1

printf "FIM Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD2.log 2>&1 

