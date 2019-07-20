using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    class GetCommand : Command
    {
        public static int Run(GetOptions GetOptions)
        {
            BaseFiles.SetRunDirectory(GetOptions.changeRunDir);

            //1. If no PACKAGE_NAME is provided, exit with error.
            // maybe the required keyword protects and we don't need this
            if (string.IsNullOrEmpty(GetOptions.PackageName) == true)
            {
                Console.WriteLine("No Package Specified, will do nothing.");
                return 1;
            }

            //2. Check if the command is run from a folder containing a valid Game.agf project.  If not, exit with error. 
            if (!GameAgfIO.Valid())
            {
                Console.WriteLine("Not an AGS Game root directory.");
                Console.WriteLine("You can only get packages for an AGS Game project.");
                return 1;
            }

            //3. Check if a package index exists on `./ags_packages_cache/package_index`, if not, it runs the functionality from `agsget update`.
            if(!BaseFiles.ExistsIndexFile())
            {
                //Update.2.If it is, creates a folder `./ ags_packages_cache /` on the directory if it doesn't exist.
                BaseFiles.CreatePackageDirIfDoesntExist();

                //Update.3.Downloads the index of packages to `./ ags_packages_cache / package_index`.
                //If it already exists, overwrites it.
                PackageCacheIO.GetPackageIndex(null);
            }

            //4.Check if PACKAGE_NAME exists on `./ ags_packages_cache / package_index`, if not, exit with error.
            if (!PackageCacheIO.PackageOnIndex(GetOptions.PackageName))
            {
                Console.WriteLine("Package {0} not found on package index.", GetOptions.PackageName);
                Console.WriteLine("If you are sure you spelled correctly, try updating your local package index.");
                return 1;
            }

            //5. Download PACKAGE_NAME to `./ags_packages_cache/PACKAGE_NAME`.
            if(!PackageCacheIO.GetPackage(
                Configuration.PackageIndexURL,
                GetOptions.PackageName))
            {
                Console.WriteLine("Error downloading package {0}.", GetOptions.PackageName);
                return 1;
            }

            return 0;
        }
    }
}
