<?xml version="1.0" encoding="utf-8"?>
<ScrInfo ScreenNo="0" ScreenType="" ScreenSize="0">
	<PartInfo PartType="LuaPart" PartClassifyType="CustomType" PartName="Lua_0_0" PartID="0_Lua_0">
		<General Area="767 583 1016 752" DataFormat="105" Const="" Align="3" LaStartPt="98 61" IsIndirectR="0" IndirectLabelIndexR="0" IsManyTypeShow="1" Fast="0" StatusCovType="0" StatusFreq="10" AnimaReturn="0" ByAddr="0" Trigger="0" isNautomatic="0" UseClickTime="0" ClickTime="2000" isReturn="0" IsControl="1" ControlNum="1" FigureFile="" WSShowErrorState="0" WSErrorState="0" TextAlign="0" TextArea="52 26" BmpIndex="102" BorderColor="#ade7f7" />
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
print(&quot;>>> FIM DO TESTE &lt;&lt;&lt;&quot;)" LuaClickUp="" LuaRunning="" />
		<Extension TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" />
		<SVGColor svgfile="" dark="#000000" light="#000000" hlight="#000000" shadow="#000000" shape="#000000" gstartcolor="#000000" gmidcolor="#000000" gendcolor="#000000" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
		<Label Status="0" Bold="0" CharSize="1414141414141414" Pattern="1" svgfile="Button\Button0016.svg" keyValue="0" IsEnableStringTable="0" IsDynamic="0" FontStyle="26px SimSun26px SimSun26px SimSun26px SimSun26px SimSun26px SimSun26px SimSun26px SimSun" LaIndexID="Api " LaFrnColor="#000000" FrnColor="#c4f0fd" BgColor="#c4f0fd" dark="#000000" light="#000000" hlight="#000000" shadow="#000000" shape="#000000" gstartcolor="#333333" gmidcolor="#000000" gendcolor="#999999" />
	</PartInfo>
</ScrInfo>
