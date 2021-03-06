using System;

namespace AgsGetCore.Actions
{
    public class ListDo
    {
        public static Package[] Do(Action<string> writerMethod, string changeRunDir, int pageSize, int pageNumber)
        {
            BaseFiles.SetRunDirectory(changeRunDir);

            //1. Check if the command is run from a folder containing a valid Game.agf project.  If not, exit with error. 
            if (!GameAgfIO.Valid())
            {
                writerMethod("Not an AGS Game root directory.");
                writerMethod("You can only get packages for an AGS Game project.");
                return new Package[0];
            }

            //2. Check if a package index exists on `./ags_packages_cache/package_index`, if not, it runs the functionality from `agsget update`.
            if (!BaseFiles.ExistsIndexFile())
            {
                //Update.2.If it is, creates a folder `./ ags_packages_cache /` on the directory if it doesn't exist.
                BaseFiles.CreatePackageDirIfDoesntExist();

                //Update.3.Downloads the index of packages to `./ ags_packages_cache / package_index`.
                //If it already exists, overwrites it.
                PackageCacheIO.GetPackageIndex(writerMethod, null);
            }

            if (!BaseFiles.ExistsIndexFile())
            {
                return new Package[0];
            }

            return PackageCacheIO.PackagesPage(pageNumber, pageSize);
        }
    }
}
