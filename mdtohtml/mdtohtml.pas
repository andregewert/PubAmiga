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
{    i: integer; }
    InputFileName: String;
    OutputFileName: String;
    inputString: String;
    outputString: String;
    md: TMarkdownProcessor;
begin
    ErrorMsg := CheckOptions('hfo', ['help', 'file', 'outfile']);
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

    if NOT HasOption('f', 'file') then begin
        WriteHelp;
        Terminate;
        Exit;
    end;
    
    if HasOption('f', 'file') then begin
        InputFileName := getOptionValue('f', 'file');
    end;
    
    if HasOption('o', 'outfile') then begin
        OutputFileName := getOptionValue('o', 'outfile');
    end;
    
{
    for i := 0 to getEnvironmentVariableCount() -1 do begin
        writeln(getEnvironmentString(i));
    end;
}

    md := TMarkdownProcessor.createDialect(mdDaringFireball);
    md.UnSafe := true;
    
    inputString := readFile(inputFileName);
    
    outputString := md.process(inputString);
    
    if OutputFileName = '' then begin
        writeln(outputString);
    end else begin
        writeFile(OutputFileName, outputString);
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
    { mdtohtml -f inputfile [-o outputfile] }
    writeln('Usage: ', ExeName, ' -h');
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
