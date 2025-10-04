/**
 * A simple GUI for editing and previewing Markdown files
 * Author: Andre Gewert <agewert@gmail.com>
 * Created: 2025-06-19
 */

SIGNAL ON ERROR
SIGNAL ON HALT
SIGNAL ON BREAK_C

args.displayFile = ''
PARSE ARG args.displayFile
/*Call dumpVar('args.displayFile')*/

call Init
call CreateApp
if Length(args.displayFile) > 0 THEN DO
    CALL loadFile(args.displayFile)
END
call HandleApp

/***********************************************************************/
Init: procedure expose global. args.
    l="rmh.library";if ~show("L",l) then;if ~addlib(l,0,-30) then exit
    if AddLibrary("rxmui.library")~=0 then exit
    if AddLibrary("rxasl.library")~=0 then exit
    call rxmuiopt("debugmode showerr")
    call setrxmuistack(32000)
    global.currentFile = ''
return
    
/* <fold> CreateApp */
CreateApp: procedure expose global.

    app.Title="Markdown editor"
    app.Version="$VER: Markdown editor 1.0 (16.06.2025)"
    app.Copyright="©2025, www.ubergeek.de"
    app.Author="André Gewert"
    app.Description="Markdown editor"
    app.Base="MDEDIT"
    app.menustrip="muiMenuStrip"
    app.SubWindow="win"
        win.ID="MAIN"
        win.Title="Markdown editor"
        win.Contents="mgroup"
        win.userightborderscroller=1
        win.sizeright=1
        
        mgroup.0="thebargroup"
            thebargroup.class="TheBar"
            thebargroup.Horiz=1
            thebargroup.PicsDrawer="icons"
            thebargroup.EnabeKeys=1
            thebargroup.Framed=1
            thebargroup.DragBar=0
            thebargroup.AutoID=1
            thebargroup.ViewMode="GFX"

            thebargroup.Pics.0="TBImages:new"
            thebargroup.Pics.1="TBImages:open"
            thebargroup.Pics.2="TBImages:refresh"
            thebargroup.Pics.3="TBImages:save"
            thebargroup.Pics.4="TBImages:saveas"
            thebargroup.Pics.5="TBImages:copyfile"
            thebargroup.Pics.6="TBImages:info"
            
            thebargroup.0.Img=0
            thebargroup.0.Text="New"
            thebargroup.0.Help="Create new document"
            
            thebargroup.1.Img=1
            thebargroup.1.Text="Open"
            thebargroup.1.Help="Open markdown file"
            
            thebargroup.2.Img=2
            thebargroup.2.Text="Refresh"
            thebargroup.2.Help="Refresh HTML preview"
            
            thebargroup.3.Img=3
            thebargroup.3.Text="Save"
            thebargroup.3.Help="Save markdown file"
            
            thebargroup.4.Img=4
            thebargroup.4.Text="Save as"
            thebargroup.4.Help="Save markdown file as ..."
            
            thebargroup.5.Img=5
            thebargroup.5.Text="Save HTML"
            thebargroup.5.Help="Save HTML file as ..."

            thebargroup.6.Img=6
            thebargroup.6.Text="Info"
            thebargroup.6.Help="About this application"

        mgroup.1="np"
            np.class="HGroup"
            np.0="nph"
                nph.class="group"
                nph.Horiz=1
                nph.Spacing=0
                nph.0="editor"
                    editor.class="texteditor"
                    editor.frame="virtual"
                    editor.FIXEDFONT=1
                    editor.slider=XNewObj("scrollbar","editorscr")
                nph.1="editorscr"
                np.1="npbal"
                    npbal.class="Balance"
                np.2="nppre"
                    nppre.class="scrollgroup"
                    nppre.UseWinBorder=1
                    nppre.virtgroupcontents="hp"
                        hp.class="htmlview"
                        hp.frame="virtual"
                        hp.ntautoload=1
                        hp.nocontextmenu=1
        mgroup.2="status"
            status.Class="Text"
            status.Frame="Text"
            status.Contents=""
            
            
    muiMenuStrip.0 = "muiMenuProject"
	muiMenuProject.Title = "Project"
	muiMenuProject.Class = "MENU"
	muiMenuProject.0 = MenuItem('muiProjectNew', 'New', 'N')
	muiMenuProject.1 = MenuItem("muiProjectOpen", "Open ...", "O")
	muiMenuProject.2 = MenuItem("muiProjectSave", "Save", "S")
	muiMenuProject.3 = MenuItem("muiProjectSaveAs", "Save As ...", "A")
	muiMenuProject.4 = MenuItem("muiProjectSaveAs", "Export HTML ...", "H")
	muiMenuProject.5 = MenuItem("", "BAR")
	muiMenuProject.6 = MenuItem("muiMenuQuit", "Quit", "Q")

    muiMenuStrip.1 = "muiMenuAbout"
        muiMenuAbout.Title      = "?"
        muiMenuAbout.Class      = "MENU"
        muiMenuAbout.0 = MenuItem("muiMenuAboutME", "About ...", "?")
        muiMenuAbout.1 = MenuItem("", "BAR")
        muiMenuAbout.2 = MenuItem("muiMenuAboutrxMUI", "About RxMUI ...")
        muiMenuAbout.3 = MenuItem("muiMenuAboutMUI", "About MUI ...")
    
    res = NewObj("MENUSTRIP", "muiMenuStrip")
    if res ~= 0 THEN exit
    res = NewObj("APPLICATION","APP")
    if res~=0 then exit
    
    call Notify("win","closerequest",1,"app","returnid","quit")

    /* Menu events */
    CALL Notify("muiProjectOpen", "MENUTRIGGER", "EVERYTIME", "app", "RETURNID")

    /* Toolbar button events */
    call TheBarNotify("thebargroup",0,"pressed",0,"app","return","call NewButtonPressed")
    call TheBarNotify("thebargroup",1,"pressed",0,"app","return","call OpenButtonPressed")
    call TheBarNotify("thebargroup",2,"pressed",0,"app","return","call RefreshButtonPressed")
    call TheBarNotify("thebargroup",3,"pressed",0,"app","return","call SaveButtonPressed")
    call TheBarNotify("thebargroup",4,"pressed",0,"app","return","call SaveAsButtonPressed")
    call TheBarNotify("thebargroup",5,"pressed",0,"app","return","call SaveHtmlAsButtonPressed")
    call TheBarNotify("thebargroup",6,"pressed",0,"app","return","call InfoButtonPressed")

    call set("win","open",1)
