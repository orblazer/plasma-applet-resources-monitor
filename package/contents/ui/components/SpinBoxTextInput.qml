import QtQuick 2.2

TextInput {
    color: theme.textColor
    selectionColor: theme.highlightColor
    selectedTextColor: theme.highlightedTextColor

    // Store the previous text for restoring it if we cancel
    property string oldText

    // Lets us know that the user is cancelling the save
    property bool cancelling

     Keys.onEscapePressed: {
        // Cancel the save, and deselect the text input
        cancelling = true
        focus = false
    }

    onEditingFinished: {
        if (cancelling) {
            // When cancelling, restore the old text, and clear state.
            text = oldText
            oldText = ""
            cancelling = false
        }
    }

    onActiveFocusChanged: {
        // When we first gain focus, save the old text and select everything for clearing.
        if (activeFocus) {
            oldText = text
            selectAll()
        }
    }
}
