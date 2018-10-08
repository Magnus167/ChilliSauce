unit ChilliSauce;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, URLMon, ShellApi, Vcl.Grids,
  Vcl.StdCtrls, Vcl.ExtCtrls, IdHashMessageDigest, idHash;

type
  TChilliSauceV1 = class( TForm )
    StringGrid1 : TStringGrid;
    Log : TMemo;
    Timer1 : TTimer;
    Button1 : TButton;
    function DownloadFile( sourceURL, DestFile : string ) : Boolean;
    procedure getFile( );
    procedure FormCreate( Sender : TObject );
    procedure Timer1Timer( Sender : TObject );
    procedure loadFile( );
    procedure readGrid( );
    function addQuotes( s : String ) : String;
    function MD5File( const FileName : string ) : string;
    procedure HashItUp( );
    function GetFileNames( Path : string ) : TStringList;
    function isNew( hash : String ) : Boolean;
    procedure Button1Click( Sender : TObject );
    function addLog( msg : String ) : Boolean;
    procedure deleteTempFiles( );
    procedure FormClose( Sender : TObject; var Action : TCloseAction );


  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  CompletedTorsDir = 'D:\Movies\Completed .torrent files\';
  ToAddTorsDir = 'D:\Movies\To download .torrent\';

var
  ChilliSauceV1 : TChilliSauceV1;
  LoadedFilesHash : TStringList;


implementation

{$R *.dfm}

function TChilliSauceV1.addLog( msg : String ) : Boolean;
var
  I : Integer;
begin

  // add log wraps add to memo and print time with the string in one function
  Log.Lines.Add( '' );
  msg := DateTimeToStr( Now ) + ' : ' + msg;

  for I := 1 to msg.length do
    Log.Lines[Log.Lines.Count - 1] := Log.Lines[Log.Lines.Count - 1] + msg[I];


end;

function TChilliSauceV1.addQuotes( s : String ) : String;
var
  I : Integer;
  temp : String;
begin

  // add quotes before and after each value
  // so the delimiter can be proccessed properly
  // if a CSV doesn't have quotes, Delphi takes SPACE as a delimiter too.
  temp := '';
  for I := 1 to s.length do
    if s[I] = ',' then
      temp := temp + '","'
    else
      temp := temp + s[I];

  temp := '"' + temp + '"';
  Result := temp;


end;

procedure TChilliSauceV1.Button1Click( Sender : TObject );
begin

  // force-refresh button, call the timer1 proc
  Screen.Cursor := crHourGlass;
  //Button1.Enabled := False;

  Timer1Timer( Sender );

 // Button1.Enabled := True;
  Screen.Cursor := crDefault;

end;

procedure TChilliSauceV1.deleteTempFiles;
var
  tempFiles : TStringList;
  I : Integer;
