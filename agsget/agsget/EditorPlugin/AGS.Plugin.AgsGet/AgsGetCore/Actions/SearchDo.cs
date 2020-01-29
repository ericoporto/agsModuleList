using System;

namespace AgsGetCore.Actions
{
    public class SearchDo
    {
        public static int Do(Action<string> writerMethod, string changeRunDir, string searchQuery)
        {
            writerMethod("NOT IMPLEMENTED YET");
            writerMethod(string.Format("Search query: '{0}'", searchQuery));

            if (string.IsNullOrEmpty(searchQuery) == true)
            {
                writerMethod("No query to use for search.");
                return 1;
            }

            writerMethod("-" );
            return 0;
        }
    }
}
