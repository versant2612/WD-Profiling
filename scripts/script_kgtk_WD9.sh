printf "Profiling WD - June 2022\n" > /home/cloud-di/kgtk_WD9.log 2>&1 

printf "START Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD9.log 2>&1

export GRAPH_ALIAS=/app/kgtk/data/wikidata/alias.en.tsv.gz >> /home/cloud-di/kgtk_WD9.log 2>&1
export GRAPH_QUALS=/app/kgtk/data/wikidata/qualifiers.tsv.gz >> /home/cloud-di/kgtk_WD9.log 2>&1
export GRAPH_CLAIMS=/app/kgtk/data/wikidata/claims.tsv.gz >> /home/cloud-di/kgtk_WD9.log 2>&1
export GRAPH_LABEL=/app/kgtk/data/wikidata/labels.en.tsv.gz >> /home/cloud-di/kgtk_WD9.log 2>&1

printf "WD9.0 Graph Cache %s\n" "$(date)" >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD9.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_ALIAS --as alias -i $GRAPH_QUALS --as quals -i $GRAPH_CLAIMS --as claims --limit 3 >> /home/cloud-di/kgtk_WD9.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_LABEL --as lab --limit 3 >> /home/cloud-di/kgtk_WD9.log 2>&1 
\time --format='Elapsed time: %e seconds'  kgtk query --show-cache >> /home/cloud-di/kgtk_WD9.log 2>&1 

printf "WD9.1 All Claims and Qualifications %s\n" "$(date)" >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_CLAIMS --as claims \
--match '()-[c1]->()' \
--return 'count(c1) as total_claims' >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_QUALS --as quals \
--match '()-[q1]->()' \
--return 'count(q1) as total_qualifications' >> /home/cloud-di/kgtk_WD9.log 2>&1

printf "WD9.2 Properties and Scope - Table 1 %s\n" "$(date)" >> /home/cloud-di/kgtk_WD9.log 2>&1

export GRAPH_P2302=/app/kgtk/data/WD4/predicate-P2302-constraints.tsv.gz 
export GRAPH_P2302Q=/app/kgtk/data/WD4/predicate-P2302-constraints-qualifiers.tsv.gz 
export GRAPH_PROP=/app/kgtk/data/WD6/all-properties.tsv.gz >> /home/cloud-di/kgtk_WD9.log 2>&1 

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_PROP --as prop \
--match '(prop)-[]->()' \
--return 'count(distinct prop) as total_properties' >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_P2302 --as p2302 -i $GRAPH_P2302Q --as q2302 -i $GRAPH_LABEL --as lab -i $GRAPH_PROP --as prop \
--match '(pred)-[]->()' \
--opt 'p2302: (pred)-[p1]->(:Q53869507), q2302: (p1)-[:P5314]->(p_scope)' \
--opt 'lab: (pred)-[]->(pred_name)' \
--opt 'lab: (p_scope)-[]->(scope_name)' \
--return 'distinct pred as node1, pred_name as `node1;label`, "property scope" as label, scope_name as node2' \
-o /app/kgtk/data/WD6/properties-labeled-scope.tsv >> /home/cloud-di/kgtk_WD9.log 2>&1

export GRAPH_Q53869507=/app/kgtk/data/WD6/properties-labeled-scope.tsv >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_Q53869507 --as p5314 \
--match 'p5314: (pred)-[p1]->(scope_name)' \
--return 'scope_name, count(pred)' \
--order-by 'count(pred) desc' \
-o /app/kgtk/data/WD6/properties-scope-count.tsv >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug head \
-i /app/kgtk/data/WD6/properties-scope-count.tsv >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_CLAIMS --as claims \
--match '()-[c1]->()' \
--return 'count(distinct c1.label) as total_predicate' >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_QUALS --as quals \
--match '()-[q1]->()' \
--return 'count(distinct q1.label) as total_qualifiers' >> /home/cloud-di/kgtk_WD9.log 2>&1

printf "WD9.3 Constraints about Qualifiers %s\n" "$(date)" >> /home/cloud-di/kgtk_WD9.log 2>&1

export GRAPH_Q21510856=/app/kgtk/data/WD4/required_qualifier/predicate-P2302-constraints-Q21510856.tsv.gz >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_Q21510856 --as required  \
--match 'required: (pred)-[p1]->()' \
--return 'count(distinct pred) as total_predicate_with_required_qualifier' >> /home/cloud-di/kgtk_WD9.log 2>&1

export GRAPH_Q21510851=/app/kgtk/data/WD4/allowed_qualifier/predicate-P2302-constraints-Q21510851.tsv.gz >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_Q21510851 --as allowed  \
--match 'allowed: (pred)-[p1]->()' \
--return 'count(distinct pred) as total_predicate_with_allowed_qualifier' >> /home/cloud-di/kgtk_WD9.log 2>&1

printf "WD9.4 Disputed By %s\n" "$(date)" >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_CLAIMS --as claims -i $GRAPH_QUALS --as quals \
--match 'claims:()-[c1]->(), quals: (c1)-[:P1310]->()' \
--return 'count(distinct c1) as total_P1310_claims, count(distinct c1.label) as total_P1310_predicates' >> /home/cloud-di/kgtk_WD9.log 2>&1

printf "WD9.5 Claims with Qualification %s\n" "$(date)" >> /home/cloud-di/kgtk_WD9.log 2>&1

export GRAPH_QCLAIMS=/app/kgtk/data/WD1/all-claims-quals-sorted.tsv.gz >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk query -i $GRAPH_QCLAIMS --as c --limit 3 >> /home/cloud-di/kgtk_WD9.log 2>&1 

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_QCLAIMS --as c \
--match 'c:()-[cq]->() ' \
--return 'count(distinct cq) as total_quali_claims' >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query \
-i $GRAPH_QCLAIMS --as c \
--match 'c:()-[cq]->() ' \
--return 'count(distinct cq.label) as pred_quali_claims' >> /home/cloud-di/kgtk_WD9.log 2>&1

printf "WD9.6 Multiple Values and Constraints %s\n" "$(date)" >> /home/cloud-di/kgtk_WD9.log 2>&1

export GRAPH_F1=/app/kgtk/data/WD3/filtered-claims-sorted-uniq.tsv >> /home/cloud-di/kgtk_WD9.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_F1 --as f1  \
--match 'f1: ()-[p1]->()' \
--return 'count(distinct p1) as total_mv_claims' >> /home/cloud-di/kgtk_WD9.log 2>&1

export GRAPH_MVRQ=/app/kgtk/data/WD4/required_qualifier/filtered-claims-any-required_qualifier_violated.tsv.gz  >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds' kgtk --debug query -i $GRAPH_MVRQ --as mvrq \
--match '()-[mv]->()' \
--return 'count(mv) as total_mv_req_quali_violations' >> /home/cloud-di/kgtk_WD9.log 2>&1

printf "END Current date %s\n" "$(date)" >> /home/cloud-di/kgtk_WD9.log 2>&1 
