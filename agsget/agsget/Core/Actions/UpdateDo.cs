using System;

namespace agsget
{
    public class UpdateDo
    {
        // If an INDEX_URL is provided, use the provided url for download operations. 
        // Otherwise, use default package index url.
        // I think maybe the url should be moved 
        //to a general option available for all commands, but not sure yet
        public static int Do(Action<string> writerMethod, string changeRunDir, string packageIndexURL)
        {
            BaseFiles.SetRunDirectory(changeRunDir);
            //1. Checks if the command is run from a folder containing a valid Game.agf project. 
            if (!GameAgfIO.Valid())
            {
                writerMethod("Not an AGS Game root directory.");
                writerMethod("You can only update agsget package cache for an AGS Game project.");
                return 1;
            }

            //2.If it is, creates a folder `./ ags_packages_cache /` on the directory if it doesn't exist.
            BaseFiles.CreatePackageDirIfDoesntExist();

            //3.Downloads the index of packages to `./ ags_packages_cache / package_index`.
            //If it already exists, overwrites it.
            PackageCacheIO.GetPackageIndex(packageIndexURL);

            writerMethod("Success.");
            return 0;
        }
    }
}
