/* 
 *  Copyright (c) 2012. All Rights Reserved. The PlumTree Group
 *  Code is under development state at The PlumTree Group written by
 *  Hamza Waqas (Mobile Application Developer) at Karachi from MacOSX
 */


Ext.define("OnNotes.view.NotesList", {
    extend: "Ext.dataview.List",
    alias:  "widget.noteslist",
    config: {
        loadingText: "Loading your Notes!..",
        emptyText:   '<pre><div class="no-new-note-found">No Note Found yet!</div></pre>',
        onItemDisclosure: true,
        grouped: true,
        itemTpl: '<pre><div class="item-title">{title}</div><div class="item-narrative">{narrative}</div></pre>'
    }
});