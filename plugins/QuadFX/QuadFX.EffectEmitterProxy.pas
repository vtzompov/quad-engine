unit QuadFX.EffectEmitterProxy;

interface

uses
  Vec2f, QuadFX.LayerEffectProxy;

type
  IEffectEmitterProxy = interface
  ['{9EA02530-1AB7-456F-B599-06F11963B017}']
    function GetPosition: TVec2f;
    function GetScale: Single;
    function GetAngle: Single;
    function GetGravitation: TVec2f;
    procedure GetSinCos(out ASinRad, ACosRad: Single);
  end;

  TEffectEmitterProxy = class(TInterfacedObject, IEffectEmitterProxy)
  private
    FPosition: TVec2f;
    FScale: Single;
    FAngle: Single;
    FSinRad, FCosRad: Single;
    FLayerEffectProxy: ILayerEffectProxy;
    function GetPosition: TVec2f; inline;
    function GetScale: Single; inline;
    function GetAngle: Single; inline;
    procedure SetAngle(Value: Single);
    function GetGravitation: TVec2f; inline;
  public
    constructor Create(APosition: TVec2f; AAngle, AScale: Single);
    procedure GetSinCos(out ASinRad, ACosRad: Single);
    procedure SetLayerEffectProxy(ALayerEffectProxy: ILayerEffectProxy);

    property Position: TVec2f read GetPosition write FPosition;
    property Angle: Single read GetAngle write SetAngle;
    property Scale: Single read GetScale write FScale;
  end;

implementation

uses
  QuadEngine.Utils;

constructor TEffectEmitterProxy.Create(APosition: TVec2f; AAngle, AScale: Single);
begin
  Position := APosition;
  Scale := AScale;
  Angle := AAngle;
end;

function TEffectEmitterProxy.GetAngle: Single;
begin
  Result := FAngle;
end;

function TEffectEmitterProxy.GetPosition: TVec2f;
begin
  Result := FPosition;
end;

function TEffectEmitterProxy.GetScale: Single;
begin
  Result := FScale;
end;

procedure TEffectEmitterProxy.GetSinCos(out ASinRad, ACosRad: Single);
begin
  ASinRad := FSinRad;
  ACosRad := FCosRad;
end;

function TEffectEmitterProxy.GetGravitation: TVec2f;
begin
  if Assigned(FLayerEffectProxy) then
    Result := FLayerEffectProxy.GetGravitation
  else
    Result := TVec2f.Zero;
end;

procedure TEffectEmitterProxy.SetLayerEffectProxy(ALayerEffectProxy: ILayerEffectProxy);
begin
  FLayerEffectProxy := ALayerEffectProxy;
end;

procedure TEffectEmitterProxy.SetAngle(Value: Single);
begin
  if FAngle <> Value then
    FastSinCos(Value, FSinRad, FCosRad);
  FAngle := Value;
end;

end.
