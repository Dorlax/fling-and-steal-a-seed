# Pipeline creature Fling & Steal a Seed : GLB (TRELLIS.2) -> pret pour Roblox
# Usage dans Blender : modifier NOM et GLB, puis executer.
import bpy, bmesh, os, numpy as np
NOM="DragonCristal"; GLB=r"C:\Users\OlivierT\Documents\FlingSeed\sample.glb"
TRIS=12000; LONGUEUR=3.0; TEX=1024
OUT=os.path.dirname(GLB)
bpy.ops.import_scene.gltf(filepath=GLB)
mesh=[o for o in bpy.context.selected_objects if o.type=='MESH'][0]
for o in list(bpy.context.selected_objects):
    if o.type!='MESH': mw=mesh.matrix_world.copy(); mesh.parent=None; mesh.matrix_world=mw; bpy.data.objects.remove(o)
bpy.context.view_layer.objects.active=mesh; mesh.select_set(True)
bpy.ops.object.transform_apply(location=True,rotation=True,scale=True)
bm=bmesh.new(); bm.from_mesh(mesh.data); bmesh.ops.remove_doubles(bm,verts=bm.verts,dist=0.0003); bm.to_mesh(mesh.data); bm.free()
d=mesh.modifiers.new("Dec","DECIMATE"); d.ratio=min(1,TRIS/len(mesh.data.polygons)); bpy.ops.object.modifier_apply(modifier="Dec")
# separer les morceaux ; supprimer les feuilles plates (fumee) -> remplacees par des particules Roblox
bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.separate(type='LOOSE'); bpy.ops.object.mode_set(mode='OBJECT')
parts=list(bpy.context.selected_objects)
for p in parts:
    if min(p.dimensions)<0.02*max(p.dimensions): bpy.data.objects.remove(p)
parts=[p for p in bpy.data.objects if p.name.startswith(mesh.name)]
big=max(parts,key=lambda p:len(p.data.polygons)); big.name=NOM
# echelle + sol
s=LONGUEUR/max(big.dimensions)
for p in parts: p.scale=(s,s,s)
bpy.ops.object.select_all(action='DESELECT')
for p in parts: p.select_set(True)
bpy.ops.object.transform_apply(scale=True)
zmin=min(min((p.matrix_world@v.co).z for v in p.data.vertices) for p in parts)
for p in parts: p.location.z-=zmin
bpy.ops.object.transform_apply(location=True)
# textures
m=big.data.materials[0]; imgs=[n.image for n in m.node_tree.nodes if n.bl_idname=="ShaderNodeTexImage" and n.image]
for i,im in enumerate(imgs):
    c=im.copy(); c.scale(TEX,TEX); px=np.empty(TEX*TEX*4,dtype=np.float32); c.pixels.foreach_get(px); px=px.reshape(-1,4)
    if i==0:
        c.filepath_raw=os.path.join(OUT,NOM+"_color.png"); c.file_format='PNG'; c.save()
    else:
        for ch,suf in ((1,"_roughness"),(2,"_metalness")):
            o_=np.ones_like(px); o_[:,0]=o_[:,1]=o_[:,2]=px[:,ch]
            g=bpy.data.images.new(NOM+suf,TEX,TEX); g.pixels.foreach_set(o_.ravel()); g.filepath_raw=os.path.join(OUT,NOM+suf+".png"); g.file_format='PNG'; g.save()
bpy.ops.export_scene.fbx(filepath=os.path.join(OUT,NOM+".fbx"),use_selection=True,object_types={'MESH'},mesh_smooth_type='FACE')
print("OK", NOM, [ (p.name,len(p.data.polygons)) for p in parts])
