using System;

namespace AgsGetCore.Actions
{
    public class ApplyDo
    {
        public static async System.Threading.Tasks.Task<int> DoAsync(Action<string> writerMethod, string changeRunDir, string packageName)
        {
            BaseFiles.SetRunDirectory(changeRunDir);

            //1. If no PACKAGE_NAME is provided, exit with error.
            // maybe the required keyword protects and we don't need this
            if (string.IsNullOrEmpty(packageName) == true)
            {
                writerMethod("No Package Specified, will do nothing.");
                return 1;
            }

            //2. Check if the command is run from a folder containing a valid Game.agf project.  If not, exit with error.
            if (!GameAgfIO.Valid())
            {
                writerMethod("Not an AGS Game root directory.");
                writerMethod("You can only get packages for an AGS Game project.");
                return 1;
            }

            //3. Check if AGS Editor is open by looking for a lockfile in the folder, if it is, exit with error.
            if (GameAgfIO.IsProjectOpenOnAGSEditor())
            {
                writerMethod("AGS Editor is open on project file.");
                writerMethod("Close AGS Editor, and try again.");
                return 1;
            }

            //4. Check if a package index exists on `./ ags_packages_cache / package_index`, 
            // if not, it runs the functionality from `agsget update`.
            if(!BaseFiles.ExistsIndexFile())
            {
                //Update.2.If it is, creates a folder `./ ags_packages_cache /` on the directory if it doesn't exist.
                BaseFiles.CreatePackageDirIfDoesntExist();

                //Update.3.Downloads the index of packages to `./ ags_packages_cache / package_index`.
                //If it already exists, overwrites it.
                await PackageCacheIO.GetPackageIndexAsync(writerMethod, null);
            }

            //5. Check if PACKAGE_NAME exists on `./ ags_packages_cache / PACKAGE_NAME`, 
            // if not, exit with error Download PACKAGE_NAME to `./ ags_packages_cache / PACKAGE_NAME`.
            //6.If download doesn't complete, exit with error.
            if (!PackageCacheIO.IsPackageOnLocalCache(packageName))
            {
                //Get.4. Check if PACKAGE_NAME exists on `./ ags_packages_cache / package_index`, if not, exit with error.
                if (!PackageCacheIO.PackageOnIndex(packageName))
                {
                    writerMethod(string.Format("Package {0} not found on package index.", packageName));
                    writerMethod("If you are sure you spelled correctly, try updating your local package index.");
                    return 1;
                }

                //Get.5. Download PACKAGE_NAME to `./ags_packages_cache/PACKAGE_NAME`.
                if (!await PackageCacheIO.GetPackageAsync(
                    writerMethod,
                    Configuration.PackageIndexURL,
                    packageName))
                {
                    writerMethod(string.Format("Error downloading package {0}.", packageName));
                    return 1;
                }
            }


            //7.Check if a script pair with the same name already exists on Game.agf, 
            // if there is, ask about update, if the answer is no, exit with error.
            if (GameAgfIO.IsScriptPairInserted(packageName))
            {
                Console.WriteLine("Script already found on Game.agf.");

                //TODO: This question must be console on console or a callback to an yes/no GUI, need to figure out how
                if (!ConsoleExtra.ConfirmYN("Are you sure you want to replace?"))
                {
                    writerMethod("Package already inserted and will not be replaced.");
                    return 1;
                }
            }

            //8.Check if script pairs with the same name of dependencies already exists on Game.agf,
            // and if they are above insert position, if they are not, exit with error.

            //9.If dependencies are already the in Game.agf, ask the user if he
            //wants to proceed, if not, exit with error.

            //10.Insert or replace the script and dependencies in Game.agf, and
            // copy(or overwrite) script pairs in the project folder.


            writerMethod("NOT IMPLEMENTED YET");
            writerMethod(string.Format("Install Package: '{0}'", packageName));

            if (string.IsNullOrEmpty(packageName) == true)
            {
                writerMethod("No Package Specified, will do nothing.");
                return 1;
            }

            writerMethod("");
            return 0;
        }
    }
}
