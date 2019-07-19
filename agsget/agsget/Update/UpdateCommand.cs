using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    class UpdateCommand : Command
    {
        public static int Run(UpdateOptions UpdateOptions)
        {
            //1. Checks if the command is run from a folder containing a valid Game.agf project. 
            if (!GameAgfIO.Valid())
            {
                Console.WriteLine("Not an AGS Game root directory.");
                Console.WriteLine("You can only update agsget package cache for an AGS Game project.");
                return 1;
            }

            //2.If it is, creates a folder `./ ags_packages_cache /` on the directory if it doesn't exist.
            BaseFiles.createPackageDirIfDoesntExist();

            //3.Downloads the index of packages to `./ ags_packages_cache / package_index`.
            //If it already exists, overwrites it.

            Console.WriteLine("NOT IMPLEMENTED YET");
            Console.WriteLine("Looked Directory URL: '{0}'", UpdateOptions.PackageIndexURL);

            if (string.IsNullOrEmpty(UpdateOptions.PackageIndexURL) == true)
            {
                Console.WriteLine("No Directory Specified, will update from Default Module Index.");
                return 0;
            }

            Console.WriteLine();
            return 0;
        }
    }
}