begin

  (*
    generates a list of all files in the temp folder and deletes them
    should be called while exiting
  *)
  tempFiles := TStringList.Create;

  tempFiles := GetFileNames( GetCurrentDir + '\files\temp\' );
  for I := 0 to tempFiles.Count - 1 do
    DeleteFile( GetCurrentDir + '\files\temp\' + tempFiles[I] );
end;

function TChilliSauceV1.DownloadFile( sourceURL, DestFile : string ) : Boolean;

begin

  // download the file from the sourceURL and save it to the DestFile
  (*
    the interesting thing about this function is it can directly be used in an if statement where
    it will download a file and return a true if the download was succesful, preventing errors that can
    occir if we try working with a file without downloading it
  *)
  try
    Result := UrlDownloadToFile( nil, PChar( sourceURL ), PChar( DestFile ), 0,
      nil ) = 0;
  except
    Result := False;
  end;

end;

procedure TChilliSauceV1.FormClose( Sender : TObject;
  var Action : TCloseAction );
begin
  deleteTempFiles( );
end;

procedure TChilliSauceV1.FormCreate( Sender : TObject );
begin
  Log.Text := '';
  Timer1.Interval := 30 * 1000; // set refresh rate
  LoadedFilesHash := TStringList.Create;
  (* the following code checks for directories and files that should be in place.

    if the 'files' directory which holds the CSV files for 'downloaded' and 'to download' files
    doesn't exist, create it
    if there is an error while creating it, ask for relaunch in ADMIN mode
    also, tell the user what's going on in the Log Memo.
    most other messages that are being printed to the log screen are self-explanatory
    it also checks if the 'completed' torrents file (which contains hashes generated from .TORRENT files) exists
    if that file is there, it is loaded into memory.



  *)

  if ( ( ( DirectoryExists( GetCurrentDir + '\files' ) ) AND
    ( DirectoryExists( GetCurrentDir + '\files\temp' ) ) ) ) then
  begin
    addLog( '"files" Directory exists, initilizing program.' );
    addLog( 'loading files.' );

    try
      LoadedFilesHash.LoadFromFile( GetCurrentDir + '\files\completed.csv' );
    except
      addLog( 'Failed to load required files.' );
    end;
  end
  else
  begin
    try
      CreateDir( GetCurrentDir + '\files' );
      CreateDir( GetCurrentDir + '\files\temp' );
      addLog( '"files" Directory does not exist, creating directory' );
      addLog( 'Directory created, initializing program.' )

    except
      ShowMessage( 'Please re-launch the program as administrator.' );
      Exit;
    end;


  end;

  // Timer1Timer( Sender );


end;


procedure TChilliSauceV1.getFile;

var
  sURL, sFile : String;
begin
  (* SourceURL and SaveFile :
    URL from where the CSV is to be fetched and the location it is to be saved at

    the DownloadFile function is explained in its implementation
  *)

  sURL := 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTDrNfxGu1TJFvzKkbm-0Jy-RDYxMWvbA1sJjOqg4FuL3CSnLswI8x6E-cEVfO9WWEURk2IdSOUKDgu/pub?output=csv';
  sFile := GetCurrentDir + '\files\Dloads.csv';

  if DownloadFile( sURL, sFile ) then
  begin
    addLog( 'que Fetch succesful' );
  end
  else
    addLog( 'Error fetching file, check internet connection ' );
end;


function TChilliSauceV1.GetFileNames( Path : string ) : TStringList;

var
  SR : TSearchRec;
  dest : TStringList;
begin

  (* get a list of all files within the folder 'Path'.
    'Path' must have a trailing BACK-SLASH '\' to indicate path is a directory and not a file.
    the '*.*' filter can be replaced by any file type you want to search for.
    since torrent files are usually marked as '*.torrent' i'm using that as a filter;
  *)

  dest := TStringList.Create;

  if FindFirst( Path + '*.torrent', faAnyFile, SR ) = 0 then
    repeat
      dest.Add( SR.Name );
    until FindNext( SR ) <> 0;
  FindClose( SR );

  Result := dest;

end;


procedure TChilliSauceV1.HashItUp;
var
  fileNamesForHash : TStringList;
  I : Integer;
begin
  // initialize stringlists

  fileNamesForHash := TStringList.Create;

  // get a list of all files in the completed dir
  fileNamesForHash := GetFileNames( CompletedTorsDir );


  // add the complete address to the file
  for I := 0 to fileNamesForHash.Count - 1 do
    fileNamesForHash.Strings[I] := CompletedTorsDir +
      fileNamesForHash.Strings[I];


  Screen.Cursor := crHourGlass;
  // hash up all the files ~ and show the hourglass/wheel style point while at it :P
  for I := 2 to fileNamesForHash.Count - 1 do
    LoadedFilesHash.Add( MD5File( fileNamesForHash[I] ) );

  Screen.Cursor := crDefault;

  // then save the hashes to a file for later use

  LoadedFilesHash.SaveToFile( GetCurrentDir + '\files\completed.csv' );

  addLog( 'Hash done' );


end;

function TChilliSauceV1.isNew( hash : String ) : Boolean;
var
  I, tryPos : Integer;
  res : Boolean;

begin
  res := True;

  // checks if a hash already exists in the generated list

  for I := 0 to LoadedFilesHash.Count - 1 do

    if hash = LoadedFilesHash.Strings[I] then
    begin
      res := False;
      Result := res;
      Exit;
    end;

  Result := res;

end;

procedure TChilliSauceV1.loadFile;
var
  ldStr : TStringList;
  I : Integer;
  cTxt : String;
begin
  // init strlist and load the file we just fetched from google sheets
  ldStr := TStringList.Create;
  ldStr.LoadFromFile( GetCurrentDir + '\files\DLoads.csv' );
  StringGrid1.RowCount := ldStr.Count + 1;
  // StringGrid1.ColCount := 10;

  // load the string list to strGrid by adding quotes to the CSV
  for I := 0 to ldStr.Count - 1 do
    StringGrid1.Rows[I].CommaText := addQuotes( ldStr.Strings[I] );
  addLog( 'File loaded.' );


end;

function TChilliSauceV1.MD5File( const FileName : string ) : string;
var
  IdMD5 : TIdHashMessageDigest5;
  FS : TFileStream;
begin

  // Load file 'FileName'
  // Hash the files, and return the hash
  // free memory when done

  IdMD5 := TIdHashMessageDigest5.Create;
  FS := TFileStream.Create( FileName, fmOpenRead or fmShareDenyWrite );
  try
    Result := IdMD5.HashStreamAsHex( FS )
  finally
    FS.Free;
    IdMD5.Free;
  end;

end;

procedure TChilliSauceV1.readGrid;
var
  currFileName : String;
  I, J : Integer;
  Empty : Boolean;
begin
  // read the grid

  for I := 1 to StringGrid1.RowCount - 1 do
  begin
    // if any of the four reqd. fields in a row are empty, do not consider that particular row

    Empty := False;
    for J := 0 to 4 do
      if StringGrid1.Cells[J, I] = '' then
        Empty := True;


    if NOT ( Empty ) then
    begin

      // construct the full name for a torrent file ~ including the directories
      currFileName := GetCurrentDir + '\files\temp\' + StringGrid1.Cells[0, I] +
        '.' + StringGrid1.Cells[1, I] + '.' + StringGrid1.Cells[3, I] + '.' +
        StringGrid1.Cells[4, I] + '.torrent';

      // add hashes to the grid ~ JLT :P


      (*
        the following macro downloads the files listed on the strGrid in a temp. folder
        the file is then used to create a hash ~ MD5 and check if the same file had recently been queued/downloaded
        Namex is the full name of the file

      *)

      if NOT ( StringGrid1.Cells[5, I] = '' ) then
        StringGrid1.Cells[5, I] := MD5File( currFileName );


      if DownloadFile( StringGrid1.Cells[2, I], currFileName ) then
        if isNew( MD5File( currFileName ) ) then
        begin


          LoadedFilesHash.Add( MD5File( currFileName ) );
          StringGrid1.Cells[5, I] := MD5File( currFileName );

          LoadedFilesHash.SaveToFile( GetCurrentDir + '\files\completed.csv' );
          currFileName := StringGrid1.Cells[0, I] + '.' + StringGrid1.Cells
            [1, I] + '.' + StringGrid1.Cells[3, I] + '.' + StringGrid1.Cells
            [4, I] + '.torrent';

          CopyFile( PChar( GetCurrentDir + '\files\temp\' + currFileName ),
            PChar( ToAddTorsDir + currFileName ), False );

          addLog( 'Added New Torrent' );


        end;


    end;

  end;

  addLog( 'Grid read.' );


end;

procedure TChilliSauceV1.Timer1Timer( Sender : TObject );
begin

  // do all the functions
  Screen.Cursor := crHourGlass;
 // Button1.Enabled := True;
  getFile( );
  loadFile( );

  HashItUp( );
  readGrid( );
  //Button1.Enabled := False;
  Screen.Cursor := crDefault;


end;

end.
