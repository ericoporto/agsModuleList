using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using Newtonsoft.Json.Linq;

namespace agsget
{
    public class PackageCacheIO
    {
        public static void GetPackageIndex(string packageIndexUrl)
        {
            if (string.IsNullOrEmpty(packageIndexUrl))
            {
                DownloadPretty.File(Configuration.PackageIndexURL, BaseFiles.GetIndexFilePath());
            }
            else
            {
                DownloadPretty.File(packageIndexUrl, BaseFiles.GetIndexFilePath());
            }
        }

        public static bool PackageOnIndex(string packageName)
        {
            var packageIndexAsString = File.ReadAllText(BaseFiles.GetIndexFilePath());
            JToken token = JObject.Parse(packageIndexAsString);

            // I need to iterate through the array until I find a package with the id that I need.
            // I am not doing this yet
            string id = (string)token.SelectToken("id");

            if (id.Equals(packageName))
            {
                return true;
            }

            return false;
        }
    }
}
