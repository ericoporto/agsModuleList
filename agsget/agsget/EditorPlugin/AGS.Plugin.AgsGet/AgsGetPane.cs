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
		private IAGSEditor _editor;

		public AgsGetPane(IAGSEditor editor)
		{
			InitializeComponent();
			_editor = editor;
		}

		public string TextBoxContents
		{
			get { return textBox1.Text; }
			set { textBox1.Text = value; }
		}

		private void btnShowGameData_Click(object sender, EventArgs e)
		{
			_editor.GUIController.ShowMessage("The game name is: " + _editor.CurrentGame.Settings.GameName, MessageBoxIconType.Information);
		}
	}
}
