printf "Predicates with constraints da WD - Junho 2022\n" > /home/cloud-di/kgtk_WD7_constraints.log 2>&1 

printf "INICIO Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1 

export GRAPH_ALIAS=/app/kgtk/data/wikidata/alias.en.tsv.gz >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
export GRAPH_QUALS=/app/kgtk/data/wikidata/qualifiers.tsv.gz >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
export GRAPH_CLAIMS=/app/kgtk/data/wikidata/claims.tsv.gz >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
export GRAPH_LABEL=/app/kgtk/data/wikidata/labels.en.tsv.gz >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.0 Preparar ambiente %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_ALIAS --as alias -i $GRAPH_QUALS --as quals \
-i $GRAPH_CLAIMS --as claims --index none --limit 3 >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_LABEL --as lab --limit 3 >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1 

printf "WD7.1 Selecionar Constraints (P2302) associadas aos predicados Px  %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug filter -i /app/kgtk/data/wikidata/claims.tsv.gz -p ' ; P2302 ; ' \
-o /app/kgtk/data/WD7/predicate-P2302-constraints.tsv.gz >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

export GRAPH_P2302=/app/kgtk/data/WD7/predicate-P2302-constraints.tsv.gz >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.2 Selecionar qualificadores Qy associados a predicados Px que tem constraints %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug ifexists --input-file /app/kgtk/data/wikidata/qualifiers.tsv.gz --filter-on $GRAPH_P2302 \
              --input-keys node1 --filter-keys id \
	      --output /app/kgtk/data/WD7/predicate-P2302-constraints-qualifiers.tsv.gz  >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

export GRAPH_P2302Q=/app/kgtk/data/WD7/predicate-P2302-constraints-qualifiers.tsv.gz >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

#### Required Qualifier ####

printf "WD7.3 Selecionar qualificadores Qy associados a predicados Px que tem a constraint required qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2302 --as p2302 -i $GRAPH_P2302Q --as q2302 -i $GRAPH_LABEL --as lab \
--match 'p2302: (pred)-[p1]->(:Q21510856), q2302: (p1)-[:P2306]->(quali)' \
--opt   'lab: (pred)-[]->(pred_name)' --opt 'lab: (quali)-[]->(quali_name)' \
--return 'distinct pred as node1, pred_name as `node1;label`, "required qualifier" as label, quali as node2, quali_name as `node2;label`' \
-o /app/kgtk/data/WD7/predicate-P2302-constraints-required_qualifier-P2306-quali.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

export GRAPH_P2302_2306=/app/kgtk/data/WD7/predicate-P2302-constraints-required_qualifier-P2306-quali.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.4 Selecionar CLAIMS do conjunto Multi Value COM qualificador Qy referente aos predicados Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

export GRAPH_F1=/app/kgtk/data/my-tsv/filtered-claims-sorted-uniq.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
export GRAPH_QF12=/app/kgtk/data/WD3/filtered-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as r2306 -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1]->(), qf12: (p1)-[q1]->(), r2306: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and q1.label =  quali ' \
--return 'distinct pred as node1, pred_name as `node1;label`, count(pred) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD7/filtered-predicate-constraints-required_qualifier.tsv  >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.5 Selecionar CLAIMS do conjunto Completo COM qualificador Qy referente aos predicados Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as r2306 -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1]->(), quals: (p1)-[q1]->(), r2306: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and q1.label =  quali' \
--return 'distinct pred as node1, pred_name as `node1;label`, count(pred) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD7/claims-predicate-constraints-required_qualifier.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

