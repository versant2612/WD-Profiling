printf "Predicates with constraints da WD - Junho 2022\n" > /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1 

printf "INICIO Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1 

export GRAPH_ALIAS=/app/kgtk/data/wikidata/alias.en.tsv.gz >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
export GRAPH_QUALS=/app/kgtk/data/wikidata/qualifiers.tsv.gz >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
export GRAPH_CLAIMS=/app/kgtk/data/wikidata/claims.tsv.gz >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
export GRAPH_LABEL=/app/kgtk/data/wikidata/labels.en.tsv.gz >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.0 Preparar ambiente %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_ALIAS --as alias -i $GRAPH_QUALS --as quals \
-i $GRAPH_CLAIMS --as claims --index none --limit 3 >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_LABEL --as lab --limit 3 >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1 

printf "WD4.1 Selecionar Constraints (P2302) associadas aos predicados Px  %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug filter -i /app/kgtk/data/wikidata/claims.tsv.gz -p ' ; P2302 ; ' \
-o /app/kgtk/data/WD4/required_qualifier/predicate-P2302-constraints.tsv.gz >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

## Mandatory Constraint

printf "WD4.2 Selecionar predicados Px associados a Constraints mandatórias (P2316-> Q21502408) %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

## https://www.wikidata.org/wiki/Help:Property_constraints_portal/Required_qualifiers
## mandatory constraints (CQ -P2316-> Q21502408) & required qualifier (CQ: Px -P2302-> Q21510856. CQ -P2306-> Qy): Statements for this property must have all of the listed qualifiers.
	
\time --format='Elapsed time: %e seconds' kgtk --debug filter -i /app/kgtk/data/wikidata/qualifiers.tsv.gz -p ' ; P2316 ; ' -o /app/kgtk/data/WD4/required_qualifier/qualifiers-P2316-constraint-state.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

export GRAPH_P2302=/app/kgtk/data/WD4/required_qualifier/predicate-P2302-constraints.tsv.gz >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
export GRAPH_P2316=/app/kgtk/data/WD4/required_qualifier/qualifiers-P2316-constraint-state.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.3 Selecionar qualificadores Qy associados a predicados Px que tem a constraint required qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug ifexists --input-file /app/kgtk/data/wikidata/qualifiers.tsv.gz --filter-on $GRAPH_P2302 \
              --input-keys node1 --filter-keys id \
	      --output /app/kgtk/data/WD4/required_qualifier/predicate-P2302-constraints-qualifiers.tsv.gz  >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

export GRAPH_P2302Q=/app/kgtk/data/WD4/required_qualifier/predicate-P2302-constraints-qualifiers.tsv.gz >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.4 Selecionar qualificadores Qy associados a predicados Px que tem a constraint required qualifier obrigatória %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2302 --as p2302 -i $GRAPH_P2316 --as p2316 -i $GRAPH_P2302Q --as q2302 -i $GRAPH_LABEL --as lab \
--match 'p2302: (pred)-[p1]->(:Q21510856), q2302: (p1)-[:P2306]->(quali)' \
--where 'NOT EXISTS {p2316: (p1)-[]->(:Q62026391)}' \
--opt   'lab: (pred)-[]->(pred_name)' --opt 'lab: (quali)-[]->(quali_name)' \
--return 'distinct pred as node1, pred_name as `node1;label`, "required qualifier" as label, quali as node2, quali_name as `node2;label`' \
-o /app/kgtk/data/WD4/required_qualifier/predicate-P2302-mandatory_constraints-required_qualifier-P2306-quali.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

export GRAPH_P2302_2316=/app/kgtk/data/WD4/required_qualifier/predicate-P2302-mandatory_constraints-required_qualifier-P2306-quali.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.5 Selecionar CLAIMS do conjunto Multi Value SEM qualificador Qy referente aos predicados Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

