# Pipeline artistique

## Taille des cases
- **16x16 pixels** pour les tiles de la grille
- Chaque tile possède des états visuels distincts (caché, révélé, flag, mine, etc.)

## Palette
- Fichier : `assets/sprites/hollow-grid-palette.gpl` (format GIMP, compatible Aseprite)
- 32 couleurs, ambiance sombre/industrielle
- Chaque sprite DOIT utiliser uniquement ces couleurs

## Sprites
- Format Aseprite (.aseprite) pour les sources
- Export PNG pour Godot
- Import preset Godot : Filter = Nearest, Mipmaps = Off

## Fonts
- Police pixel recommandée : [Press Start 2P] ou [Pixel Operator]
- Tailles : 5px (petit), 8px (normal), 12px (titre)
- Fichiers .ttf ou .otf dans `assets/fonts/`

## Contraintes
- Pas d'antialiasing sur les sprites
- Pas de dégradé (flat colors ou dithering uniquement)
- Transparence uniquement sur le pixel pur magenta (255,0,255) pour le debug, jamais en production
