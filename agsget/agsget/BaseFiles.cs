using System;
using System.Collections.Generic;
using System.Text;
using System.IO;


namespace agsget
{
    public class BaseFiles
    {
        public const string PackageCacheDirectory = "ags_packages_cache";
        public const string PackageIndexFile = "package_index";
        public const string GameAgfFile = "Game.agf";
        private string RunDirectory = Path.GetFullPath(Directory.GetCurrentDirectory());

        public void setRunDirectory(string  rundir)
        {
            if(rundir.Length > 0)
            {
                RunDirectory = rundir;
            }
            else
            {
                RunDirectory = Path.GetFullPath(Directory.GetCurrentDirectory());
            }
        }

        public string getIndexFilePath()
        {
            return Path.Combine(RunDirectory, PackageCacheDirectory, PackageIndexFile);
        }

        public bool existsIndexFile()
        {
            return File.Exists(getIndexFilePath());
        }

        public string getCacheDirectoryPath()
        {
            return Path.Combine(RunDirectory, PackageCacheDirectory);
        }

        public bool existsPackageCacheDirectory()
        {
            return Directory.Exists(getCacheDirectoryPath());
        }

        public string getGameAgfPath()
        {
            return Path.Combine(RunDirectory, GameAgfFile);
        }

        public bool existsGameAgf()
        {
            return File.Exists(getGameAgfPath());
        }




    }
}
