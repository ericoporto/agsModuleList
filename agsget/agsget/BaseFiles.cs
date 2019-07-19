using System;
using System.Collections.Generic;
using System.Text;
using System.IO;


namespace agsget
{
    public class BaseFiles
    {
        private static readonly BaseFiles instance = new BaseFiles();
        public const string PackageCacheDirectory = "ags_packages_cache";
        public const string PackageIndexFile = "package_index";
        public const string GameAgfFile = "Game.agf";

        private BaseFiles() {
            setRunDirectory("");
        }

        public static BaseFiles Instance
        {
            get
            {
                return instance;
            }
        }

        private string RunDirectory;



        public static void setRunDirectory(string rundir)
        {
            if (rundir.Length > 0)
            {
                instance.RunDirectory = rundir;
            }
            else
            {
                instance.RunDirectory = Path.GetFullPath(Directory.GetCurrentDirectory());
            }
        }

        public static string getRunDirectory()
        {
            return instance.RunDirectory;
        }

        public static string getIndexFilePath()
        {
            return Path.Combine(getRunDirectory(), PackageCacheDirectory, PackageIndexFile);
        }

        public static bool existsIndexFile()
        {
            return File.Exists(getIndexFilePath());
        }

        public static string getCacheDirectoryPath()
        {
            return Path.Combine(getRunDirectory(), PackageCacheDirectory);
        }

        public static bool existsPackageCacheDirectory()
        {
            return Directory.Exists(getCacheDirectoryPath());
        }

        public static void createPackageDirIfDoesntExist()
        {
            if (!existsPackageCacheDirectory())
            {
                Directory.CreateDirectory(getCacheDirectoryPath());
            }
        }

        public static string getGameAgfPath()
        {
            return Path.Combine(getRunDirectory(), GameAgfFile);
        }

        public static bool existsGameAgf()
        {
            return File.Exists(getGameAgfPath());
        }

    }
}
