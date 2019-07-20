using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    class ApplyCommand : Command
    {
        public static int Run(ApplyOptions ApplyOptions)
        {
            BaseFiles.SetRunDirectory(ApplyOptions.changeRunDir);

            if (GameAgfIO.IsScriptPairInserted(ApplyOptions.PackageName))
            {
                Console.WriteLine("Script already found on Game.agf.");
            }

            Console.WriteLine("NOT IMPLEMENTED YET");
            Console.WriteLine("Install Package: '{0}'", ApplyOptions.PackageName);

            if (string.IsNullOrEmpty(ApplyOptions.PackageName) == true)
            {
                Console.WriteLine("No Package Specified, will do nothing.");
                return 1;
            }

            Console.WriteLine();
            return 0;
        }
    }
}
