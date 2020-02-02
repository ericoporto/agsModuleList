using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

// The PackageLocker is meant to produce a lock file using the manifest and package index as inputs
// It's function is to analyze dependencies and write the lock file
// The lock file is the complete list of packages to install, including dependencies, and install order.

// note: We still don't have versions, so for now we will write them only for registering.
// once we do have versions, this step will fail if two packages depend on different versions of the same package.

namespace AgsGetCore
{
    class MinimalPackageWithDependencies
    {
        public string id_and_version { get; private set; }
        public List<string> Dependencies { get; private set; }

        public MinimalPackageWithDependencies(MinimalPackageDescriptor _mpd, List<MinimalPackageDescriptor> dependencies)
        {
            id_and_version = _mpd.id + "#" + _mpd.version;
            Dependencies = dependencies.Select(p => p.id + "#" + p.version).ToList();
        }
        public MinimalPackageWithDependencies(string _id, string _version, List<string> dependencies)
        {
            id_and_version = _id + "#" + _version;
            Dependencies = dependencies;
        }

        public MinimalPackageWithDependencies(string _id_and_version, List<string> dependencies)
        {
            id_and_version = _id_and_version;
            Dependencies = dependencies;
        }

        private static void Visit(
            MinimalPackageWithDependencies item,
            HashSet<string> visited,
            List<MinimalPackageWithDependencies> sorted,
            Func<MinimalPackageWithDependencies, IEnumerable<string>> dependencies,
            bool throwOnCycle)
        {
            if (!visited.Contains(item.id_and_version))
            {
                visited.Add(item.id_and_version);

                if (dependencies(item) != null)
                {
                    foreach (var dep in dependencies(item))
                        Visit(new MinimalPackageWithDependencies(dep, null), visited, sorted, dependencies, throwOnCycle);
                }

                sorted.Add(item);
            }
            else
            {
                if (throwOnCycle && !sorted.Contains(item))
                    throw new Exception("Cyclic dependency found");
            }
        }
        public static IEnumerable<MinimalPackageWithDependencies> Sort(
            IEnumerable<MinimalPackageWithDependencies> source,
            Func<MinimalPackageWithDependencies,
            IEnumerable<string>> dependencies,
            bool throwOnCycle = false)
        {
            var sorted = new List<MinimalPackageWithDependencies>();
            var visited = new HashSet<string>();

            foreach (var item in source)
                Visit(item, visited, sorted, dependencies, throwOnCycle);

            return sorted;
        }
    }

    class PackageLocker
    {
        private const string LockFile = "agsget-lock.json";

        public static string GetLockFilePath(string changeRunDir)
        {
            BaseFiles.SetRunDirectory(changeRunDir);
            return Path.Combine(BaseFiles.GetRunDirectory(), LockFile);
        }
        public static string GetLockFilePath()
        {
            return Path.Combine(BaseFiles.GetRunDirectory(), LockFile);
        }

        public static bool LockFileExists()
        {
            return File.Exists(GetLockFilePath());
        }

        private static void WriteToLock(string contents)
        {
            System.IO.File.WriteAllText(GetLockFilePath(), contents);
        }

        private static List<MinimalPackageDescriptor> PackageWithDependenciesToMPD(List<MinimalPackageWithDependencies> mpwd)
        {
            return mpwd.Select(p => new MinimalPackageDescriptor
            {
                id = p.id_and_version.Split('#')[0],
                version = p.id_and_version.Split('#')[1]
            }).ToList();
        }

        private static List<MinimalPackageWithDependencies> GetPackagesWithDependencies(
            List<MinimalPackageDescriptor> packagesToInstall,
            List<Package> index)
        {
            List<MinimalPackageWithDependencies> packagesWithDependencies = new List<MinimalPackageWithDependencies>();

            foreach (MinimalPackageDescriptor package in packagesToInstall)
            {
                List<MinimalPackageDescriptor> package_dependency = index.Where(p =>
                {
                    return p.id == package.id && p.depends != null;
                }).Select(p => new MinimalPackageDescriptor
                {
                    id = p.depends
                }).ToList();

                packagesWithDependencies.Add(
                    new MinimalPackageWithDependencies(
                        package, package_dependency));
            }

            return packagesWithDependencies;
        }

        private static List<MinimalPackageDescriptor> FlatOrderedDependencies(
            List<MinimalPackageWithDependencies> packagesWithDependencies)
        {
            return PackageWithDependenciesToMPD(
                MinimalPackageWithDependencies
                    .Sort(packagesWithDependencies, pd => pd.Dependencies)
                    .ToList());
        }

        private static bool AreAllPackagesOnIndex(List<MinimalPackageDescriptor> packages)
        {
            List<string> packageIDs = packages.Select(p => p.id).ToList();
            return PackageCacheIO.AreAllPackagesOnIndex(packageIDs);
        }

        public static bool Lock()
        {
            if (!BaseFiles.ExistsIndexFile())
            {
                // we don't even have an index, we need one before adding packages for installation
                return false;
            }

            if (!IntentDescriptor.ManifestExists())
            {
                // we don't have a manifest file to follow, nothing to do here
                return false;
            }

            var manifest = IntentDescriptor.GetManifestAsList();

            if (!AreAllPackagesOnIndex(manifest))
            {
                // if not all packages are on the index, our dependency graph generation will fail
                // note: we will skip checking if the index itself is sane here - has all dependencies it can point to.
                return false;
            }

            if (manifest.Count() <= 0)
            {
                // our manifest is empty, we generate a empty lock
                WriteToLock("[]\r\n");
                return true;
            }

            var desiredPackagesToInstall = IntentDescriptor.GetManifestAsList();
            var packageIndex = PackageCacheIO.AllPackages();

            var packagesWithDependencies = GetPackagesWithDependencies(
                desiredPackagesToInstall,
                packageIndex);

            var sortedPackages = FlatOrderedDependencies(packagesWithDependencies);



            WriteToLock(SerializerExtra.ObjectToJSON(sortedPackages));

            return true;
        }

        public static List<MinimalPackageDescriptor> GetLockFileAsList()
        {
            if (!LockFileExists())
            {
                return new List<MinimalPackageDescriptor>();
            }

            var lockFileAsString = File.ReadAllText(GetLockFilePath());

            return JsonConvert.DeserializeObject<List<MinimalPackageDescriptor>>(lockFileAsString);
        }
    }
}
