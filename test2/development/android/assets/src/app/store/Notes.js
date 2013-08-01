/* 
 *  Copyright (c) 2012. All Rights Reserved. The PlumTree Group
 *  Code is under development state at The PlumTree Group written by
 *  Hamza Waqas (Mobile Application Developer) at Karachi from MacOSX
 */


Ext.define("OnNotes.store.Notes", {
    extend: "Ext.data.Store",
    requires: ["Ext.data.proxy.LocalStorage"],
    config: {
        model: "OnNotes.model.Note",
        proxy: {
            type: "localstorage",
            id:   "notes-app-store"
        },
        sorter: [{property: "dateCreated", direction: "DESC"}],
        grouper: {
            sortProperty: "dateCreated",
            direction:    "DESC",
            groupFn: function(record) {
                if (record && record.data.dateCreated) {
                    return record.data.dateCreated.toDateString();
                } else {
                    return "";
                }
            }
        }
    }
});