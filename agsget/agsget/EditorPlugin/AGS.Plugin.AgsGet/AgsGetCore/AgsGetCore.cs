using System;
using System.Collections.Generic;
using System.Text;

using AgsGetCore.Actions;
namespace AgsGetCore
{
    class AgsGetCore
    {
        public static int Apply(Action<string> writerMethod, string changeRunDir, string packageName)
        {

            return ApplyDo.Do(writerMethod, changeRunDir, packageName);
        }

        public static int Get(Action<string> writerMethod, string changeRunDir, string packageName)
        {
            return GetDo.Do(writerMethod, changeRunDir, packageName);
        }

        public static int Pack(Action<string> writerMethod, string changeRunDir, string pairName)
        {
            return PackDo.Do(writerMethod, changeRunDir, pairName);
        }

        public static int Search(Action<string> writerMethod, string changeRunDir, string searchQuery)
        {
            return SearchDo.Do(writerMethod, changeRunDir, searchQuery);
        }

        public static int Update(Action<string> writerMethod, string changeRunDir, string packageIndexURL)
        {
            return UpdateDo.Do(writerMethod, changeRunDir, packageIndexURL);
        }

        public static List<Package> ListAll(Action<string> writerMethod, string changeRunDir, string packageIndexURL)
        {
            return ListDo.Do(writerMethod, changeRunDir, packageIndexURL, 0, 0);
        }
    }
}
