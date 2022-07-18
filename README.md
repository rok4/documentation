# Documentation du projet ROK4

Ce dépôt contient : 

* Les spécifications globales du projet
* Toutes les configurations pour la compilation des documentations utilisateur et développeur des dépôts du projet
* Le script de compilation du site du projet

Le site est disponible [ici](https://rok4.github.io/documentation).

## Compilation de la documentation du projet

* Pour la documentation du code source C++ : `sudo apt install doxygen graphviz`
* Pour la documentation du code source Perl : `sudo apt install naturaldocs`
* Pour la documentation utilisateur : `sudo apt install mkdocs && pip3 install mkdocs-material mkdocs-select-files`

Depuis le dossier racine du projet : `bash build.sh --clone --doxygen --naturaldocs --mkdocs`.