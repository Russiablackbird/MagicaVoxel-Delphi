unit VoxelEngine;

interface

uses System.SysUtils, System.Classes;

type
  Colour = record
    R: Byte;
    G: Byte;
    B: Byte;
    A: Byte;
  end;

type
  MagicaVoxelData = record
    x: Byte;
    y: Byte;
    z: Byte;
    color: Byte;
  end;

type
  VoxData = record
    FStream: TMemoryStream;
    Map_X, Map_Y, Map_Z: Integer; // SIZE MAP TO X Y Z;
    Map: array of MagicaVoxelData; // array X Y Z Color;
    Palette: array [0 .. 255] of Colour; // MAP Palette RGB;
    _MagicaVoxelData: MagicaVoxelData;
    magic: array [0 .. 3] of AnsiChar; // 'VOX '
    chunkID: array [0 .. 3] of AnsiChar; // CHUNK NAME MAIN RGBA XYZI SIZE PACK
    Version: Integer; // 150
    ChunkSize: Integer; // -
    ChunkChild: Integer; // -
    NumModels: Integer; // Voxel count
    ChunkName: string; // CHUNK NAME MAIN RGBA XYZI SIZE PACK
  end;

type
  VoxManager = class
    constructor Create(FileName: String);
    class function ExtractMap(): VoxData;
  end;

implementation

var
  _VoxData: VoxData;

constructor VoxManager.Create(FileName: String);
begin
  _VoxData.FStream := TMemoryStream.Create;
  _VoxData.FStream.LoadFromFile(FileName);
end;

class function VoxManager.ExtractMap(): VoxData;
var
  i: Integer;
begin
  _VoxData.FStream.Read(_VoxData.magic, 4);
  _VoxData.FStream.Read(_VoxData.Version, 4);
  if _VoxData.magic = 'VOX ' then
  begin

    while (_VoxData.FStream.Position < _VoxData.FStream.Size) do
    begin
      _VoxData.FStream.Read(_VoxData.chunkID, 4);
      _VoxData.FStream.Read(_VoxData.ChunkSize, 4);
      _VoxData.FStream.Read(_VoxData.ChunkChild, 4);
      _VoxData.ChunkName := _VoxData.chunkID;
      if (_VoxData.ChunkName = 'SIZE') then
      begin
        _VoxData.FStream.Read(_VoxData.Map_X, 4);
        _VoxData.FStream.Read(_VoxData.Map_Y, 4);
        _VoxData.FStream.Read(_VoxData.Map_Z, 4);
      end
      else if (_VoxData.ChunkName = 'XYZI') then
      begin
        _VoxData.FStream.Read(_VoxData.NumModels, 4);
        SetLength(_VoxData.Map, _VoxData.NumModels);
        for i := 0 to _VoxData.NumModels - 1 do
        begin
          _VoxData.FStream.Read(_VoxData.Map[i].x, 1);
          _VoxData.FStream.Read(_VoxData.Map[i].y, 1);
          _VoxData.FStream.Read(_VoxData.Map[i].z, 1);
          _VoxData.FStream.Read(_VoxData.Map[i].color, 1);
        end;

      end
      else if (_VoxData.ChunkName = 'RGBA') then
      begin
        for i := 0 to 255 do
        begin
          _VoxData.FStream.Read(_VoxData.Palette[i].R, 1);
          _VoxData.FStream.Read(_VoxData.Palette[i].G, 1);
          _VoxData.FStream.Read(_VoxData.Palette[i].B, 1);
          _VoxData.FStream.Read(_VoxData.Palette[i].A, 1);
        end;

      end
      else if (_VoxData.ChunkName = 'PACK') then
      begin
        _VoxData.FStream.Read(_VoxData.ChunkSize, 4);
      end;

    end;

  end;
  Result := _VoxData;
end;

end.
