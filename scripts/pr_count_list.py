import os
import datetime
import time

query_count1 = """
SELECT ?referrer (count( ?ref) as ?ref_per_ref)
WHERE {
   ?ref ?referrer ?pr_obj .
VALUES ?referrer {?pr_prop}
}
GROUP BY ?referrer"""

query_count2 = """
SELECT ?referrer (count(distinct ?statement) as ?statement_per_ref)
WHERE {
   ?ref ?referrer ?pr_obj .
   ?statement prov:wasDerivedFrom ?ref .
VALUES ?referrer {?pr_prop}
}
GROUP BY ?referrer
"""

f1 = open("/home/cloud-di/pr_list.txt", 'r', encoding="utf8")

pr_list = f1.readlines()

pr_prop_list = '\n'

for pr_item in pr_list: 

	pr_prop_list = pr_prop_list + pr_item.replace('http://www.wikidata.org/prop/reference/', 'pr:').replace('"', '') 
	pr_prop = pr_item.replace("http://www.wikidata.org/prop/reference/", '').replace('"', '').strip()  
	print(pr_prop)
	if len(pr_prop_list) > 5000:

		query_exec = query_count1.replace ("?pr_prop", pr_prop_list)
		f2_file = "/home/cloud-di/sparql/count_ref_" + pr_prop + ".txt"
		f2 = open(f2_file, mode="w", encoding="utf-8")
		f2.write(query_exec)

		query_exec = query_count2.replace ("?pr_prop", pr_prop_list)
		f3_file = "/home/cloud-di/sparql/count_stat_" + pr_prop + ".txt"
		f3 = open(f3_file, mode="w", encoding="utf-8")
		f3.write(query_exec)

		pr_prop_list = '\n'

f2 = open("/home/cloud-di/sparql/count_ref_" + pr_prop + ".txt", mode="w", encoding="utf-8")
query_exec = query_count1.replace ("?pr_prop", pr_prop_list)
f2.write(query_exec)

f3 = open("/home/cloud-di/sparql/count_stat_" + pr_prop + ".txt", mode="w", encoding="utf-8")
query_exec = query_count2.replace ("?pr_prop", pr_prop_list)
f3.write(query_exec)

f2.close()
f3.close()
f1.close()

