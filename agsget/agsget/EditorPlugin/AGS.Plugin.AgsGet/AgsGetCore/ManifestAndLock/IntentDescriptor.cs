using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Newtonsoft.Json;

// this file deals with writing intent as a manifest file
// when we want to add a package, we add it to the list
// when we want to remove a package, we remove it from the list
// we will use this file to store the state of which packages we need to install later on
// in another step we will get these packages, and figure out dependencies and the order to insert!
// in the future we probably want to modify this so we also store versions and go latest when we don't.

namespace AgsGetCore
{
    class IntentDescriptor
    {
        private const string ManifestFile = "agsget-manifest.json";

        public static string GetManifestFilePath(string changeRunDir)
        {
            BaseFiles.SetRunDirectory(changeRunDir);
            return Path.Combine(BaseFiles.GetRunDirectory(), ManifestFile);
        }

        public static string GetManifestFilePath()
        {
            return Path.Combine(BaseFiles.GetRunDirectory(), ManifestFile);
        }
        public static bool ManifestExists()
        {
            return File.Exists(GetManifestFilePath());
        }

        public static List<MinimalPackageDescriptor> GetManifestAsList()
        {
            if (!ManifestExists())
            {
                return new List<MinimalPackageDescriptor>();
            }

            var manifestAsString = File.ReadAllText(GetManifestFilePath());

            return JsonConvert.DeserializeObject<List<MinimalPackageDescriptor>>(manifestAsString);
        }

        public static bool AddPackage(string package_id)
        {
            var manifestList = GetManifestAsList();

            if (!BaseFiles.ExistsIndexFile())
            {
                // we don't even have an index, we need one before adding packages for installation
                return false;
            }

            if (!PackageCacheIO.PackageOnIndex(package_id))
            {
                // the package_id is wrong or our index is wrong
                return false;
            }

            var previouslyAddedPackage = manifestList.Where<MinimalPackageDescriptor>(_mpd =>
            {
                return _mpd.id.Equals(package_id.ToLower());
            });

            if (previouslyAddedPackage.Count() > 0)
            {
                return true;
            }

            var mpd = new MinimalPackageDescriptor();
            mpd.id = package_id;

            manifestList.Add(mpd);

            string resulting_json_manifest = SerializerExtra.ObjectToJSON(manifestList);
            const string bkp_ext = ".bkp";
            string manifest_file = GetManifestFilePath();
            string bkp_manifest_file = manifest_file + bkp_ext;

            if (File.Exists(manifest_file)) File.Move(manifest_file, bkp_manifest_file);
            System.IO.File.WriteAllText(manifest_file, resulting_json_manifest);
            if (File.Exists(bkp_manifest_file)) File.Delete(bkp_manifest_file);

            return true;
        }
        public static bool RemovePackage(string package_id)
        {
            var manifestList = GetManifestAsList();

            var previouslyAddedPackage = manifestList.Where<MinimalPackageDescriptor>(_mpd =>
            {
                return _mpd.id.Equals(package_id.ToLower());
            });

            if (previouslyAddedPackage.Count() == 0)
            {
                return false;
            }

            manifestList = manifestList.Where<MinimalPackageDescriptor>(_mpd =>
            {
                return !_mpd.id.Equals(package_id.ToLower());
            }).ToList();

            string resulting_json_manifest = SerializerExtra.ObjectToJSON(manifestList);
            const string bkp_ext = ".bkp";
            string manifest_file = GetManifestFilePath();
            string bkp_manifest_file = manifest_file + bkp_ext;

            if (File.Exists(manifest_file)) File.Move(manifest_file, bkp_manifest_file);
            System.IO.File.WriteAllText(manifest_file, resulting_json_manifest);
            if (File.Exists(bkp_manifest_file)) File.Delete(bkp_manifest_file);

            return true;
        }
    }
}
