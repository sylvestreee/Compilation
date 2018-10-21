# Compilation
Projet de Compilation

Pour compiler et lancer le fichier pragma.lex en une commande :
`flex -o pragma.c -s -p -p -v  pragma.lex && gcc pragma.c -lfl && ./a.out [file_to_compile]`

Pour le moment, le programme se contente d'indiquer les valeurs qu'il a reconnues dans le fichier `file_to_compile`.