export GRAPH_F1=/app/kgtk/data/my-tsv/filtered-claims-sorted-uniq.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
export GRAPH_QF12=/app/kgtk/data/WD3/filtered-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316 --as m2316 -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1]->(), m2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and NOT EXISTS {qf12: (p1)-[q1]->() WHERE q1.label =  quali}' \
--return 'distinct pred as node1, pred_name as `node1;label`, count(pred) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/required_qualifier/filtered-predicate-mandatory_constraints-required_qualifier_violated.tsv  >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.6 Selecionar CLAIMS do conjunto Completo SEM qualificador Qy referente aos predicados Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316 --as m2316 -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1]->(), m2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and NOT EXISTS {quals: (p1)-[q1]->() WHERE q1.label =  quali}' \
--return 'distinct pred as node1, pred_name as `node1;label`, count(pred) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/required_qualifier/claims-predicate-mandatory_constraints-required_qualifier_violated.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.7 Sumarização do processamento %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.7a Total Claims com violação da constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316 --as m2316 -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1]->(), m2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and NOT EXISTS {quals: (p1)-[q1]->() WHERE q1.label =  quali}' \
--return 'count(distinct p1) as total_claims_required_qualifier_violated' >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.7b Total Predicados distintos encontrados em Claims com violação da constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
cat /app/kgtk/data/WD4/required_qualifier/claims-predicate-mandatory_constraints-required_qualifier_violated.tsv | wc -l  >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.7c TOP-10 Predicados encontrados em Claims com violação da constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/required_qualifier/claims-predicate-mandatory_constraints-required_qualifier_violated.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.7d Multi Value Claims com violação da constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316 --as m2316 -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1]->(), m2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and NOT EXISTS {qf12: (p1)-[q1]->() WHERE q1.label =  quali}' \
--return 'count(distinct p1) as multi_value_claims_required_qualifier_violated' >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.7e Total Predicados distintos encontrados em Multi Value Claims com violação da constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
cat /app/kgtk/data/WD4/required_qualifier/filtered-predicate-mandatory_constraints-required_qualifier_violated.tsv | wc -l  >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.7f TOP-10 Predicados encontrados em Multi Value Claims com violação da constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/required_qualifier/filtered-predicate-mandatory_constraints-required_qualifier_violated.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.7g Total Predicados distintos associados a constraint required_qualifier obrigatória %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2302 --as p2302 -i $GRAPH_P2316 --as p2316 -i $GRAPH_P2302Q --as q2302 -i $GRAPH_LABEL --as lab \
--match 'p2302: (pred)-[p1]->(:Q21510856), q2302: (p1)-[:P2306]->(quali)' \
--where 'NOT EXISTS {p2316: (p1)-[]->(:Q62026391)}' \
--opt   'lab: (pred)-[]->(pred_name)' --opt 'lab: (quali)-[]->(quali_name)' \
--return 'count(distinct pred) as required_qualifier_constraint_predicates' >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

## Suggested Constraint

printf "WD4.8 Selecionar qualificadores Qy associados a predicados Px que tem a constraint required qualifier sugerida %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2302 --as p2302 -i $GRAPH_P2316 --as p2316 -i $GRAPH_P2302Q --as q2302 -i $GRAPH_LABEL --as lab \
--match 'p2302: (pred)-[p1]->(:Q21510856), q2302: (p1)-[:P2306]->(quali)' \
--where 'EXISTS {p2316: (p1)-[]->(:Q62026391)}' \
--opt   'lab: (pred)-[]->(pred_name)' --opt 'lab: (quali)-[]->(quali_name)' \
--return 'distinct pred as node1, pred_name as `node1;label`, "required qualifier" as label, quali as node2, quali_name as `node2;label`' \
-o /app/kgtk/data/WD4/required_qualifier/predicate-P2302-suggested_constraints-required_qualifier-P2306-quali.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

export GRAPH_P2302_2316s=/app/kgtk/data/WD4/required_qualifier/predicate-P2302-suggested_constraints-required_qualifier-P2306-quali.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.9 Selecionar CLAIMS do conjunto Multi Value SEM qualificador Qy referente aos predicados Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

