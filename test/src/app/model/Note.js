/* 
 *  Copyright (c) 2012. All Rights Reserved. The PlumTree Group
 *  Code is under development state at The PlumTree Group written by
 *  Hamza Waqas (Mobile Application Developer) at Karachi from MacOSX
 */

Ext.define("OnNotes.model.Note", {
    extend: "Ext.data.Model",
    config: {
        idProperty: "id",
        fields: [
            { name: "id", type: "int"},
            { name: "dateCreated", type: "date", dataFormat: "c"},
            { name: "title", type: "string"},
            { name: "narrative", type: "string"},
        ],
        validations: [
            { type: "presence", field: "id"},
            { type: "presence", field: "title"},
            { type: "presence", field: "narrative", message: "Please enter a title for this note."},
        ]
    }
});
