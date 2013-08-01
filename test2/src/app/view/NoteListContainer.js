/* 
 *  Copyright (c) 2012. All Rights Reserved. The PlumTree Group
 *  Code is under development state at The PlumTree Group written by
 *  Hamza Waqas (Mobile Application Developer) at Karachi from MacOSX
 */


Ext.define("OnNotes.view.NoteListContainer", {
    extend : "Ext.Container",
    alias: "widget.noteslistcontainer",
    initialize: function() {
        this.callParent(arguments);
        
        var newButton = {
            xtype:  "button",
            text:   "New",
            ui:     "action ",
            handler: this.onNewButtonTap,
            scope:  this
        }
        
        var topToolbar = {
            xtype:  "toolbar",
            title:  "My Notes",
            docked: "top",
            items: [
                {xtype: "spacer"},
                newButton
            ]
        }
        
        var noteList = {
            xtype: "noteslist",
            store: Ext.getStore("Notes"),
            listeners: {
                disclose: {
                    fn: this.onNoteListDisclose,
                    scope: this
                }
            }
        }
        
        this.add([topToolbar,noteList]);
    },
    onNewButtonTap: function() {
        this.fireEvent("newNoteCommand",this);
    },
    onNoteListDisclose: function(list,record,target,index,evt,options) {
        this.fireEvent("editNoteCommand",this,record);
    },
    config: {
        layout: {
            type: "fit"
        }
    }
    
});