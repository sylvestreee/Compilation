# Compilateur pour les bibliothèques MPC/MPFR
Projet de Compilation réalisé par Méline Bour-Lang, Martin Heitz, Tiphaine Richard et Morgane Ritter.

## Principe

Ce compilateur, écrit avec Lex et Yacc, permet d'utiliser les bibliothèques MPFR et MPC sans avoir à écrire le code soi-même. Il prend en entrée le code utilisateur et y remplace les calculs par une nouvelle version utilisant les bibliothèques en question.

Le code n'est modifié que s'il est placé dans une instruction `pragma`. Par exemple :

```
#pragma MPC precision(128) rounding(MPC_RNDZZ)
{
  resultat = 1+1;
}
```

où l'utilisateur choisit :
- La bibliothèque qu'il souhaite utiliser, ici MPC.
- La précision des calculs sur les flottants, ici 128.
- Le mode d'arrondi, ici MPC_RNDZZ.

## Utilisation

Pour compiler le code du compilateur :
`make`.
Il est également possible de supprimer les fichiers produits avec `make clean`.

### Avec un fichier

`./main [file.c]` permet de compiler *file.c*. Le résultat est ensuite disponible dans le fichier généré *result.c*.

### Dans la console

Cette option est utile pour le développement.
`./main` permet de lancer le compilateur, et d'écrire directement dans la console le code à compiler. Le résultat produit n'est cependant pas visible.

# Fonctionnalités

## Traitement du pragma

- Reconnaissance du pragma : **fait**
- Bibliothèque : à faire
- Précision : à faire
- Arrondi : à faire
- Récupération du code hors pragma (exécutable) : à faire

## Expressions mathématiques gérées

- Opérateurs binaires : **+ \* / -**
- Opérateurs unaires : à faire
- Fonctions mathématiques : à faire
- Boucles et conditions : à faire

## Optimisations

- Elimination de sous-expressions communes : à faire
- Minimisation du nombre de variables temporaires : à faire
- Sortie de boucle des invariants : à faire
