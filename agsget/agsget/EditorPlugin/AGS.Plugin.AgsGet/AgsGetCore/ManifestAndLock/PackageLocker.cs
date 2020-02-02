using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AgsGetCore.ManifestAndLock;
using Newtonsoft.Json;

// The PackageLocker is meant to produce a lock file using the manifest and package index as inputs
// It's function is to analyze dependencies and write the lock file
// The lock file is the complete list of packages to install, including dependencies, and install order.

// note: We still don't have versions, so for now we will write them only for registering.
// once we do have versions, this step will fail if two packages depend on different versions of the same package.

namespace AgsGetCore
{
    class MinimalPackageWithDependencies : MinimalPackageDescriptor
    {
        public List<MinimalPackageWithDependencies> Dependencies { get; private set; }

        public MinimalPackageWithDependencies(MinimalPackageDescriptor _mpd, List<MinimalPackageWithDependencies> dependencies)
        {
            id = _mpd.id;
            version = _mpd.version;
            Dependencies = dependencies;
        }
        public MinimalPackageWithDependencies(string _id, string _version, List<MinimalPackageWithDependencies> dependencies)
        {
            id = _id;
            version = _version;
            Dependencies = dependencies;
        }
    }

    class PackageLocker
    {
        private const string LockFile = "agsget-lock.json";

        private static string GetLockFilePath()
        {
            return Path.Combine(BaseFiles.GetRunDirectory(), LockFile);
        }

        private static void WriteToLock(string contents)
        {
            System.IO.File.WriteAllText(GetLockFilePath(), contents);
        }

        private static List<MinimalPackageDescriptor> PackageToMPD(List<Package> packages)
        {
            return packages.Select(p => new MinimalPackageDescriptor { id = p.id, version = p.version }).ToList();
        }

        private static List<MinimalPackageWithDependencies> MPDToPackageWithDependencies(List<MinimalPackageDescriptor> mpwd)
        {
            return mpwd.Select(p => new MinimalPackageWithDependencies(p.id, p.version, null) ).ToList();
        }
        private static List<MinimalPackageDescriptor> PackageWithDependenciesToMPD(List<MinimalPackageWithDependencies> mpwd)
        {
            return mpwd.Select(p => new MinimalPackageDescriptor { id = p.id, version = p.version }).ToList();
        }

        private static List<Package> MPDToPackage(List<MinimalPackageDescriptor> packages)
        {
            return packages.Select(p => new Package { id = p.id, version = p.version }).ToList();
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
                    return p.id == package.id;
                }).Select(p => new MinimalPackageDescriptor
                {
                    id = p.depends
                }).ToList();

                packagesWithDependencies.Add(
                    new MinimalPackageWithDependencies(
                        package, MPDToPackageWithDependencies(package_dependency)));
            }

            return packagesWithDependencies;
        }
        //private static List<KeyValuePair<MinimalPackageDescriptor, List<MinimalPackageDescriptor>>> BuildDependencyGraph(
        //    List<MinimalPackageDescriptor> packagesToInstall,
        //    List<Package> index)
        //{
        //    List < KeyValuePair < MinimalPackageDescriptor, List < MinimalPackageDescriptor >>> dependencyGraph = new List<KeyValuePair<MinimalPackageDescriptor, List<MinimalPackageDescriptor>>>();

        //    foreach (MinimalPackageDescriptor package in packagesToInstall) {
        //        List<MinimalPackageDescriptor> package_dependency = index.Where(p =>
        //        {
        //            return p.id == package.id;
        //        }).Select(p => new MinimalPackageDescriptor
        //        {
        //            id = p.depends
        //        }).ToList();

        //        dependencyGraph.Add(
        //            new KeyValuePair<MinimalPackageDescriptor, List<MinimalPackageDescriptor>>(
        //                package, package_dependency));
        //    }

        //    return dependencyGraph;
        //}

        private static List<MinimalPackageDescriptor> FlatOrderedDependencies(
            List<MinimalPackageWithDependencies> packagesWithDependencies)
        {
            return PackageWithDependenciesToMPD(
                TopologicalSort
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

            if(manifest.Count() <= 0)
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

            WriteToLock(JsonConvert.SerializeObject(sortedPackages));

            return true;
        }
    }
}
