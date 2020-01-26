using System;
using System.Collections.Generic;
using System.Text;

namespace agsget
{
    
    class ApplyCommand : Command
    {
        // Inserts a package from package cache into an AGS Game Project. If package not in cache, downloads it.
        public static int Run(ApplyOptions ApplyOptions)
        {
            if (ApplyOptions == null)
            {
                throw new ArgumentNullException(nameof(ApplyOptions));
            }

            return  AgsGetCore.AgsGetCore.Apply(Console.WriteLine, ApplyOptions.changeRunDir, ApplyOptions.PackageName);
        }
    }
}
