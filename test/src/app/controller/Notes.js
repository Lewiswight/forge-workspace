/* 
 *  Copyright (c) 2012. All Rights Reserved. The PlumTree Group
 *  Code is under development state at The PlumTree Group written by
 *  Hamza Waqas (Mobile Application Developer) at Karachi from MacOSX
 */


Ext.define("OnNotes.controller.Notes",{
    extend: "Ext.app.Controller",
    config: {
        refs: {
            notesListContainer: "noteslistcontainer",
            noteEditor:         "noteeditor"
        },
        control: {
            notesListContainer: {
                newNoteCommand: "onNewNoteCommand",
                editNoteCommand: "onEditNoteCommand"
            },
            noteEditor: {                
                saveNoteCommand:    "onSaveNoteCommand",
                deleteNoteCommand:  "onDeleteNoteCommand",
                backNoteCommand:    "onBackNoteCommand"
            }
        }
    },
    
    onNewNoteCommand: function() {
        var now = new Date();
        var noteId = (now.getTime()).toString() + (this.getRandomInt(0,100)).toString();
        
        var newNote = Ext.create("OnNotes.model.Note", {
            id: noteId,
            dateCreated: now,
            title: "",
            narrative: ""
        });
        
        this.activateNoteEditor(newNote);
    },
    onEditNoteCommand: function(list,record) {
        this.activateNoteEditor(record);
    },
    onSaveNoteCommand: function() {
        var noteEditor = this.getNoteEditor();

        var currentNote = noteEditor.getRecord();
        var newValues = noteEditor.getValues();

        // Update the current note's fields with form values.
        currentNote.set("title", newValues.title);
        currentNote.set("narrative", newValues.narrative);

        var errors = currentNote.validate();

        if (!errors.isValid()) {
            Ext.Msg.alert('Wait!', errors.getByField("title")[0].getMessage(), Ext.emptyFn);
            currentNote.reject();
            return;
        }

        var notesStore = Ext.getStore("Notes");

        if (null == notesStore.findRecord('id', currentNote.data.id)) {
            notesStore.add(currentNote);
        }

        notesStore.sync();

        notesStore.sort([{property: 'dateCreated', direction: 'DESC'}]);

        this.activateNoteList();
        
    },
    onBackNoteCommand: function() {
        this.activateNoteList();
    },
    onDeleteNoteCommand: function() {
        var noteEditor = this.getNoteEditor();
        var currNote   = noteEditor.getRecord();
        var noteStore  = Ext.getStore("Notes");
        
        noteStore.remove(currNote);
        noteStore.sync();
        this.activateNoteList();
    },
    launch: function() {
        this.callParent(arguments);
        Ext.getStore('Notes').load();
        console.log("launch")
    },
    init: function() {
        this.callParent(arguments);
        console.log("init")
    },
    getRandomInt: function (min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    },
    activateNoteEditor: function(record) {
        var noteEditor = this.getNoteEditor();
        //console.log(noteEditor);
        noteEditor.setRecord(record);
        Ext.Viewport.animateActiveItem(noteEditor,this.slideLeftTransition);
    },
    activateNoteList: function() {
        Ext.Viewport.animateActiveItem(this.getNotesListContainer(),this.slideRightTransition);
    },
    slideLeftTransition: {type: "slide", direction: "left"},
    slideRightTransition: {type: 'slide', direction: 'right'}
});