export GRAPH_F1=/app/kgtk/data/my-tsv/filtered-claims-sorted-uniq.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
export GRAPH_QF12=/app/kgtk/data/WD3/filtered-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316s --as s2316 -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1]->(), s2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and NOT EXISTS {qf12: (p1)-[q1]->() WHERE q1.label =  quali}' \
--return 'distinct pred as node1, pred_name as `node1;label`, count(pred) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/required_qualifier/filtered-predicate-suggested_constraints-required_qualifier_violated.tsv  >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.10 Selecionar CLAIMS do conjunto Completo SEM qualificador Qy referente aos predicados Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316s --as s2316 -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1]->(), s2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and NOT EXISTS {quals: (p1)-[q1]->() WHERE q1.label =  quali}' \
--return 'distinct pred as node1, pred_name as `node1;label`, count(pred) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/required_qualifier/claims-predicate-suggested_constraints-required_qualifier_violated.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.11 Sumarização do processamento %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.11a Total Claims com violação da constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316s --as s2316 -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1]->(), s2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and NOT EXISTS {quals: (p1)-[q1]->() WHERE q1.label =  quali}' \
--return 'count(distinct p1) as total_claims_suggested_required_qualifier_violated' >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.11b Total Predicados distintos encontrados em Claims com violação da constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
cat /app/kgtk/data/WD4/required_qualifier/claims-predicate-suggested_constraints-required_qualifier_violated.tsv | wc -l  >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.11c TOP-10 Predicados encontrados em Claims com violação da constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/required_qualifier/claims-predicate-suggested_constraints-required_qualifier_violated.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.11d Multi Value Claims com violação da constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316s --as s2316 -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1]->(), s2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and NOT EXISTS {qf12: (p1)-[q1]->() WHERE q1.label =  quali}' \
--return 'count(distinct p1) as multi_value_claims_suggested_required_qualifier_violated' >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.11e Total Predicados distintos encontrados em Multi Value Claims com violação da constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
cat /app/kgtk/data/WD4/required_qualifier/filtered-predicate-suggested_constraints-required_qualifier_violated.tsv | wc -l  >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.11f TOP-10 Predicados encontrados em Multi Value Claims com violação da constraint required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/required_qualifier/filtered-predicate-suggested_constraints-required_qualifier_violated.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4.11g Total Predicados distintos associados a constraint required_qualifier sugeridas  %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2302 --as p2302 -i $GRAPH_P2316 --as p2316 -i $GRAPH_P2302Q --as q2302 -i $GRAPH_LABEL --as lab \
--match 'p2302: (pred)-[p1]->(:Q21510856), q2302: (p1)-[:P2306]->(quali)' \
--where 'EXISTS {p2316: (p1)-[]->(:Q62026391)}' \
--opt   'lab: (pred)-[]->(pred_name)' --opt 'lab: (quali)-[]->(quali_name)' \
--return 'count(distinct pred) as suggested_required_qualifier_constraint_predicates' >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

## Mandatory Constraint

printf "WD4B.1 Contabilizar a ausência do qualificador Qy referente aos predicados Px no conjunto Multi Value %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316 --as p2302_2316 -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1]->(), p2302_2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and NOT EXISTS {qf12: (p1)-[q1]->() WHERE q1.label =  quali}' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/required_qualifier/filtered-qualifier-mandatory_constraints-required_qualifier_violated.tsv  >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.2 Contabilizar a ausência do qualificador Qy referente aos predicados Px no conjunto conjunto Completo Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316 --as p2302_2316 -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1]->(), p2302_2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and NOT EXISTS {quals: (p1)-[q1]->() WHERE q1.label =  quali}' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/required_qualifier/claims-qualifier-mandatory_constraints-required_qualifier_violated.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.3 Contabilizar frequencia do qualificador Qy referente aos predicados Px nas mandatory constraints required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316 --as p2302_2316 \
--match 'p2302_2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/required_qualifier/qualifier-P2302-mandatory_constraints-required_qualifier-P2306.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

## Suggested Constraint

