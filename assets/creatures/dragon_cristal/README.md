# Dragon Cristal (créature 3D de référence)

Modèle de référence de « qualité » pour tout le bestiaire : concept du propriétaire,
modèle généré avec TRELLIS.2 (Hugging Face, licence MIT), puis retravaillé dans Blender.

- `dragon_cristal_rig.fbx` : maillage 11 465 triangles + halo (280) + squelette de 17 os
  + 6 animations (Idle, Marche, Course, Joie, Etourdi, Porte). Longueur 3 unités.
- Textures 1024 px (`dragon_cristal_color.png`, `_roughness.png`, `_metalness.png`, pour une
  SurfaceAppearance) et aperçu `dragon_animations.mp4` : sur le PC du propriétaire, dans
  `Documents\FlingSeed` (le stockage LFS n'est pas joignable depuis la pipeline).
- `pipeline_creature.py` : script Blender qui prépare un GLB TRELLIS pour Roblox
  (allègement à 12 000 triangles, nettoyage, échelle, textures).
- `prompts_creatures.txt` : descriptions des 12 prochaines espèces pour TRELLIS.2 Text-to-3D.

## Reste à faire dans Studio
1. Importer le FBX (3D Importer) et publier le maillage et les textures sur le compte du propriétaire.
2. Poser l'attribut `Squelette = "Quadrupede"` sur le modèle : le client `AnimationsOs` l'anime
   (clip choisi par `EtatAnim` ou par la vitesse).
3. Vérifier le sens des mouvements ; si besoin, régler `AnimationsOs.Axes`.
