using System;
using System.Collections.Generic;
using System.Text;

using AgsGetCore.Actions;
namespace AgsGetCore
{
    class AgsGetCore
    {
        public static async System.Threading.Tasks.Task<int> ApplyAsync(Action<string> writerMethod, string changeRunDir, string packageName)
        {

            return await ApplyDo.DoAsync(writerMethod, changeRunDir, packageName);
        }

        public static async System.Threading.Tasks.Task<int> GetAsync(Action<string> writerMethod, string changeRunDir, string packageName)
        {
            return await GetDo.DoAsync(writerMethod, changeRunDir, packageName);
        }

        public static int Pack(Action<string> writerMethod, string changeRunDir, string pairName)
        {
            return PackDo.Do(writerMethod, changeRunDir, pairName);
        }

        public static async System.Threading.Tasks.Task<List<Package>> SearchAsync(Action<string> writerMethod, string changeRunDir, string searchQuery)
        {
            return await SearchDo.DoAsync(writerMethod, changeRunDir, searchQuery);
        }

        public static async System.Threading.Tasks.Task<int> UpdateAsync(Action<string> writerMethod, string changeRunDir, string packageIndexURL)
        {
            return await UpdateDo.DoAsync(writerMethod, changeRunDir, packageIndexURL);
        }

        public static async System.Threading.Tasks.Task<List<Package>> ListAllAsync(Action<string> writerMethod, string changeRunDir, string packageIndexURL)
        {
            return await ListDo.DoAsync(writerMethod, changeRunDir, packageIndexURL, 0, 0);
        }

        public static async System.Threading.Tasks.Task<int> AddPackageAsync(Action<string> writerMethod, string changeRunDir, string packageName)
        {
            return await AddPackageDo.DoAsync(writerMethod, changeRunDir, packageName);
        }

        public static async System.Threading.Tasks.Task<int> RemovePackageAsync(Action<string> writerMethod, string changeRunDir, string packageName)
        {
            return await RemovePackageDo.DoAsync(writerMethod, changeRunDir, packageName);
        }

        public static string GetLockFilePath(string changeRunDir)
        {
            return PackageLocker.GetLockFilePath(changeRunDir);
        }

        public static string GetManifestFilePath(string changeRunDir)
        {
            return IntentDescriptor.GetManifestFilePath(changeRunDir);
        }
    }
}
