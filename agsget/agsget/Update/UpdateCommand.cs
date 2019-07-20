using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    class UpdateCommand : Command
    {
        public static int Run(UpdateOptions UpdateOptions)
        {
            BaseFiles.SetRunDirectory(UpdateOptions.changeRunDir);
            //1. Checks if the command is run from a folder containing a valid Game.agf project. 
            if (!GameAgfIO.Valid())
            {
                Console.WriteLine("Not an AGS Game root directory.");
                Console.WriteLine("You can only update agsget package cache for an AGS Game project.");
                return 1;
            }

            //2.If it is, creates a folder `./ ags_packages_cache /` on the directory if it doesn't exist.
            BaseFiles.CreatePackageDirIfDoesntExist();

            //3.Downloads the index of packages to `./ ags_packages_cache / package_index`.
            //If it already exists, overwrites it.
            PackageCacheIO.GetPackageIndex(UpdateOptions.PackageIndexURL);

            Console.WriteLine("Success.");
            return 0;
        }
    }
}
