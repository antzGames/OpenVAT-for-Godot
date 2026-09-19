<br />
<br />

<h2 align="center">
	<img alt="Minimize HTML Build" src="https://raw.githubusercontent.com/markushevpro/godot-minimize-html-build/refs/heads/master/assets/icon.png" />
	<br/>
	<br/>
	Godot "Minimize Web Build" Addon
  <br/>
</h2>

<h3 align="center">
	A minification tool for Godot 4.3+ that automatically compresses files in your web build
</h3>

<p align="center">
	Speeds up your game loading even if your server does not support gzip compression<br/><br/>
	<blockquote align="center">
		<br/><strong style="color: red">DISCLAIMER</strong><br/><br/>
		The compression ratio of a .pck file depends heavily on the set of assets in your project.<br/>Loading speed depends on server settings.<br/>On average, loading speed when using a plugin can be from <strong>10% to 100%</strong> faster.<br/><br/><strong>See comparison calculations <a href="https://github.com/markushevpro/godot-minimize-html-build/blob/master/COMPARE.md">here</a>.</strong><br/><br/>
	</blockquote>
</p>

<br/>

<p align="center">
	<i><b>Supported host platforms (where your editor runs):</b> Windows x64 and Linux x64</i>
	<br/>
	<i>Please <a href="https://github.com/markushevpro/godot-minimize-html-build/issues/new">create an issue</a> if you need support for other operating systems.</i>
</p>

## Recent updates
- 🐧 **Linux support added!** Now works on Linux x64 platforms
- All PCK and WASM files in export folder now compressing automatically
- Fixes & vendor udpates

<br />

<p align="center">
	<img alt="Godot 4.3+" src="https://img.shields.io/badge/Godot-4.3+-blue" />
	<img alt="GitHub License" src="https://img.shields.io/github/license/markushevpro/godot-minimize-html-build" />
	<img alt="GitHub commit activity" src="https://img.shields.io/github/commit-activity/t/markushevpro/godot-minimize-html-build" />
</p>

## How it works
The add-on resaves large files (.pck, .wasm) with gzip compression, minifies core files (.js and .html) and adds the ability to load gzip-compressed assets in the browser using [pako](https://github.com/nodeca/pako). Nothing else will be changed in your files.

## Usage
1. Install the addon from [AssetLib](https://godotengine.org/asset-library/asset/3862) or from source (copy `addons` folder to your project directory)
2. Enable the plugin in your Project Settings.
3. Export your project to Web.

## Detailed explanation

### Step-by-step algorythm
1. Godot creates release files.
2. The addon copies additional and temporary files to the build directory (pako.js, compressor, minifier)
3. Using a [tool written in Go](#why-golang-compresser) (see `/vendor/bin/compress/src` in the plugin directory), the **.pck** and **.wasm** files are converted to a gzip enconding
4. Using [minify by tdewolff](https://github.com/tdewolff/minify), the core **.html** and **.js** files are minified. 
5. Using some crappy code, parts of the core JS and HTML files are slightly adapted to support the use of pako.
6. The directory is cleared of temporary files (compressor, minifier).

### Why Golang compresser?
It was painful to implement the encoder directly in Godot because of the "original" implementation of Gzip conversion. You can create a PR if you are brave enough to implement it.

### Is it necessary to minify?
Nope, it does save a bit of size compared to gzip, but it makes js easier to update.

## FAQ

### Custom templates support
Honestly, it hasn't been tested. But you can try. If it doesn't work, feel free to [create an issue](https://github.com/markushevpro/godot-minimize-html-build/issues/new).

### Why Godot 4.0 - 4.2 aren't supported?
Because Godot had a broken web build until version 4.3. Actually, the addon works and compresses files on older versions, but the web build still doesn't work, so I don't recommend using it.

### What about Godot 3.x?
There are no plans at the moment.

<br/>
<hr />
<br/>

## 🙏 Acknowledgments

<p align="center">
    🐧 Linux support added by the community with ❤️
</p>

<br/>

[@aturbidflow](https://t.me/aturbidflow) – Telegram
