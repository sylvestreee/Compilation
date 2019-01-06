# English

## Compiler for MPC/MPFR libraries
Compilation project by Méline Bour-Lang, Martin Heitz, Tiphaine Richard and Morgane Ritter.

### Concept

This compiler, written with Lex and Yacc, is a way to use the MPFR and MPC libraries without having to write the entire code, which is rather complex.
With a given code, it replaces the calculations with a new version using the libraries.

The code is modified only if it is placed inside a `pragma` instruction. For example:

```c
#pragma MPC precision(128) rounding(MPC_RNDZZ)
{
  result = 1+1;
}
```

Here, the user choose:
- The used library (MPC).
- The precision (128).
- The rounding mode (MPC_RNDZZ).

### Use

To compile the compiler in order to use it: `make`.
It is also possible to delete the created files with `make clean`.

#### With a file

`./main [file.c]` compiles *file.c*. The result is available in the created file *result.c*.

#### In a terminal

This function is useful during development.
`./main` launches the compiler, and the user can then write directly the code to compile in the terminal. However, the result is not available.

# Français

## Compilateur pour les bibliothèques MPC/MPFR
Projet de Compilation réalisé par Méline Bour-Lang, Martin Heitz, Tiphaine Richard et Morgane Ritter.

### Principe

Ce compilateur, écrit avec Lex et Yacc, permet d'utiliser les bibliothèques MPFR et MPC sans avoir à écrire le code soi-même. Il prend en entrée le code utilisateur et y remplace les calculs par une nouvelle version utilisant les bibliothèques en question.

Le code n'est modifié que s'il est placé dans une instruction `pragma`. Par exemple :

```c
#pragma MPC precision(128) rounding(MPC_RNDZZ)
{
  resultat = 1+1;
}
```

où l'utilisateur choisit :
- La bibliothèque qu'il souhaite utiliser, ici MPC.
- La précision des calculs sur les flottants, ici 128.
- Le mode d'arrondi, ici MPC_RNDZZ.

### Utilisation

Pour compiler le code du compilateur :
`make`.
Il est également possible de supprimer les fichiers produits avec `make clean`.

#### Avec un fichier

`./main [file.c]` permet de compiler *file.c*. Le résultat est ensuite disponible dans le fichier généré *result.c*.

Pour la suite, la librairie visée doit être installée.
- `sudo apt-get install libmpc-dev` permettra d'installer MPC.
- `sudo apt-get install libmpfr-dev` permettra d'installer MPFR.

Pour ensuite compiler *result.c*, il faudra lancer `gcc -c result.c -o result.o`, puis

- `gcc result.o -o main -lmpc` pour MPC.
- `gcc result.o -o main -lmpfr` pour MPFR.

#### Dans la console

Cette option est utile pour le développement.
`./main` permet de lancer le compilateur, et d'écrire directement dans la console le code à compiler. Le résultat produit n'est cependant pas visible.

## Fonctionnalités

### Traitement du pragma

- Reconnaissance du pragma
- Bibliothèque
- Précision
- Arrondi
- Récupération du code hors pragma (exécutable)

### Expressions mathématiques gérées

- Opérateurs binaires : **+ \* / - =**
- Opérateurs unaires : non gérés
- Fonctions mathématiques : voir `projet.l`
- Boucles et conditions : non gérées
