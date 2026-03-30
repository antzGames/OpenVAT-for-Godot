# OpenVAT for Godot + Animated MultiMeshInstance3D support

A plugin that provides [OpenVAT](https://openvat.org/) support to Godot.

OpenVAT is a Blender-native toolkit for baking Vertex Animation Textures (VATs) — 
enabling engines and DCCs to semalessly play back complex animated deformation as 
vertex offsets on GPU via low-cost vertex shaders. OpenVAT GitHub: https://github.com/sharpen3d/openvat

In addition a easy to use new `OpenVATVATMultiMeshInstance3D` node is provided for easy 
instanced animation support, with auto OpenVAT configuration importing.

## Preview

https://github.com/user-attachments/assets/d9d33d3f-720a-48d8-9bb5-6a15169e03d9

## OpenVAT Support

- Auto import of the OpenVAT JSON configuration file. This includes:
	- minimum/maximun vectors
	- all animation track meta data
- Can support multiple baked in animation tracks (supports a total of 4096 combined frames).

## `OpenVATMultiMeshInstance3D` features

- Ability to set a unique animation track per instance.
- Ability to change animation track at any time per instance.
- Ability to control the alpha channel for individual instances.
- All the `MultiMeshInstance3D` features such as a unique transform (scale, rotation, and position) per instance.
- Works on all renderers, and on HTML builds.

## Limitations

- Mesh must be less than 8192 vertices.
- Total number of frames for all animations must be less than 4096.
- No blending or transitions between animation tracks.
- Although the complete OpenVAT animation meta data is imported and stored in the `OpenVATMultiMeshInstance3D` node, it is not used in the shader. 
So `framerate` and `isLooping` are ignored. All animation tracks will use the same framerate.  Maybe in the future it will be used in the Godot OpenVAT solution.
- Animation tracks will always loop, so you need to develop a custom solution for chaining different animations.
- `MultiMeshInstance3D` `custom_data` is used by this plugin so you will not have access to use it.

## Requirements

- Godot 4.5+
- Blender 4.2+

## Installing this plugin

Maybe if this plugin gets noticed, I will add it to Godot's AssetLib.  Until then follow these instructions:

- Download this repository as a ZIP file.
- Extract the ZIP file.
- Copy the `addons` directory from the extracted ZIP file into your Godot project's `res://` filesystem.
- Go to `Project > Project Settings > Plugins` and enable **OpenVAT Animated MultiMeshInstance3D Plugin**.
- Test to see if you can add the new `OpenVATMultiMeshInstance3D` node into a scene.

## `OpenVATMultiMeshInstance3D`

This plugin provides a new node called `VATMultiMeshInstance3D` which inherits `MultiMeshInstance3D`.

### Preparing your Mesh for use with the `OpenVATMultiMeshInstance3D` node

> [!IMPORTANT]  
> Crucial information necessary for to use the `OpenVATMultiMeshInstance3D` node.

1. Not going to explain how to use OpenVAT as the OpenVAT developer has hours of videos demonstrating how to use it.
However, the Godot version of the OpenVAT shader assumes you exported your model in Blender with the OpenVAT tool using these settings:
 - `Vertex Normals` = `Packed`
 - `Use Single Row` checked
 - `Export Model` checked
 - `Model Format` = `glTF Binary`
2. The OpenVAT output will be 3 files: a `GLB` file, a `EXR` file and a `JSON` file.  Copy these files into you Godot project.
3. Make sure the `EXR` file is re-imported as `Lossless` and turn off `Generate` Mipmaps. 
4. Open the `GLB` model, go to the Meshes tab, and on the right select `Save to File` option. You should also disable LODs 
generation.  Re-import.
5. Open your newly saved Mesh resource.  In `Surface 0`, change the `Material` to a `ShaderMaterial` and assign the 
OpenVAT instanced shader: `res://addons/openvat_animated/shaders/openvat_instanced_shader.gdshader`
6. Drag the `EXR` OpenVAT file into the `Vertex Animation Texture` shader parameter
7. (Optional) Drag or configure any albedo, metallic, roghness, norma map textures into the provided shader paramters.
8. Save your configued Mesh.

Now this Mesh can be used in any `OpenVATMultiMeshInstance3D`

This video will show you how to do these steps.

### `OpenVATMultiMeshInstance3D` Properties

- **Exported Mesh**: `ArrayMesh` = the mesh that you prepared in the previous step.
- **Instance Count**: `int` = the number of instances
- **Rand Anim Offset**: `bool` =  randomize the animation offset (true/false)

- **OpenVAT JSON Config File**: `String` = the path to the JSON file exported by the OpenVAT Blender tool
- **Min and Max Values**: `Vector3` = these values will be filled in when the OpenVAT JSON file is imported

You can manually force the loading of the JSON file by click on the `Import JSON` button in the inspector.

> [!NOTE]  
> The JSON file is automatically imported on `_ready()` which means it runs every activation.  This makes sure that the latest JSON file is used.d

### `OpenVATMultiMeshInstance3D` Functions

### `MutiMeshInstance3D` `custom_data` information

`MultiMeshInstance3D` `custom_data` is used by this plugin and instanced shader.  Here is how it is used:

- `custom_data.r` = **animation offset**: used to randomize instances playing the same animation track
- `custom_data.g` = **animation start frame**
- `custom_data.b` = **animation end frame**
- `custom_data.a` = **alpha of mesh**: used to fade in/out a unique instance

## Demo

A demo is provided.  Just run the project.  Pressing SPACE or F1 will load the next scene.

## Using the OpenVAT shader on its own

I have provied the official OpenVAT Godot shader for you to use on your own custom solutions.

The unaltered shader is in: `res://addons/openvat_animated/shaders/openvat_singleton_shader.gdshader`

You will have to set the min/max values, and all other shader parameters manually. 
Some of the demo scenes ('cloth.tscn', 'jello.tscn') use this, so look at the code to see how it is done.

## Asset Attributions

[Skeleton](https://kaylousberg.itch.io/kaykit-skeletons) by Kay Lousberg - [CC0 License](http://creativecommons.org/publicdomain/zero/1.0/)

[Floor Tile](https://kenney.nl/assets/prototype-textures) by Kenney - [CC0 License](http://creativecommons.org/publicdomain/zero/1.0/)

[Cloth Sim Waves Perfect Loop](https://sketchfab.com/3d-models/cloth-sim-waves-perfect-loop-a93202e50a0342348f1728b18e3b92e8) by SonicVisual - [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

[Animated Jello](https://sketchfab.com/3d-models/animated-jello-c7ba6da061a1483bb1c81ecc3a59a564) by Logan S. - [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

[Shape Key Bone Driver Test](https://sketchfab.com/3d-models/shape-key-bone-driver-test-ed93191ec2fa4f7494cf4a689470a4ac) by Tsawodi - [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