printf "WD4B.4 Contabilizar a ausência do qualificador Qy referente aos predicados Px no conjunto Multi Value %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316s --as s2316 -i $GRAPH_F1 --as f1 -i $GRAPH_QF12 --as qf12 \
--force \
--match 'f1: (item)-[p1]->(), s2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and NOT EXISTS {qf12: (p1)-[q1]->() WHERE q1.label =  quali}' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/required_qualifier/filtered-qualifier-suggested_constraints-required_qualifier_violated.tsv  >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.5 Contabilizar a ausência do qualificador Qy referente aos predicados Px no conjunto conjunto Completo Px %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316s --as s2316 -i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--force \
--match 'claims: (item)-[p1]->(), s2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--where 'p1.label = pred and NOT EXISTS {quals: (p1)-[q1]->() WHERE q1.label =  quali}' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/required_qualifier/claims-qualifier-suggested_constraints-required_qualifier_violated.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.6 Contabilizar frequencia do qualificador Qy referente aos predicados Px nas mandatory constraints required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_P2302_2316s --as s2316 \
--match 's2316: (pred {label: pred_name})-[]->(quali {label: quali_name})' \
--return 'distinct quali as node1, quali_name as `node1;label`, count(quali) as `node1;count`' \
--order-by '`node1;count` desc' \
-o /app/kgtk/data/WD4/required_qualifier/qualifier-P2302-suggested_constraints-required_qualifier-P2306.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7 Sumarização do processamento %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7a Total de qualificadores Qy referente aos predicados Px nas mandatory constraints required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
cat /app/kgtk/data/WD4/required_qualifier/qualifier-P2302-mandatory_constraints-required_qualifier-P2306.tsv  | wc -l >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7b TOP-10 Qualificadores Qy referente aos predicados Px nas mandatory constraints required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/required_qualifier/qualifier-P2302-mandatory_constraints-required_qualifier-P2306.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7c Total de qualificadores Qy referente aos predicados Px das mandatory constraints required_qualifier ausentes no conjunto Multi Value %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
cat /app/kgtk/data/WD4/required_qualifier/filtered-qualifier-mandatory_constraints-required_qualifier_violated.tsv | wc -l >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7d TOP-10 Qualificadores Qy referente aos predicados Px das mandatory constraints required_qualifier ausentes no conjunto Multi Value  %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/required_qualifier/filtered-qualifier-mandatory_constraints-required_qualifier_violated.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7e Total de qualificadores Qy referente aos predicados Px das mandatory constraints required_qualifier ausentes no conjunto Completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
cat /app/kgtk/data/WD4/required_qualifier/claims-qualifier-mandatory_constraints-required_qualifier_violated.tsv | wc -l >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7f TOP-10 Qualificadores Qy referente aos predicados Px das mandatory constraints required_qualifier ausentes no conjunto Completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/required_qualifier/claims-qualifier-mandatory_constraints-required_qualifier_violated.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7g Total de qualificadores Qy referente aos predicados Px nas suggested constraints required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
cat /app/kgtk/data/WD4/required_qualifier/qualifier-P2302-suggested_constraints-required_qualifier-P2306.tsv  | wc -l >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7h TOP-10 Qualificadores Qy referente aos predicados Px nas suggested constraints required_qualifier %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/required_qualifier/qualifier-P2302-suggested_constraints-required_qualifier-P2306.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7i Total de qualificadores Qy referente aos predicados Px das suggested constraints required_qualifier ausentes no conjunto Multi Value %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
cat /app/kgtk/data/WD4/required_qualifier/filtered-qualifier-suggested_constraints-required_qualifier_violated.tsv | wc -l >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7j TOP-10 Qualificadores Qy referente aos predicados Px das suggested constraints required_qualifier ausentes no conjunto Multi Value  %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/required_qualifier/filtered-qualifier-suggested_constraints-required_qualifier_violated.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7k Total de qualificadores Qy referente aos predicados Px das suggested constraints required_qualifier ausentes no conjunto Completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
cat /app/kgtk/data/WD4/required_qualifier/claims-qualifier-suggested_constraints-required_qualifier_violated.tsv | wc -l >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "WD4B.7l TOP-10 Qualificadores Qy referente aos predicados Px das suggested constraints required_qualifier ausentes no conjunto Completo %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1
kgtk head -i /app/kgtk/data/WD4/required_qualifier/claims-qualifier-suggested_constraints-required_qualifier_violated.tsv >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1

printf "FIM Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD4_required_qualifier.log 2>&1 



