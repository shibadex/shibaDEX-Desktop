import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import Qaterial 1.0 as Qaterial

import App 1.0
import "../Components"


Qaterial.ToolTip
{	
	id: _control
	property string tip_position: ""
	property string text_value: ""
	
	function getPos(pos) {
		console.log(pos)
		switch(pos) {
			case 'Top':
				return Qaterial.Style.Position.Top
			default: 
				return Qaterial.Style.Position.Right
		}
	}

    contentItem: DexLabel {
	   text: qsTr(_control.text_value)
       font: DexTypo.caption
       color: DexTheme.foregroundColor
	   padding: 5
	}
	visible: parent.mouse_area.containsMouse && !sidebar.expanded
	background: FloatingBackground {auto_set_size: false}
	position: getPos(_control.tip_position)
} 
