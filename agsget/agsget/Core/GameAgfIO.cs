using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Linq;
using System.Xml.Linq;

namespace AgsGetCore
{
    //I think I may need to refactor this for GameProjectIO
    public class GameAgfIO
    {
        public static bool Valid()
        {
            // We need to check if an AGF file is valid. 
            // TEMPORARLY For now, we will just check if it exists.
            return BaseFiles.ExistsGameAgf();
        }

        public static bool IsScriptPairInserted(string scriptPairName)
        {
            // Load Game.agf as XML for reading
            var xmlStr = File.ReadAllText(BaseFiles.GetGameAgfPath());

            var parsedXml = XElement.Parse(xmlStr);
            var scriptHeaderFile = scriptPairName + ".ash";

            var scriptElements = parsedXml.Descendants("Script");
            var result = scriptElements.Where(x => x.
                Element("FileName").
                Value.Equals(scriptHeaderFile));
            
            return result.AsEnumerable().Count() == 1;
        }

        // Looks for lockfile to see if AGS Editor is open on current dir
        public static bool IsProjectOpenOnAGSEditor()
        {
            return File.Exists(Path.Combine(BaseFiles.GetRunDirectory(), "_OpenInEditor.lock"));
        }
    }
}
