# Plan de développement — Démineur Deckbuilder Roguelike

*Nom de code du projet : `Hollow Grid` (à redéfinir)*

---

## Philosophie du plan

Ce plan suit une approche **prototypage vertical incrémental** : à chaque étape, tu as un jeu **jouable**, même s'il est incomplet. On ne construit jamais "en largeur" (toutes les classes à moitié, tous les systèmes vides) — toujours "en profondeur" (une tranche complète qui fonctionne, puis on épaissit).

Chaque phase se termine par un livrable testable. Si à la fin d'une phase le jeu n'est pas fun à jouer, on ne passe pas à la suivante : on itère sur la phase courante.

**Durée totale estimée** : 12 à 18 mois en solo dev à temps partiel (10-15h/semaine).

---

## Phase 0 — Préproduction et setup (2 à 3 semaines)

### Objectifs
Valider le concept sur papier, préparer l'environnement technique, éliminer les décisions bloquantes pour pouvoir coder sans friction ensuite.

### Étapes

#### 0.1 — Game Design Document (GDD) minimaliste
Un document vivant, pas un pavé de 80 pages. Sections à couvrir :
- Pitch en une phrase
- Boucle de gameplay principale (diagramme)
- Les 3 ressources du jeu (Concentration, Intuitions, Bruit)
- Les 5 familles de cartes avec 3 exemples par famille
- Structure d'une run (secteurs, nœuds, boss)
- Une classe détaillée à fond (Le Géomètre)
- Liste des inconnues à résoudre en prototype

#### 0.2 — Setup technique Godot 4
- Installation Godot 4.x (dernière stable)
- Configuration projet :
  - Rendering method : `Mobile` ou `Compatibility` (2D pur, plus léger)
  - Resolution : viewport base `320x180` ou `480x270`, scaling mode `viewport`, stretch aspect `keep`
  - Import presets : filter `Nearest`, mipmaps off (pixel-perfect)
- Création du repo Git avec un `.gitignore` Godot correct
- Structure de dossiers initiale (voir section Architecture)

#### 0.3 — Outils et pipeline
- Aseprite configuré avec des templates pour tiles et sprites
- Définition d'une palette couleur restreinte (16 à 32 couleurs max, ambiance sombre/noire)
- Feuille de style des nombres (fonts pixel, tailles définies)
- Décision sur la taille des cases : je recommande `16x16` ou `20x20` pixels

#### 0.4 — Architecture de code de base
Inspirée de ton approche modulaire React, mais adaptée à Godot :

```
res://
├── addons/               # Plugins Godot
├── assets/
│   ├── sprites/
│   ├── audio/
│   ├── fonts/
│   └── shaders/
├── features/             # Modules métier (ton "feature based")
│   ├── grid/             # Mécanique démineur pure
│   ├── deck/             # Système de cartes
│   ├── run/              # Gestion d'une run roguelike
│   ├── meta/             # Méta-progression
│   └── ui/               # Interfaces
├── autoloads/            # Singletons Godot (l'équivalent de ton Zustand)
│   ├── GameState.gd
│   ├── EventBus.gd
│   └── SaveSystem.gd
├── scenes/               # Scènes principales
│   ├── main_menu/
│   ├── run/
│   └── hub/
└── project.godot
```

### Livrables phase 0
- GDD v0.1 écrit
- Projet Godot initialisé, commit initial sur Git
- Une scène vide qui se lance en pixel-perfect
- Palette et premiers sprites de test

---

## Phase 1 — Le démineur de base (3 à 4 semaines)

### Objectifs
Avoir un démineur classique fonctionnel, jouable, qui fait plaisir à manipuler. C'est la fondation. Si cette phase n'est pas parfaite, rien ne tiendra.

### Étapes

