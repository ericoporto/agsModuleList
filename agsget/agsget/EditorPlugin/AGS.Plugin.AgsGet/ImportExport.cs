using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml;
using AGS.Types;

namespace AGS.Plugin.AgsGet
{
public class ImportExport
    {
        private const string MODULE_FILE_SIGNATURE = "AGSScriptModule\0";
        private const uint MODULE_FILE_TRAILER = 0xb4f76a65;
        
        public static List<Script> ImportScriptModule(string fileName)
        {
            BinaryReader reader = new BinaryReader(new FileStream(fileName, FileMode.Open, FileAccess.Read));
            string fileSig = Encoding.ASCII.GetString(reader.ReadBytes(16));
            if (fileSig != MODULE_FILE_SIGNATURE)
            {
                reader.Close();
                throw new AGS.Types.InvalidDataException("This is not a valid AGS script module.");
            }
            if (reader.ReadInt32() != 1)
            {
                reader.Close();
                throw new AGS.Types.InvalidDataException("This module requires a newer version of AGS.");
            }

            string author = ReadNullTerminatedString(reader);
            string description = ReadNullTerminatedString(reader);
            string name = ReadNullTerminatedString(reader);
            string version = ReadNullTerminatedString(reader);

            int scriptLength = reader.ReadInt32();
            string moduleScript = Encoding.Default.GetString(reader.ReadBytes(scriptLength));
            reader.ReadByte();  // discard null terminator

            int headerLength = reader.ReadInt32();
            string moduleHeader = Encoding.Default.GetString(reader.ReadBytes(headerLength));
            reader.ReadByte();  // discard null terminator

            int uniqueKey = reader.ReadInt32();
            reader.Close();

            List<Script> scriptsImported = new List<Script>();
            Script header = new Script(null, moduleHeader, name, description, author, version, uniqueKey, true);
            Script mainScript = new Script(null, moduleScript, name, description, author, version, uniqueKey, false);
            scriptsImported.Add(header);
            scriptsImported.Add(mainScript);

            return scriptsImported;
        }
        private static string ReadNullTerminatedString(BinaryReader reader)
        {
            return ReadNullTerminatedString(reader, 0);
        }

        private static string ReadNullTerminatedString(BinaryReader reader, int fixedLength)
        {
            StringBuilder sb = new StringBuilder(100);
            int bytesToRead = fixedLength;
            byte thisChar;
            while ((thisChar = reader.ReadByte()) != 0)
            {
                sb.Append((char)thisChar);
                bytesToRead--;

                if ((fixedLength > 0) && (bytesToRead < 1))
                {
                    break;
                }
            }
            if (bytesToRead > 0)
            {
                reader.ReadBytes(bytesToRead - 1);
            }
            return sb.ToString();
        }
    }
}

