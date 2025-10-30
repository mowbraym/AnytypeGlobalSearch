// reference for the API is at https://developers.anytype.io/docs/reference
//
unit AnytypeAPIcalls;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, fpjson;

// Spaces
function AnytypeAPIListSpaces                 : TJSONObject;
function AnytypeAPIGetSpace(SpaceId : string) : TJSONObject;

// Search
function AnytypeAPISearchGlobal(SearchTerm, ObjectTypes : string) : TJSONObject;
function AnytypeAPISearchSpace(SearchTerm, ObjectTypes, SpaceId : string) : TJSONObject;

implementation

var
  Client: TFPHTTPClient;
  RequestBody, Response: TStringStream;
  JsonData, URL : string;

procedure InitialiseClient;forward;
procedure CleanUp;forward;

{ List all Spaces
  Returns a TJSONObject
}
function AnytypeAPIListSpaces : TJSONObject;
begin
  InitialiseClient;
  try
    Client.Get(URL + 'spaces?limit=1000', Response);
    AnytypeAPIListSpaces:=TJSONObject(GetJSON(Response.DataString));

  except
    on E: Exception do
          WriteLn('Error occurred: ', E.Message);
  end;
end;

{ Get a single Space
  SpaceId is a simple string returned from List Spaces
  Returns a TJSONObject
}
function AnytypeAPIGetSpace(SpaceId : string) : TJSONObject;
begin
  InitialiseClient;
  try
    Client.Get(URL + 'spaces/' + SpaceId, Response);
    AnytypeAPIGetSpace:=TJSONObject(GetJSON(Response.DataString));

  except
    on E: Exception do
          WriteLn('Error occurred: ', E.Message);
  end;
end;

{ Search across all Spaces
  SearchTerm is a double quoted string, "" for all. e.g. "test"
  Object Types is a comma separated list of Anytype Types, e.g. "page", "task", "bookmark"
  Returns a TJSONObject
}
function AnytypeAPISearchGlobal(SearchTerm, ObjectTypes : string) : TJSONObject;
begin
  InitialiseClient;

  try
    // Prepare JSON request body
    JsonData :=
      '{' +
      '  "query": ' + SearchTerm + ',' +
      '  "sort": {' +
      '    "direction": "desc",' +
      '    "property_key": "last_modified_date"' +
      '  },' +
      '  "types": [ ' + ObjectTypes + ' ]' +
      '}';

    // Write JSON to the request stream
    RequestBody.WriteString(JsonData);
    RequestBody.Position:=0;

    // Send the POST request
    Client.AllowRedirect:=True;
    Client.RequestBody:=RequestBody;
    Client.Post(URL + 'search?limit=1000', Response);

    AnytypeAPISearchGlobal:=TJSONObject(GetJSON(Response.DataString));

  except
    on E: Exception do
      WriteLn('Error occurred: ', E.Message);
  end;
end;

{ Search within a Space
  SpaceId is a simple string returned from List Spaces
  SearchTerm is a double quoted string, "" for all. e.g. "test"
  Object Types is a comma separated list of Anytype Types, e.g. "page", "task", "bookmark"
  Returns a TJSONObject
}
function AnytypeAPISearchSpace(SearchTerm, ObjectTypes, SpaceId : string) : TJSONObject;
begin
  InitialiseClient;

  try
    // Prepare JSON request body
    JsonData :=
      '{' +
      '  "query": ' + SearchTerm + ',' +
      '  "sort": {' +
      '    "direction": "desc",' +
      '    "property_key": "last_modified_date"' +
      '  },' +
      '  "types": [ ' + ObjectTypes + ' ]' +
      '}';

    // Write JSON to the request stream
    RequestBody.WriteString(JsonData);
    RequestBody.Position:=0;

    // Send the POST request
    Client.AllowRedirect:=True;
    Client.RequestBody:=RequestBody;
    Client.Post(URL + 'spaces/' + SpaceId +'/search?limit=1000', Response);

    AnytypeAPISearchSpace:=TJSONObject(GetJSON(Response.DataString));

  except
    on E: Exception do
      WriteLn('Error occurred: ', E.Message);
  end;
end;

//private
procedure InitialiseClient;
begin
  URL := GetEnvironmentVariable('ANYTYPE_URL');
  Client:=TFPHTTPClient.Create(nil);
  RequestBody:=TStringStream.Create('');
  Response:=TStringStream.Create('');
  try
    // Set headers
    Client.AddHeader('Content-Type', 'application/json');
    Client.AddHeader('Accept', 'application/json');
    Client.AddHeader('Authorization', GetEnvironmentVariable('ANYTYPE_TOKEN'));
    Client.AddHeader('Anytype-Version', '2025-05-20');
  except
    on E: Exception do
      WriteLn('Error occurred: ', E.Message);
  end;
end;

procedure CleanUp;
begin
  Client.Free;
  RequestBody.Free;
  Response.Free;

end;

end.
