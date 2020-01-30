using System;
using System.Collections.Generic;
using System.Text;
using System.Net;

namespace AgsGetCore
{
    public class DownloadPretty
    {
        public static async System.Threading.Tasks.Task<bool> FileAsync(Action<string> writerMethod, string url, string filename) { 
            var webClient = new WebClient();

            writerMethod("Will download from:"+ url);

            bool is_async = true;

            if (writerMethod == Console.WriteLine) is_async = false;


            var downloadTask = webClient.DownloadFileTaskAsync(
            new Uri(url),
                filename,
            new Progress<Tuple<long, int, long>>(t =>
            {
                writerMethod(string.Format($"\r({t.Item2,25:#,###}) Bytes received: {t.Item1,25:#,###}/{t.Item3,25:#,###}"));
            }));

            await downloadTask;

            return true;
        }


        public static bool File(Action<string> writerMethod, string url, string filename) { 
            var webClient = new WebClient();

            writerMethod("Will download from:"+ url);

            webClient.DownloadFileTaskAsync(
            new Uri(url),
                filename,
            new Progress<Tuple<long, int, long>>(t =>
            {
                writerMethod(string.Format($"\r({t.Item2,25:#,###}) Bytes received: {t.Item1,25:#,###}/{t.Item3,25:#,###}" ));

//                Console.WriteLine($@"
//            Bytes received: {t.Item1,25:#,###}
//       Progress percentage: {t.Item2,25:#,###}
//    Total bytes to receive: {t.Item3,25:#,###}");

            })).Wait();
            return true;
        }

    }
}
