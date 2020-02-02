using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Linq;

namespace AgsGetCore
{
    // This class should be the interface when interacting with the package cache
    // some commands are distributed on BaseFiles, maybe they need to be here and not there?
    public class PackageCacheIO
    {
        public static async System.Threading.Tasks.Task<bool> GetPackageIndexAsync(Action<string> writerMethod, string packageIndexUrl)
        {
            var destinationFile = BaseFiles.GetIndexFilePath();
            bool downloadResult;
            const string bkp_ext = ".bkp";
            string bkp_downloadFile = destinationFile + bkp_ext;

            if (File.Exists(destinationFile)) File.Move(destinationFile, bkp_downloadFile);

            if (string.IsNullOrEmpty(packageIndexUrl))
            {
                downloadResult = await DownloadPretty.FileAsync(writerMethod, Configuration.PackageIndexURL + "index/package_index.json", destinationFile);
            }
            else
            {
                downloadResult = await DownloadPretty.FileAsync(writerMethod, packageIndexUrl + "index/package_index.json", destinationFile);
            }

            // If the download succeeds we delete the backup, if not, we replace it with the backup
            if(!downloadResult)
            {
                if (File.Exists(destinationFile)) File.Delete(destinationFile);
                if (File.Exists(bkp_downloadFile)) File.Move(bkp_downloadFile, destinationFile);
                return false;
            }

            if (File.Exists(bkp_downloadFile)) File.Delete(bkp_downloadFile);
            writerMethod("Index downloaded to:" + destinationFile);
            return true;
        }

        public static bool PackageOnIndex(string packageID)
        {
            var packageIndexAsString = File.ReadAllText(BaseFiles.GetIndexFilePath());

            // I need to iterate through the array until I find a package with the id that I need.
            var packageList = JsonConvert.DeserializeObject<List<Package>>(packageIndexAsString);
                        
            foreach (var pack in packageList)
            {
                if (packageID.Equals(pack.id))
                {
                    return true;
                }
            }
            
            return false;
        }

        public static bool AreAllPackagesOnIndex(List<string> packageIDs)
        {
            var packageIndexAsString = File.ReadAllText(BaseFiles.GetIndexFilePath());

            // I need to iterate through the array until I find a package with the id that I need.
            var packageList = JsonConvert.DeserializeObject<List<Package>>(packageIndexAsString);

            foreach (string _id in packageIDs)
            {
                if (packageList.Where(p => { return p.id == _id; }).Count() <= 0) return false;
            }
            return true;
        }

        public static bool IsPackageOnLocalCache(string packageName)
        {
            var packageDirPath = Path.Combine(BaseFiles.GetCacheDirectoryPath(), packageName);

            // because it's only scm script modules, I know this answer.
            // later on, I will need extra information to resolve this.
            var scriptModuleFile = Path.Combine(packageDirPath, packageName + ".scm");
                       
            return File.Exists(scriptModuleFile);
        }

        public static async System.Threading.Tasks.Task<bool> GetPackageAsync(Action<string> writerMethod, string packageIndexUrl, string packageName)
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
            const string bkp_ext = ".bkp";
            string bkp_downloadFile = destinationFile + bkp_ext;

            if (File.Exists(destinationFile)) File.Move(destinationFile, bkp_downloadFile);

            if (!await DownloadPretty.FileAsync(writerMethod,
                packageIndexUrl + "pkgs/" + packageName + "/" + packageName + ".scm",
                destinationFile))
            {
                if (File.Exists(destinationFile)) File.Delete(destinationFile);
                if (File.Exists(bkp_downloadFile)) File.Move(bkp_downloadFile, destinationFile);
                return false;
            }

            if (File.Exists(bkp_downloadFile)) File.Delete(bkp_downloadFile);
            writerMethod("Package downloaded to:" + destinationFile);

            return true;
        }

        public static int PackagesCount()
        {
            var packageIndexAsString = File.ReadAllText(BaseFiles.GetIndexFilePath());

            // I need to iterate through the array until I find a package with the id that I need.
            var packageList = JsonConvert.DeserializeObject<List<Package>>(packageIndexAsString);

            return packageList.Count;
        }

        public static List<Package> AllPackages()
        {
            var packageIndexAsString = File.ReadAllText(BaseFiles.GetIndexFilePath());

            return JsonConvert.DeserializeObject<List<Package>>(packageIndexAsString);
        }


        public static List<Package> QueryPackages(string searchQuery)
        {
            var packageIndexAsString = File.ReadAllText(BaseFiles.GetIndexFilePath());

            var packageList = JsonConvert.DeserializeObject<List<Package>>(packageIndexAsString);

            var searchResult = packageList.Where<Package>(p => {
                return p.name.Contains(searchQuery) ||
                       p.id.Contains(searchQuery.ToLower()) ||
                       p.author.ToLower().Contains(searchQuery.ToLower()) ||
                       p.text.Contains(searchQuery) ||
                       p.keywords.ToLower().Contains(searchQuery.ToLower());
                });

            return searchResult.ToList();
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
        public string keywords { get; set; }
    }
}
