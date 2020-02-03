using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using AGS.Types;

namespace AGS.Plugin.AgsGet
{
	partial class AgsGetPane
	{
		/// <summary> 
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;
        private List<AgsGetCore.Package> packages = null;
        private const string AGSGET_SCRIPT_FOLDER = "AgsGetPackages";

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

        public void AppendToConsoleOut(string text)
        {
            if (text.StartsWith("\r")) textBox_ConsoleOut.Undo();

            textBox_ConsoleOut.AppendText(text);
            textBox_ConsoleOut.AppendText(Environment.NewLine);
        }

        private async void DoSearchQuery(string query)
        {
            // Do Package Search
            List<AgsGetCore.Package> package_query_result;

            if ( string.IsNullOrEmpty(query) || query.Length < 1)
            {
                package_query_result = await AgsGetCore.AgsGetCore.ListAllAsync(AppendToConsoleOut, _editor.CurrentGame.DirectoryPath, null);
            }
            else
            {
                package_query_result = await AgsGetCore.AgsGetCore.SearchAsync(AppendToConsoleOut, _editor.CurrentGame.DirectoryPath, textBox_searchQuery.Text);
            }

            if (package_query_result != null)
            {
                button_GetPackage.Enabled = false;
                packages = package_query_result;
                listBox_packagesResults.BeginUpdate();
                listBox_packagesResults.Items.Clear();
                string[] package_names = packages.Select(p => p.id).ToArray();
                listBox_packagesResults.Items.AddRange(package_names);
                listBox_packagesResults.EndUpdate();
            }
        }

