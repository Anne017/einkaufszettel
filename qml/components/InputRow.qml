import QtQuick 2.7
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Popups 1.3

Row{
    id: root

    property string placeholderText: ""
    property string text: input.text
    property bool enabled: true

    property var db_histo
    property var model: ListModel{}

    function updateModel(){
        model.clear()
        var rows = db_histo.selectKeys()
        if (rows)
            for (var i=0;i<rows.length;i++)
                model.append(rows[i])
    }

    SortFilterModel{
        id: filterModel
        model: root.model
        sort.property: "key"
        sort.order: Qt.AscendingOrder
        sortCaseSensitivity: Qt.CaseInsensitive
        filter.property: "key"
        filter.pattern: new RegExp(input.text)
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    signal accepted()
    function reset(){input.text = ""}

    property int dropDownRowHeight: units.gu(5)
    property int dropDownMaxRows: 5

    padding: units.gu(2)
    spacing: units.gu(2)
    TextField{
        id: input
        width: root.width - button.width - 2*inputRow.padding - inputRow.spacing
        placeholderText: root.placeholderText
        enabled: root.enabled
        onAccepted: {
            root.accepted()
        }
        onFocusChanged: if (!focus) dropDown.visible = false
        onTextChanged:  dropDown.visible = (db_histo.active && text.length>0)
        inputMethodHints: Qt.ImhNoPredictiveText
        Rectangle{
            id: dropDown
            anchors{
                left:  input.left
                right: input.right
                top:   input.bottom
            }
            height: (dropDownList.model.count<dropDownMaxRows ? dropDownList.model.count : dropDownMaxRows)*dropDownRowHeight
            visible: false

            color: theme.palette.normal.field
            border.width: 1
            border.color: theme.palette.normal.base
            radius: units.gu(1)

            UbuntuListView{
                id: dropDownList
                anchors.fill: parent
                model: filterModel
                clip: true
                currentIndex: -1
                delegate: ListItem{
                    height: root.dropDownRowHeight
                    Label{
                        anchors.centerIn: parent
                        text: key
                    }
                    onClicked: {
                        input.text = key
                        root.accepted()
                    }
                }
            }
        }
    }
    Button{
        id: button
        color: theme.palette.normal.positive
        width: 1.6*height
        iconName: "add"
        enabled: root.enabled
        onClicked: root.accepted()
    }
}