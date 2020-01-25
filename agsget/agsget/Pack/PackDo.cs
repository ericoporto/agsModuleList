using System;

namespace agsget
{
    public class PackDo
    {
        public static int Do(string changeRunDir, string pairName)
        {
            Console.WriteLine("NOT IMPLEMENTED YET");
            Console.WriteLine("Create Package: '{0}'", pairName);

            if (string.IsNullOrEmpty(pairName) == true)
            {
                Console.WriteLine("No Script Pair Name Specified, will do nothing.");
                return 1;
            }

            Console.WriteLine();
            return 0;
        }
    }
}
