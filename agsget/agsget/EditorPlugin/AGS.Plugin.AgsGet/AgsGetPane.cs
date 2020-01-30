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
        private System.Windows.Forms.Button btn_InstallPackage;
        private GroupBox groupBox1;
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

		private void btnShowGameData_Click(object sender, EventArgs e)
		{
			_editor.GUIController.ShowMessage("The game name is: " + _editor.CurrentGame.Settings.GameName, MessageBoxIconType.Information);
		}

        private void InitializeComponent()
        {
            this.label_packageSearch = new System.Windows.Forms.Label();
            this.listBox_packagesResults = new System.Windows.Forms.ListBox();
            this.label_packageInstalled = new System.Windows.Forms.Label();
            this.listBox_packagesInstalled = new System.Windows.Forms.ListBox();
            this.textBox_ConsoleOut = new System.Windows.Forms.TextBox();
            this.btn_InstallPackage = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
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
            this.textBox_searchQuery = new System.Windows.Forms.TextBox();
            this.groupBox1.SuspendLayout();
            this.groupBox2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).BeginInit();
            this.splitContainer1.Panel1.SuspendLayout();
            this.splitContainer1.Panel2.SuspendLayout();
            this.splitContainer1.SuspendLayout();
            this.flowLayoutPanel1.SuspendLayout();
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
            this.listBox_packagesResults.Size = new System.Drawing.Size(354, 199);
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
            this.listBox_packagesInstalled.MinimumSize = new System.Drawing.Size(4, 100);
            this.listBox_packagesInstalled.Name = "listBox_packagesInstalled";
            this.listBox_packagesInstalled.Size = new System.Drawing.Size(354, 95);
            this.listBox_packagesInstalled.TabIndex = 2;
            // 
            // textBox_ConsoleOut
            // 
            this.textBox_ConsoleOut.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.textBox_ConsoleOut.Location = new System.Drawing.Point(3, 406);
            this.textBox_ConsoleOut.Multiline = true;
            this.textBox_ConsoleOut.Name = "textBox_ConsoleOut";
            this.textBox_ConsoleOut.ReadOnly = true;
            this.textBox_ConsoleOut.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textBox_ConsoleOut.Size = new System.Drawing.Size(1069, 89);
            this.textBox_ConsoleOut.TabIndex = 1;
            this.textBox_ConsoleOut.Text = "-";
            // 
            // btn_InstallPackage
            // 
            this.btn_InstallPackage.AutoSize = true;
            this.btn_InstallPackage.Location = new System.Drawing.Point(3, 3);
            this.btn_InstallPackage.Name = "btn_InstallPackage";
            this.btn_InstallPackage.Size = new System.Drawing.Size(111, 25);
            this.btn_InstallPackage.TabIndex = 2;
            this.btn_InstallPackage.Text = "Install Package";
            this.btn_InstallPackage.UseVisualStyleBackColor = true;
            this.btn_InstallPackage.Click += new System.EventHandler(this.btnShowGameData_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.AutoSize = true;
            this.groupBox1.Controls.Add(this.groupBox2);
            this.groupBox1.Controls.Add(this.textBox_ConsoleOut);
            this.groupBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.groupBox1.Location = new System.Drawing.Point(0, 0);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(1075, 498);
            this.groupBox1.TabIndex = 3;
            this.groupBox1.TabStop = false;
            // 
            // groupBox2
            // 
            this.groupBox2.AutoSize = true;
            this.groupBox2.Controls.Add(this.splitContainer1);
            this.groupBox2.Controls.Add(this.textBox_searchQuery);
            this.groupBox2.Dock = System.Windows.Forms.DockStyle.Top;
            this.groupBox2.Location = new System.Drawing.Point(3, 16);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(1069, 387);
            this.groupBox2.TabIndex = 0;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "AgsGet Package Search";
            // 
            // splitContainer1
            // 
            this.splitContainer1.Dock = System.Windows.Forms.DockStyle.Top;
            this.splitContainer1.Location = new System.Drawing.Point(3, 36);
            this.splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
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
            this.splitContainer1.Size = new System.Drawing.Size(1063, 348);
            this.splitContainer1.SplitterDistance = 354;
            this.splitContainer1.TabIndex = 2;
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
            this.textBox_selectedPackageText.Size = new System.Drawing.Size(705, 60);
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
            this.flowLayoutPanel1.Controls.Add(this.btn_InstallPackage);
            this.flowLayoutPanel1.Controls.Add(this.label1);
            this.flowLayoutPanel1.Controls.Add(this.button_UpdateIndex);
            this.flowLayoutPanel1.Controls.Add(this.button_GetPackage);
            this.flowLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.flowLayoutPanel1.Location = new System.Drawing.Point(0, 0);
            this.flowLayoutPanel1.Name = "flowLayoutPanel1";
            this.flowLayoutPanel1.Size = new System.Drawing.Size(705, 31);
            this.flowLayoutPanel1.TabIndex = 0;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(120, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(28, 13);
            this.label1.TabIndex = 4;
            this.label1.Text = "       ";
            // 
            // button_UpdateIndex
            // 
            this.button_UpdateIndex.AutoSize = true;
            this.button_UpdateIndex.Location = new System.Drawing.Point(154, 3);
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
            this.button_GetPackage.Location = new System.Drawing.Point(241, 3);
            this.button_GetPackage.Name = "button_GetPackage";
            this.button_GetPackage.Size = new System.Drawing.Size(80, 23);
            this.button_GetPackage.TabIndex = 5;
            this.button_GetPackage.Text = "Get Package";
            this.button_GetPackage.UseVisualStyleBackColor = true;
            this.button_GetPackage.Click += new System.EventHandler(this.button_GetPackage_Click);
            // 
            // textBox_searchQuery
            // 
            this.textBox_searchQuery.Dock = System.Windows.Forms.DockStyle.Top;
            this.textBox_searchQuery.Location = new System.Drawing.Point(3, 16);
            this.textBox_searchQuery.Name = "textBox_searchQuery";
            this.textBox_searchQuery.Size = new System.Drawing.Size(1063, 20);
            this.textBox_searchQuery.TabIndex = 1;
            this.textBox_searchQuery.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.textBox_searchQuery_KeyPress);
            // 
            // AgsGetPane
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.groupBox1);
            this.Name = "AgsGetPane";
            this.Size = new System.Drawing.Size(1075, 498);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.splitContainer1.Panel1.ResumeLayout(false);
            this.splitContainer1.Panel1.PerformLayout();
            this.splitContainer1.Panel2.ResumeLayout(false);
            this.splitContainer1.Panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.splitContainer1)).EndInit();
            this.splitContainer1.ResumeLayout(false);
            this.flowLayoutPanel1.ResumeLayout(false);
            this.flowLayoutPanel1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

    }
}
