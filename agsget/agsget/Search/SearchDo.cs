using System;

namespace agsget
{
    public class SearchDo
    {
        public static int Do(string changeRunDir, string searchQuery)
        {
            Console.WriteLine("NOT IMPLEMENTED YET");
            Console.WriteLine("Search query: '{0}'", searchQuery);

            if (string.IsNullOrEmpty(searchQuery) == true)
            {
                Console.WriteLine("No query to use for search.");
                return 1;
            }

            Console.WriteLine();
            return 0;
        }
    }
}