return
/* </fold> */

/***********************************************************************/
HandleApp: procedure expose global.
    DO FOREVER
        h.event = ''
        CALL NewHandle("APP", "H", 2**12)
        if and(h.signals,2**12)>0 THEN Signal QUIT

        SELECT
            /*when h.event="QUIT" then exit*/
            WHEN h.event = 'QUIT' THEN DO
                EXIT
            END
            
            WHEN h.event = 'MUIPROJECTOPEN' THEN DO
                Say 'Menu: Open'
                CALL OpenButtonPressed
            END
            
            OTHERWISE interpret h.event
        end
    end
end

NewButtonPressed: procedure
    Say 'New'
return

OpenButtonPressed: procedure
    Say 'Open'
    Call System('RequestFile PATTERN="#?.md"', 10000, "name")
    IF name ~= '' THEN DO
        name = Substr(name, 1, Length(name) -1)
        CALL loadFile(name)
    END
return

RefreshButtonPressed: procedure
    Say 'Refresh'
    CALL updatePreview()
return

SaveButtonPressed: PROCEDURE EXPOSE global.
    Say 'Save'
    IF global.currentFilename = '' THEN DO
        CALL SaveAsButtonPressed()
        RETURN
    END
return

SaveAsButtonPressed: procedure
    Say 'Save as'
return

SaveHtmlAsButtonPressed: procedure
    Say 'Save html as'
    name = ''
    CALL System('RequestFile PATTERN="#?.html"', 10000, "name")
    Say "'" || name || "'"
    IF name ~= '' THEN DO
        name = Substr(name, 1, Length(name) -1)
        CALL saveHtmlAs(name)
    END
RETURN

InfoButtonPressed: procedure
    Say 'Info'
RETURN

/**
 * Opens (loads) the given file and update the HTML preview.
 * @param String filename
 */
loadFile: procedure EXPOSE global.
    PARSE ARG filename
    Say "Open file: '" || filename || "'"
    source = ''
    in = ''
    
    If ~Open(in, filename, 'read') THEN DO
        Say "Could not open file"
        Return
    End
    Do While ~EOF(in)
        source = source || READCH(in, 1000)
    End
    Call Close(in)

    global.currentFile = filename
    Call setStatusText(filename)
    Call set("editor", "contents", source)
    Call updatePreview
return

saveMarkdownAs: PROCEDURE EXPOSE global.
    PARSE ARG filename
    Say "Save markdown as '" || filename || "'"
Return

saveHtmlAs: PROCEDURE EXPOSE global.
    PARSE ARG filename
    Say "Save HTML as '" || filename || "'"
    
    tempFileIn = 'ram:mdedit-' || pragma('id')
    CALL getattr("editor", "contents", source)
    
    Open(in, tempFileIn, 'w')
    WriteLn(in, source)
    Close(in)
    
    Address command 'mdtohtml -f ' || tempFileIn || ' -o ' || filename

    preview = ''
    Open(out, filename, 'R')
    Do While ~EOF(out)
        preview = preview || READCH(out, 1000)
    End
    Close(out)
    ADDRESS command 'Delete QUIET ' || tempFileIn
    CALL set("hp", "contents", preview)
Return

/**
 * Changes the text of the status bar
 * @param String message
 */
setStatusText: procedure
    parse arg message
    call set("status", "contents", message)
return

/***********************************************************************/
Quit:
Halt:
Break_c:
    exit
    
/***********************************************************************/
openfile: procedure
    if reqfile(f)~=0 then return
    call domethod("text","open",addpart(f.drawer,f.file))
    call pragma("D",f.drawer)
    return

/***********************************************************************/
insertfile: procedure
    if reqfile(f)~=0 then return
    call domethod("text","insert",addpart(f.drawer,f.file))
    call pragma("D",f.drawer)
    return

/***********************************************************************/
savefile: procedure
    if reqfile(f)~=0 then return
    call domethod("text","save",addpart(f.drawer,f.file))
    call pragma("D",f.drawer)
    return
    
/***********************************************************************/
updatePreview: procedure
    tempFileIn = 'ram:mdedit-' || pragma('id')
    tempFileOut = 'PIPE:mdeditout' || pragma('id')

    Call getattr("editor", "contents", source)
    Call Open(in, tempFileIn, 'w')
    Call WriteLn(in, source)
    Call Close(in)
    
    Address command 'mdtohtml -f ' || tempFileIn || ' >' || tempFileOut

    preview = ''
    Call Open(out, tempFileOut, 'R')
    Do While ~EOF(out)
        preview = preview || READCH(out, 1000)
    End
    Call Close(out)
    Address command 'Delete QUIET ' || tempFileIn
    Call set("hp", "contents", preview)
return

dumpVar:
    PARSE ARG vn
    INTERPRET 't = "'|| vn || ' = ["'|| vn ||'"]"'
    Say t
Return 0

/*
Error:
    f = rc
    str = "Command in line "|| sigl || " throws RC="|| f
    Say str
Return
*/
