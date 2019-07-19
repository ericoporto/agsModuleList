using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    class ApplyCommand : Command
    {
        public static int Run(ApplyOptions ApplyOptions)
        {
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
