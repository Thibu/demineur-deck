# GDD — Hollow Grid

*Nom de code : `Hollow Grid` (a redéfinir)*

---

## Pitch en une phrase

Un deckbuilder roguelike oú chaque combat est une grille de démineur : utilise tes cartes pour sonder, manipuler et dominer la grille sans jamais exploser.

---

## Boucle de gameplay principale

```
[Choix de classe] -> [Carte de secteur] -> [Sélection d'un nœud]
                                              |
                                    [Grille démineur]
                                     /            \
                              Victoire          Défaite
                                |                  |
                         Récompenses           Game Over
                      (or / cartes / relique)       |
                                |              Retry ou Menu
                        [Retour carte secteur]
                                |
                         ... nœuds suivants ...
                                |
                          [Boss de secteur]
                                |
                          Victoire run ?
                         /              \
                      Oui              Non
                  (Fin de run)     (Game Over)
                       |
               [Déblocages méta]
                       |
                 [Nouvelle run]
```

---

## Les 3 ressources du jeu

### Concentration
- Recharge chaque tour
- Coút de base pour révéler une case (clic gauche)
- Les cartes coútent de la Concentration
- Valeur de départ : 3/tour (modifiable par cartes et reliques)

### Intuitions
- Ressource accumulable entre les tours
- Gagnée en révélant des cases vides ou via des cartes
- Permet d'utiliser des capacités spéciales (flag automatique, scan global, etc.)
- Plus rare et plus précieuse que la Concentration

### Bruit
- Jauge qui monte quand le joueur fait des actions "bruyantes" (révéler en cascade, déclencher des explosions atténuées, utiliser certaines cartes)
- Un Bruit trop élevé déclenche des effets négatifs (apparition de mines bonus, événements malveillants)
- Crée une tension entre efficacité et prudence
- Se réduit entre les grilles ou via des cartes/reliques spécifiques

---

## Les 5 familles de cartes

### 1. Scan (Observation)
*Voir sans toucher.*
- **Sonar** (1 Concentration) — Révèle le nombre de mines dans un rayon 3x3 autour de la cible
- **Analyse Spectrale** (2 Intuitions) — Marque tous les chiffres impairs de la grille pendant 3 tours
- **Prémonition** (1 Concentration) — Révèle si la prochaine case que tu révéleras sera une mine

### 2. Sonde (Révélation)
*Révéler avec contrôle.*
- **Révélation en Croix** (2 Concentration) — Révèle 5 cases en croix (centre + 4 cardinaux)
- **Forage** (4 Concentration, 1 Intuition) — Révèle un carré 3x3 complet, désamorce les mines dedans
- **Toucher Léger** (1 Concentration) — Révèle une case et ses voisins vides en cascade, sans déclencher les mines

### 3. Manipulation (Modification)
*Changer les règles.*
- **Téléportation** (2 Concentration) — Déplace une mine vers une case vide aléatoire
- **Neutralisation** (3 Concentration) — Transforme une mine en case safe (case choisie aléatoirement parmi les mines)
- **Transmutation** (2 Concentration, 1 Intuition) — Change la valeur d'un chiffre révélé de ±1

### 4. Protection (Défense)
*Survivre aux erreurs.*
- **Bouclier** (2 Concentration) — Bloque la prochaine explosion (consommé si une mine est révélée)
- **Champ de Force** (3 Concentration, 1 Intuition) — Pendant 2 tours, les mines révélées ne causent pas de dégâts
- **Plongée Contrôlée** (1 Concentration) — Révèle une case au hasard sans risque (garanti non-mine)

### 5. Exploitation (Économie)
*Tirer profit de la grille.*
- **Prospection** (0 Concentration) — Gagne 1 or par case vide révélée ce tour-ci
- **Concentration Pure** (0 Concentration) — Gagne +2 Concentration ce tour
- **Récupération** (1 Concentration) — Pioche 2 cartes supplémentaires

---

## Structure d'une run

### Secteurs
- **3 secteurs** par run (Phase 5)
- Chaque secteur = un biome visuel et thématique
- Secteur 1 : Industriel (tuyaux, métal, rouillé)
- Secteur 2 : Organique (caverneux, vivant, disturbing)
- Secteur 3 : Mental (abstrait, psyché, géométrie impossible)

### Nœuds par secteur
- 8 à 12 nœuds par carte de secteur
- Types de nœuds :
  - **Grille normale** : démineur standard, difficulté croissante
  - **Élite** : grille avec règle spéciale (plus de mines, chiffres cachés, etc.)
  - **Cache** : récompense bonus (relique ou or) aprés une grille facile
  - **Atelier** : retirer/améliorer des cartes
  - **Marchand** : acheter cartes et reliques avec l'or
  - **Événement** : choix narratif avec conséquences mécaniques
  - **Sanctuaire** : soin, repos, choix de relique

### Boss
- 1 boss par secteur + 1 boss final
- Chaque boss = une grille de démineur avec une mécanique unique qui perturbe les règles

---

## Classe détaillée : Le Géomètre

### Identité
Le maître de l'analyse. Joue de manière méthodique, marque des hypothèses, scanne plus qu'il ne révèle. Récompense la pensée logique poussée.

### Mécanique signature : Hypothèses
- Peut marquer jusqu'à 3 cases comme "hypothèses" (état spécial, ni flag ni révélé)
- Si une hypothèse se révèle correcte (la case correspond à ce que le joueur a déduit), gain d'Intuition bonus
- Si incorrecte, perte de Concentration
- Ajoute une couche de déduction active au démineur

### Starter deck (10 cartes)
1. Sonar x2
2. Révélation en Croix x2
3. Bouclier x1
4. Prospection x1
5. Concentration Pure x1
6. Toucher Léger x1
7. Prémonition x1
8. Plongée Contrôlée x1

### Relique de départ
**Boussole** — La première case révélée chaque tour indique la direction de la mine la plus proche.

---

## Inconnues à résoudre en prototype

1. **Solvabilité** : Peut-on garantir qu'une grille de démineur est toujours solvable logiquement sans guessing ? Quel solver implémenter ?
2. **Équilibre Bruit** : Le système de Bruit ajoute-t-il de la tension intéressante ou est-ce juste frustrant ?
3. **Pacing** : Combien de temps dure une grille individuelle ? Trop long = rébarbatif. Trop court = pas de place pour le deckbuilding.
4. **Interaction cartes-grille** : Est-ce que les cartes qui manipulent la grille (déplacer une mine) cassent le feeling du démineur ou l'enrichissent ?
5. **Taille de grille optimale** : Quelle taille pour que les cartes aient un impact significatif sans que la grille soit vide ?
6. **Scaling difficulté** : Comment augmenter la difficulté au fil de la run (mines, taille, règles) ?
7. **Nombre de cartes en main** : 5 est-il le bon chiffre ? Assez pour combiner, assez peu pour forcer des choix ?
8. **Coût Concentration vs révélation libre** : Si révéler une case coúte de la Concentration, est-ce que le démineur reste fun ?
9. **Système de reliques** : Les effets passifs déclenchés par signaux sont-ils lisibles pour le joueur ?
10. **Boucle de récompense** : Le format "3 cartes proposées, choix ou skip" est-il assez satisfaisant ?
