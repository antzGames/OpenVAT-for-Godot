# OpenVAT for Godot + Animated MultiMeshInstance3D support

A plugin that provides [OpenVAT](https://openvat.org/) support to Godot.

OpenVAT is a Blender-native toolkit for baking Vertex Animation Textures (VATs) 
enabling engines and DCCs to seamlessly play back complex animated deformation as 
vertex offsets on GPU via low-cost vertex shaders. OpenVAT GitHub: https://github.com/sharpen3d/openvat

In addition, a new, easy to use `OpenVATMultiMeshInstance3D` node is provided for 
instanced animation support, with auto OpenVAT configuration importing.

You can play with the demo in your browser at: [https://antzgames.itch.io/openvat-for-godot](https://antzgames.itch.io/openvat-for-godot)

## Preview

Watch a complete overview video on [YouTube](https://youtu.be/0Ok142yRlog).  I also have a [level destruction](https://youtu.be/-JMrnT9dD2g) video.

https://github.com/user-attachments/assets/8ab836ec-a085-454a-b0d3-394aaa6a44b2

## OpenVAT Support

- Auto import of the OpenVAT JSON configuration file. This includes:
	- minimum/maximun vectors
	- animation track meta data
- Can support multiple baked in animation tracks (supports a total of 4096 combined frames).
- Supoorts both looping and non-looping animation tracks. 

## `OpenVATMultiMeshInstance3D` features

- Ability to set a unique animation track per instance.
- Ability to change animation track at any time per instance.
- Ability to control the alpha channel for individual instances.  Also includes easy fade in/out tweened functions.
- Ability to restart the non-looping animation tracks for individual instances.
- All the `MultiMeshInstance3D` features such as a unique transform (scale, rotation, and position) per instance.
- Works on all renderers, and on HTML builds.

## Limitations

- Mesh must be less than 8192 vertices. Verticies count needs to be constant across all animation frames.
- Total number of frames for all animations must be less than 4096.
- No blending or mixing of animation tracks.
- `MultiMeshInstance3D` `custom_data` is used by this plugin so you will not have access to use it.

## Product Roadmap

| Version | Status | Features |
|---|---|---|
| V0.0.1 | ✅Released | OpenVAT JSON file import.  New `OpenVATMultimeshInstance3D` node. Basic instanced animation track control. Instanced alpha channel control. Roughness, Metallic, Normal Map texture support in shader. |
| V0.0.2 | ✅Released | Instanced `isLooping` and `timestamp` support using the `INSTANCE_COLOR.rg` fields. |
| V0.0.3 | 💀Canceled | Animation blending support needs at a minimum `3` more instanced uniforms which Godot does not provide. Need to wait for https://github.com/godotengine/godot-proposals/issues/8666 |

## Requirements

- Godot 4.5+
- Blender 4.2+ with the [OpenVAT Extension](https://extensions.blender.org/add-ons/openvat/) installed.

## Installing this plugin

Maybe if this plugin gets noticed, I will add it to Godot's AssetLib.  Until then follow these instructions:

- Download this repository as a ZIP file.
- Extract the ZIP file.
- Copy the `addons` directory from the extracted ZIP file into your Godot project's `res://` filesystem.
- Go to `Project > Project Settings > Plugins` and enable **OpenVAT Animated MultiMeshInstance3D Plugin**.
- Add the new `OpenVATMultiMeshInstance3D` node into a scene.

<img width="1433" height="315" alt="image" src="https://github.com/user-attachments/assets/914a90a5-723c-4e14-b7c3-db2c950bdc76" />

## `OpenVATMultiMeshInstance3D`

This plugin provides a new node called `OpenVATMultiMeshInstance3D` which inherits `MultiMeshInstance3D`.

### Preparing your Mesh for use with the `OpenVATMultiMeshInstance3D` node

> [!IMPORTANT]  
> Crucial information necessary for to use the `OpenVATMultiMeshInstance3D` node.

1. Not going to explain how to use OpenVAT Blender tool, as the OpenVAT developer has hours of [videos](https://www.youtube.com/@LukeStilson) demonstrating how to use it.
However, the Godot version of the OpenVAT shader assumes you exported your model in Blender with the OpenVAT tool using these settings:
	- `Vertex Normals` = `Packed`
	- `Use Single Row` checked
	- `Export Model` checked
	- `Model Format` = `glTF Binary`
	- `Image Format` = `EXR16`
2. The Blender OpenVAT Tool output will be 3 files. Copy these 3 files into your Godot project:
	- a `.glb` file - single mesh version of your 3D model
	- a `.exr` file - vertex and normal (packed together) encoded Vertex Animation Texture (VAT)
	- a `.json` file - contains the min/max extents and animation meta data for your model
3. Make sure the `.exr` file is re-imported with compress mode as `Lossless` and turn off `Generate` Mipmaps. 
4. Open the `.glb` model, go to the Meshes tab, select the mesh, then on the right select `Save to File` option. Re-import.
5. Open your newly saved `Mesh` resource.  In `Surface 0`, change the `Material` to a `ShaderMaterial` and assign the 
OpenVAT instanced shader: `res://addons/openvat_animated/shaders/openvat_instanced.gdshader`
6. Drag the `.exr` OpenVAT file into the `Vertex Animation Texture` shader parameter.
7. Set the `Speed` shader parameter to the FPS of the animation that was in Blender (defaults to 30).
8. (Optional) Drag or configure any albedo, metallic, roghness, normal map textures into the provided shader paramters.
9. Save your configured Mesh.

✅This `Mesh` can now be used in any `OpenVATMultiMeshInstance3D`

🎞️This [video](https://youtu.be/0Ok142yRlog?si=Lp9F-twPYnpHOYs8&t=601) will show you how to prepare your `Mesh` for the `OpenVATMultiMeshInstance3D` node.

### `OpenVATMultiMeshInstance3D` Properties

- **Exported Mesh**: `ArrayMesh` = the mesh that you prepared in the previous step.
- **Instance Count**: `int` = the number of instances
- **Rand Anim Offset**: `bool` =  randomize the animation offset (true/false)

- **OpenVAT JSON Config File**: `String` = the path to the JSON file exported by the OpenVAT Blender tool
- **Min and Max Values**: `Vector3` = these values will be filled in when the OpenVAT JSON file is imported

🎞️This [video](https://youtu.be/0Ok142yRlog?si=4vIiX3uICbk5h6a3&t=736) will show you how to use `OpenVATMultiMeshInstance3D`.

<img width="414" height="410" alt="inspector" src="https://github.com/user-attachments/assets/af634458-9cb6-4ff0-b1df-a745c162a369" />

You can manually force the loading of the JSON file by click on the `Import JSON` button in the inspector.

> [!NOTE]  
> The JSON file is automatically imported on `_ready()` which means it imports on every activation.  This makes sure that the latest JSON file is used.

> [!NOTE]  
> If no animation tracks are defined in the OpenVAT JSON file, then a `Default` looping animation track is created on import.

The JSON importer outputs information on the console:

<img width="1467" height="750" alt="output" src="https://github.com/user-attachments/assets/2a4bea60-f4e0-40d7-ab89-7c73de0d0037" />

### `OpenVATMultiMeshInstance3D` Update Functions

If you want to change the animation track for a specific instance, use:

`update_instance_track(instance_id: int, track_number: int)`

If you want to change the alpha of a specific instance use:

`update_instance_alpha(instance_id: int, alpha: float)`

If you want to change the animation offset of an instance, so that different instances playing the same animation
track are not syncronized, use:

`update_instance_animation_offset(instance_id: int, animation_offset: float)`

You can also change all parameters of a specific instance by using:

`update_instance(instance_id: int, animation_offset: float, track_number: int, alpha: float)`

You can also change ALL instances by using:

`update_all_instances(animation_offset: float, track_number: int, alpha: float)`

### `OpenVATMultiMeshInstance3D` Tweened Fade In/Out Functions

You can get Godot to automatically fade out an instance using a `Tween` with:

`fade_out_instance(instance_id: int, fade_out_time: float = 1.0, start_delay: float = 0.0):`

You can get Godot to automatically fade in an instance using a `Tween` with:

`fade_in_instance(instance_id: int, fade_in_time: float = 1.0, start_delay: float = 0.0):`

### `OpenVATMultiMeshInstance3D` Animation Play Functions

You can play the next animation track of an instance using:

`play_next_track_instance(instance_id: int)`

Or play the next animation track of all instances using:
	
`play_next_track_all_instances()`

### `OpenVATMultiMeshInstance3D` Animation Get Functions

Animation meta data is stored in the `animation_tracks` variable.  It is an `Array` of `OpenVATAnimationTrack`:
```gdscript
var animation_tracks: Array[OpenVATAnimationTrack] 
```

This is the `OpenVATAnimationTrack` class :
```gdscript
class_name OpenVATAnimationTrack
extends RefCounted

var name: String
var startFrame: int
var endFrame: int
var framerate: int
var isLooping: bool
```

To get the `OpenVATAnimationTrack` object from an instance:

`get_animation_from_instance(instance_id: int) -> OpenVATAnimationTrack`

To get the animation track index from the provided `OpenVATAnimationTrack` object: 

`get_track_number_from_animation(animation: OpenVATAnimationTrack) -> int`

To get the currently playing animation track index from the instance, use:

`get_track_number_from_instance(instance_id: int) -> int`

To get the animation track index by animation track name:

`get_track_number_from_name(name: String) -> int:`

To get the animation track index from the start and end frames, use:

`get_track_number_from_start_end_frames(start: int, end: int) -> int`

### Instanced `custom_data` and instanced `color` shader uniforms

The inherited `MultiMeshInstance3D` `custom_data` is used by this plugin and instanced shader.  Here is how it is used:

- `custom_data.r` = **animation offset**: used to randomize instances playing the same animation track
- `custom_data.g` = **animation start frame**
- `custom_data.b` = **animation end frame**
- `custom_data.a` = **alpha of mesh**: used to fade in/out a unique instance

- `color.r` = **is_looping** 1.0 = true, 0.0 = false
- `color.g` = **timestamp** used to keep track of when an animation was set or the one_shot has been reset.

## Common Issues

❓**Question**: My mesh is all white, with no colors or textures. 💡**Answer**: You forgot to add Albedo, Metallic, Roughness, Normal Map textures that came with the original model to the shader.

❓**Question**: My mesh's verticies are cracked or all over the place. 💡**Answer**: Re-import your VAT texture (`.exr` file) with compress mode as `Lossless` and turn off `Generate` Mipmaps. 

❓**Question**: My animations still looked deformed. 💡**Answer**: This is a Blender/OpenVAT usage issue, and it could be caused by many things.  Check out the OpenVAT [videos](https://www.youtube.com/@LukeStilson), or post an issue on OpenVAT on [GitHub](https://github.com/sharpen3d/openvat). 

❓**Question**: How do I restart a non-looping animation for a specific instance? 💡**Answer**:  Use `reset_one_shot(instance_id)` or `update_instance_track(instance_id: int, track_number: int)` both assume the animation track is set with `is_looping =  false`.

❓**Question**: How do I implement a static pose in an animation track:
 
  - 💡**Answer 1**: Create a 3 frame action on your NLA strip in Blender with each keyframe being the same, then do an OpenVAT export, and re-import into Godot.  The shader will loop these 3 frames, and look like the model is static because the vertex positions have not moved. 
  - 💡**Answer 2**: Manually encode another animation track in the JSON file with the same startFrame and endFrame, then do an OpenVAT export, and re-import JSON file into Godot.

## Demo

A demo is provided.  Just run the project.  Pressing `SPACE` or `F1` key will load the next scene.

Pressing the `F3` key will display more FPS information.

`MSAA 2x` is set at the project level.  Turning off `MSAA` improves performance.

## Using the OpenVAT Godot shader on its own

I have provied the official OpenVAT Godot shader for you to use on your own custom solutions.  Remember that the 
official OpenVAT Godot shader does not have support for multiple animations.  It will only loop through all encoded frames.

The unaltered OpenVAT Godot shader is in: `res://addons/openvat_animated/shaders/openvat_singleton.gdshader`
See the MIT license for this shader below.

The most up to date version can be downloaded from the OpenVAT GitHub at: https://github.com/sharpen3d/openvat/blob/main/OpenVAT-Engine_Tools/GLSL/VertexAnimationPBR-GLSL.gdshader

You will have to set the min/max values, and all other shader parameters manually. 
Some of the demo scenes (`durty_rag.tscn`, `cloth.tscn`, `jello.tscn`) use the default OpenVAT shader, so take a look at the code to see how it is done.

## OpenVAT MIT License for shader in `OpenVAT-Engine_Tools`

This plugin uses a modified OpenVAT GLSL shader from the `OpenVAT-Engine_Tools` folder of 
the OpenVAT GitHub: https://github.com/sharpen3d/openvat/tree/main/OpenVAT-Engine_Tools

This comes with a MIT license:

```
MIT License

Copyright (c) 2024 Luke Stilson

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

This license applies only to the recursive contents of this folder (`OpenVAT-Engine_Tools`) and
does not affect the licensing of the core OpenVAT tool, which is licensed under GPL-3.0.
```

## Asset Attributions

[Skeleton](https://kaylousberg.itch.io/kaykit-skeletons) and [Mage](https://kaylousberg.itch.io/kaykit-adventurers) by Kay Lousberg - [CC0 License](http://creativecommons.org/publicdomain/zero/1.0/)

[Floor Tile](https://kenney.nl/assets/prototype-textures) by Kenney - [CC0 License](http://creativecommons.org/publicdomain/zero/1.0/)

[Cloth Sim Waves Perfect Loop](https://sketchfab.com/3d-models/cloth-sim-waves-perfect-loop-a93202e50a0342348f1728b18e3b92e8) by SonicVisual - [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

[Animated Jello](https://sketchfab.com/3d-models/animated-jello-c7ba6da061a1483bb1c81ecc3a59a564) by Logan S. - [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

[Shape Key Bone Driver Test](https://sketchfab.com/3d-models/shape-key-bone-driver-test-ed93191ec2fa4f7494cf4a689470a4ac) by Tsawodi - [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)

[Dentable/Crushable Soda Cans](https://sketchfab.com/3d-models/dentablecrushable-soda-cans-hp-e43d8593603f49dd8f4c8628c1cf5857) by 00004707 - [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
