﻿{==============================================================================

  Quad engine 0.6.0 Umber header file for Embarcadero™ Delphi®

     ╔═══════════╦═╗
     ║           ║ ║
     ║           ║ ║
     ║ ╔╗ ║║ ╔╗ ╔╣ ║
     ║ ╚╣ ╚╝ ╚╩ ╚╝ ║
     ║  ║ engine   ║
     ║  ║          ║
     ╚══╩══════════╝

  For further information please visit:
  http://quad-engine.com

==============================================================================}

unit QuadEngine;

interface

// Uncomment this define if Direct3D interfaces is needed
{$DEFINE USED3D}

uses
  Windows, {$IFDEF USED3D} Direct3D9,{$ENDIF} Vec2f;

const
  LibraryName: PChar = 'qei.dll';
  CreateQuadDeviceProcName: PChar = 'CreateQuadDevice';
  SecretMagicFunctionProcName: PChar = 'SecretMagicFunction';

type
  ///<summary>Blending mode types.</summary>
  ///<param name="qbmNone">Without blending</param>
  ///<param name="qbmAdd">Add source to destination</param>
  ///<param name="qbmSrcAlpha">Blend destination with alpha to source</param>
  ///<param name="qbmSrcAlphaAdd">Add source with alpha to destination</param>
  ///<param name="qbmSrcAlphaMul">Multiply source alpha with destination</param>
  ///<param name="qbmMul">Multiply Source with destination</param>
  ///<param name="qbmSrcColor">Blend source with color weight to destination</param>
  ///<param name="qbmSrcColorAdd">Blend source with color weight and alpha to destination</param>
  ///<param name="qbmInvertSrcColor">Blend inverted source color</param>
  TQuadBlendMode = (qbmInvalid        = 0,
                    qbmNone           = 1,
                    qbmAdd            = 2,
                    qbmSrcAlpha       = 3,
                    qbmSrcAlphaAdd    = 4,
                    qbmSrcAlphaMul    = 5,
                    qbmMul            = 6,
                    qbmSrcColor       = 7,
                    qbmSrcColorAdd    = 8,
                    qbmInvertSrcColor = 9);

  ///<summary>Texture adressing mode</summary>
  ///<param name="qtaWrap">Repeat UV</param>
  ///<param name="qtaMirror">Repeat UV with mirroring</param>
  ///<param name="qtaClamp">Do not repeat UV</param>
  ///<param name="qtaBorder">Fill outranged UV with border</param>
  ///<param name="qtaMirrorOnce">Mirror UV once</param>
  TQuadTextureAdressing = (qtaInvalid    = 0,
                           qtaWrap       = 1,
                           qtaMirror     = 2,
                           qtaClamp      = 3,
                           qtaBorder     = 4,
                           qtaMirrorOnce = 5);

  // Texture filtering mode
  TQuadTextureFiltering = (qtfInvalid         = 0,
                           qtfNone            = 1,    { Filtering disabled (valid for mip filter only) }
                           qtfPoint           = 2,    { Nearest }
                           qtfLinear          = 3,    { Linear interpolation }
                           qtfAnisotropic     = 4,    { Anisotropic }
                           qtfPyramidalQuad   = 5,    { 4-sample tent }
                           qtfGaussianQuad    = 6,    { 4-sample gaussian }
                           qtfConvolutionMono = 7);   { Convolution filter for monochrome textures }

  // Vector record declaration
  TVector = packed record
    x: Single;
    y: Single;
    z: Single;
  end;

  // vertex record declaration
  TVertex = packed record
    x, y, z : Single;         { X, Y of vertex. Z is not used }
    Normal  : TVector;        { Normal vector }
    Color   : Cardinal;       { Color }
    u, v    : Single;         { Texture UV coord }
    Tangent : TVector;        { Tangent vector }
    Binormal: TVector;        { Binormal vector }
    class operator Implicit(const A: TVec2f): TVertex;
  end;

  /// <summary>OnTimer Callback function prototype</summary>
  TTimerProcedure = procedure(out delta: Double; Id: Cardinal); stdcall;
  { template:
    procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;
    begin

    end;
  }

  // forward interfaces declaration
  IQuadDevice  = interface;
  IQuadRender  = interface;
  IQuadTexture = interface;
  IQuadShader  = interface;
  IQuadFont    = interface;
  IQuadLog     = interface;
  IQuadTimer   = interface;
  IQuadWindow  = interface;
  IQuadCamera  = interface;

  { Quad Render }

  // OnError routine. Calls whenever error occurs
  TOnErrorFunction = procedure(Errorstring: PWideChar); stdcall;

  ///<summary>This is main quad-engine interface. Use it methods to create resources, change states and draw primitives.</summary>
  IQuadDevice = interface(IUnknown)
    ['{E28626FF-738F-43B0-924C-1AFC7DEC26C7}']
    function CreateAndLoadFont(AFontTextureFilename, AUVFilename: PWideChar; out pQuadFont: IQuadFont): HResult; stdcall;
    function CreateAndLoadTexture(ARegister: Byte; AFilename: PWideChar; out pQuadTexture: IQuadTexture;
      APatternWidth: Integer = 0; APatternHeight: Integer = 0; AColorKey : Integer = -1): HResult; stdcall;
    function CreateCamera(out pQuadCamera: IQuadCamera): HResult; stdcall;
    /// <summary>Return a QuadFont object.</summary>
    /// <param name="pQuadFont">IQuadFont variable to recieve object.</param>
    function CreateFont(out pQuadFont: IQuadFont): HResult; stdcall;
    /// <summary>Return a QuadLog object.</summary>
    /// <param name="pQuadLog">IQuadLog variable to recieve object.</param>
    function CreateLog(out pQuadLog: IQuadLog): HResult; stdcall;
    /// <summary>Return a QuadShader object.</summary>
    /// <param name="pQuadShader">IQuadShader variable to recieve object.</param>
    function CreateShader(out pQuadShader: IQuadShader): HResult; stdcall;
    /// <summary>Return a QuadTexture object.</summary>
    /// <param name="pQuadTexure">IQuadTexture variable to recieve object.</param>
    function CreateTexture(out pQuadTexture: IQuadTexture): HResult; stdcall;
    /// <summary>Return a QuadTimer object.</summary>
    /// <param name="pQuadTimer">IQuadTimer variable to recieve object.</param>
    function CreateTimer(out pQuadTimer: IQuadTimer): HResult; stdcall;
    /// <summary>Return a QuadTimer object with full initialization.</summary>
    /// <param name="pQuadTimer">IQuadTimer variable to recieve object.</param>
    /// <param name="AProc">Callback to onTimer procedure. <see cref="TTimerProcedure"/>
    ///   <code>procedure OnTimer(out delta: Double; Id: Cardinal); stdcall;</code>
    /// </param>
    /// <param name="AInterval">Timer interval in ms.</param>
    /// <param name="IsEnabled">False if need to create in suspended state.</param>
    function CreateTimerEx(out pQuadTimer: IQuadTimer; AProc: TTimerProcedure; AInterval: Word; IsEnabled: Boolean): HResult;
    /// <summary>Return a QuadRender object.</summary>
    /// <param name="pQuadRender">IQuadRender variable to recieve object.</param>
    function CreateRender(out pQuadRender: IQuadRender): HResult; stdcall;
    /// <summary>Creates a rendertarget within specified <see cref="QuadEngine.IQuadTexture"/>.</summary>
    /// <param name="AWidth">Width of rendertarget.</param>
    /// <param name="AHeight">Height of rendertarget.</param>
    /// <param name="AQuadTexture">Pointer to declared <see cref="QuadEngine.IQuadTexture"/>. If it not created this function will create one. Otherwise it will use existing one.</param>
    /// <param name="ARegister">Texture's register in which rendertarget must be assigned.</param>
    procedure CreateRenderTarget(AWidth, AHeight: Word; var AQuadTexture: IQuadTexture; ARegister: Byte); stdcall;
    function CreateWindow(out pQuadWindow: IQuadWindow): HResult; stdcall;
    function GetIsResolutionSupported(AWidth, AHeight: Word): Boolean; stdcall;
    function GetLastError: PWideChar; stdcall;
    function GetMonitorsCount: Byte; stdcall;
    procedure GetSupportedScreenResolution(index: Integer; out Resolution: TCoord); stdcall;
    procedure SetActiveMonitor(AMonitorIndex: Byte); stdcall;
    procedure SetOnErrorCallBack(Proc: TOnErrorFunction); stdcall;
  end;

  // Shader model
  TQuadShaderModel = (qsmInvalid = 0,
                      qsmNone    = 1,   // do not use shaders
                      qsm20      = 2,   // shader model 2.0
                      qsm30      = 3);  // shader model 3.0

  /// <summary>Main Quad-engine interface used for drawing. This object is singleton and cannot be created more than once.</summary>
  IQuadRender = interface(IUnknown)
    ['{D9E9C42B-E737-4CF9-A92F-F0AE483BA39B}']
    /// </summary>Retrieves the available texture memory.
    /// This will return all available texture memory including AGP aperture.</summary>
    /// <returns>Available memory size in bytes</returns>
    function GetAvailableTextureMemory: Cardinal; stdcall;
    function GetMaxAnisotropy: Cardinal; stdcall;
    function GetMaxTextureHeight: Cardinal; stdcall;
    function GetMaxTextureStages: Cardinal; stdcall;
    function GetMaxTextureWidth: Cardinal; stdcall;
    function GetPixelShaderVersionString: PWideChar; stdcall;
    function GetPSVersionMajor: Byte; stdcall;
    function GetPSVersionMinor: Byte; stdcall;
    function GetVertexShaderVersionString: PWideChar; stdcall;
    function GetVSVersionMajor: Byte; stdcall;
    function GetVSVersionMinor: Byte; stdcall;
    procedure AddTrianglesToBuffer(const AVertexes: array of TVertex; ACount: Cardinal); stdcall;
    procedure BeginRender; stdcall;
    procedure ChangeResolution(AWidth, AHeight : Word); stdcall;
    procedure Clear(AColor: Cardinal); stdcall;
    procedure CreateOrthoMatrix; stdcall;
    procedure DrawDistort(x1, y1, x2, y2, x3, y3, x4, y4: Double; u1, v1, u2, v2: Double; Color: Cardinal); stdcall;
    procedure DrawRect(const PointA, PointB, UVA, UVB: TVec2f; Color: Cardinal); stdcall;
    procedure DrawRectRot(const PointA, PointB: TVec2f; Angle, Scale: Double; const UVA, UVB: TVec2f; Color: Cardinal); stdcall;
    procedure DrawRectRotAxis(const PointA, PointB: TVec2f; Angle, Scale: Double; const Axis, UVA, UVB: TVec2f; Color: Cardinal); stdcall;
    procedure DrawLine(const PointA, PointB: TVec2f; Color: Cardinal); stdcall;
    procedure DrawPoint(const Point: TVec2f; Color: Cardinal); stdcall;
    procedure DrawQuadLine(const PointA, PointB: TVec2f; Width1, Width2: Single; Color1, Color2: Cardinal); stdcall;
    procedure EndRender; stdcall;
    procedure Finalize; stdcall;
    procedure FlushBuffer; stdcall;
    procedure Initialize(AHandle: THandle; AWidth, AHeight: Integer;
      AIsFullscreen: Boolean; AShaderModel: TQuadShaderModel = qsm20); stdcall;
    procedure InitializeFromIni(AHandle: THandle; AFilename: PWideChar); stdcall;
    procedure Polygon(const PointA, PointB, PointC, PointD: TVec2f; Color: Cardinal); stdcall;
    procedure Rectangle(const PointA, PointB: TVec2f; Color: Cardinal); stdcall;
    procedure RectangleEx(const PointA, PointB: TVec2f; Color1, Color2, Color3, Color4: Cardinal); stdcall;
    /// <summary>Enables render to texture. You can use multiple render targets within one render call.</summary>
    /// <param name="AIsRenderToTexture">Enable render to texture.</param>
    /// <param name="AQuadTexture">IQuadTexture. Instance must be created with IQuadDevice.CreateRenderTexture only.</param>
    /// <param name="ATextureRegister">Register of IQuadTexture to be used for rendering.</param>
    /// <param name="ARenderTargetRegister">When using multiple rendertargets this parameter tells what register this rendertarget will be in output.</param>
    /// <param name="AIsCropScreen">Scale or crop scene to match rendertarget's resolution</param>
    procedure RenderToTexture(AIsRenderToTexture: Boolean; AQuadTexture: IQuadTexture = nil;
      ATextureRegister: Byte = 0; ARenderTargetRegister: Byte = 0; AIsCropScreen: Boolean = False); stdcall;
    procedure SetAutoCalculateTBN(Value: Boolean); stdcall;
    procedure SetBlendMode(qbm: TQuadBlendMode); stdcall;
    procedure SetClipRect(X, Y, X2, Y2: Cardinal); stdcall;
    procedure SetTexture(ARegister: Byte; ATexture: {$IFDEF USED3D}IDirect3DTexture9{$ELSE}Pointer{$ENDIF}); stdcall;
    procedure SetTextureAdressing(ATextureAdressing: TQuadTextureAdressing); stdcall;
    procedure SetTextureFiltering(ATextureFiltering: TQuadTextureFiltering); stdcall;
    procedure SetPointSize(ASize: Cardinal); stdcall;
    procedure SkipClipRect; stdcall;
    procedure TakeScreenshot(AFileName: PWideChar); stdcall;
    procedure ResetDevice; stdcall;
    function GetD3DDevice: {$IFDEF USED3D}IDirect3DDevice9{$ELSE}Pointer{$ENDIF} stdcall;
  end;

  { Quad Texture }

  IQuadTexture = interface(IUnknown)
    ['{9A617F86-2CEC-4701-BF33-7F4989031BBA}']
    function GetIsLoaded: Boolean; stdcall;
    function GetPatternCount: Integer; stdcall;
    function GetPatternHeight: Word; stdcall;
    function GetPatternWidth: Word; stdcall;
    function GetPixelColor(x, y: Integer; ARegister: byte = 0): Cardinal; stdcall;
    function GetSpriteHeight: Word; stdcall;
    function GetSpriteWidth: Word; stdcall;
    function GetTexture(i: Byte): {$IFDEF USED3D}IDirect3DTexture9{$ELSE}Pointer{$ENDIF}; stdcall;
    function GetTextureHeight: Word; stdcall;
    function GetTextureWidth: Word; stdcall;
    procedure AddTexture(ARegister: Byte; ATexture: {$IFDEF USED3D}IDirect3DTexture9{$ELSE}Pointer{$ENDIF}); stdcall;
    procedure Draw(const Position: Tvec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawFrame(const Position: Tvec2f; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawDistort(x1, y1, x2, y2, x3, y3, x4, y4: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawMap(const PointA, PointB, UVA, UVB: TVec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawMapRotAxis(const PointA, PointB, UVA, UVB, Axis: TVec2f; Angle, Scale: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRot(const Center: TVec2f; angle, Scale: Double; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotFrame(const Center: TVec2f; angle, Scale: Double; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotAxis(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure DrawRotAxisFrame(const Position: TVec2f; angle, Scale: Double; const Axis: TVec2f; Pattern: Word; Color: Cardinal = $FFFFFFFF); stdcall;
    procedure LoadFromFile(ARegister: Byte; AFilename: PWideChar; APatternWidth: Integer = 0;
      APatternHeight: Integer = 0; AColorKey: Integer = -1); stdcall;
    procedure LoadFromRAW(ARegister: Byte; AData: Pointer; AWidth, AHeight: Integer); stdcall;
    procedure SetIsLoaded(AWidth, AHeight: Word); stdcall;
  end;

  { Quad Shader }
  /// <summary>This is quad-engine shader interface.
  /// Use it methods to load shader into GPU, bind variables to shader, execute shader programs.</summary>
  IQuadShader = interface(IUnknown)
    ['{7B7F4B1C-7F05-4BC2-8C11-A99696946073}']
    procedure BindVariableToVS(ARegister: Byte; AVariable: Pointer; ASize: Byte); stdcall;
    procedure BindVariableToPS(ARegister: Byte; AVariable: Pointer; ASize: Byte); stdcall;
    function GetVertexShader(out Shader: {$IFDEF USED3D}IDirect3DVertexShader9{$ELSE}Pointer{$ENDIF}): HResult; stdcall;
    function GetPixelShader(out Shader: {$IFDEF USED3D}IDirect3DPixelShader9{$ELSE}Pointer{$ENDIF}): HResult; stdcall;
    procedure LoadVertexShader(AVertexShaderFilename: PWideChar); stdcall;
    procedure LoadPixelShader(APixelShaderFilename: PWideChar); stdcall;
    procedure LoadComplexShader(AVertexShaderFilename, APixelShaderFilename: PWideChar); stdcall;
    procedure SetShaderState(AIsEnabled: Boolean); stdcall;
  end;

  { Quad Font }


  { Predefined colors for SmartColoring:
      W - white
      Z - black (zero)
      R - red
      L - lime
      B - blue
      M - maroon
      G - green
      N - Navy
      Y - yellow
      F - fuchsia
      A - aqua
      O - olive
      P - purple
      T - teal
      D - gray (dark)
      S - silver

      ! - default DrawText color
    ** Do not override "!" char **  }

  // font alignments
  TqfAlign = (qfaInvalid = 0,
              qfaLeft    = 1,      { Align by left }
              qfaRight   = 2,      { Align by right }
              qfaCenter  = 3,      { Align by center }
              qfaJustify = 4);     { Align by both sides}

  // distance field options
  TDistanceFieldParams = packed record
    Edge1X, Edge1Y: Single;
    Edge2X, Edge2Y: Single;
    OuterColor: Cardinal;
    FirstEdge, SecondEdge: Boolean;
  end;

  ///<summary>This is quad-engine textured fonts interface. Use it methods to render text.</summary>
  IQuadFont = interface(IUnknown)
    ['{A47417BA-27C2-4DE0-97A9-CAE546FABFBA}']
    /// <summary>Check is QuadFont's loading of data from file.</summary>
    /// <returns>True if data is loaded.</returns>
    /// <remarks>This will be very helpfull for multithread applications.</remarks>
    function GetIsLoaded: Boolean; stdcall;
    function GetKerning: Single; stdcall;
    /// <summary>Load font data from file.</summary>
    /// <param name="ATextureFilename">Filename of texture file.</param>
    /// <param name="AUVFilename">Filename of additional font data file.</param>
    procedure LoadFromFile(ATextureFilename, AUVFilename : PWideChar); stdcall;
    procedure SetSmartColor(AColorChar: WideChar; AColor: Cardinal); stdcall;
    procedure SetDistanceFieldParams(const ADistanceFieldParams: TDistanceFieldParams); stdcall;
    procedure SetIsSmartColoring(Value: Boolean); stdcall;
    /// <summary>Set kerning for this font.</summary>
    /// <param name="AValue">Value to be set. 0.0f is default</param>
    procedure SetKerning(AValue: Single); stdcall;
    /// <summary>Get current font height.</summary>
    /// <param name="AText">Text to be measured.</param>
    /// <param name="AScale">Scale of the measured text.</param>
    /// <returns>Height in texels.</returns>
    function TextHeight(AText: PWideChar; AScale: Single = 1.0): Single; stdcall;
    /// <summary>Get current font width.</summary>
    /// <param name="AText">Text to be measured.</param>
    /// <param name="AScale">Scale of the measured text.</param>
    /// <returns>Width in texels.</returns>
    function TextWidth(AText: PWideChar; AScale: Single = 1.0): Single; stdcall;
    /// <summary>Draw text.</summary>
    /// <param name="Position">Position of text to be drawn.</param>
    /// <param name="AScale">Scale of rendered text. Default is 1.0</param>
    /// <param name="AText">Text to be drawn. #13 char is allowed.</param>
    /// <param name="Color">Color of text to be drawn.</param>
    /// <param name="AAlign">Text alignment.</param>
    /// <remarks>Note that distancefield fonts will render with Y as baseline of the font instead top pixel in common fonts.</remarks>
    procedure TextOut(const Position: TVec2f; AScale: Single; AText: PWideChar; AColor: Cardinal = $FFFFFFFF;
      AAlign : TqfAlign = qfaLeft); stdcall;
  end;

  {Quad Log}

  ///<summary>This interface will help to write any debug information to .log file.</summary>
  IQuadLog = interface(IUnknown)
    ['{7A4CE319-C7AF-4BF3-9218-C2A744F915E6}']
    procedure Write(aString: PWideChar); stdcall;
  end;

  {Quad Timer}

  /// <summary>QuadTimer uses it's own thread. Be care of using multiple timers at once.
  /// If do you must use synchronization methods or critical sections.</summary>
  IQuadTimer = interface(IUnknown)
    ['{EA3BD116-01BF-4E12-B504-07D5E3F3AD35}']
    function GetCPUload: Single; stdcall;
    function GetDelta: Double; stdcall;
    function GetFPS: Single; stdcall;
    function GetWholeTime: Double; stdcall;
    function GetTimerID: Cardinal; stdcall;
    procedure ResetWholeTimeCounter; stdcall;
    procedure SetCallBack(AProc: TTimerProcedure); stdcall;
    procedure SetInterval(AInterval: Word); stdcall;
    procedure SetState(AIsEnabled: Boolean); stdcall;
  end;

  {Quad Sprite}     {not implemented yet. do not use}

  IQuadSprite = interface(IUnknown)
  ['{3E6AF547-AB0B-42ED-A40E-8DC10FC6C45F}']
    procedure Draw; stdcall;
    procedure SetPosition(X, Y: Double); stdcall;
    procedure SetVelocity(X, Y: Double); stdcall;
  end;

  TMouseButtons = (mbLeft = 0,
                   mbRight = 1,
                   mbMiddle = 2,
                   mbX1 = 3,
                   mbX2 = 4);
  TPressedMouseButtons = packed record
    case Integer of
      0: (Left, Right, Middle, X1, X2: Boolean);
      2: (a: array[TMouseButtons] of Boolean);
  end;

  TOnKeyPress = procedure(Key: Word); stdcall;
  TOnMouseMoveEvent = procedure(APosition: TVec2i; APressedButtons: TPressedMouseButtons); stdcall;
  TOnMouseEvent = procedure(APosition: TVec2i; AButtons: TMouseButtons; APressedButtons: TPressedMouseButtons); stdcall;
  TOnMouseWheelEvent = procedure(APosition: TVec2i; AVector: TVec2i; APressedButtons: TPressedMouseButtons); stdcall;
  TOnCreate = procedure; stdcall;

  {Quad Window}

  IQuadWindow = interface(IUnknown)
  ['{8EB98692-67B1-4E64-9090-B6A0F47054BA}']
    procedure Start; stdcall;
    procedure SetCaption(ACaption: PChar); stdcall;
    procedure SetSize(AWidth, AHeight: Integer); stdcall;
    procedure SetPosition(AXpos, AYPos: Integer); stdcall;
    function GetHandle: THandle; stdcall;

    procedure SetOnKeyDown(OnKeyDown: TOnKeyPress); stdcall;
    procedure SetOnKeyUp(OnKeyUp: TOnKeyPress); stdcall;
    procedure SetOnCreate(OnCreate: TOnCreate); stdcall;
    procedure SetOnMouseMove(OnMouseMove: TOnMouseMoveEvent); stdcall;
    procedure SetOnMouseDown(OnMouseDown: TOnMouseEvent); stdcall;
    procedure SetOnMouseUp(OnMouseUp: TOnMouseEvent); stdcall;
    procedure SetOnMouseDblClick(OnMouseDblClick: TOnMouseEvent); stdcall;
    procedure SetOnMouseWheel(OnMouseWheel: TOnMouseWheelEvent); stdcall;
  end;

  {Quad Camera}

  IQuadCamera = interface(IUnknown)
  ['{BBC0BBF2-7602-489A-BE2A-37D681B7A242}']
    procedure Shift(AXShift, AYShift: Single); stdcall;
    procedure Shear(AXShear, AYShear: Single); stdcall;
    procedure Zoom(AScale: Single); stdcall;
    procedure Rotate(AAngle: Single); stdcall;
    procedure Translate(AXDistance, AYDistance: Single); stdcall;
    procedure Reset; stdcall;
    procedure ApplyTransform; stdcall;
  end;

  TCreateQuadDevice    = function(out QuadDevice: IQuadDevice): HResult; stdcall;
  TSecretMagicFunction = function: PWideChar;

  function CreateQuadDevice: IQuadDevice;

implementation

// Creating of main Quad interface object
function CreateQuadDevice: IQuadDevice;
var
  h: THandle;
  Creator: TCreateQuadDevice;
begin
  h := LoadLibrary(LibraryName);
  Creator := GetProcAddress(h, CreateQuadDeviceProcName);
  if Assigned(Creator) then
    Creator(Result);
end;

{ TVertex }

class operator TVertex.Implicit(const A: TVec2f): TVertex;
begin
  Result.x := A.X;
  Result.y := A.Y;
  Result.z := 0.0;
end;

end.
