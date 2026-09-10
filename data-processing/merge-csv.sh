Scenario: "Saint Paul": Merge Many CSVs files

Level: Easy

Type: Do

Tags: csv   data processing  

Access: Email

Description: Join (merge) all the 338 files in /home/admin/polldayregistrations_enregistjourduscrutin?????.csv into one single /home/admin/all.csv file with the contents of all the CSV files in any order. There should be only one line with the names of the columns as a header.

Root (sudo) Access: False

Test: The "Check My Solution" button runs the script /home/admin/agent/check.sh, which you can see and execute.

Time to Solve: 15 minutes.

# 1. Copia el encabezado (línea 1) desde el primer fragmento al archivo destino
head -n 1 data-00.csv > data_unido.csv

# 2. Anexa todos los fragmentos ignorando su primera línea (tail -q -n +2)
tail -q -n +2 data-*.csv >> data_unido.csv