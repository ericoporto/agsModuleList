namespace AGS.Plugin.AgsGet
{
	partial class AgsGetPane
	{
		/// <summary> 
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

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

		#region Component Designer generated code

		/// <summary> 
		/// Required method for Designer support - do not modify 
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.label1 = new System.Windows.Forms.Label();
			this.textBox1 = new System.Windows.Forms.TextBox();
			this.btnShowGameData = new System.Windows.Forms.Button();
			this.SuspendLayout();
			// 
			// label1
			// 
			this.label1.AutoSize = true;
			this.label1.Location = new System.Drawing.Point(13, 44);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(227, 13);
			this.label1.TabIndex = 0;
			this.label1.Text = "The text below will be saved into the game file:";
			// 
			// textBox1
			// 
			this.textBox1.Location = new System.Drawing.Point(16, 60);
			this.textBox1.Multiline = true;
			this.textBox1.Name = "textBox1";
			this.textBox1.Size = new System.Drawing.Size(347, 179);
			this.textBox1.TabIndex = 1;
			this.textBox1.Text = "Type random stuff in me";
			// 
			// btnShowGameData
			// 
			this.btnShowGameData.Location = new System.Drawing.Point(16, 10);
			this.btnShowGameData.Name = "btnShowGameData";
			this.btnShowGameData.Size = new System.Drawing.Size(181, 25);
			this.btnShowGameData.TabIndex = 2;
			this.btnShowGameData.Text = "Show game information";
			this.btnShowGameData.UseVisualStyleBackColor = true;
			this.btnShowGameData.Click += new System.EventHandler(this.btnShowGameData_Click);
			// 
			// AgsGetPane
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.Controls.Add(this.btnShowGameData);
			this.Controls.Add(this.textBox1);
			this.Controls.Add(this.label1);
			this.Name = "AgsGetPane";
			this.Size = new System.Drawing.Size(388, 260);
			this.ResumeLayout(false);
			this.PerformLayout();

		}

		#endregion

		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.TextBox textBox1;
		private System.Windows.Forms.Button btnShowGameData;
	}
}
