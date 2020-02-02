using AGS.Types;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Text;

namespace AGS.Plugin.AgsGet
{
    public class AgsGetComponent : IEditorComponent
    {
        /* MAKE SURE THAT YOU CHANGE THE ID's BELOW TO APPROPRIATE NAMES
		 * FOR YOUR PLUGIN.
		 * If you leave them as they are, they could conflict with another
		 * plugin that has also left them alone, and your plugins would not
		 * work together.
		 */
        private const string COMPONENT_ID = "AgsGetComponent";
        private const string CONTROL_ID_CONTEXT_MENU_OPTION = "AgsGetPluginOptionClick";
        private const string CONTROL_ID_ROOT_NODE = "AgsGetPluginRoot";
        private const string ICON_KEY = "AgsGetPluginIcon";

        private readonly IAGSEditor _editor;
        private readonly ContentDocument _pane;
        private readonly AgsGetPane _agsGetPane;

        public AgsGetComponent(IAGSEditor editor)
        {
            _editor = editor;
            _editor.GUIController.RegisterIcon(ICON_KEY, GetIcon("PluginIcon.ico"));
            _editor.GUIController.ProjectTree.AddTreeRoot(this, CONTROL_ID_ROOT_NODE, "AgsGet plugin", ICON_KEY);
            _agsGetPane = new AgsGetPane(editor);
            _pane = new ContentDocument(_agsGetPane, "AgsGet", this, ICON_KEY);
        }

        private Icon GetIcon(string fileName)
        {
            return new Icon(this.GetType(), fileName);
        }

        string IEditorComponent.ComponentID
        {
            get { return COMPONENT_ID; }
        }

        IList<MenuCommand> IEditorComponent.GetContextMenu(string controlID)
        {
            List<MenuCommand> contextMenu = new List<MenuCommand>();
            contextMenu.Add(new MenuCommand(CONTROL_ID_CONTEXT_MENU_OPTION, "About..."));
            return contextMenu;
        }

        void IEditorComponent.CommandClick(string controlID)
        {
            if (controlID == CONTROL_ID_CONTEXT_MENU_OPTION)
            {
                _editor.GUIController.ShowMessage("AgsGet Editor Plugin made by eri0o", MessageBoxIconType.Information);
            }
            else if (controlID == CONTROL_ID_ROOT_NODE)
            {
                _editor.GUIController.AddOrShowPane(_pane);
                _agsGetPane.PanelReload();
            }
        }

        void IEditorComponent.PropertyChanged(string propertyName, object oldValue)
        {
        }

        void IEditorComponent.BeforeSaveGame()
        {
        }

        void IEditorComponent.RefreshDataFromGame()
        {
            // A new game has been loaded, so remove the existing pane
            _editor.GUIController.RemovePaneIfExists(_pane);
        }

        void IEditorComponent.GameSettingsChanged()
        {
        }

        void IEditorComponent.ToXml(System.Xml.XmlTextWriter writer)
        {
           // writer.WriteElementString("TextBoxContents", ((AgsGetPane)_pane.Control).TextBoxContents);
        }

        void IEditorComponent.FromXml(System.Xml.XmlNode node)
        {
            //if (node == null)
            //{
            //    // node will be null if loading a 2.72 game or if
            //    // the game hasn't used this plugin before
            //    ((AgsGetPane)_pane.Control).TextBoxContents = "";
            //}
            //else
            //{
            //    ((AgsGetPane)_pane.Control).TextBoxContents = node.SelectSingleNode("TextBoxContents").InnerText;
            //}
        }

        void IEditorComponent.EditorShutdown()
        {
        }
    }
}
