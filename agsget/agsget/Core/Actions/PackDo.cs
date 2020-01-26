using System;

namespace AgsGetCore.Actions
{
    public class PackDo
    {
        public static int Do(Action<string> writerMethod, string changeRunDir, string pairName)
        {
            writerMethod("NOT IMPLEMENTED YET");
            writerMethod(string.Format("Create Package: '{0}'", pairName));

            if (string.IsNullOrEmpty(pairName) == true)
            {
                writerMethod("No Script Pair Name Specified, will do nothing.");
                return 1;
            }

            writerMethod("-");
            return 0;
        }
    }
}
