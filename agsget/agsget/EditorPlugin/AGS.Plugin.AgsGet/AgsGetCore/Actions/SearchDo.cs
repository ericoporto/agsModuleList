using System;
using System.Collections.Generic;

namespace AgsGetCore.Actions
{
    public class SearchDo
    {
        public static async System.Threading.Tasks.Task<List<Package>> DoAsync(Action<string> writerMethod, string changeRunDir, string searchQuery)
        {
            // we need a way to show report messages, if we can't, we return an error
            if (writerMethod == null) throw new ArgumentNullException(nameof(writerMethod), "was null");

            // Update the directory to run AgsGet
            BaseFiles.SetRunDirectory(changeRunDir);

            //1. Check if the command is run from a folder containing a valid Game.agf project.  If not, exit with error. 
            if (!GameAgfIO.Valid())
            {
                writerMethod("Not an AGS Game root directory.");
                writerMethod("You can only search packages on an AGS Game project.");
                return null;
            }

            //2. Search Query can't be empty
            if (string.IsNullOrEmpty(searchQuery) == true)
            {
                writerMethod("No query to use for search.");
                return null;
            }

            if(searchQuery.Length < 3)
            {
                writerMethod("Your query has to be at least 3 characters long.");
                return null;
            }

            writerMethod(string.Format("You searched for: '{0}'...", searchQuery));

            //3. Check if a package index exists on `./ags_packages_cache/package_index`, if not, it runs the functionality from `agsget update`.
            if (!BaseFiles.ExistsIndexFile())
            {
                writerMethod("No package index found, we are going to download one.");

                //Search.2.If it is, creates a folder `./ ags_packages_cache /` on the directory if it doesn't exist.
                BaseFiles.CreatePackageDirIfDoesntExist();

                //Search.3.Downloads the index of packages to `./ ags_packages_cache / package_index`.
                //If it already exists, overwrites it.
                await PackageCacheIO.GetPackageIndexAsync(writerMethod, null);
            }

            if (!BaseFiles.ExistsIndexFile())
            {
                writerMethod("No package index found, it's possible a download failed due to connection error.");
                return null;
            }


            var searchResults = PackageCacheIO.QueryPackages(searchQuery);

            if(searchResults.Count == 1) writerMethod(string.Format("Found {0} result.", searchResults.Count));
            else writerMethod(string.Format("Found {0} results.", searchResults.Count));

            string resultsAsString = "";

            searchResults.ForEach(p => resultsAsString += " " + p.id);

            writerMethod(resultsAsString);

            return searchResults;
        }
    }
}
