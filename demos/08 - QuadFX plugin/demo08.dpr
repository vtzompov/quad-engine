program demo08;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}
{$SETPEFLAGS 1}

uses
  QuadEngine, QuadFX, Vec2f{, QuadFX.Manager}, System.SysUtils;

const
  WIN_SIZE: TVec2i = (X: 1024; Y: 768);
  RENDER_SIZE: TVec2i = (X: 1024; Y: 768);

var
  QuadDevice: IQuadDevice;
  QuadWindow: IQuadWindow;
  QuadRender: IQuadRender;
  QuadTimer: IQuadTimer;

  QuadFXManager: IQuadFXManager;
  QuadFXLayer: IQuadFXLayer;
  QuadFXEffectParams: IQuadFXEffectParams;
  QuadFXEffectParams2: IQuadFXEffectParams;

procedure OnMouseDown(const APosition: TVec2i; const AButtons: TMouseButtons; const APressedButtons: TPressedMouseButtons); stdcall;
var
  Effect: IQuadFXEffect;
  Position: TVec2f;
begin
  Position := APosition / TVec2f(WIN_SIZE) * RENDER_SIZE;

  if AButtons = mbLeft then
    QuadFXLayer.CreateEffect(QuadFXEffectParams, Position, Effect);

  if AButtons = mbRight then
    QuadFXLayer.CreateEffect(QuadFXEffectParams2, Position, Effect);
end;

procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
var
  Effect: IQuadFXEffect;
  i: Integer;
begin
//  for i := 1 to 7 do
//    QuadFXLayer.CreateEffect(QuadFXEffectParams, TVec2f.Create(Random(RENDER_SIZE.X - 128) + 64, Random(RENDER_SIZE.Y - 128) + 64), Effect);

  QuadFXLayer.Update(delta);

  QuadWindow.SetCaption(PWideChar(Format('%f %d', [QuadTimer.GetFPS, QuadFXLayer.GetParticleCount])));

  QuadRender.BeginRender;
  QuadRender.Clear($FFCCCCCC);
  QuadFXLayer.Draw;
  QuadRender.EndRender;
end;

begin
  Randomize;
  QuadDevice := CreateQuadDevice;

  QuadDevice.CreateWindow(QuadWindow);
  QuadWindow.SetCaption('QuadFX plugin demo');
  QuadWindow.SetSize(WIN_SIZE.X, WIN_SIZE.Y);
  QuadWindow.SetOnMouseDown(OnMouseDown);

  QuadDevice.CreateRender(QuadRender);
  QuadRender.Initialize(QuadWindow.GetHandle, RENDER_SIZE.X, RENDER_SIZE.Y, False);

  QuadDevice.CreateTimerEx(QuadTimer, OnTimer, 16, True);

  //Manager := TQuadFXManager.Create(QuadDevice);
  //QuadFXManager := Manager;
  QuadFXManager := CreateQuadFXManager(QuadDevice);

  QuadFXManager.CreateLayer(QuadFXLayer);

  QuadFXManager.CreateEffectParams(QuadFXEffectParams);
  QuadFXEffectParams.LoadFromFile('Effect1', 'data\QuadFX_Effect.json');

  QuadFXManager.CreateEffectParams(QuadFXEffectParams2);
  QuadFXEffectParams2.LoadFromFile('Effect2', 'data\QuadFX_Effect.json');
  //QuadFXEffectParams.CreateEmitterParams;

  QuadWindow.Start;
end.
