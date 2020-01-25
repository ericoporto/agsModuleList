using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    class UpdateCommand : Command
    {
        // If an INDEX_URL is provided, use the provided url for download operations. 
        // Otherwise, use default package index url.
        // I think maybe the url should be moved 
        //to a general option available for all commands, but not sure yet
        public static int Run(UpdateOptions UpdateOptions)
        {
            return UpdateDo.Do(Console.WriteLine, UpdateOptions.changeRunDir, UpdateOptions.PackageIndexURL);
        }
    }
}
