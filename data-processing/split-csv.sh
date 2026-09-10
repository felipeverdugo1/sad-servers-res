

Scenario: "Minneapolis": Break a CSV file

Level: Easy

Type: Do

Tags: csv   data processing  

Access: Email

Description: Break the Comma Separated Valued (CSV) file data.csv in the /home/admin/ directory into exactly 10 smaller files of about the same size named data-00.csv, data-01.csv, ... , data-09.csv files in the same directory. All the files should have the same header (first line with column names) as data.csv. None of the smaller files should be bigger than 32KB.

Note: to simplify, disregard broken lines in your files (ie, you can break a file at any point, not just at a newline). The resulting files don't have to be proper CSV files.

Root (sudo) Access: False

Test: The "Check My Solution" button runs the script /home/admin/agent/check.sh, which you can see and execute.

Time to Solve: 10 minutes.
' 

Para ver cuanto pesa (KB, MB, GB):

ls -lh *.csv


wc -l *.csv    # Muestra la cantidad de líneas de cada archivo
wc -c *.csv    # Muestra la cantidad exacta de bytes


# Define el nuevo encabezado
NUEVO_HEADER="id,nombre,email,fecha"

# Modifica la primera línea de cada archivo .csv en la carpeta actual
for archivo in *.csv; do
  sed -i "1s/.*/$NUEVO_HEADER/" "$archivo"
done


#Imprimir head
head -n 1 *.csv

admin@ip-10-1-13-247:~$ head -n 1 *.csv
Province,Electoral District Name/Nom de circonscription,Electoral District Number/Numéro de circonscription,Candidate/Candidat,Candidate Residence/Résidence du candidat,Candidate Occupation/Profession du candidat,Votes Obtained/Votes obtenus,Percentage of Votes Obtained /Pourcentage des votes obtenus,Majority/Majorité,Majority Percentage/Pourcentage de majorité




#Sacar el header a un archivo

head -n 1 datos.csv > header.txt 

#Usa tail -n +2 para ignorar la primera línea y pásalo a split para generar 3 archivos (mini-00.csv, mini-01.csv, mini-02.csv):

tail -n +2 datos.csv | split -n l/3 -d -a 2 - mini-

#Guardas las líneas de datos (sin la línea 1) en un archivo temporal:


tail -n +2 datos.csv > datos_sin_header.txt

#Split divide en 10 archivos y usamos los datos sin header, que luego lo vamos a poner

split -n l/10 -d -a 2 --additional-suffix=.csv datos_sin_header.txt data-

y crea los archivos 

#Volvermos a poner el header

for archivo in data-*.csv; do
  cat header.txt "$archivo" > temp.csv && mv temp.csv "$archivo"
done


#Cheaqueamos no perder data
admin@ip-10-1-13-184:~$ head -n 2 data.csv 
Province,Electoral District Name/Nom de circonscription,Electoral District Number/Numéro de circonscription,Candidate/Candidat,Candidate Residence/Résidence du candidat,Candidate Occupation/Profession du candidat,Votes Obtained/Votes obtenus,Percentage of Votes Obtained /Pourcentage des votes obtenus,Majority/Majorité,Majority Percentage/Pourcentage de majorité
"Newfoundland and Labrador/Terre-Neuve-et-Labrador","Avalon","10001","Ken McDonald Liberal/Libéral","Conception Bay South, N.L./ T.-N.-L.","Retired/Retraité",23528,55.9,     16027,  38.1
admin@ip-10-1-13-184:~$ head -n 1 datos_sin_header.txt 
"Newfoundland and Labrador/Terre-Neuve-et-Labrador","Avalon","10001","Ken McDonald Liberal/Libéral","Conception Bay South, N.L./ T.-N.-L.","Retired/Retraité",23528,55.9,     16027,  38.1O


Reporte:Nos dieron un archivo .cvs donde tenia un header y muchas columnas, lo que hicismos fue primero divir el archivo una parte el header y la otra el cuerpo, luego nos pidieron que crearamos 10 archivos para que no pasen un limite, eso lo hicimos mediante split, y eso creo los 10 archivos de manera uniforme. Y por ultimo lo que nos falta es agregar el header a todos los archivos, y eso es todo


