unit QuadFX.Effect;

interface

uses
  QuadFX, QuadEngine, QuadEngine.Color, Vec2f, QuadFX.Emitter, QuadFX.LayerEffectProxy,
  System.Generics.Collections, Winapi.Windows, QuadFX.Helpers, QuadFX.EffectEmitterProxy;

type
  TQuadFXEffect = class(TInterfacedObject, IQuadFXEffect)
  private
    //FOldPosition: TVec2f;
    //FPosition: TVec2f;
    FIsNeedToKill: Boolean;
    FParams: IQuadFXEffectParams;
    FEmmiters: TList<IQuadFXEmitter>;
    FCount: Integer;
    FLife: Single;
    FAction: Boolean;
    //FOldScale: Single;
    //FScale: Single;
    //FOldAngle: Single;
    //FAngle: Single;
    //FSinRad, FCosRad: Single;

    FEffectEmitterProxy: TEffectEmitterProxy;

    FSpawnWithLerp: Boolean;
  public
    constructor Create(AParams: IQuadFXEffectParams; APosition: TVec2f; AAngle, AScale: Single);
    procedure SetLayerEffectProxy(ALayerEffectProxy: ILayerEffectProxy);
    destructor Destroy; override;

    function CreateEmitter(AParams: PQuadFXEmitterParams): IQuadFXEmitter;
    function DeleteEmitter(AParams: PQuadFXEmitterParams): Boolean;
    procedure Update(const ADelta: Double); stdcall;
    procedure Draw; stdcall;
    function GetEmitter(Index: Integer; out AEmitter: IQuadFXEmitter): HResult; stdcall;
    function GetEmitterEx(Index: Integer): TQuadFXEmitter;
    function GetEmitterCount: integer; stdcall;
    function GetParticleCount: integer; stdcall;
    function GetEffectParams(out AEffectParams: IQuadFXEffectParams): HResult; stdcall;
    procedure GetPosition(out APosition: TVec2f); stdcall;
    function GetSpawnWithLerp: Boolean; stdcall;
    function GetLife: Single; stdcall;
    function GetAngle: Single; stdcall;
    function GetScale: Single; stdcall;
    function GetEnabled: Boolean; stdcall;
    function GetEmissionEnabled: Boolean; stdcall;
    function GetVisible: Boolean; stdcall;
    procedure SetEnabled(AState: Boolean); stdcall;
    procedure SetEmissionEnabled(AState: Boolean); stdcall;
    procedure SetVisible(AState: Boolean); stdcall;

    procedure GetLerp(ADist: Single; out APosition: TVec2f; out AAngle, AScale: Single);

    procedure SetSpawnWithLerp(ASpawnWithLerp: Boolean); stdcall;
    procedure SetPosition(APosition: TVec2f); stdcall;
    procedure SetAngle(AAngle: Single); stdcall;
    procedure SetScal(AScale: Single); stdcall;
    procedure ToLife(ALife: Single);
    procedure Restart(APosition: TVec2f; AAngle, AScale: Single);
    property IsNeedToKill: Boolean read FIsNeedToKill;
    property Life: Single read FLife;
    property Action: Boolean read FAction;

    property Emmiters[Index: Integer]: TQuadFXEmitter read GetEmitterEx;
    property EmmiterCount: Integer read GetEmitterCount;
  end;

implementation

uses
  QuadFX.Layer, QuadFX.EffectParams, QuadEngine.Utils;

constructor TQuadFXEffect.Create(AParams: IQuadFXEffectParams; APosition: TVec2f; AAngle, AScale: Single);
var
  i: Integer;
  EmitterParams: PQuadFXEmitterParams;
begin
  FEffectEmitterProxy := TEffectEmitterProxy.Create(APosition, AAngle, AScale);

  FLife := 0;
  FCount := 0;
  FIsNeedToKill := False;
  FAction := True;
  FParams := AParams;

  FEmmiters := TList<IQuadFXEmitter>.Create;
  for i := 0 to AParams.GetEmitterParamsCount - 1 do
  begin
    AParams.GetEmitterParams(i, EmitterParams);
    CreateEmitter(EmitterParams);
  end;
end;

procedure TQuadFXEffect.SetLayerEffectProxy(ALayerEffectProxy: ILayerEffectProxy);
begin
  FEffectEmitterProxy.SetLayerEffectProxy(ALayerEffectProxy);
end;

procedure TQuadFXEffect.Restart(APosition: TVec2f; AAngle, AScale: Single);
var
  i: Integer;
begin
  FLife := 0;
  FCount := 0;
  FIsNeedToKill := False;
  FAction := True;

  FEffectEmitterProxy.Create(APosition, AAngle, AScale);

  for i := 0 to FEmmiters.Count - 1 do
    TQuadFXEmitter(FEmmiters[i]).Restart;
end;

function TQuadFXEffect.CreateEmitter(AParams: PQuadFXEmitterParams): IQuadFXEmitter;
begin
  Result := TQuadFXEmitter.Create(FEffectEmitterProxy, AParams);
  FEmmiters.Add(Result);
end;

function TQuadFXEffect.DeleteEmitter(AParams: PQuadFXEmitterParams): Boolean;
var
  i: Integer;
