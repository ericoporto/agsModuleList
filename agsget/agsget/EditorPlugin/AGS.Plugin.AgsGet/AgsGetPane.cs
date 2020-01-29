using AGS.Types;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;

namespace AGS.Plugin.AgsGet
{
	public partial class AgsGetPane : EditorContentPanel
    {
        private System.Windows.Forms.Label label_packageSearch;
        private System.Windows.Forms.ListBox listBox_packagesResults;
        private System.Windows.Forms.Label label_packageInstalled;
        private System.Windows.Forms.ListBox listBox_packagesInstalled;
        private System.Windows.Forms.TextBox textBox_ConsoleOut;
        private System.Windows.Forms.Button btnShowGameData;
        private GroupBox groupBox1;
        private GroupBox groupBox2;
        private SplitContainer splitContainer1;
        private Label label2;
        private LinkLabel linkLabel1;
        private Label label1;
        private FlowLayoutPanel flowLayoutPanel1;
        private TextBox textBox1;
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
            this.btnShowGameData = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.splitContainer1 = new System.Windows.Forms.SplitContainer();
            this.label2 = new System.Windows.Forms.Label();
            this.linkLabel1 = new System.Windows.Forms.LinkLabel();
            this.label1 = new System.Windows.Forms.Label();
            this.flowLayoutPanel1 = new System.Windows.Forms.FlowLayoutPanel();
            this.textBox1 = new System.Windows.Forms.TextBox();
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
            this.listBox_packagesResults.TabIndex = 2;
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
            this.listBox_packagesInstalled.MinimumSize = new System.Drawing.Size(0, 100);
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
            this.textBox_ConsoleOut.Size = new System.Drawing.Size(1069, 89);
            this.textBox_ConsoleOut.TabIndex = 1;
            this.textBox_ConsoleOut.Text = "Type random stuff in me";
            this.textBox_ConsoleOut.TextChanged += new System.EventHandler(this.textBox_ConsoleOut_TextChanged);
            // 
            // btnShowGameData
            // 
            this.btnShowGameData.Location = new System.Drawing.Point(3, 3);
            this.btnShowGameData.Name = "btnShowGameData";
            this.btnShowGameData.Size = new System.Drawing.Size(111, 25);
            this.btnShowGameData.TabIndex = 2;
            this.btnShowGameData.Text = "Show game information";
            this.btnShowGameData.UseVisualStyleBackColor = true;
            this.btnShowGameData.Click += new System.EventHandler(this.btnShowGameData_Click);
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
            this.groupBox1.Enter += new System.EventHandler(this.groupBox1_Enter);
            // 
            // groupBox2
            // 
            this.groupBox2.AutoSize = true;
            this.groupBox2.Controls.Add(this.splitContainer1);
            this.groupBox2.Controls.Add(this.textBox1);
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
            this.splitContainer1.Panel2.Controls.Add(this.label2);
            this.splitContainer1.Panel2.Controls.Add(this.linkLabel1);
            this.splitContainer1.Panel2.Controls.Add(this.label1);
            this.splitContainer1.Panel2.Controls.Add(this.flowLayoutPanel1);
            this.splitContainer1.Size = new System.Drawing.Size(1063, 348);
            this.splitContainer1.SplitterDistance = 354;
            this.splitContainer1.TabIndex = 2;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Dock = System.Windows.Forms.DockStyle.Top;
            this.label2.Location = new System.Drawing.Point(0, 57);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(35, 13);
            this.label2.TabIndex = 3;
            this.label2.Text = "label2";
            // 
            // linkLabel1
            // 
            this.linkLabel1.AutoSize = true;
            this.linkLabel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.linkLabel1.Location = new System.Drawing.Point(0, 44);
            this.linkLabel1.Name = "linkLabel1";
            this.linkLabel1.Size = new System.Drawing.Size(55, 13);
            this.linkLabel1.TabIndex = 2;
            this.linkLabel1.TabStop = true;
            this.linkLabel1.Text = "linkLabel1";
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Dock = System.Windows.Forms.DockStyle.Top;
            this.label1.Location = new System.Drawing.Point(0, 31);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(35, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "label1";
            // 
            // flowLayoutPanel1
            // 
            this.flowLayoutPanel1.AutoSize = true;
            this.flowLayoutPanel1.Controls.Add(this.btnShowGameData);
            this.flowLayoutPanel1.Dock = System.Windows.Forms.DockStyle.Top;
            this.flowLayoutPanel1.Location = new System.Drawing.Point(0, 0);
            this.flowLayoutPanel1.Name = "flowLayoutPanel1";
            this.flowLayoutPanel1.Size = new System.Drawing.Size(705, 31);
            this.flowLayoutPanel1.TabIndex = 0;
            // 
            // textBox1
            // 
            this.textBox1.Dock = System.Windows.Forms.DockStyle.Top;
            this.textBox1.Location = new System.Drawing.Point(3, 16);
            this.textBox1.Name = "textBox1";
            this.textBox1.Size = new System.Drawing.Size(1063, 20);
            this.textBox1.TabIndex = 1;
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
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        private void groupBox1_Enter(object sender, EventArgs e)
        {

        }

        private void textBox_ConsoleOut_TextChanged(object sender, EventArgs e)
        {

        }
    }
}
