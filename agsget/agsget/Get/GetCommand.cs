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
            //This is solved by the required parameter, so we will skip this.

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



              Console.WriteLine("NOT IMPLEMENTED YET");
            Console.WriteLine("Get Packaged: '{0}'", GetOptions.PackageName);

            if (string.IsNullOrEmpty(GetOptions.PackageName) == true)
            {
                Console.WriteLine("No Package Specified, will do nothing.");
                return 1;
            }

            Console.WriteLine();
            return 0;
        }
    }
}
