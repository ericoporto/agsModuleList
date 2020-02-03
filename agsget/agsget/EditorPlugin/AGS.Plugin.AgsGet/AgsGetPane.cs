using AGS.Types;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;
using System.Linq;

namespace AGS.Plugin.AgsGet
{
	public partial class AgsGetPane : EditorContentPanel
    {
        private System.Windows.Forms.Label label_packageSearch;
        private System.Windows.Forms.ListBox listBox_packagesResults;
        private System.Windows.Forms.Label label_packageInstalled;
        private System.Windows.Forms.ListBox listBox_packagesInstalled;
        private System.Windows.Forms.TextBox textBox_ConsoleOut;
        private System.Windows.Forms.Button button_InstallPackage;
        private GroupBox groupBox2;
        private SplitContainer splitContainer1;
        private LinkLabel linkLabel_selectedPackageForumPage;
        private Label label_selectedPackageName;
        private FlowLayoutPanel flowLayoutPanel1;
        private TextBox textBox_searchQuery;
        private Label label_selectedPackageVersion;
        private Label label_selectedPackageAuthor;
        private Label label_selectedPackageDepends;
        private TextBox textBox_selectedPackageText;
        private Label label1;
        private Button button_UpdateIndex;
        private Button button_GetPackage;
        private TextBox textBox_LockFile;
        private Button button_AddPackage;
        private Button button_RemovePackage;
        private TabControl tabControl1;
        private TabPage tabPage1;
        private TabPage tabPage2;
        private TextBox textBox_ManifestFile;
        private System.IO.FileSystemWatcher fileSystemWatcher_LockFile;
        private System.IO.FileSystemWatcher fileSystemWatcher_Manifest;
        private Button button_UninstallPackage;
        private IAGSEditor _editor;

		public AgsGetPane(IAGSEditor editor)
		{
			InitializeComponent();
			_editor = editor;
		}

		public string TextBoxContents
		{
			get { return textBox_ConsoleOut.Text; }
			set { textBox_ConsoleOut.Text = value; }
		}

