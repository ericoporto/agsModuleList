# agsget

agsget is a package getter for ags resources.

🚨EXPERIMENTAL CODE DO NOT USE🚨

## roadmap

expected functionality, in no particular order.

- [x] get .scm script modules
- [ ] search an index of script modules
- [ ] inject .scm file to a AGS Game project (Game.agf and script pairs)
- [ ] do the above safely
- [ ] export script pairs (.asc and .ash) to .scm script modules
- [ ] have an AGS Editor plugin for package search, get, and insertion.
  
  **far future roadmap**
  
- [ ] get plugins
- [ ] get other resources (Characters, GUIs, Templates, ...)
  
## technology

agsget is written in C# using dotnet core first, for cross platform and easy to use. An AGS Editor plugin will be provided in the future using .NET.
  
## interface

agsget provides a command line interface for interacting with it.

```$ agsget 
agsget 1.0.0
Copyright (C) 2019 agsget

  update     update package index
  search     search on package index
  get        download a single package to cache
  apply      insert a package in a Game.agf project
  pack       pack a pair .asc and .ash into a .scm package
  help       Display more information on a specific command.
  version    Display version information.
```


### `agsget update [PACKAGE_INDEX_URL]`

```
  packageIndexURL (pos. 0)    URL to get package index from. Gets from default, if empty.
```

If an INDEX_URL is provided, use the provided url for download operations. Otherwise, use default package index url.

1. Checks if the command is run from a folder containing a valid Game.agf project. 
2. If it is, creates a folder `./ags_packages_cache/` on the directory if it doesn't exist.
3. Downloads the index of packages to `./ags_packages_cache/package_index`. If it already exists, overwrites it.


### `agsget get <PACKAGE_NAME>`

```
  packageName (pos. 0)    Required. Package name to download.
```

Downloads a package to package cache.

1. If no PACKAGE_NAME is provided, exit with error.
2. Check if the command is run from a folder containing a valid Game.agf project.  If not, exit with error.
3. Check if a package index exists on `./ags_packages_cache/package_index`, if not, it runs the functionality from `agsget update`.
4. Check if PACKAGE_NAME exists on `./ags_packages_cache/package_index`, if not, exit with error.
5. Download PACKAGE_NAME to `./ags_packages_cache/PACKAGE_NAME`.
6. If download completes, exit with success message.


### `agsget search <SEARCH_QUERY>`

```
  searchQuery (pos. 0)    Required. Query to search the index.
```

Search package index and returns matching packages.

1. If no SEARCH_QUERY is provided, exit with error.
2. Check if the command is run from a folder containing a valid Game.agf project.  If not, exit with error.
3. Check if a package index exists on `./ags_packages_cache/package_index`, if not, it runs the functionality from `agsget update`.
4. Search on the downloaded package index on `./ags_packages_cache/package_index` and print results.


### `agsget apply <PACKAGE_NAME>`

```
  packageName (pos. 0)    Required. Package name to insert in Game.agf project.
```

Inserts a package from package cache into an AGS Game Project. If package not in cache, downloads it.

1. If no PACKAGE_NAME is provided, exit with error.
2. Check if the command is run from a folder containing a valid Game.agf project.  If not, exit with error.
3. Check if AGS Editor is open by looking for a lockfile in the folder, if it is, exit with error.
4. Check if a package index exists on `./ags_packages_cache/package_index`, if not, it runs the functionality from `agsget update`.
5. Check if PACKAGE_NAME exists on `./ags_packages_cache/PACKAGE_NAME`, if not, exit with error Download PACKAGE_NAME to `./ags_packages_cache/PACKAGE_NAME`.
6. If download doesn't complete, exit with error.
7. Check if a script pair with the same name already exists on Game.agf, if there is, ask about update, if the answer is no, exit with error.
8. Check if script pairs with the same name of dependencies already exists on Game.agf, and if they are above insert position, if they are not, exit with error.
9. If dependencies are already the in Game.agf, ask the user if he wants to proceed, if not, exit with error.
10. Insert or replace the script and dependencies in Game.agf, and copy (or overwrite) script pairs in the project folder.


### `agsget pack <PAIR_NAME>`

```
  pairName (pos. 0)    Required. Name used for .asc and .ash filenames.
```

Turn a script pair .asc and .ash file into a scm. In the future, functionality for this command will change.
