using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    class PackCommand : Command
    {
        public static int RunPackCommand(PackOptions PackOptions)
        {
            Console.WriteLine("NOT IMPLEMENTED YET");
            Console.WriteLine("Create Package: '{0}'", PackOptions.PairName);

            if (string.IsNullOrEmpty(PackOptions.PairName) == true)
            {
                Console.WriteLine("No Script Pair Name Specified, will do nothing.");
                return 1;
            }

            Console.WriteLine();
            return 0;
        }
    }
}
