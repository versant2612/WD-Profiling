printf "Predicates with constraints da WD - Junho 2022\n" > /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1 

printf "INICIO Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1 

export GRAPH_ALIAS=/app/kgtk/data/wikidata/alias.en.tsv.gz >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
export GRAPH_QUALS=/app/kgtk/data/wikidata/qualifiers.tsv.gz >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
export GRAPH_CLAIMS=/app/kgtk/data/wikidata/claims.tsv.gz >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
export GRAPH_LABEL=/app/kgtk/data/wikidata/labels.en.tsv.gz >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.0 Preparar ambiente %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_ALIAS --as alias -i $GRAPH_QUALS --as quals \
-i $GRAPH_CLAIMS --as claims --index none --limit 3 >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_LABEL --as lab --limit 3 >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1 

printf "WD4.1 Selecionar Constraints (P2302) do tipo allowed qualifiers associadas aos predicados Px  %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug filter -i /app/kgtk/data/wikidata/claims.tsv.gz -p ' ; P2302 ; Q21510851' \
-o /app/kgtk/data/WD4/allowed_qualifier/predicate-P2302-constraints-Q21510851.tsv.gz >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

export GRAPH_Q21510851=/app/kgtk/data/WD4/allowed_qualifier/predicate-P2302-constraints-Q21510851.tsv.gz >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.2 Selecionar qualificadores Qy associados a predicados Px que tem a constraint allowed qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug ifexists --input-file /app/kgtk/data/wikidata/qualifiers.tsv.gz --filter-on $GRAPH_P2302 \
      --input-keys node1 --filter-keys id \
      --output /app/kgtk/data/WD4/allowed_qualifier/predicate-P2302-constraints-qualifiers.tsv.gz  >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

export GRAPH_P2302Q=/app/kgtk/data/WD4/allowed_qualifier/predicate-P2302-constraints-qualifiers.tsv.gz >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

## allowed qualifier (CQ: Px -P2302-> Q21510851. CQ -P2306-> Qy)
## Statements for this property should not have any qualifiers other than the listed ones

printf "WD4.3 Selecionar qualificadores Qy associados a predicados Px que tem a constraint allowed qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_Q21510851 --as allowed -i $GRAPH_P2302Q --as p2302q -i $GRAPH_LABEL --as lab \
--match 'allowed: (pred)-[p1]->(), p2302q: (p1)-[q1:P2306]->(quali)' \
--opt   'lab: (pred)-[]->(pred_name)' --opt 'lab: (quali)-[]->(quali_name)' \
--return 'distinct q1, pred as node1, pred_name as `node1;label`, "allowed qualifier" as label, quali as node2, quali_name as `node2;label`' \
-o /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier-P2302-predicate-P2306-quali.tsv >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

export GRAPH_P2306=/app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier-P2302-predicate-P2306-quali.tsv >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.4 Selecionar CLAIMS do conjunto Multi Value COM qualificador Qw que não seja permitido para o predicado Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