        private void InitializeComponent()
        {
            this.label_packageSearch = new System.Windows.Forms.Label();
            this.listBox_packagesResults = new System.Windows.Forms.ListBox();
            this.label_packageInstalled = new System.Windows.Forms.Label();
            this.listBox_packagesInstalled = new System.Windows.Forms.ListBox();
            this.textBox_ConsoleOut = new System.Windows.Forms.TextBox();
            this.button_InstallPackage = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPage1 = new System.Windows.Forms.TabPage();
            this.textBox_LockFile = new System.Windows.Forms.TextBox();
            this.tabPage2 = new System.Windows.Forms.TabPage();
            this.textBox_ManifestFile = new System.Windows.Forms.TextBox();
            this.textBox_selectedPackageText = new System.Windows.Forms.TextBox();
            this.label_selectedPackageDepends = new System.Windows.Forms.Label();
            this.linkLabel_selectedPackageForumPage = new System.Windows.Forms.LinkLabel();
            this.label_selectedPackageVersion = new System.Windows.Forms.Label();
            this.label_selectedPackageAuthor = new System.Windows.Forms.Label();
            this.label_selectedPackageName = new System.Windows.Forms.Label();
            this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
            this.label1 = new System.Windows.Forms.Label();
            this.button_UpdateIndex = new System.Windows.Forms.Button();
            this.button_GetPackage = new System.Windows.Forms.Button();
            this.button_AddPackage = new System.Windows.Forms.Button();
            this.button_RemovePackage = new System.Windows.Forms.Button();
            this.textBox_searchQuery = new System.Windows.Forms.TextBox();
            this.fileSystemWatcher_LockFile = new System.IO.FileSystemWatcher();
            this.fileSystemWatcher_Manifest = new System.IO.FileSystemWatcher();
            this.button_UninstallPackage = new System.Windows.Forms.Button();
            this.groupBox2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.tabControl1.SuspendLayout();
            this.tabPage1.SuspendLayout();
            this.tabPage2.SuspendLayout();
            this.flowLayoutPanel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.fileSystemWatcher_LockFile)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.fileSystemWatcher_Manifest)).BeginInit();
            this.SuspendLayout();
            // 
            // label_packageSearch
            // 
            this.label_packageSearch.AutoSize = true;
            this.label_packageSearch.Dock = System.Windows.Forms.DockStyle.Top;
            this.label_packageSearch.Location = new System.Drawing.Point(0, 0);
            this.label_packageSearch.Name = "label_packageSearch";
            this.label_packageSearch.Size = new System.Drawing.Size(148, 13);
            this.label_packageSearch.TabIndex = 0;
            this.label_packageSearch.Text = "Results from package search:";
            // 
            // listBox_packagesResults
            // 
            this.listBox_packagesResults.Dock = System.Windows.Forms.DockStyle.Top;
            this.listBox_packagesResults.Location = new System.Drawing.Point(0, 13);
            this.listBox_packagesResults.MinimumSize = new System.Drawing.Size(4, 200);
            this.listBox_packagesResults.Name = "listBox_packagesResults";
            this.listBox_packagesResults.Size = new System.Drawing.Size(332, 199);
            this.listBox_packagesResults.Sorted = true;
            this.listBox_packagesResults.TabIndex = 2;
            this.listBox_packagesResults.SelectedIndexChanged += new System.EventHandler(this.listBox_packagesResults_SelectedIndexChanged);
            // 
            // label_packageInstalled
            // 
            this.label_packageInstalled.AutoSize = true;
            this.label_packageInstalled.Dock = System.Windows.Forms.DockStyle.Top;
            this.label_packageInstalled.Location = new System.Drawing.Point(0, 212);
            this.label_packageInstalled.Name = "label_packageInstalled";
            this.label_packageInstalled.Size = new System.Drawing.Size(100, 13);
            this.label_packageInstalled.TabIndex = 0;
            this.label_packageInstalled.Text = "Installed Packages:";
            // 
            // listBox_packagesInstalled
            // 
            this.listBox_packagesInstalled.Dock = System.Windows.Forms.DockStyle.Top;
            this.listBox_packagesInstalled.Location = new System.Drawing.Point(0, 225);
            this.listBox_packagesInstalled.MinimumSize = new System.Drawing.Size(60, 60);
            this.listBox_packagesInstalled.Name = "listBox_packagesInstalled";
            this.listBox_packagesInstalled.Size = new System.Drawing.Size(332, 56);
            this.listBox_packagesInstalled.TabIndex = 2;
            this.listBox_packagesInstalled.SelectedIndexChanged += new System.EventHandler(this.listBox_packagesInstalled_SelectedIndexChanged);
            // 
            // textBox_ConsoleOut
            // 
            this.textBox_ConsoleOut.Dock = System.Windows.Forms.DockStyle.Top;
            this.textBox_ConsoleOut.Location = new System.Drawing.Point(0, 539);
            this.textBox_ConsoleOut.Multiline = true;
            this.textBox_ConsoleOut.Name = "textBox_ConsoleOut";
            this.textBox_ConsoleOut.ReadOnly = true;
            this.textBox_ConsoleOut.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textBox_ConsoleOut.Size = new System.Drawing.Size(1007, 89);
            this.textBox_ConsoleOut.TabIndex = 1;
            // 
            // button_InstallPackage
            // 
            this.button_InstallPackage.AutoSize = true;
            this.button_InstallPackage.Location = new System.Drawing.Point(3, 3);
            this.button_InstallPackage.Name = "button_InstallPackage";
            this.button_InstallPackage.Size = new System.Drawing.Size(111, 25);
            this.button_InstallPackage.TabIndex = 2;
            this.button_InstallPackage.Text = "Install Package";
            this.button_InstallPackage.UseVisualStyleBackColor = true;
            this.button_InstallPackage.Click += new System.EventHandler(this.button_InstallPackage_Click);
            // 
            // groupBox2
            // 
            this.groupBox2.AutoSize = true;
            this.groupBox2.Controls.Add(this.splitContainer1);
            this.groupBox2.Controls.Add(this.textBox_searchQuery);
            this.groupBox2.Dock = System.Windows.Forms.DockStyle.Top;
            this.groupBox2.Location = new System.Drawing.Point(0, 0);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(1007, 539);
            this.groupBox2.TabIndex = 0;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "AgsGet Package Search";
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Top;
            this.splitContainer1.Location = new System.Drawing.Point(3, 36);
            this.splitContainer1.MinimumSize = new System.Drawing.Size(0, 500);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            this.splitContainer1.Panel1.Controls.Add(this.tabControl1);
            this.splitContainer1.Panel1.Controls.Add(this.listBox_packagesInstalled);
            this.splitContainer1.Panel1.Controls.Add(this.label_packageInstalled);
            this.splitContainer1.Panel1.Controls.Add(this.listBox_packagesResults);
            this.splitContainer1.Panel1.Controls.Add(this.label_packageSearch);
            // 
            // splitContainer1.Panel2
            // 
            this.splitContainer1.Panel2.Controls.Add(this.textBox_selectedPackageText);
            this.splitContainer1.Panel2.Controls.Add(this.label_selectedPackageDepends);
            this.splitContainer1.Panel2.Controls.Add(this.linkLabel_selectedPackageForumPage);
            this.splitContainer1.Panel2.Controls.Add(this.label_selectedPackageVersion);
            this.splitContainer1.Panel2.Controls.Add(this.label_selectedPackageAuthor);
            this.splitContainer1.Panel2.Controls.Add(this.label_selectedPackageName);
            this.splitContainer1.Panel2.Controls.Add(this.flowLayoutPanel1);
            this.splitContainer1.Size = new System.Drawing.Size(1001, 500);
            this.splitContainer1.SplitterDistance = 332;
            this.splitContainer1.TabIndex = 2;
            // 
            // tabControl1
            // 
            this.tabControl1.Controls.Add(this.tabPage1);
            this.tabControl1.Controls.Add(this.tabPage2);
            this.tabControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl1.Location = new System.Drawing.Point(0, 281);
            this.tabControl1.MinimumSize = new System.Drawing.Size(0, 140);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(332, 219);
            this.tabControl1.TabIndex = 5;
            // 
            // tabPage1
            // 
            this.tabPage1.Controls.Add(this.textBox_LockFile);
            this.tabPage1.Location = new System.Drawing.Point(4, 22);
            this.tabPage1.Name = "tabPage1";
            this.tabPage1.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage1.Size = new System.Drawing.Size(324, 193);
            this.tabPage1.TabIndex = 0;
            this.tabPage1.Text = "LockFile";
            this.tabPage1.UseVisualStyleBackColor = true;
            // 
            // textBox_LockFile
            // 
            this.textBox_LockFile.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textBox_LockFile.Location = new System.Drawing.Point(3, 3);
            this.textBox_LockFile.MinimumSize = new System.Drawing.Size(90, 90);
            this.textBox_LockFile.Multiline = true;
            this.textBox_LockFile.Name = "textBox_LockFile";
            this.textBox_LockFile.ReadOnly = true;
            this.textBox_LockFile.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.textBox_LockFile.Size = new System.Drawing.Size(318, 187);
            this.textBox_LockFile.TabIndex = 4;
            // 
            // tabPage2
            // 
            this.tabPage2.Controls.Add(this.textBox_ManifestFile);
            this.tabPage2.Location = new System.Drawing.Point(4, 22);
            this.tabPage2.Name = "tabPage2";
            this.tabPage2.Padding = new System.Windows.Forms.Padding(3);
            this.tabPage2.Size = new System.Drawing.Size(330, 193);
            this.tabPage2.TabIndex = 1;
            this.tabPage2.Text = "ManifestFile";
            this.tabPage2.UseVisualStyleBackColor = true;
            // 
            // textBox_ManifestFile
            // 
            this.textBox_ManifestFile.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textBox_ManifestFile.Location = new System.Drawing.Point(3, 3);
            this.textBox_ManifestFile.MinimumSize = new System.Drawing.Size(90, 90);
            this.textBox_ManifestFile.Multiline = true;
            this.textBox_ManifestFile.Name = "textBox_ManifestFile";
            this.textBox_ManifestFile.ReadOnly = true;
            this.textBox_ManifestFile.ScrollBars = System.Windows.Forms.ScrollBars.Both;
            this.textBox_ManifestFile.Size = new System.Drawing.Size(324, 187);
            this.textBox_ManifestFile.TabIndex = 0;
            // 
            // textBox_selectedPackageText
            // 
            this.textBox_selectedPackageText.CausesValidation = false;
            this.textBox_selectedPackageText.Dock = System.Windows.Forms.DockStyle.Top;
            this.textBox_selectedPackageText.Location = new System.Drawing.Point(0, 96);
            this.textBox_selectedPackageText.MinimumSize = new System.Drawing.Size(4, 60);
            this.textBox_selectedPackageText.Multiline = true;
            this.textBox_selectedPackageText.Name = "textBox_selectedPackageText";
            this.textBox_selectedPackageText.ReadOnly = true;
            this.textBox_selectedPackageText.Size = new System.Drawing.Size(665, 60);
            this.textBox_selectedPackageText.TabIndex = 7;
            // 
            // label_selectedPackageDepends
            // 
            this.label_selectedPackageDepends.AutoSize = true;
            this.label_selectedPackageDepends.Dock = System.Windows.Forms.DockStyle.Top;
            this.label_selectedPackageDepends.Location = new System.Drawing.Point(0, 83);
            this.label_selectedPackageDepends.Name = "label_selectedPackageDepends";
            this.label_selectedPackageDepends.Size = new System.Drawing.Size(35, 13);
            this.label_selectedPackageDepends.TabIndex = 6;
            this.label_selectedPackageDepends.Text = "label1";
            // 
            // linkLabel_selectedPackageForumPage
            // 
            this.linkLabel_selectedPackageForumPage.AutoSize = true;
            this.linkLabel_selectedPackageForumPage.Dock = System.Windows.Forms.DockStyle.Top;
            this.linkLabel_selectedPackageForumPage.Location = new System.Drawing.Point(0, 70);
            this.linkLabel_selectedPackageForumPage.Name = "linkLabel_selectedPackageForumPage";
            this.linkLabel_selectedPackageForumPage.Size = new System.Drawing.Size(55, 13);
            this.linkLabel_selectedPackageForumPage.TabIndex = 2;
            this.linkLabel_selectedPackageForumPage.TabStop = true;
            this.linkLabel_selectedPackageForumPage.Text = "linkLabel1";
            this.linkLabel_selectedPackageForumPage.LinkClicked += new System.Windows.Forms.LinkLabelLinkClickedEventHandler(this.linkLabel_selectedPackageForumPage_LinkClicked);
            // 
            // label_selectedPackageVersion
            // 
            this.label_selectedPackageVersion.AutoSize = true;
            this.label_selectedPackageVersion.Dock = System.Windows.Forms.DockStyle.Top;
            this.label_selectedPackageVersion.Location = new System.Drawing.Point(0, 57);
            this.label_selectedPackageVersion.Name = "label_selectedPackageVersion";
            this.label_selectedPackageVersion.Size = new System.Drawing.Size(35, 13);
            this.label_selectedPackageVersion.TabIndex = 4;
            this.label_selectedPackageVersion.Text = "label1";
            // 
            // label_selectedPackageAuthor
            // 
            this.label_selectedPackageAuthor.AutoSize = true;
            this.label_selectedPackageAuthor.Dock = System.Windows.Forms.DockStyle.Top;
            this.label_selectedPackageAuthor.Location = new System.Drawing.Point(0, 44);
            this.label_selectedPackageAuthor.Name = "label_selectedPackageAuthor";
            this.label_selectedPackageAuthor.Size = new System.Drawing.Size(35, 13);
            this.label_selectedPackageAuthor.TabIndex = 5;
            this.label_selectedPackageAuthor.Text = "label1";
            // 
            // label_selectedPackageName
            // 
            this.label_selectedPackageName.AutoSize = true;
            this.label_selectedPackageName.Dock = System.Windows.Forms.DockStyle.Top;
            this.label_selectedPackageName.Location = new System.Drawing.Point(0, 31);
            this.label_selectedPackageName.Name = "label_selectedPackageName";
            this.label_selectedPackageName.Size = new System.Drawing.Size(35, 13);
            this.label_selectedPackageName.TabIndex = 1;
            this.label_selectedPackageName.Text = "label1";
            // 
            // flowLayoutPanel1
            // 
            this.flowLayoutPanel1.AutoSize = true;
            this.flowLayoutPanel1.Controls.Add(this.button_InstallPackage);
            this.flowLayoutPanel1.Controls.Add(this.button_UninstallPackage);
            this.flowLayoutPanel1.Controls.Add(this.label1);
            this.flowLayoutPanel1.Controls.Add(this.button_UpdateIndex);
            this.flowLayoutPanel1.Controls.Add(this.button_GetPackage);
            this.flowLayoutPanel1.Controls.Add(this.button_AddPackage);
            this.flowLayoutPanel1.Controls.Add(this.button_RemovePackage);
            this.flowLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.flowLayoutPanel1.Location = new System.Drawing.Point(0, 0);
            this.flowLayoutPanel1.Name = "flowLayoutPanel1";
            this.flowLayoutPanel1.Size = new System.Drawing.Size(665, 31);
            this.flowLayoutPanel1.TabIndex = 0;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(229, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(28, 13);
            this.label1.TabIndex = 4;
            this.label1.Text = "       ";
            // 
            // button_UpdateIndex
            // 
            this.button_UpdateIndex.AutoSize = true;
            this.button_UpdateIndex.Location = new System.Drawing.Point(263, 3);
            this.button_UpdateIndex.Name = "button_UpdateIndex";
            this.button_UpdateIndex.Size = new System.Drawing.Size(81, 23);
            this.button_UpdateIndex.TabIndex = 3;
            this.button_UpdateIndex.Text = "Update Index";
            this.button_UpdateIndex.UseVisualStyleBackColor = true;
            this.button_UpdateIndex.Click += new System.EventHandler(this.button_UpdateIndex_Click);
            // 
            // button_GetPackage
            // 
            this.button_GetPackage.AutoSize = true;
            this.button_GetPackage.Enabled = false;
            this.button_GetPackage.Location = new System.Drawing.Point(350, 3);
            this.button_GetPackage.Name = "button_GetPackage";
            this.button_GetPackage.Size = new System.Drawing.Size(80, 23);
            this.button_GetPackage.TabIndex = 5;
            this.button_GetPackage.Text = "Get Package";
            this.button_GetPackage.UseVisualStyleBackColor = true;
            this.button_GetPackage.Click += new System.EventHandler(this.button_GetPackage_Click);
            // 
            // button_AddPackage
            // 
            this.button_AddPackage.AutoSize = true;
            this.button_AddPackage.Location = new System.Drawing.Point(436, 3);
            this.button_AddPackage.Name = "button_AddPackage";
            this.button_AddPackage.Size = new System.Drawing.Size(82, 23);
            this.button_AddPackage.TabIndex = 6;
            this.button_AddPackage.Text = "Add Package";
            this.button_AddPackage.UseVisualStyleBackColor = true;
            this.button_AddPackage.Click += new System.EventHandler(this.button_AddPackage_Click);
            // 
            // button_RemovePackage
            // 
            this.button_RemovePackage.AutoSize = true;
            this.button_RemovePackage.Location = new System.Drawing.Point(524, 3);
            this.button_RemovePackage.Name = "button_RemovePackage";
            this.button_RemovePackage.Size = new System.Drawing.Size(103, 23);
            this.button_RemovePackage.TabIndex = 7;
            this.button_RemovePackage.Text = "Remove Package";
            this.button_RemovePackage.UseVisualStyleBackColor = true;
            this.button_RemovePackage.Click += new System.EventHandler(this.button_RemovePackage_Click);
            // 
            // textBox_searchQuery
            // 
            this.textBox_searchQuery.Dock = System.Windows.Forms.DockStyle.Top;
            this.textBox_searchQuery.Location = new System.Drawing.Point(3, 16);
            this.textBox_searchQuery.Name = "textBox_searchQuery";
            this.textBox_searchQuery.Size = new System.Drawing.Size(1001, 20);
            this.textBox_searchQuery.TabIndex = 1;
            this.textBox_searchQuery.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.textBox_searchQuery_KeyPress);
            // 
            // fileSystemWatcher_LockFile
            // 
            this.fileSystemWatcher_LockFile.EnableRaisingEvents = true;
            this.fileSystemWatcher_LockFile.NotifyFilter = System.IO.NotifyFilters.LastWrite;
            this.fileSystemWatcher_LockFile.SynchronizingObject = this;
            this.fileSystemWatcher_LockFile.Changed += new System.IO.FileSystemEventHandler(this.fileSystemWatcher_LockFile_Changed);
            // 
            // fileSystemWatcher_Manifest
            // 
            this.fileSystemWatcher_Manifest.EnableRaisingEvents = true;
            this.fileSystemWatcher_Manifest.NotifyFilter = System.IO.NotifyFilters.LastWrite;
            this.fileSystemWatcher_Manifest.SynchronizingObject = this;
            this.fileSystemWatcher_Manifest.Changed += new System.IO.FileSystemEventHandler(this.fileSystemWatcher_Manifest_Changed);
            // 
            // button_UninstallPackage
            // 
            this.button_UninstallPackage.AutoSize = true;
            this.button_UninstallPackage.Location = new System.Drawing.Point(120, 3);
            this.button_UninstallPackage.Name = "button_UninstallPackage";
            this.button_UninstallPackage.Size = new System.Drawing.Size(103, 23);
            this.button_UninstallPackage.TabIndex = 8;
            this.button_UninstallPackage.Text = "Uninstall Package";
            this.button_UninstallPackage.UseVisualStyleBackColor = true;
            this.button_UninstallPackage.Click += new System.EventHandler(this.button_UninstallPackage_Click);
            // 
            // AgsGetPane
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoScroll = true;
            this.Controls.Add(this.textBox_ConsoleOut);
            this.Controls.Add(this.groupBox2);
            this.DoubleBuffered = true;
            this.Name = "AgsGetPane";
            this.Size = new System.Drawing.Size(1007, 498);
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.tabControl1.ResumeLayout(false);
            this.tabPage1.ResumeLayout(false);
            this.tabPage1.PerformLayout();
            this.tabPage2.ResumeLayout(false);
            this.tabPage2.PerformLayout();
            this.flowLayoutPanel1.ResumeLayout(false);
            this.flowLayoutPanel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.fileSystemWatcher_LockFile)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.fileSystemWatcher_Manifest)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }
    }
}
