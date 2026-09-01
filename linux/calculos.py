#Ejecutar de consula
#python3 calculos.py > /home/admin/solution
def main():
    # 1. Leer el archivo y extraer la segunda columna
    scores = []
    with open('./scores.txt', 'r') as f:
        for line in f:
            parts = line.split()
            if len(parts) >= 2:
                #Pushea el numero y lo pone en float
                scores.append(float(parts[1]))

    # 2. Calcular la media aritmética
    if not scores:
        return

    avg = sum(scores) / len(scores)
    # 3. Truncar a 2 decimales sin redondear
    #Prepara el formato despues del punto que sea max hasta 8
    avg_str = f"{avg:.8f}"
    integer_part, decimal_part = avg_str.split('.')
    truncated_avg = f"{integer_part}.{decimal_part[:2]}"

    # 4. Enviar el resultado a la salida estándar (stdout)
    print(truncated_avg)

if __name__ == '__main__':
    main()
