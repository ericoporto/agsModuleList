using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace AgsGetCore
{
    // This class should be the interface when interacting with the package cache
    // some commands are distributed on BaseFiles, maybe they need to be here and not there?
    public class PackageCacheIO
    {
        public static void GetPackageIndex(Action<string> writerMethod, string packageIndexUrl)
        {
            if (string.IsNullOrEmpty(packageIndexUrl))
            {
                DownloadPretty.File(writerMethod, Configuration.PackageIndexURL + "index/package_index.json", BaseFiles.GetIndexFilePath());
            }
            else
            {
                DownloadPretty.File(writerMethod, packageIndexUrl + "index/package_index.json", BaseFiles.GetIndexFilePath());
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

        public static bool IsPackageOnLocalCache(string packageName)
        {
            var packageDirPath = Path.Combine(BaseFiles.GetCacheDirectoryPath(), packageName);

            // because it's only scm script modules, I know this answer.
            // later on, I will need extra information to resolve this.
            var scriptModuleFile = Path.Combine(packageDirPath, packageName + ".scm");
                       
            return File.Exists(scriptModuleFile);
        }

        public static bool GetPackage(Action<string> writerMethod, string packageIndexUrl, string packageName)
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

            if (!DownloadPretty.File(writerMethod,
                packageIndexUrl + "pkgs/" + packageName + "/" + packageName + ".scm",
                destinationFile))
            {
                return false;
            }

            return true;
        }

        public static int PackagesCount()
        {
            var packageIndexAsString = File.ReadAllText(BaseFiles.GetIndexFilePath());

            // I need to iterate through the array until I find a package with the id that I need.
            var packageList = JsonConvert.DeserializeObject<List<Package>>(packageIndexAsString);

            return packageList.Count;
        }

        public static List<Package> PackagesPage(int pageNumber, int pageSize)
        {
            if (pageSize < 0 || pageNumber < 0) return new List<Package>();

            var packageIndexAsString = File.ReadAllText(BaseFiles.GetIndexFilePath());

            // I need to iterate through the array until I find a package with the id that I need.
            var packageList = JsonConvert.DeserializeObject<List<Package>>(packageIndexAsString);

            if (pageSize == 0 || pageSize > packageList.Count) return packageList;
            if ((pageNumber+1) * pageSize > packageList.Count + pageSize) return new List<Package>();

            int clampedPageSize = pageSize;
            if ((pageNumber + 1) * pageSize > packageList.Count)
            {
                clampedPageSize = packageList.Count - pageNumber * pageSize;
            }

            return packageList.GetRange(pageNumber * pageSize, clampedPageSize);
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
