using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace agsget
{
    public class PackageCacheIO
    {
        public static void GetPackageIndex(string packageIndexUrl)
        {
            if (string.IsNullOrEmpty(packageIndexUrl))
            {
                DownloadPretty.File(Configuration.PackageIndexURL + "index/package_index.json", BaseFiles.GetIndexFilePath());
            }
            else
            {
                DownloadPretty.File(packageIndexUrl + "index/package_index.json", BaseFiles.GetIndexFilePath());
            }
        }

        public static bool PackageOnIndex(string packageName)
        {
            var packageIndexAsString = File.ReadAllText(BaseFiles.GetIndexFilePath());

            // I need to iterate through the array until I find a package with the id that I need.
            var packageList = JsonConvert.DeserializeObject<List<Package>>(packageIndexAsString);
                        
            foreach (var pack in packageList)
            {
                if (packageName.Equals(pack.id))
                {
                    return true;
                }
            }
            
            return false;
        }

        public static bool GetPackage(string packageIndexUrl, string packageName)
        {
            var packageDirPath = Path.Combine(BaseFiles.GetCacheDirectoryPath(), packageName);

            if (!Directory.Exists(packageDirPath))
            {
                Directory.CreateDirectory(packageDirPath);
            }

            // because it's only scm script modules, I know this answer.
            // later on, the index should contain file information too.
            // This will enable downloading license, readme and extra resources
            // for the package.
            var destinationFile = Path.Combine(packageDirPath, packageName + ".scm");

            if (!DownloadPretty.File(
                packageIndexUrl + "pkgs/" + packageName + "/" + packageName + ".scm",
                destinationFile))
            {
                return false;
            }

            return true;
        }
    }

    public class Package
    {
        public string id { get; set; }
        public string name { get; set; }
        public string text { get; set; }
        public string version { get; set; }
        public string forum { get; set; }
        public string author { get; set; }
        public string depends { get; set; }
    }
}
