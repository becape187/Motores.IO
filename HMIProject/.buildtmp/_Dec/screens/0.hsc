<?xml version="1.0" encoding="utf-8"?>
<ScrInfo ScreenNo="0" ScreenType="" ScreenSize="0">
	<PartInfo PartType="LuaPart" PartName="Lua_0" PartClassifyType="CustomType" PartID="0_Lua_0">
		<General Area="767 583 1016 752" DataFormat="105" Const="" BmpIndex="101" Align="3" LaStartPt="98 61" IsIndirectR="0" IndirectLabelIndexR="0" IsManyTypeShow="1" Fast="0" StatusCovType="0" StatusFreq="10" AnimaReturn="0" ByAddr="0" Trigger="0" isNautomatic="0" UseClickTime="0" ClickTime="2000" isReturn="0" IsControl="1" ControlNum="1" FigureFile="" BorderColor="0xf7e7ad 0" WSShowErrorState="0" WSErrorState="0" TextAlign="0" TextArea="52 26" Locking="0" />
		<LuaScript LuaClickDown="-- Script para testar a chamada da API
print(&quot;>>> INICIANDO TESTE &lt;&lt;&lt;&quot;)
local apiClient = APIClient:new()
print(&quot;>>> APIClient criado &lt;&lt;&lt;&quot;)
local success, resultado = apiClient:ReceberPlanta()
print(&quot;>>> ReceberPlanta retornou &lt;&lt;&lt;&quot;)
if success then
    print(&quot;SUCESSO! Motores: &quot; .. tostring(#resultado))
else
    print(&quot;ERRO: &quot; .. tostring(resultado))
end
print(&quot;>>> FIM DO TESTE &lt;&lt;&lt;&quot;)" />
		<Extension TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0x0 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
		<Label Status="0" Bold="0" LaIndexID="Api " CharSize="1414141414141414" LaFrnColor="0x0 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" svgfile="Button\Button0016.svg" dark="0x0 0" light="0x0 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x333333 0" gmidcolor="0x0 0" gendcolor="0x999999 0" keyValue="0" IsEnableStringTable="0" IsDynamic="0" />
	</PartInfo>
</ScrInfo>
