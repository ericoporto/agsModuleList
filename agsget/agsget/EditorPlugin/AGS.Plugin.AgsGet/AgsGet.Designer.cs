using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Windows.Forms;

namespace AGS.Plugin.AgsGet
{
	partial class AgsGetPane
	{
		/// <summary> 
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;
        private List<AgsGetCore.Package> packages = null;

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
                button_AddPackage.Enabled = false;
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
                button_AddPackage.Enabled = false;
                return;
            }

            string selected_item = listBox_packagesResults.SelectedItem.ToString();

            AgsGetCore.Package match = packages
                .FirstOrDefault(p => p.id.Equals(selected_item, StringComparison.InvariantCultureIgnoreCase));

            if (match == null)
            {
                button_GetPackage.Enabled = false;
                button_AddPackage.Enabled = false;
                return;
            }


            button_GetPackage.Enabled = true;
            button_AddPackage.Enabled = true;
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
            string selected_item = listBox_packagesResults.SelectedItem.ToString();
            if (selected_item == null || selected_item.Length <= 0) return;

            await AgsGetCore.AgsGetCore.AddPackageAsync(AppendToConsoleOut, _editor.CurrentGame.DirectoryPath, selected_item);
        }

        private async void button_RemovePackage_Click(object sender, EventArgs e)
        {
            string selected_item = listBox_packagesResults.SelectedItem.ToString();
            if (selected_item == null || selected_item.Length <= 0) return;

            await AgsGetCore.AgsGetCore.RemovePackageAsync(AppendToConsoleOut, _editor.CurrentGame.DirectoryPath, selected_item);
        }

        private void listBox_packagesInstalled_SelectedIndexChanged(object sender, EventArgs e)
        {

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
        }
    }
}
