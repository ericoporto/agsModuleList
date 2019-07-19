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
            SetRunDirectory("");
        }

        public static BaseFiles Instance
        {
            get
            {
                return instance;
            }
        }

        private string RunDirectory;



        public static void SetRunDirectory(string rundir)
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

        public static string GetRunDirectory()
        {
            return instance.RunDirectory;
        }

        public static string GetIndexFilePath()
        {
            return Path.Combine(GetRunDirectory(), PackageCacheDirectory, PackageIndexFile);
        }

        public static bool ExistsIndexFile()
        {
            return File.Exists(GetIndexFilePath());
        }

        public static string GetCacheDirectoryPath()
        {
            return Path.Combine(GetRunDirectory(), PackageCacheDirectory);
        }

        public static bool ExistsPackageCacheDirectory()
        {
            return Directory.Exists(GetCacheDirectoryPath());
        }

        public static void CreatePackageDirIfDoesntExist()
        {
            if (!ExistsPackageCacheDirectory())
            {
                Directory.CreateDirectory(GetCacheDirectoryPath());
            }
        }

        public static string GetGameAgfPath()
        {
            return Path.Combine(GetRunDirectory(), GameAgfFile);
        }

        public static bool ExistsGameAgf()
        {
            return File.Exists(GetGameAgfPath());
        }

    }
}