pprintf "WD7.6 Selecionar CLAIMS do conjunto Multi Value COM qualificador Qy referente aos predicados Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as r2306 -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1]->(), r2306: (pred {label: pred_name})-[]->(quali {label: quali_name}), qf12: (p1)-[q1]->()' \
--where 'p1.label = pred and q1.label =  quali' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD7/filtered-qualifier-constraints-required_qualifier.tsv  >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.7 Contabilizar a presença do qualificador Qy referente aos predicados Px no conjunto conjunto Completo Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as r2306 -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1]->(), r2306: (pred {label: pred_name})-[]->(quali {label: quali_name}), quals: (p1)-[q1]->()' \
--where 'p1.label = pred and q1.label =  quali' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD7/claims-qualifier-constraints-required_qualifier.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.8 Contabilizar frequencia do qualificador Qy referente aos predicados Px nas constraints required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as r2306 \
--match 'r2306: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD7/qualifier-P2302-constraints-required_qualifier-P2306.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9 Sumarização do processamento %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9a Total Claims atendendo a constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as r2306 -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1]->(), r2306: (pred {label: pred_name})-[]->(quali {label: quali_name}), quals: (p1)-[q1]->()' \
--where 'p1.label = pred and q1.label =  quali' \
--return 'count(distinct p1) as total_claims_required_qualifier' >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9b Total Predicados distintos encontrados em Claims atendendo a constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
cat /app/kgtk/data/WD7/claims-predicate-constraints-required_qualifier.tsv | wc -l  >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9c TOP-10 Predicados encontrados em Claims atendendo a constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
kgtk head -i /app/kgtk/data/WD7/claims-predicate-constraints-required_qualifier.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9d Multi Value Claims atendendo a constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as r2306 -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1]->(), r2306: (pred {label: pred_name})-[]->(quali {label: quali_name}), qf12: (p1)-[q1]->()' \
--where 'p1.label = pred and q1.label =  quali' \
--return 'count(distinct p1) as multi_value_claims_required_qualifier' >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9e Total Predicados distintos encontrados em Multi Value Claims atendendo a constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
cat /app/kgtk/data/WD7/filtered-predicate-constraints-required_qualifier.tsv | wc -l  >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9f TOP-10 Predicados encontrados em Multi Value Claims atendendo a constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
kgtk head -i /app/kgtk/data/WD7/filtered-predicate-constraints-required_qualifier.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9g Total Predicados distintos associados a constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2302 --as p2302 -i $GRAPH_P2302Q --as q2302 -i $GRAPH_LABEL --as lab \
--match 'p2302: (pred)-[p1]->(:Q21510856), q2302: (p1)-[:P2306]->(quali)' \
--opt   'lab: (pred)-[]->(pred_name)' --opt 'lab: (quali)-[]->(quali_name)' \
--return 'count(distinct pred) as required_qualifier_constraint_predicates' >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9h Total de qualificadores Qy referente aos predicados Px nas constraints required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
cat /app/kgtk/data/WD7/qualifier-P2302-constraints-required_qualifier-P2306.tsv  | wc -l >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9i TOP-10 Qualificadores Qy referente aos predicados Px nas constraints required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
kgtk head -i /app/kgtk/data/WD7/qualifier-P2302-constraints-required_qualifier-P2306.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9j Total de qualificadores Qy referente aos predicados Px das constraints required_qualifier presentes no conjunto Multi Value %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
cat /app/kgtk/data/WD7/filtered-qualifier-constraints-required_qualifier.tsv | wc -l >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9k TOP-10 Qualificadores Qy referente aos predicados Px das constraints required_qualifier presentes no conjunto Multi Value  %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
kgtk head -i /app/kgtk/data/WD7/filtered-qualifier-constraints-required_qualifier.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9l Total de qualificadores Qy referente aos predicados Px das constraints required_qualifier presentes no conjunto Completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
cat /app/kgtk/data/WD7/claims-qualifier-constraints-required_qualifier.tsv | wc -l >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9m TOP-10 Qualificadores Qy referente aos predicados Px das constraints required_qualifier presentes no conjunto Completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
kgtk head -i /app/kgtk/data/WD7/claims-qualifier-constraints-required_qualifier.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

#### Allowed Qualifier ####

printf "WD7.3 Selecionar qualificadores Qy associados a predicados Px que tem a constraint allowed qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2302 --as p2302 -i $GRAPH_P2302Q --as q2302 -i $GRAPH_LABEL --as lab \
--match 'p2302: (pred)-[p1]->(:Q21510851), q2302: (p1)-[:P2306]->(quali)' \
--opt   'lab: (pred)-[]->(pred_name)' --opt 'lab: (quali)-[]->(quali_name)' \
--return 'distinct pred as node1, pred_name as `node1;label`, "allowed qualifier" as label, quali as node2, quali_name as `node2;label`' \
-o /app/kgtk/data/WD7/predicate-P2302-constraints-allowed_qualifier-P2306-quali.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

export GRAPH_P2302_2306=/app/kgtk/data/WD7/predicate-P2302-constraints-allowed_qualifier-P2306-quali.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.4 Selecionar CLAIMS do conjunto Multi Value COM qualificador Qy referente aos predicados Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

export GRAPH_F1=/app/kgtk/data/my-tsv/filtered-claims-sorted-uniq.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
export GRAPH_QF12=/app/kgtk/data/WD3/filtered-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as a2306 -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1]->(), qf12: (p1)-[q1]->(), a2306: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and q1.label =  quali ' \
--return 'distinct pred as node1, pred_name as `node1;label`, count(pred) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD7/filtered-predicate-constraints-allowed_qualifier.tsv  >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.5 Selecionar CLAIMS do conjunto Completo COM qualificador Qy referente aos predicados Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as a2306 -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1]->(), quals: (p1)-[q1]->(), a2306: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and q1.label =  quali' \
--return 'distinct pred as node1, pred_name as `node1;label`, count(pred) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD7/claims-predicate-constraints-allowed_qualifier.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

