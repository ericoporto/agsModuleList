using System;
using System.Collections.Generic;
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
            textBox_ConsoleOut.AppendText(text);
            textBox_ConsoleOut.AppendText(Environment.NewLine);
        }

        private void textBox_searchQuery_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Return)
            {
                // Do Package Search
                packages = AgsGetCore.AgsGetCore.ListAll(AppendToConsoleOut, _editor.CurrentGame.DirectoryPath, null);
                listBox_packagesResults.BeginUpdate();
                listBox_packagesResults.Items.Clear();
                string[] package_names = packages.Select(p => p.id).ToArray();
                listBox_packagesResults.Items.AddRange(package_names);
                listBox_packagesResults.EndUpdate();
            }
        }
        private void listBox_packagesResults_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (packages.Count <= 0) return;
            if (listBox_packagesResults.SelectedIndex < 0 ||
                listBox_packagesResults.SelectedItem == null ||
                listBox_packagesResults.SelectedItem.ToString().Length <= 0) return;

            string selected_item = listBox_packagesResults.SelectedItem.ToString();

            AgsGetCore.Package match = packages
                .FirstOrDefault(p => p.id.Equals(selected_item, StringComparison.InvariantCultureIgnoreCase));
            
            if (match == null) return;

            label_selectedPackageName.Text = match.name;
            linkLabel_selectedPackageForumPage.Text = match.forum;
            label_selectedPackageText.Text = match.text;
        }
    }
}
