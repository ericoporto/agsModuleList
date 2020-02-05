# agsModuleList
[A list of AGS modules with search](https://ericoporto.github.io/agsModuleList/) - still a sketch

[![Build Status](https://dev.azure.com/ericoporto/agsget/_apis/build/status/ericoporto.agsModuleList?branchName=master)](https://dev.azure.com/ericoporto/agsget/_build/latest?definitionId=14&branchName=master)

[AgsGet Releases](https://github.com/ericoporto/agsModuleList/releases) | [AgsGet Help Manual](https://github.com/ericoporto/agsModuleList/blob/master/agsget/README.md) | [AGS Forum Post](https://www.adventuregamestudio.co.uk/forums/index.php?topic=57763.0)

[![](https://user-images.githubusercontent.com/2244442/73703045-7695f300-46cd-11ea-871b-f44adedf0fa4.gif)](https://streamable.com/bmi9k)

## Information

👷IN CONSTRUCTION👷

You can query by typing in the box or url.

Ex: 

    https://ericoporto.github.io/agsModuleList/?q=author:eri0o
    https://ericoporto.github.io/agsModuleList/?q=speech

The list right now is a single file: [`index/package_index.json`](index/package_index.json)

This is a simplified package system for Adventure Game Studio, inspired by early versions of the C++ package manager `vcpkg`. For now it only support script modules.

The way it works, is it provides a website to browse for packages, pkgs can be added directly or through pull requests from the package developer, a command line tool ([**`agsget`**](https://github.com/ericoporto/agsModuleList/tree/master/agsget)) is provided too for browsing and downloading packages. An Editor Plug-in is planned too. 

## How to include a package

Create a directory under `pkgs/` with the package name using only lowercase alphanumeric characters, no spaces or other characters. A package name can't start with numbers. This will also be the package `id`. Inside the directory, place only the minimum files required to ship your package. For now, only script modules with `.scm` extension are allowed.

After placing the package there, write down the `package.json` file for that package. The following fields are possible, only include the ones needed. At a minimum, a package needs an id, a name, a text with the package description, it's version, it's author and the forum page where it was released.

## Updating the index for website and tools

After including or modifying a package, you need to update the website and tools to include the new packages, this requires having node JS installed, and scripts are provided to help with this task.

Go to the scripts directory, and run on cmd.exe or bash:
```
node pkgDirectoriesToIndex.js
node buildSearchableIndex.js
```

This will update the index json under. Copy the contents of this file and change the `agsmodules.js` under `__js` to be in sync.

Commit this changes and reload the website or update the index if using the command line tool.

## Mass edit of package.json

When developing and experimenting, one may decide to modify the fields available in package.json, for now this can be accomplished by modifying the index directly after having it updated.

Edit `index/package_index.json` with your preferred json editor (I use Oxygen XML Editor, despite it's name, it provides a capable json editor). Make sure the index is in sync with the packages json before editing.

After you are done editing, use the script `indexToPkgsDirectories.js` to update the individual package.json files.

## Root Files and directory description

```
__css/      // webpage style
__js/       // webpage js->lunr, pk index
agsget/     // tool and plugin to get pkg
index/      // the package index       
pkgs        // all packages we have
scripts     // utility scripts
.gitignore  // 
.nojekyll   // required for GitHub Pages
LICENSE     // our license
README.md   // this readme
azure-pipelines.yml  // the ci for agsget
index.html  // website home page
```

## AgsGet Editor Plug-in and how it works

For information on how to install, see the [AGS Manual on how to install plug-ins](https://adventuregamestudio.github.io/ags-manual/Plugins.html#plugins).

AgsGet may create the following files in your game directory.

```
├── ags_packages_cache/
│   ├── package_index
│   ├── pkg1/
│   │   └── pkg1.scm
│   └── pkg2/
│       └── pkg2.scm
│   ...
│
├── agsget-lock.json
├── agsget-lock.json.removal
└── agsget-manifest.json
```

Let's see the steps involved in installing a package:

1. At first, when loading AgsGet, if no `package_index` is found, it will create the ags_packages_cache directory, and place it inside the package_index file, which is obtained directly from here: https://ericoporto.github.io/agsModuleList/index/package_index.json .
2. Whenever you install a package, AgsGet reads the `agsget-manifest.json` to figure out which packages are already installed and recreates it including the new package.
3. If there's any `agsget-lock.json.removal`, it's deleted, and if there's any `agsget-lock.json`, it's renamed to `agsget-lock.json.removal`.
4. Then, it reads this generated `agsget-manifest.json` and the `package_index` to figure out if the packages have any dependencies, and order them correctly, using topological sorting, writing the resulting list in `agsget-lock.json`.
5. It then removes and deletes any script and headers in the project with the same name as a package in the `agsget-lock.json`.
6. It then will download from `https://ericoporto.github.io/agsModuleList` any package not on cache that it's listed in the `agsget-lock.json`.
7. Finally, all packages listed in `agsget-lock.json` gets imported in the Game.agf project and shows in the editor.



## Troubleshooting

### I downloaded the plugin but AGS Crashed when loading.

![](https://user-images.githubusercontent.com/2244442/73697349-3be48880-46d6-11ea-8a54-f934ba4629d5.png)

First, make sure the plugin is unblocked, right click on it, and select Unblock, like in the picture above, then click OK.

## challenges and notes

Here are some challenges I am a bit unsure how to fix:

- agsget needs AGS.Types to be able to insert packages, remove and modify the Game.agf project file, in a consistent maner, but it unfortunately depends of the graphical and Windows exclusive parts of the AGS Editor.

- an agsget Editor plug-in could be made to enable the feature above, for now agsget has been reasonably decoupled from it's command line interface, and a core part. The implementation is naive.

- the editor plug-in has one non-trivial part, loading plugins in the Editor requires the Editor being closed. If we want to also support downloading packages that include/are plug-ins (Engine or Editor ones), we need to write into AGS Editor installation directory, which may be tricky in Windows, needing for instance to unload and reload plug-ins that are in use by the Editor.