pprintf "WD7.6 Selecionar CLAIMS do conjunto Multi Value COM qualificador Qy referente aos predicados Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as a2306 -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1]->(), a2306: (pred {label: pred_name})-[]->(quali {label: quali_name}), qf12: (p1)-[q1]->()' \
--where 'p1.label = pred and q1.label =  quali' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD7/filtered-qualifier-constraints-allowed_qualifier.tsv  >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.7 Contabilizar a presença do qualificador Qy referente aos predicados Px no conjunto conjunto Completo Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as a2306 -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1]->(), a2306: (pred {label: pred_name})-[]->(quali {label: quali_name}), quals: (p1)-[q1]->()' \
--where 'p1.label = pred and q1.label =  quali' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD7/claims-qualifier-constraints-allowed_qualifier.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.8 Contabilizar frequencia do qualificador Qy referente aos predicados Px nas constraints allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as a2306 \
--match 'a2306: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD7/qualifier-P2302-constraints-allowed_qualifier-P2306.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9 Sumarização do processamento %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9a Total Claims atendendo a constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as a2306 -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1]->(), a2306: (pred {label: pred_name})-[]->(quali {label: quali_name}), quals: (p1)-[q1]->()' \
--where 'p1.label = pred and q1.label =  quali' \
--return 'count(distinct p1) as total_claims_allowed_qualifier' >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9b Total Predicados distintos encontrados em Claims atendendo a constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
cat /app/kgtk/data/WD7/claims-predicate-constraints-allowed_qualifier.tsv | wc -l  >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9c TOP-10 Predicados encontrados em Claims atendendo a constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
kgtk head -i /app/kgtk/data/WD7/claims-predicate-constraints-allowed_qualifier.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9d Multi Value Claims atendendo a constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2306 --as a2306 -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1]->(), a2306: (pred {label: pred_name})-[]->(quali {label: quali_name}), qf12: (p1)-[q1]->()' \
--where 'p1.label = pred and q1.label =  quali' \
--return 'count(distinct p1) as multi_value_claims_allowed_qualifier' >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9e Total Predicados distintos encontrados em Multi Value Claims atendendo a constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
cat /app/kgtk/data/WD7/filtered-predicate-constraints-allowed_qualifier.tsv | wc -l  >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9f TOP-10 Predicados encontrados em Multi Value Claims atendendo a constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
kgtk head -i /app/kgtk/data/WD7/filtered-predicate-constraints-allowed_qualifier.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9g Total Predicados distintos associados a constraint allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2302 --as p2302 -i $GRAPH_P2302Q --as q2302 -i $GRAPH_LABEL --as lab \
--match 'p2302: (pred)-[p1]->(:Q21510856), q2302: (p1)-[:P2306]->(quali)' \
--opt   'lab: (pred)-[]->(pred_name)' --opt 'lab: (quali)-[]->(quali_name)' \
--return 'count(distinct pred) as allowed_qualifier_constraint_predicates' >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9h Total de qualificadores Qy referente aos predicados Px nas constraints allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
cat /app/kgtk/data/WD7/qualifier-P2302-constraints-allowed_qualifier-P2306.tsv  | wc -l >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9i TOP-10 Qualificadores Qy referente aos predicados Px nas constraints allowed_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
kgtk head -i /app/kgtk/data/WD7/qualifier-P2302-constraints-allowed_qualifier-P2306.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9j Total de qualificadores Qy referente aos predicados Px das constraints allowed_qualifier presentes no conjunto Multi Value %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
cat /app/kgtk/data/WD7/filtered-qualifier-constraints-allowed_qualifier.tsv | wc -l >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9k TOP-10 Qualificadores Qy referente aos predicados Px das constraintsallowed_qualifier presentesno conjunto Multi Value  %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
kgtk head -i /app/kgtk/data/WD7/filtered-qualifier-constraints-allowed_qualifier.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9l Total de qualificadores Qy referente aos predicados Px das constraints allowed_qualifier presentes no conjunto Completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
cat /app/kgtk/data/WD7/claims-qualifier-constraints-allowed_qualifier.tsv | wc -l >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "WD7.9m TOP-10 Qualificadores Qy referente aos predicados Px das constraints allowed_qualifier presentes no conjunto Completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1
kgtk head -i /app/kgtk/data/WD7/claims-qualifier-constraints-allowed_qualifier.tsv >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1

printf "FIM Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD7_constraints.log 2>&1 



