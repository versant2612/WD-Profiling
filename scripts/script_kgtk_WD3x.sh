printf "WD3.15 Agregar aos contadores de Predicados encontrados em Claims potencialmente controversos não qualificados os seus respectivos tipos e constraints %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1

export GRAPH_CLAIMS=/app/kgtk/data/wikidata/claims.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1
export GRAPH_LABEL=/app/kgtk/data/wikidata/labels.en.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1
export GRAPH_MVWQ=/app/kgtk/data/WD3/filtered-claims-without-quals-counted-label.tsv  >> /home/cloud-di/kgtk_WD3.log 2>&1
export GRAPH_P2302=/app/kgtk/data/WD4/required_qualifier/predicate-P2302-constraints.tsv.gz >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_MVWQ --as mvwq -i $GRAPH_LABEL --as lab -i $GRAPH_P2302 --as p2302 \
--match 'mvwq: (pred {label: pred_name, `all-count`: all_p_count})-[p1]->(p_count)' \
--opt 'p2302: (pred)-[c1]->(c_type)' \
--opt 'lab: (c_type)-[]->(c_name)' \
--return 'pred as node1, "count" as label, p_count as node2, pred_name as `node1;label`, all_p_count as `node1;all-count`, group_concat(distinct c_name) as `node1;constraint`' \
-o /app/kgtk/data/WD3/filtered-claims-without-quals-counted-label-constraint.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

export GRAPH_MVWQC=/app/kgtk/data/WD3/filtered-claims-without-quals-counted-label-constraint.tsv  >> /home/cloud-di/kgtk_WD3.log 2>&1

\time --format='Elapsed time: %e seconds'  kgtk --debug query -i $GRAPH_MVWQC --as mvwqc -i $GRAPH_LABEL --as lab -i $GRAPH_CLAIMS --as claims \
--match 'mvwqc: (pred {label: pred_name, `all-count`: all_p_count, constraint: list_constraint})-[p1]->(p_count)' \
--opt 'claims: (pred)-[:P31]->(pred_type) ' \
--opt 'lab: (pred_type)-[]->(pt_name)' \
--return 'pred as node1, "count" as label, p_count as node2, pred_name as `node1;label`, all_p_count as `node1;all-count`, list_constraint as `node1;constraint`, group_concat(distinct pt_name) as `node1;type`' \
-o /app/kgtk/data/WD3/filtered-claims-without-quals-counted-label-constraint-type.tsv >> /home/cloud-di/kgtk_WD3.log 2>&1

printf "WD3.16 TOP-10 Predicados encontrados em Claims potencialmente controversos não qualificados e seus respectivos tipos e constraints %s\n" "$(date)" >> /home/cloud-di/kgtk_WD3.log 2>&1
\time --format='Elapsed time: %e seconds'  kgtk sort -i /app/kgtk/data/WD3/filtered-claims-without-quals-counted-label-constraint-type.tsv -c node2 --reverse-columns node2 --numeric-columns node2 / head  >> /home/cloud-di/kgtk_WD3.log 2>&1



