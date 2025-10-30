program GlobalSearchExample;

{$mode objfpc}{$H+}

uses
  fpjson, jsonparser, SysUtils, Classes, fphttpclient, AnytypeAPIcalls,
  Generics.Collections, fileinfo;

var
  Result      : TJSONObject;
  i           : Integer;
  MyParamCount: Integer;
  DataResults : TJSONArray;
  Key         : string;
  Spaces      : specialize TDictionary<string, string>;
  ListSpaces  : boolean = False;
  Help        : boolean = False;
  Verbose     : boolean = False;
  Quiet       : boolean = False;
  MAX_OUTPUT  : Integer = 200;
  Info        : TVersionInfo;

{$R *.res}

begin
  { look for command switches }
  for i := 0 to ParamCount do
  begin
     case (ParamStr(i)) of
       '-s' : ListSpaces := True;
       '-v' : Verbose := True ;
       '-h' : Help := True;
       '-q' : Quiet := True;
     else
       Key := ParamStr(i);
     end;
  end;

  MyParamCount := ParamCount;
  if Quiet then
    MyParamCount := MyParamCount - 1
  else
  begin
    Info := TVersionInfo.Create;
    try
    { Load version info from the current executable }
      Info.Load(HInstance);
    { Access FileVersion (e.g., for display in an About box) }
      WriteLn(ExtractFileName(ParamStr(0)), ' ',
        Format('%d.%d.%d.%d', [Info.FixedInfo.FileVersion[0],
                               Info.FixedInfo.FileVersion[1],
                               Info.FixedInfo.FileVersion[2],
                               Info.FixedInfo.FileVersion[3]]));
      WriteLn;

    finally
      Info.Free;
    end;
  end;

  If Help then
  begin
    WriteLn('Usage         : ', ExtractFileName(ParamStr(0)), ' [-s] [-h] [-v] [SearchString]');
    WriteLn(' -h           : This Help message');
    WriteLn(' -s           : List Space Names prior to results');
    WriteLn(' -v           : Output up to 32K characters per Object (default is 200)');
    WriteLn(' -q           : Suppress Version info');
    WriteLn(' SearchString : Enclose in double quotes "" if it contains spaces');
    Exit;
  end;

  if Verbose then
  begin
    MAX_OUTPUT := 32000;
    MyParamCount := MyParamCount - 1;
  end;

  if ListSpaces then
  begin
    Writeln('Spaces');
    MyParamCount := MyParamCount - 1;
  end;

  { Initialise a dictionary to decode Spaces in results }
  Result := AnytypeAPIListSpaces;
  DataResults := TJSONArray(Result.FindPath('data'));
  Spaces := specialize TDictionary<string, string>.Create;
  for i:=0 to DataResults.Count - 1 do
  begin
     Spaces.Add(DataResults[i].FindPath('id').AsString,
       DataResults[i].FindPath('name').AsString);
     if ListSpaces then
       Writeln('Space: ', DataResults[i].FindPath('name').AsString);
  end;
  if ListSpaces then
    Writeln;

  { Get the Search term from command line or prompt if none }

  if (MyParamCount < 1) then
  begin
    Write('Enter global search term: ');
    ReadLn(Key);
  end;

  { Format Key for API Call }
  Key := Concat('"', Key, '"');

  { Call the API and translate to useable JSON }
  { Blank P2 means search all Object Types }
  Result := AnytypeAPISearchGlobal(Key, '');
  DataResults := TJSONArray(Result.FindPath('data'));

  { Output raw results }
  for i:=0 to DataResults.Count - 1 do
  begin
    Write(i,' | ', LeftStr(DataResults[i].FindPath('name').AsString, MAX_OUTPUT));
    if Length(DataResults[i].FindPath('name').AsString) > MAX_OUTPUT then
      Write(' (more...)');
    WriteLn(' | ', DataResults[i].FindPath('type.name').AsString,
      ' | ', Spaces[DataResults[i].FindPath('space_id').AsString]);
    Write(LeftStr(DataResults[i].FindPath('snippet').AsString, MAX_OUTPUT));
    if Length(DataResults[i].FindPath('snippet').AsString) > MAX_OUTPUT then
      Write(' (more...)');
    WriteLn;
    WriteLn;
  end;
end.
