using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

// The PackageLocker is meant to produce a lock file using the manifest and package index as inputs
// It's function is to analyze dependencies and write the lock file
// The lock file is the complete list of packages to install, including dependencies, and install order.

// note: We still don't have versions, so for now we will write them only for registering.
// once we do have versions, this step will fail if two packages depend on different versions of the same package.

namespace AgsGetCore
{
    class PackageLocker
    {
        private const string LockFile = "agsget-lock.json";

        private static string GetManifestFilePath()
        {
            return Path.Combine(BaseFiles.GetRunDirectory(), LockFile);
        }

    }
}