export GRAPH_F1=/app/kgtk/data/WD3/filtered-claims-sorted-uniq.tsv >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
export GRAPH_QF12=/app/kgtk/data/WD3/filtered-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2306 --as a2306 -i $GRAPH_Q21510851 --as allowed -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 -i $GRAPH_LABEL --as lab \
--force \
--match 'f1: (item)-[p1 {label: pred}]->(), qf12: (p1)-[q1 {label: quali}]->(), allowed: (pred)-[]->()' \
--where 'NOT EXISTS {a2306: (pred)-[]->(quali)}' \
--opt   'lab: (pred)-[]->(pred_name)' \
--return 'distinct pred as node1, pred_name as `node1;label`, count(pred) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier_violated-filtered-predicate.tsv  >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.5 Selecionar CLAIMS do conjunto Completo COM qualificador Qy que não seja permitido para o predicado Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2306 --as a2306 -i $GRAPH_Q21510851 --as allowed -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals -i $GRAPH_LABEL --as lab \
--force \
--match 'claims: (item)-[p1 {label: pred}]->(), quals: (p1)-[q1 {label: quali}]->(), allowed: (pred)-[]->()' \
--where 'NOT EXISTS {a2306: (pred)-[]->(quali)}' \
--opt   'lab: (pred)-[]->(pred_name)' \
--return 'distinct pred as node1, pred_name as `node1;label`, count(pred) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier_violated-claims-predicate.tsv >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.6 Contabilizar a presença do qualificador Qy não permitido para o predicados Px no conjunto Multi Value %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2306 --as a2306 -i $GRAPH_Q21510851 --as allowed -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 -i $GRAPH_LABEL --as lab \
--force \
--match 'f1: (item)-[p1 {label: pred}]->(), qf12: (p1)-[q1 {label: quali}]->(), allowed: (pred)-[]->()' \
--where 'NOT EXISTS {a2306: (pred)-[]->(quali)}' \
--opt   'lab: (quali)-[]->(quali_name)' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier_violated-filtered-qualifiers.tsv  >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.7 Contabilizar a presença do qualificador Qy não permitido para o predicados Px no conjunto conjunto Completo Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2306 --as a2306 -i $GRAPH_Q21510851 --as allowed -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals -i $GRAPH_LABEL --as lab \
--force \
--match 'claims: (item)-[p1 {label: pred}]->(), quals: (p1)-[q1 {label: quali}]->(), allowed: (pred)-[]->()' \
--where 'NOT EXISTS {a2306: (pred)-[]->(quali)}' \
--opt   'lab: (quali)-[]->(quali_name)' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier_violated-claims-qualifiers.tsv >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.8 Contabilizar frequencia do qualificador Qy referente aos predicados Px nas constraints allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2306 --as a2306 \
--match 'a2306: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier-P2302-predicate-P2306-quali-counted.tsv >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9 Sumarização do processamento %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9a Total Claims com violação da constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2306 --as a2306 -i $GRAPH_Q21510851 --as allowed -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1 {label: pred}]->(), quals: (p1)-[q1 {label: quali}]->(), allowed: (pred)-[]->()' \
--where 'NOT EXISTS {a2306: (pred)-[]->(quali)}' \
--return 'count(distinct p1) as total_claims_allowed_qualifier_violated' >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9b Total Predicados distintos encontrados em Claims com violação da constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
cat /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier_violated-claims-predicate.tsv | wc -l  >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9c TOP-10 Predicados encontrados em Claims com violação da constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier_violated-claims-predicate.tsv >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9d Multi Value Claims com violação da constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2306 --as a2306 -i $GRAPH_Q21510851 --as allowed -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1 {label: pred}]->(), qf12: (p1)-[q1 {label: quali}]->(), allowed: (pred)-[]->()' \
--where 'NOT EXISTS {a2306: (pred)-[]->(quali)}' \
--return 'count(distinct p1) as multi_value_claims_allowed_qualifier_violated' >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9e Total Predicados distintos encontrados em Multi Value Claims com violação da constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
cat /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier_violated-filtered-predicate.tsv | wc -l  >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9f TOP-10 Predicados encontrados em Multi Value Claims com violação da constraint allowed_qualifier %s\n" "$(dallowed_qualifier_violated-filtered-predicate.tsvate)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier_violated-filtered-predicate.tsv >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9g Total Predicados distintos associados a constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i -i $GRAPH_Q21510851 --as allowed \
--match 'allowed (pred)-[p1]->()' \
--return 'count(distinct pred) as allowed_qualifier_constraint_predicates' >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9h Total de qualificadores Qy referente aos predicados Px nas constraints allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
cat /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier-P2302-predicate-P2306-quali-counted.tsv  | wc -l >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9i TOP-10 Qualificadores Qy referente aos predicados Px nas constraints allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier-P2302-predicate-P2306-quali-counted.tsv >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9j Total de qualificadores Qy não permitido para o predicados Px no conjunto Multi Value %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
cat /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier_violated-filtered-qualifiers.tsv | wc -l >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9k TOP-10 Qualificadores Qy não permitido para o predicados Px no conjunto Multi Value  %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier_violated-filtered-qualifiers.tsv >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9l Total de qualificadores Qy não permitido para o predicados Px no conjunto conjunto Completo  %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
cat /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier_violated-claims-qualifiers.tsv | wc -l >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "WD4.9m TOP-10 Qualificadores Qy não permitido para o predicados Px no conjunto conjunto Completo  %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/allowed_qualifier/allowed_qualifier_violated-claims-qualifiers.tsv >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1

printf "FIM Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_allowed_qualifier.log 2>&1 



