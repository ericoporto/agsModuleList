using System;
using System.Collections.Generic;
using System.Text;

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

        public static bool PackageExists(string packageName)
        {

            return false;
        }
    }
}