#### 1.1 — Génération de grille
- `GridGenerator` : génère une grille de taille variable avec N mines
- **CRITIQUE** : implémenter la garantie que le premier clic ne soit jamais une mine (démineur standard)
- **CRITIQUE** : implémenter un solver qui garantit la solvabilité logique (pas de "deviner au hasard") — c'est un sujet technique profond, prévois du temps pour ça

#### 1.2 — Rendu visuel de la grille
- `TileMap` ou grille de `Sprite2D` custom (je recommande Sprite2D pour plus de flexibilité d'animation)
- États visuels : caché, révélé vide, révélé avec chiffre, flaggé, mine, mine explosée
- Chiffres 1-8 avec couleurs distinctes (classique)
- Animation d'apparition des cases révélées (flip, fade, cascade)

#### 1.3 — Input et interaction
- Clic gauche : révéler
- Clic droit : flag / unflag
- Clic molette ou double clic : chording (révéler tous les voisins si le chiffre correspond au nombre de flags)
- Support clavier et manette en parallèle (à anticiper dès maintenant, c'est pénible à rajouter plus tard)

#### 1.4 — État de jeu
- Détection de victoire (toutes les cases non-mines révélées)
- Détection de défaite (clic sur mine)
- Timer et compteur de mines
- Signal émis sur victoire/défaite (pattern observer, base de tout le reste)

#### 1.5 — Juice et feedback
Cette étape est **non négociable**. Un démineur sans juice est mort. Ajoute :
- Screen shake léger sur révélation en cascade
- Particules sur révélation
- Sons pour chaque action (clic, flag, cascade, explosion, victoire)
- Hit stop bref sur explosion
- Couleurs qui pulsent brièvement

### Livrables phase 1
- Démineur classique 100% fonctionnel
- Trois tailles de grille testées (small/medium/large)
- Boucle de jeu complète : start → play → win/lose → restart
- Au moins 30 parties jouées par toi pour valider le feel

### Critère de passage à la phase suivante
Tu dois avoir envie de rejouer une partie juste après en avoir fini une. Si non, itère sur le juice.

---

## Phase 2 — Prototype vertical du système de cartes (4 à 6 semaines)

### Objectifs
Prouver que le mariage démineur + deckbuilder fonctionne. C'est **la** phase la plus risquée du projet. Si ça ne marche pas ici, le concept entier est à revoir.

### Étapes

#### 2.1 — Système de cartes (architecture)
- `CardResource` : une `Resource` Godot custom pour définir une carte (nom, coût, effet, art, description)
- `CardDatabase` : autoload qui charge toutes les cartes du jeu
- `Deck` : classe qui gère pioche/main/défausse avec les mécaniques standard du deckbuilder
- `CardEffect` : système d'effets composables (un effet peut révéler, scanner, modifier, etc.)

**Pattern à utiliser** : effets comme *command pattern*, chaque effet est un objet qui sait s'exécuter sur une grille. Ça te permet de combiner des effets simples pour créer des cartes complexes.

#### 2.2 — Les 3 ressources
Implémente `Concentration`, `Intuitions`, `Bruit` comme des ressources observables.
- `ResourceSystem` singleton qui centralise
- Signaux émis à chaque changement
- UI qui écoute et affiche

#### 2.3 — Premières cartes (10 cartes suffisent pour le proto)
Choisis des cartes qui testent des mécaniques **différentes** :
1. **Sonar** — révèle le nombre de mines en 3x3 (test : carte Scan pure)
2. **Révélation en croix** — révèle 5 cases (test : carte Sonde basique)
3. **Téléportation** — déplace une mine (test : carte Manipulation, impact sur la logique)
4. **Bouclier** — bloque la prochaine explosion (test : carte Protection)
5. **Prospection** — gagne de l'or passif (test : carte Exploitation)
6. **Analyse spectrale** — marque les chiffres impairs (test : info globale)
7. **Forage** — révèle 3x3 complet, désamorce les mines (test : carte puissante)
8. **Neutralisation** — transforme mine en safe (test : solution brute force)
9. **Prémonition** — révèle la prochaine mine déclenchée (test : info conditionnelle)
10. **Concentration pure** — gagne +2 Concentration ce tour (test : tempo)

#### 2.4 — Interface de jeu
- Main de cartes en bas de l'écran (max 5 cartes visibles)
- Drag & drop sur la grille ou clic sur carte puis clic sur cible
- Animations de pioche/jeu/défausse
- Pile de pioche et pile de défausse visibles avec compteur

**Astuce Godot** : pour la main de cartes, utilise un `Control` parent avec des enfants `Control` positionnés manuellement via `tween`. Ne pas utiliser `HBoxContainer` (pas assez de contrôle sur les animations).

#### 2.5 — Premier playtest bouclé
- Une seule grille, toujours la même taille
- Deck fixe de 10 cartes
- Pas encore de run, pas encore de méta, pas encore de reliques
- Objectif : compléter la grille en utilisant les cartes stratégiquement

### Livrables phase 2
- Système de cartes complet et extensible
- 10 cartes jouables avec effets réels sur la grille
- UI de main fonctionnelle et juteuse
- 50 parties testées avec prise de notes

### Critère de passage à la phase suivante
**Test décisif** : fais tester à 3 à 5 personnes (amis, dev, joueurs). Si au moins 3 disent spontanément "j'aimerais avoir plus de cartes" ou "j'ai envie de rejouer", tu valides. Sinon, le concept a un problème fondamental à résoudre avant d'aller plus loin.

---

## Phase 3 — Structure de run (4 à 5 semaines)

### Objectifs
Transformer le prototype en véritable expérience roguelike. Plusieurs grilles enchaînées, choix stratégiques, sensation d'aventure.

### Étapes

#### 3.1 — Gestion d'une run
- `RunManager` autoload : état global d'une run (HP, or, deck actuel, reliques, progression)
- Début de run : choix de classe, deck de départ, relique de départ
- Fin de run : victoire (boss final battu) ou défaite (HP à 0)

#### 3.2 — Carte de secteur (style Slay the Spire)
- Génération d'une carte ramifiée de nœuds
- Types de nœuds : grille normale, élite, cache, atelier, marchand, événement, sanctuaire
- Rendu visuel de la carte avec path tracé
- Navigation clic à clic entre les nœuds

#### 3.3 — Progression dans une run
- Après chaque grille complétée : récompenses (or, cartes à ajouter, relique parfois)
- Écran de choix de récompense (3 cartes proposées, skip possible)
- Système d'ajout de cartes au deck

#### 3.4 — Économie de run
- Or comme monnaie
- HP qui baisse sur dégât (mine déclenchée, événement)
- Système de soin (sanctuaires, cartes, reliques)

#### 3.5 — Un premier boss
Implémente **un seul** boss bien léché : **Le Menteur** (20% des chiffres sont faux de ±1). C'est un bon premier boss parce qu'il force le joueur à utiliser ses cartes Scan pour vérifier, ce qui teste toute ta mécanique.

#### 3.6 — 30 cartes au total
Élargis le pool à 30 cartes pour avoir de la variété dans les récompenses. Répartition :
- 8 Scan
- 7 Sonde
- 6 Manipulation
- 5 Protection
- 4 Exploitation

### Livrables phase 3
- Run complète jouable : 1 secteur de 8-10 nœuds, boss final
- Système de récompenses qui donne envie de rejouer
- 30 cartes équilibrées (ou au moins testées)
- Game over et retour au menu propre

### Critère de passage
Tu dois pouvoir perdre une run et avoir envie immédiate d'en relancer une pour essayer une stratégie différente. C'est le test fondamental du roguelike.

---

## Phase 4 — Première classe complète et reliques (3 à 4 semaines)

### Objectifs
Avoir une classe signature parfaitement designée, introduire le système de reliques, poser les bases de la différenciation stratégique.

### Étapes

#### 4.1 — Le Géomètre en profondeur
- Mécanique *Hypothèses* : système permettant de marquer 3 cases comme "hypothèses"
- Starter deck de 10 cartes spécifiques au Géomètre, centrées Scan
- 15 à 20 cartes "Géomètre-exclusive" supplémentaires dans le pool
- Visuel/UI spécifique (couleur dominante, icône)

#### 4.2 — Système de reliques
- `RelicResource` comme pour les cartes
- `RelicManager` autoload
- Effets passifs (déclenchement sur signaux globaux : début de grille, fin de grille, mine déclenchée, etc.)
- 15 reliques de départ, de rareté variée

#### 4.3 — Raretés
- Cartes : commune, peu commune, rare
- Reliques : commune, peu commune, rare, boss (relique spéciale après boss)
- Distribution des raretés dans les récompenses (pondérée)

#### 4.4 — Intégration de toute la boucle
Assure-toi que tout s'imbrique proprement :
- Cartes qui synergie avec reliques
- Reliques qui changent les règles du démineur
- Combos possibles à découvrir

### Livrables phase 4
- Le Géomètre jouable à fond, avec identité claire
- 15 reliques intégrées
- Pool de 45-50 cartes
- Runs qui se sentent différentes selon build

---

## Phase 5 — Extension du contenu (6 à 8 semaines)

### Objectifs
Passer de "prototype convaincant" à "jeu early-access". Volume de contenu suffisant pour justifier des dizaines d'heures de jeu.

### Étapes

#### 5.1 — Deuxième classe : La Démolisseuse
- Mécanique *Contrôle* (déclencher volontairement des mines pour des effets)
- Starter deck + 20 cartes exclusives
- Test d'équilibrage croisé Géomètre/Démolisseuse

#### 5.2 — Deuxième secteur
- Nouveau biome visuel (le premier était "industriel ?", le second pourrait être "organique" ou "mental")
- Nouveau pool d'ennemis et événements
- Nouveaux types de grilles (règles spéciales localisées)

#### 5.3 — Deuxième et troisième boss
- Un boss par secteur, chacun avec mécanique unique
- Pattern : chaque boss teste une facette différente du deckbuilding

#### 5.4 — Événements narratifs
- Système d'événements : nœud qui affiche un texte + choix
- 20 à 30 événements scénarisés
- Intégration du worldbuilding (psychologique si tu gardes cette direction)

#### 5.5 — Troisième secteur et boss final
- Le boss final doit être un événement mémorable
- Récompense narrative et mécanique (déblocage d'Ascension)

### Livrables phase 5
- 3 secteurs jouables
- 3 boss + 1 boss final
- 2 classes distinctes
- ~80 cartes, ~25 reliques
- 30 événements narratifs
- Une run complète de 45-60 minutes

---

## Phase 6 — Méta-progression et polish (4 à 6 semaines)

### Objectifs
Donner des raisons de rejouer longtemps, peaufiner l'expérience, préparer une release.

### Étapes

#### 6.1 — Compendium
- Enregistrement de tout ce que le joueur rencontre
- Pages par classe, carte, relique, ennemi, événement
- Statistiques personnelles (taux de victoire, cartes préférées, etc.)

#### 6.2 — Atelier de déblocage
- Gems dépensées pour débloquer nouvelles cartes dans le pool
- Progression persistante
- Courbe d'économie à équilibrer

#### 6.3 — Ascensions
- 20 niveaux d'Ascension, chacun ajoute un modificateur
- Déblocage progressif
- Leaderboards éventuels (optionnel, ajoute de la complexité backend)

#### 6.4 — Défis quotidiens
- Seed quotidien partagé entre tous les joueurs
- Contraintes spéciales (deck imposé, relique de départ, règle modifiée)
- Système de scoring

#### 6.5 — Polish global
- Passes audio complètes (musique dynamique, sons variés)
- Tutoriel progressif (pas un mur de texte, de l'apprentissage par la pratique)
- Accessibilité : daltonisme, taille de police, remappage touches
- Sauvegarde/chargement robuste
- Localisation (FR et EN minimum, vu que tu es francophone)

---

## Phase 7 — Release et Early Access (selon plateforme)

### Objectifs
Sortir le jeu, itérer avec la communauté.

### Étapes

#### 7.1 — Préparation Steam (ou itch.io en premier lieu)
- Page store avec screenshots, gif, trailer
- Build Steam et tests
- Prix à définir (15-20 euros pour ce type de jeu)

#### 7.2 — Early Access si tu choisis cette voie
- Roadmap publique
- Communication régulière (devlog)
- Récolte de feedback et itération

#### 7.3 — 1.0
- Classes 3 et 4 (L'Opportuniste notamment)
- 150+ cartes au total
- 5 secteurs complets
- Bande-son finale
- Patch notes et post-launch support

---

## Principes transverses (applicables à toutes les phases)

### Versionning et discipline Git
- Un commit par feature atomique
- Branches pour gros chantiers (`feature/boss-menteur`, `feature/ascension-system`)
- Tag pour chaque phase terminée
- Backup cloud en plus de Git (Godot peut corrompre des fichiers en cas de crash)

### Playtest régulier
- Chaque vendredi : 1h de playtest pur, sans coder
- Prise de notes systématique (fichier `playtest-journal.md`)
- Chaque mois : faire tester par une personne extérieure

### Équilibrage
- Ne pas équilibrer trop tôt (attendre la phase 4 au moins)
- Utiliser des `Resource` pour tous les chiffres (dégâts, coûts, drops) pour pouvoir tweaker sans recompiler
- Outils de debug : triche active en dev (spawn cartes, or infini, etc.)

### Gestion de scope
- Chaque fois que tu ajoutes une idée à ta liste, demande-toi : "est-ce que le jeu est moins bon sans ?"
- Si la réponse est non, la fonctionnalité va dans `nice-to-have.md` et pas dans la roadmap
- Favoris absolus : peu de classes mais profondes, peu de cartes mais variées

### Ne pas tomber dans les pièges
- **Refactoring prématuré** : tant qu'une feature marche, laisse le code "correct mais pas parfait"
- **Perfectionnisme artistique** : placeholders tant que le gameplay n'est pas validé, art final seulement après
- **Feature creep** : garde ta vision initiale, ajoute seulement ce qui sert cette vision

---

## Checklist de progression

- [ ] Phase 0 : préproduction terminée
- [ ] Phase 1 : démineur de base fun
- [ ] Phase 2 : mariage cartes + grille validé par playtests externes
- [ ] Phase 3 : première run complète jouable
- [ ] Phase 4 : classe Géomètre et reliques intégrées
- [ ] Phase 5 : contenu early-access atteint
- [ ] Phase 6 : polish et méta-progression
- [ ] Phase 7 : release

---

## Recommandations finales

**Tiens un devlog public dès la phase 2**. Blog, fil Twitter/Bluesky, peu importe. Ça te force à structurer ta pensée, ça construit une communauté avant la release, et ça te motive quand tu traverses les phases difficiles (notamment phase 5, la plus longue et la plus ingrate).

**Ne travaille pas seul sur le sound design**. Si tu peux, échange ton temps contre celui d'un sound designer en freelance ou ami. Le son est 50% du feel et c'est la partie la plus difficile à faire soi-même.

**Fixe-toi une deadline souple mais réelle**. "Finir en 18 mois max". Au-delà, c'est soit que le scope est trop gros, soit que tu perds la motivation. Les deux cas nécessitent de réévaluer plutôt que de pousser mécaniquement.

**Célèbre les petites victoires**. Fin de phase = petit rituel (une soirée off, un bon repas, peu importe). Un projet de 18 mois est un marathon, pas un sprint.

---

*Ce plan est vivant. À relire tous les deux mois pour ajuster selon ce que tu apprends en cours de route.*
