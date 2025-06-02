program mdtohtml;

{$mode objfpc}{$H+}


uses
    Classes, SysUtils, CustApp, MarkdownProcessor, MarkdownUtils;
	
type
    TMdToHtml = class(TCustomApplication)
    private
        function readFile(filename: string): string;
        procedure writeFile(filename, content: string);
    protected
        procedure DoRun; override;
    public
        constructor Create(TheOwner: TComponent); override;
        destructor Destroy; override;
        procedure WriteHelp; virtual;
    end;
    
procedure TMdToHtml.DoRun;
var
    ErrorMsg: String;
    InputFileName: String;
    OutputFileName: String;
    TemplateFileName: String;
    TemplateString: String;
    MarkdownDialect: TMarkdownDialect;
    Encoding: String = 'ISO-8859-1';
    HtmlTitle: String = 'Title';
    inputString: String;
    outputString: String;
    md: TMarkdownProcessor;
begin
    ErrorMsg := CheckOptions('hfomet', ['help', 'file', 'outfile', 'mode', 'encoding', 'template']);
    if ErrorMsg <> '' then begin
        ShowException(Exception.Create(ErrorMsg));
        Terminate;
        Exit;
    end;
    
    if HasOption('h', 'help') then begin
        WriteHelp;
        Terminate;
        Exit;
    end;

    { Input file }
    if NOT HasOption('f', 'file') then begin
        WriteHelp;
        Terminate;
        Exit;
    end;
    
    if HasOption('f', 'file') then begin
        InputFileName := getOptionValue('f', 'file');
    end;

    { Markdown dialect }
    if HasOption('m', 'mode') then begin
        Case LowerCase(getOptionValue('m', 'mode')) of
            'daringfireball': MarkdownDialect := mdDaringFireball;
            'txtmark': MarkdownDialect := mdTxtMark;
            'commonmark': MarkdownDialect := mdCommonMark;
            'asciidoc': MarkdownDialect := mdAsciiDoc;
        else
            begin
                WriteLn('Unknown markdown dialect: ', getOptionValue('m', 'mode'));
                WriteHelp;
                Exit;
            end;
        end;
    end;
    
    { Output file }
    if HasOption('o', 'outfile') then begin
        OutputFileName := getOptionValue('o', 'outfile');
    end;
    
    { Encoding }
    if HasOption('e', 'encoding') then begin
        Encoding := getOptionValue('e', 'encoding');
    end;
    
    { Template file }
    if HasOption('t', 'template') then begin
        TemplateFileName := getOptionValue('t', 'template');
    end;

    md := TMarkdownProcessor.createDialect(MarkdownDialect);
    md.UnSafe := true;   
    inputString := readFile(inputFileName);
    outputString := md.process(inputString);
    
    { Output template }
    if TemplateFileName = '' then begin
        TemplateString := '<!DOCTYPE html>' +
        '<html><head>' +
        '<meta charset="$encoding$" />' +
        '<title>$title$</title>' +
        '</head>' +
        '<body>$body$</body>' +
        '</html>';
    end else begin
        TemplateString := readFile(TemplateFileName);
    end;
    
    TemplateString := StringReplace(TemplateString, '$title$', HtmlTitle, [rfIgnoreCase, rfReplaceAll]);
    TemplateString := StringReplace(TemplateString, '$encoding$', Encoding, [rfIgnoreCase, rfReplaceAll]);
    TemplateString := StringReplace(TemplateString, '$body$', outputString, [rfIgnoreCase]);
    
    if OutputFileName = '' then begin
        writeln(TemplateString);
    end else begin
        writeFile(OutputFileName, TemplateString);
    end;
    
    Terminate;
end;

constructor TMdToHtml.Create(TheOwner: TComponent);
begin
    inherited Create(TheOwner);
    StopOnException := True;
end;

destructor TMdToHtml.Destroy;
begin
    inherited Destroy;
end;

procedure TMdToHtml.WriteHelp;
begin
    writeln('Usage: mdtohtml [-h|--help] -f|--file <input file> [-o|--outfile <output file>] [-m|--mode <markdown mode>] [-e|--encoding <character encoding>] [-t|--template <template file>]');
end;

function TMdToHtml.readFile(filename: string): string;
var
    stream: TFileStream;
begin
    stream := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
    try
        SetLength(Result, stream.Size);
        stream.Read(Result[1], stream.Size);
    finally
        stream.Free;
    end;
end;

procedure TMdToHtml.writeFile(filename, content: string);
var
    F: TextFile;
begin
    AssignFile(F, filename);
    try
        ReWrite(F);
        Write(F, content);
    finally
        CloseFile(F);
    end;
end;


var
    Application: TMdToHtml;
begin
    Application := TMdToHtml.Create(nil);
    Application.Title := 'Markdown to HTML';
    Application.Run;
    Application.Free;
end.