begin
  for i := 0 to FEmmiters.Count - 1 do
    if TQuadFXEmitter(FEmmiters[i]).Params = AParams then
    begin
      FEmmiters.Delete(i);
      Exit(True);
    end;
  Result := False;
end;

destructor TQuadFXEffect.Destroy;
begin
  FParams := nil;
  FEmmiters.Free;
  //FEffectEmitterProxy.free;
  inherited;
end;

procedure TQuadFXEffect.ToLife(ALife: Single);
var
  i: Integer;
begin
  FAction := True;
  FIsNeedToKill := False;
  FLife := ALife;
  for i := 0 to FEmmiters.Count - 1 do
  begin
    TQuadFXEmitter(FEmmiters[i]).Restart;
  //  FEmmiters[i].Update(ALife);
  end;
end;

procedure TQuadFXEffect.Update(const ADelta: Double); stdcall;
var
  i: Integer;
  Ac: Boolean;
begin
  if FIsNeedToKill or not FEffectEmitterProxy.Enabled then
    Exit;

  FLife := FLife + ADelta;

  Ac := False;
  FCount := 0;
  for i := 0 to FEmmiters.Count - 1 do
    if Assigned(FEmmiters[i]) then
    begin
      FEmmiters[i].Update(ADelta);
      FCount := FCount + FEmmiters[i].GetParticleCount;
      if not TQuadFXEmitter(FEmmiters[i]).IsNeedToKill then
        Ac := True;
    end;

  if not Ac and (FCount = 0) then
  begin
    FAction := False;
    FIsNeedToKill := True;
  end;
end;

procedure TQuadFXEffect.Draw; stdcall;
var
  i: Integer;
begin
  if not FEffectEmitterProxy.Visible then
    Exit;

  for i := 0 to FEmmiters.Count - 1 do
    if Assigned(FEffectEmitterProxy.OnDraw) then
      FEffectEmitterProxy.OnDraw(FEmmiters[i], TQuadFXEmitter(FEmmiters[i]).Particle, FEmmiters[i].GetParticleCount)
    else
      FEmmiters[i].Draw;
end;

function TQuadFXEffect.GetParticleCount: integer; stdcall;
begin
  Result := FCount;
end;

procedure TQuadFXEffect.GetPosition(out APosition: TVec2f); stdcall;
begin
  APosition := FEffectEmitterProxy.Position;
end;

function TQuadFXEffect.GetLife: Single; stdcall;
begin
  Result := FLife;
end;

function TQuadFXEffect.GetAngle: Single; stdcall;
begin
  Result := FEffectEmitterProxy.Angle;
end;

function TQuadFXEffect.GetScale: Single; stdcall;
begin
  Result := FEffectEmitterProxy.Scale;
end;

procedure TQuadFXEffect.SetPosition(APosition: TVec2f); stdcall;
begin
  FEffectEmitterProxy.Position := APosition;
end;

procedure TQuadFXEffect.SetAngle(AAngle: Single); stdcall;
begin
  FEffectEmitterProxy.Angle := AAngle;
end;

procedure TQuadFXEffect.SetScal(AScale: Single); stdcall;
begin
  FEffectEmitterProxy.Scale := AScale;
end;

procedure TQuadFXEffect.SetSpawnWithLerp(ASpawnWithLerp: Boolean); stdcall;
begin
  FSpawnWithLerp := ASpawnWithLerp;
end;

procedure TQuadFXEffect.GetLerp(ADist: Single; out APosition: TVec2f; out AAngle, AScale: Single);
begin

end;

function TQuadFXEffect.GetEnabled: Boolean; stdcall;
begin
  Result := FEffectEmitterProxy.Enabled;
end;

function TQuadFXEffect.GetEmissionEnabled: Boolean; stdcall;
begin
  Result := FEffectEmitterProxy.EmissionEnabled;
end;

function TQuadFXEffect.GetVisible: Boolean; stdcall;
begin
  Result := FEffectEmitterProxy.Visible;
end;

procedure TQuadFXEffect.SetEnabled(AState: Boolean); stdcall;
begin
  FEffectEmitterProxy.Enabled := AState;
end;

procedure TQuadFXEffect.SetEmissionEnabled(AState: Boolean); stdcall;
begin
  FEffectEmitterProxy.EmissionEnabled := AState;
end;

procedure TQuadFXEffect.SetVisible(AState: Boolean); stdcall;
begin
  FEffectEmitterProxy.Visible := AState;
end;

function TQuadFXEffect.GetSpawnWithLerp: Boolean; stdcall;
begin
  Result := FSpawnWithLerp;
end;

function TQuadFXEffect.GetEffectParams(out AEffectParams: IQuadFXEffectParams): HResult; stdcall;
begin
  AEffectParams := FParams;
  if Assigned(AEffectParams) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadFXEffect.GetEmitterEx(Index: Integer): TQuadFXEmitter;
begin
  Result := TQuadFXEmitter(FEmmiters[Index]);
end;

function TQuadFXEffect.GetEmitter(Index: Integer; out AEmitter: IQuadFXEmitter): HResult; stdcall;
begin
  AEmitter := FEmmiters[Index];
  if Assigned(AEmitter) then
    Result := S_OK
  else
    Result := E_FAIL;
end;

function TQuadFXEffect.GetEmitterCount: integer; stdcall;
begin
  Result := FEmmiters.Count;
end;

end.
