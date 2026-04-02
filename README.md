# OpenVAT for Godot + Animated MultiMeshInstance3D support

> [!Note]
> I am waiting for written confirmation directly from the OpenVAT Blender Toolkit developer that my Godot Plugin can use a MIT license.  I will change my plugin license from AGPL to MIT once I get written confirmation. The only reason why I set it to AGPL initially, is because I did not want any legal risks from OpenVAT in the future.

A plugin that provides [OpenVAT](https://openvat.org/) support to Godot.

OpenVAT is a Blender-native toolkit for baking Vertex Animation Textures (VATs) 
enabling engines and DCCs to seamlessly play back complex animated deformation as 
vertex offsets on GPU via low-cost vertex shaders. OpenVAT GitHub: https://github.com/sharpen3d/openvat

In addition, a new, easy to use `OpenVATMultiMeshInstance3D` node is provided for 
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
- No blending or mixing of animation tracks.
- Although the complete OpenVAT animation meta data is imported and stored in the `OpenVATMultiMeshInstance3D` node, `framerate` and `isLooping` are ignored. All animation tracks will use the same framerate.
All animation tracks will loop.
- `MultiMeshInstance3D` `custom_data` is used by this plugin so you will not have access to use it.

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
2. The Blender OpenVAT Tool output will be 3 files. Copy these 3 files into you Godot project:
	- a `.glb` file - single mesh version of your 3D model
	- a `.exr` file - vertex and normal (packed together) encoded Vertex Animation Texture (VAT)
	- a `.json` file - contains the mix/max extents and animation meta data for your model
3. Make sure the `.exr` file is re-imported with compress mode as `Lossless` and turn off `Generate` Mipmaps. 
4. Open the `.glb` model, go to the Meshes tab, select the mesh, then on the right select `Save to File` option. Re-import.
5. Open your newly saved `Mesh` resource.  In `Surface 0`, change the `Material` to a `ShaderMaterial` and assign the 
OpenVAT instanced shader: `res://addons/openvat_animated/shaders/openvat_instanced_shader.gdshader`
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

The JSON importer outputs information on the console:

<img width="1467" height="750" alt="output" src="https://github.com/user-attachments/assets/2a4bea60-f4e0-40d7-ab89-7c73de0d0037" />

### `OpenVATMultiMeshInstance3D` Update Functions

If you want to change the animation track for a specific instance, use:

`update_instance_track(instance_id: int, track_number: int)`

If you want to change the alpha so can fade a specific instance out (or fade in), use:

`update_instance_alpha(instance_id: int, alpha: float)`

If you want to change the animation offset of an instance, so that different instances playing the same animation
track are not syncronized, use:

`update_instance_animation_offset(instance_id: int, animation_offset: float)`

You can also change all parameters of a specific instance by using:

`update_instance(instance_id: int, animation_offset: float, track_number: int, alpha: float)`

You can also change ALL instances by using:

`update_all_instances(animation_offset: float, track_number: int, alpha: float)`

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

To get the animation track index from the start and end frames, use:

`get_track_number_from_start_end_frames(start: int, end: int) -> int`

### Instanced `custom_data` information

The inherited `MultiMeshInstance3D` `custom_data` is used by this plugin and instanced shader.  Here is how it is used:

- `custom_data.r` = **animation offset**: used to randomize instances playing the same animation track
- `custom_data.g` = **animation start frame**
- `custom_data.b` = **animation end frame**
- `custom_data.a` = **alpha of mesh**: used to fade in/out a unique instance

## Common Issues

❓**Question**: My mesh is all white, with no colors or textures. 💡**Answer**: You forgot to add Albedo, Metallic, Roughness, Normal Map textures that came with the original model to the shader.

❓**Question**: My mesh's verticies are cracked or all over the place. 💡**Answer**: Re-import your VAT texture (`.exr` file) with compress mode as `Lossless` and turn off `Generate` Mipmaps. 

❓**Question**: My animations still looked deformed. 💡**Answer**: This is a Blender/OpenVAT usage issue, and it could be caused by many things.  Check out the OpenVAT [videos](https://www.youtube.com/@LukeStilson), or post an issue on OpenVAT on [GitHub](https://github.com/sharpen3d/openvat). 

❓**Question**: How do I implement a static pose in an animation track:
 
  - 💡**Answer 1**: Create a 3 frame action on your NLA strip in Blender with each keyframe being the same, then do an OpenVAT export, and re-import into Godot.  The shader will loop these 3 frames, and look like the model is static because the vertext positions have not moved. 
  - 💡**Answer 2**: Manually encode another animation track with the same startFrame and endFrame, then do an OpenVAT export, and re-import into Godot. (TODO: test this)

## Demo

A demo is provided.  Just run the project.  Pressing `SPACE` or `F1` key will load the next scene.

Pressing the `F3` key will display more FPS information.

`MSAA 2x` is set at the project level.  Turning off `MSAA` improves performance.

## Using the OpenVAT Godot shader on its own

I have provied the official OpenVAT Godot shader for you to use on your own custom solutions.  Remember that the 
official OpenVAT Godot shader does not have support for animations.  

The unaltered OpenVAT Godot shader is in: `res://addons/openvat_animated/shaders/openvat_singleton_shader.gdshader`

The most up to date version can be downloaded from the OpenVAT GitHub at: https://github.com/sharpen3d/openvat/blob/main/OpenVAT-Engine_Tools/GLSL/VertexAnimationPBR-GLSL.gdshader

You will have to set the min/max values, and all other shader parameters manually. 
Some of the demo scenes (`cloth.tscn`, `jello.tscn`) use this, so look at the code to see how it is done.

## Asset Attributions

[Skeleton](https://kaylousberg.itch.io/kaykit-skeletons) by Kay Lousberg - [CC0 License](http://creativecommons.org/publicdomain/zero/1.0/)

[Floor Tile](https://kenney.nl/assets/prototype-textures) by Kenney - [CC0 License](http://creativecommons.org/publicdomain/zero/1.0/)

[Cloth Sim Waves Perfect Loop](https://sketchfab.com/3d-models/cloth-sim-waves-perfect-loop-a93202e50a0342348f1728b18e3b92e8) by SonicVisual - [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

[Animated Jello](https://sketchfab.com/3d-models/animated-jello-c7ba6da061a1483bb1c81ecc3a59a564) by Logan S. - [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)

[Shape Key Bone Driver Test](https://sketchfab.com/3d-models/shape-key-bone-driver-test-ed93191ec2fa4f7494cf4a689470a4ac) by Tsawodi - [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/)