        private async void textBox_searchQuery_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Return)
            {
                DoSearchQuery(textBox_searchQuery.Text);
            }
        }
        private async void listBox_packagesResults_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (packages.Count <= 0 ||
                listBox_packagesResults.SelectedIndex < 0 ||
                listBox_packagesResults.SelectedItem == null ||
                listBox_packagesResults.SelectedItem.ToString().Length <= 0)
            {
                button_GetPackage.Enabled = false;
                button_InstallPackage.Enabled = false;
                return;
            }

            string selected_item = listBox_packagesResults.SelectedItem.ToString();

            AgsGetCore.Package match = packages
                .FirstOrDefault(p => p.id.Equals(selected_item, StringComparison.InvariantCultureIgnoreCase));

            if (match == null)
            {
                button_GetPackage.Enabled = false;
                button_InstallPackage.Enabled = false;
                return;
            }


            button_GetPackage.Enabled = true;
            button_InstallPackage.Enabled = true;
            label_selectedPackageName.Text = match.name;
            linkLabel_selectedPackageForumPage.Text = match.forum;
            textBox_selectedPackageText.Text = match.text;
            label_selectedPackageAuthor.Text = "author: " + match.author;
            if (match.depends != null && match.depends.Length > 0) 
                label_selectedPackageDepends.Text = "depends: " + match.depends;
            else 
                label_selectedPackageDepends.Text = "";
            label_selectedPackageVersion.Text = "version: " + match.version;
        }

        private void linkLabel_selectedPackageForumPage_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            bool IsValidUri(string uri)
            {
                if (!Uri.IsWellFormedUriString(uri, UriKind.Absolute))
                    return false;
                Uri tmp;
                if (!Uri.TryCreate(uri, UriKind.Absolute, out tmp))
                    return false;
                return tmp.Scheme == Uri.UriSchemeHttp || tmp.Scheme == Uri.UriSchemeHttps;
            }
            linkLabel_selectedPackageForumPage.Text = linkLabel_selectedPackageForumPage.Text.Trim();
            if (!linkLabel_selectedPackageForumPage.Text.StartsWith("https://www.adventuregamestudio.co.uk/forums/index.php?topic=", StringComparison.InvariantCultureIgnoreCase)) return;
            if (!IsValidUri(linkLabel_selectedPackageForumPage.Text)) return;
            if (!linkLabel_selectedPackageForumPage.Text.EndsWith(".0", StringComparison.InvariantCultureIgnoreCase)) return;
            if (linkLabel_selectedPackageForumPage.Text.Length > 72) return;
            System.Diagnostics.Process.Start(linkLabel_selectedPackageForumPage.Text);
        }
        private async void button_UpdateIndex_Click(object sender, EventArgs e)
        {
            await AgsGetCore.AgsGetCore.UpdateAsync(AppendToConsoleOut, _editor.CurrentGame.DirectoryPath, null);
        }

        private async void button_GetPackage_Click(object sender, EventArgs e)
        {

            string selected_item = listBox_packagesResults.SelectedItem.ToString();
            if (selected_item == null || selected_item.Length <= 0) return;

            await AgsGetCore.AgsGetCore.GetAsync(AppendToConsoleOut, _editor.CurrentGame.DirectoryPath, selected_item);
        }


        private async void button_AddPackage_Click(object sender, EventArgs e)
        {
            if (listBox_packagesResults.SelectedIndex < 0) return;
            string selected_item = listBox_packagesResults.SelectedItem.ToString();
            if (selected_item == null || selected_item.Length <= 0) return;

            await AgsGetCore.AgsGetCore.AddPackageAsync(AppendToConsoleOut, _editor.CurrentGame.DirectoryPath, selected_item);
        }

        private void ReloadTreeIfPossible()
        {
            var comp = _editor.Components.Where(p => p.ComponentID == "Scripts");
            if (comp != null && comp.ToList().Count > 0)
            {
                _editor.GUIController.RePopulateTreeView(comp.First());
            }
        }
        private void RemoveScriptAndHeader(string filename)
        {
            ScriptAndHeader scripts_to_del = _editor.CurrentGame.ScriptsAndHeaders.GetScriptAndHeaderByFilename(filename);
            if (scripts_to_del != null)
            {
                _editor.CurrentGame.ScriptsAndHeaders.Remove(scripts_to_del);
            }
            var header_file = Path.Combine(_editor.CurrentGame.DirectoryPath, filename + ".ash");
            var script_file = Path.Combine(_editor.CurrentGame.DirectoryPath, filename + ".asc");
            if (File.Exists(header_file)) File.Delete(header_file);
            if (File.Exists(script_file)) File.Delete(script_file);
        }

        public static async Task IsFileReady(string filename)
        {
            await Task.Run(() =>
            {
                if (!File.Exists(filename))
                {
                    throw new IOException("File does not exist!");
                }

                var isReady = false;

                while (!isReady)
                {
                    // If the file can be opened for exclusive access it means that the file
                    // is no longer locked by another process.
                    try
                    {
                        using (FileStream inputStream =
                            File.Open(filename, FileMode.Open, FileAccess.Read, FileShare.None))
                            isReady = inputStream.Length > 0;
                    }
                    catch (Exception e)
                    {
                        // Check if the exception is related to an IO error.
                        if (e.GetType() == typeof(IOException))
                        {
                            isReady = false;
                        }
                        else
                        {
                            // Rethrow the exception as it's not an exclusively-opened-exception.
                            throw;
                        }
                    }
                }
            });
        }

        private void InsertScriptModules()
        {
            var packages_path = AgsGetCore.AgsGetCore.GetLockedPackagesPath();
            packages_path.Reverse();
            foreach (var pkg_path in packages_path)
            {
                string destFileName = Path.GetFileNameWithoutExtension(pkg_path);
                RemoveScriptAndHeader(destFileName);

                IsFileReady(pkg_path).Wait(200);                
                List <Script> newScripts = ImportExport.ImportScriptModule(pkg_path);
                newScripts[0].FileName = destFileName + ".ash";
                newScripts[1].FileName = destFileName + ".asc";
                newScripts[0].Modified = true;
                newScripts[1].Modified = true;
                newScripts[0].SaveToDisk();
                newScripts[1].SaveToDisk();
                ScriptAndHeader scripts = new ScriptAndHeader(newScripts[0], newScripts[1]);
                _editor.CurrentGame.ScriptsAndHeaders.AddAt(scripts, 0);
            }
            ReloadTreeIfPossible();
        }

        void PopulateInstalledPackages()
        {
            listBox_packagesInstalled.BeginUpdate();
            listBox_packagesInstalled.Items.Clear();
            var packages = AgsGetCore.AgsGetCore.GetManifestPackages();
            string[] package_names = packages.Where(
                p => _editor.CurrentGame.ScriptsAndHeaders.GetScriptAndHeaderByFilename(p) != null).ToArray();
            listBox_packagesInstalled.Items.AddRange(package_names);
            listBox_packagesInstalled.EndUpdate();
        }

        private async void button_InstallPackage_Click(object sender, EventArgs e)
        {
            if (listBox_packagesResults.SelectedIndex < 0) return;
            string selected_item = listBox_packagesResults.SelectedItem.ToString();
            if (selected_item == null || selected_item.Length <= 0) return;

            await AgsGetCore.AgsGetCore.AddPackageAsync(AppendToConsoleOut, _editor.CurrentGame.DirectoryPath, selected_item);

            InsertScriptModules();
            PopulateInstalledPackages();
        }

        private async void button_UninstallPackage_Click(object sender, EventArgs e)
        {
            if (listBox_packagesInstalled.SelectedIndex < 0) return;
            string selected_item = listBox_packagesInstalled.SelectedItem.ToString();
            if (selected_item == null || selected_item.Length <= 0) return;

            await AgsGetCore.AgsGetCore.RemovePackageAsync(AppendToConsoleOut, _editor.CurrentGame.DirectoryPath, selected_item);

            List<string> pkgForRemoval = AgsGetCore.AgsGetCore.GetPackagesForRemoval();
            if (pkgForRemoval != null)
            {
                foreach (var pkg in pkgForRemoval) RemoveScriptAndHeader(pkg);
            }
            PopulateInstalledPackages();
            ReloadTreeIfPossible();
        }

        private async void button_RemovePackage_Click(object sender, EventArgs e)
        {
            string selected_item = listBox_packagesResults.SelectedItem.ToString();
            if (selected_item == null || selected_item.Length <= 0) return;

            await AgsGetCore.AgsGetCore.RemovePackageAsync(AppendToConsoleOut, _editor.CurrentGame.DirectoryPath, selected_item);
            PopulateInstalledPackages();
        }

        private void listBox_packagesInstalled_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (
                listBox_packagesInstalled.SelectedIndex < 0 ||
                listBox_packagesInstalled.SelectedItem == null ||
                listBox_packagesInstalled.SelectedItem.ToString().Length <= 0)
            {
                button_UninstallPackage.Enabled = false;
                return;
            }

            string selected_item = listBox_packagesInstalled.SelectedItem.ToString();

            AgsGetCore.Package match = packages
                .FirstOrDefault(p => p.id.Equals(selected_item, StringComparison.InvariantCultureIgnoreCase));

            if (match == null)
            {
                button_UninstallPackage.Enabled = false;
                return;
            }

            button_UninstallPackage.Enabled = true;
        }

        private void fileSystemWatcher_LockFile_Changed(object sender, System.IO.FileSystemEventArgs e)
        {
            textBox_LockFile.Text = "";
            if (e.ChangeType == WatcherChangeTypes.Created || e.ChangeType == WatcherChangeTypes.Changed)
            {
                textBox_LockFile.Text = File.ReadAllText(AgsGetCore.AgsGetCore.GetLockFilePath(_editor.CurrentGame.DirectoryPath));
            }
        }

        private void fileSystemWatcher_Manifest_Changed(object sender, System.IO.FileSystemEventArgs e)
        {
            textBox_ManifestFile.Text = "";
            if (e.ChangeType == WatcherChangeTypes.Created || e.ChangeType == WatcherChangeTypes.Changed)
            {
                textBox_ManifestFile.Text = File.ReadAllText(AgsGetCore.AgsGetCore.GetManifestFilePath(_editor.CurrentGame.DirectoryPath));
            }
        }

        public void PanelReload()
        {
            string lockFileFullPath = AgsGetCore.AgsGetCore.GetLockFilePath(_editor.CurrentGame.DirectoryPath);
            string manifestFileFullPath = AgsGetCore.AgsGetCore.GetManifestFilePath(_editor.CurrentGame.DirectoryPath);
            fileSystemWatcher_LockFile.Path = new FileInfo(lockFileFullPath).Directory.FullName;
            fileSystemWatcher_LockFile.Filter = new FileInfo(lockFileFullPath).Name;
            fileSystemWatcher_Manifest.Path = new FileInfo(manifestFileFullPath).Directory.FullName;
            fileSystemWatcher_Manifest.Filter = new FileInfo(manifestFileFullPath).Name;
            if(File.Exists(lockFileFullPath)) 
                textBox_LockFile.Text = File.ReadAllText(AgsGetCore.AgsGetCore.GetLockFilePath(_editor.CurrentGame.DirectoryPath));
            if(File.Exists(manifestFileFullPath))
                textBox_ManifestFile.Text = File.ReadAllText(AgsGetCore.AgsGetCore.GetManifestFilePath(_editor.CurrentGame.DirectoryPath));
            label_selectedPackageAuthor.Text = "";
            label_selectedPackageDepends.Text = "";
            label_selectedPackageVersion.Text = "";
            label_selectedPackageName.Text = "";
            linkLabel_selectedPackageForumPage.Text = "";
            DoSearchQuery(null);
            PopulateInstalledPackages();
            button_UninstallPackage.Enabled = false;
            button_InstallPackage.Enabled = false;
        }
    }
}
