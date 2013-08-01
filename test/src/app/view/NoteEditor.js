/* 
 *  Copyright (c) 2012. All Rights Reserved. The PlumTree Group
 *  Code is under development state at The PlumTree Group written by
 *  Hamza Waqas (Mobile Application Developer) at Karachi from MacOSX
 */


Ext.define("OnNotes.view.NoteEditor", {
    extend: "Ext.form.Panel",
    requires: "Ext.form.FieldSet",
    alias: "widget.noteeditor",
    config: {
        scrollable: true
    },
    initialize: function() {
        this.callParent(arguments);
        
        var backButton = {
            xtype:  "button",
            ui:     "back",
            text:   "Home",
            scope:  this,
            handler: this.onBackButtonTap
        };
        
        var saveButton = {
            xtype: "button",
            ui:    "action",
            text:  "Save",
            scope: this,
            handler: this.onSaveButtonTap
        };
        
        var topToolbar = {
            xtype: "toolbar",
            docked:"top",
            title: "Edit Note",
            items: [
                backButton,
                {xtype: "spacer"},
                saveButton
            ]
        }
        
        var deleteButton = {
            xtype: "button",
            iconCls: "trash",
            iconMask: true,
            scope:  this,
            handler: this.onDeleteButtonTap
        }
        
        var bottomToolbar = {
            xtype: "toolbar",
            docked: "bottom",
            items: [
                deleteButton
            ]
        }
        
        var noteTitleEditor = {
            xtype: "textfield",
            name:  "title",
            label: "Title",
            required: true
        }
        
        var noteNarrativeEditor = {
            xtype:  "textareafield",
            name:   "narrative",
            label:  "Narrative"
        }
        
        this.add([
            topToolbar,
                {xtype: "fieldset",
                    items: [noteTitleEditor,noteNarrativeEditor]},
            bottomToolbar
        ]);
    },
    onSaveButtonTap: function() {
        console.log("onSave");
        this.fireEvent("saveNoteCommand",this);
    },
    onBackButtonTap: function() {
        this.fireEvent("backNoteCommand",this);
    },
    onDeleteButtonTap: function () {
        this.fireEvent("deleteNoteCommand",this);
    }
});