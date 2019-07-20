using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    class GetCommand : Command
    {
        public static int Run(GetOptions GetOptions)
        {
            BaseFiles.SetRunDirectory(GetOptions.changeRunDir);
            Console.WriteLine("Dir set");

            GameAgfIO.IsScriptPairInserted(GetOptions.PackageName);

            Console.WriteLine("NOT IMPLEMENTED YET");
            Console.WriteLine("Get Packaged: '{0}'", GetOptions.PackageName);

            if (string.IsNullOrEmpty(GetOptions.PackageName) == true)
            {
                Console.WriteLine("No Package Specified, will do nothing.");
                return 1;
            }

            Console.WriteLine();
            return 0;
        }
    }
}
