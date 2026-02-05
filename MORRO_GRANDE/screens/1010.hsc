<?xml version="1.0" encoding="utf-8"?>
<ScrInfo ScreenNo="1010" ScreenType="" ScreenSize="0">
	<Script>
		<InitialAction>@B_HSX1047.1=1
</InitialAction>
		<TimerAction>
			<Timer Interval="1">if @W_HSW920=1 then @W_HSW1048=1
if @W_HSW920=2 then @W_HSW1048=3
if @W_HSW920=3 then @W_HSW1048=7
if @W_HSW920=4 then @W_HSW1048=15
if @W_HSW920=5 then @W_HSW1048=31
if @W_HSW920=6 then @W_HSW1048=63
if @W_HSW920=7 then @W_HSW1048=127
if @W_HSW920=8 then @W_HSW1048=255
if @W_HSW920=9 then @W_HSW1048=511
if @W_HSW920=10 then @W_HSW1048=1023
if @W_HSW920=11 then @W_HSW1048=2047
if @W_HSW920=12 then @W_HSW1048=4095
if @W_HSW920=0 then @W_HSW1048=0
</Timer>
		</TimerAction>
	</Script>
	<PartInfo PartType="FunctionSwitch" PartName="FS_1" PartClassifyType="Switch" PartID="1010_FS_1">
		<General Desc="FS_0" Area="603 539 686 580" ScrSwitch="0" FuncFunc="4" ScreenNo="0" ScreenNo2="-1" PointPos="0 0" PopupScreenType="0" PopupCloseWithParent="0" OperateDataType="0" FigureFile="" BorderColor="0xf7e7ad 0" Pattern="0" FrnColor="0x0 0" BgColor="0x0 0" BmpIndex="3" Align="3" LaStartPt="5 2" DelayTime="0" FunAllTerminal="0" EnableTryAddr="0" TextAlign="0" TextArea="72 36" />
		<SVGColor Status="0" svgfile="" dark="0xf5fa7d 0" light="0xffcc00 0" hlight="0x0 0" shadow="0xff5904 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<SVGColor Status="1" svgfile="" dark="0x0 0" light="0x0 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig TriggMode="1" TriggAddr="HSX1047.0" />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
		<Label Status="0" Bold="0" LaIndexID="SaveSaveSaveSaveSaveSaveSaveSave" CharSize="1313131313131313" LaFrnColor="0x0 0" />
	</PartInfo>
	<PartInfo PartType="FunctionSwitch" PartName="FS_0" PartClassifyType="Switch" PartID="1010_FS_0">
		<General Desc="FS_0" Area="603 603 686 644" ScrSwitch="0" FuncFunc="4" ScreenNo="0" ScreenNo2="-1" PointPos="0 0" PopupScreenType="0" PopupCloseWithParent="0" OperateDataType="0" FigureFile="" BorderColor="0xf7e7ad 0" Pattern="0" FrnColor="0x0 0" BgColor="0x0 0" BmpIndex="3" LaStartPt="5 2" DelayTime="0" FunAllTerminal="0" EnableTryAddr="0" TextAlign="0" TextArea="72 36" />
		<SVGColor Status="0" svgfile="" dark="0xf5fa7d 0" light="0xffcc00 0" hlight="0x0 0" shadow="0xff5904 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<SVGColor Status="1" svgfile="" dark="0x0 0" light="0x0 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
		<Label Status="0" Bold="0" LaIndexID="ExitExitExitExitExitExitExitExit" CharSize="1313131313131313" LaFrnColor="0x0 0" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_0" PartClassifyType="InputAndShow" PartID="1010_STR_0">
		<General Desc="STR_0" Area="444 16 598 50" WordAddr="HSW921" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW921" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="4" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_0" PartClassifyType="OtherClassType" PartID="1010_TXT_0">
		<General TextContent="Super key:Super key:Super key:Super key:Super key:Super key:Super key:Super key:" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="256 14" Width="180" Height="36" Area="256 14 436 50" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_0" PartClassifyType="InputAndShow" PartID="1010_NUM_0">
		<General Desc="NUM_0" Area="170 16 210 50" CharSize="1313131313131313" WordAddr="HSW920" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW920" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_1" PartClassifyType="OtherClassType" PartID="1010_TXT_1">
		<General TextContent="Total:Total:Total:Total:Total:Total:Total:Total:" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="8 14" Width="108" Height="36" Area="8 14 116 50" />
	</PartInfo>
	<PartInfo PartType="Rect" PartName="REC_0" PartClassifyType="OtherClassType" PartID="1010_REC_0">
		<General Area="8 99 598 691" Rx="0" BorderColor="0xffffff -1" Pattern="-1" BgColor="0x0 0" PatternNew="0" BgColorNew="0xfefab8 0" ChangeColor="0xffffff 0" IsCirleAngle="0" IsCorlorAddr="0" LineTranValue="0" IsTranValue="0" LineWidth="3" CirleAngle="1" IsMoveControl="0" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_2" PartClassifyType="OtherClassType" PartID="1010_TXT_2">
		<General TextContent="TimeTimeTimeTimeTimeTimeTimeTime" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="405 107" Width="72" Height="36" Area="405 107 477 143" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_3" PartClassifyType="OtherClassType" PartID="1010_TXT_3">
		<General TextContent="KeyKeyKeyKeyKeyKeyKeyKey" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="158 107" Width="54" Height="36" Area="158 107 212 143" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_4" PartClassifyType="OtherClassType" PartID="1010_TXT_4">
		<General TextContent="NONONONONONONONO" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="34 107" Width="36" Height="36" Area="34 107 70 143" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_0" PartClassifyType="OtherClassType" PartID="1010_LN_0">
		<General Area="89 99 93 691" BorderColor="0xffffff -1" StartPt="91 99" EndPt="91 691" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_1" PartClassifyType="OtherClassType" PartID="1010_LN_1">
		<General Area="273 99 277 691" BorderColor="0xffffff -1" StartPt="275 99" EndPt="275 691" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_5" PartClassifyType="OtherClassType" PartID="1010_TXT_5">
		<General TextContent="11111111" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="42 156" Width="13" Height="26" Area="42 156 60 192" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_6" PartClassifyType="OtherClassType" PartID="1010_TXT_6">
		<General TextContent="22222222" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="42 202" Width="13" Height="26" Area="42 202 60 238" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_7" PartClassifyType="OtherClassType" PartID="1010_TXT_7">
		<General TextContent="33333333" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="42 248" Width="13" Height="26" Area="42 248 60 284" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_8" PartClassifyType="OtherClassType" PartID="1010_TXT_8">
		<General TextContent="44444444" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="42 293" Width="13" Height="26" Area="42 293 60 329" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_9" PartClassifyType="OtherClassType" PartID="1010_TXT_9">
		<General TextContent="55555555" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="42 338" Width="13" Height="26" Area="42 338 60 374" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_10" PartClassifyType="OtherClassType" PartID="1010_TXT_10">
		<General TextContent="66666666" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="42 383" Width="13" Height="26" Area="42 383 60 419" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_11" PartClassifyType="OtherClassType" PartID="1010_TXT_11">
		<General TextContent="77777777" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="42 429" Width="13" Height="26" Area="42 429 60 465" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_12" PartClassifyType="OtherClassType" PartID="1010_TXT_12">
		<General TextContent="88888888" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="42 473" Width="13" Height="26" Area="42 473 60 509" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_13" PartClassifyType="OtherClassType" PartID="1010_TXT_13">
		<General TextContent="99999999" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="42 520" Width="13" Height="26" Area="42 520 60 556" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_14" PartClassifyType="OtherClassType" PartID="1010_TXT_14">
		<General TextContent="1010101010101010" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="34 565" Width="26" Height="26" Area="34 565 70 601" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_15" PartClassifyType="OtherClassType" PartID="1010_TXT_15">
		<General TextContent="1111111111111111" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="34 611" Width="26" Height="26" Area="34 611 70 647" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_16" PartClassifyType="OtherClassType" PartID="1010_TXT_16">
		<General TextContent="1212121212121212" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="34 656" Width="26" Height="26" Area="34 656 70 692" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_1" PartClassifyType="InputAndShow" PartID="1010_STR_1">
		<General Desc="STR_0" Area="97 154 270 185" WordAddr="HSW925" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW925" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xececec 0" hlight="0x0 0" shadow="0xffffff 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.0" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_2" PartClassifyType="InputAndShow" PartID="1010_STR_2">
		<General Desc="STR_0" Area="97 199 270 230" WordAddr="HSW935" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW935" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xececec 0" hlight="0x0 0" shadow="0xffffff 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.1" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="1" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_3" PartClassifyType="InputAndShow" PartID="1010_STR_3">
		<General Desc="STR_0" Area="97 245 270 276" WordAddr="HSW945" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW945" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xececec 0" hlight="0x0 0" shadow="0xffffff 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.2" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_4" PartClassifyType="InputAndShow" PartID="1010_STR_4">
		<General Desc="STR_0" Area="97 290 270 321" WordAddr="HSW955" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW955" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xececec 0" hlight="0x0 0" shadow="0xffffff 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.3" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_5" PartClassifyType="InputAndShow" PartID="1010_STR_5">
		<General Desc="STR_0" Area="97 336 270 367" WordAddr="HSW965" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW965" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xececec 0" hlight="0x0 0" shadow="0xffffff 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.4" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_6" PartClassifyType="InputAndShow" PartID="1010_STR_6">
		<General Desc="STR_0" Area="97 381 270 412" WordAddr="HSW975" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW975" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xececec 0" hlight="0x0 0" shadow="0xffffff 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.5" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_7" PartClassifyType="InputAndShow" PartID="1010_STR_7">
		<General Desc="STR_0" Area="97 426 270 457" WordAddr="HSW985" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW985" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xececec 0" hlight="0x0 0" shadow="0xffffff 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.6" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_8" PartClassifyType="InputAndShow" PartID="1010_STR_8">
		<General Desc="STR_0" Area="97 472 270 503" WordAddr="HSW995" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW995" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xececec 0" hlight="0x0 0" shadow="0xffffff 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.7" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_9" PartClassifyType="InputAndShow" PartID="1010_STR_9">
		<General Desc="STR_0" Area="97 517 270 548" WordAddr="HSW1005" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW1005" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xececec 0" hlight="0x0 0" shadow="0xffffff 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.8" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_10" PartClassifyType="InputAndShow" PartID="1010_STR_10">
		<General Desc="STR_0" Area="97 563 270 594" WordAddr="HSW1015" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW1015" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xececec 0" hlight="0x0 0" shadow="0xffffff 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.9" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_11" PartClassifyType="InputAndShow" PartID="1010_STR_11">
		<General Desc="STR_0" Area="97 608 270 639" WordAddr="HSW1025" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW1025" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xececec 0" hlight="0x0 0" shadow="0xffffff 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.10" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="String" PartName="STR_12" PartClassifyType="InputAndShow" PartID="1010_STR_12">
		<General Desc="STR_0" Area="97 654 270 685" WordAddr="HSW1035" Fast="0" stCount="8" HighLowChange="0" HighLowByteChange="0" IsInput="1" WriteAddr="HSW1035" KbdScreen="1001" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" CharSize="1313131313131313" IsHideNum="0" IsShowPwd="0" IsIndirectR="0" IsIndirectW="0" IsInputDefault="0" IsDWord="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xececec 0" hlight="0x0 0" shadow="0xffffff 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.11" HideType="0" IsHideAllTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_2" PartClassifyType="OtherClassType" PartID="1010_LN_2">
		<General Area="8 145 595 149" BorderColor="0xffffff -1" StartPt="8 147" EndPt="595 147" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_3" PartClassifyType="OtherClassType" PartID="1010_LN_3">
		<General Area="8 189 595 193" BorderColor="0xffffff -1" StartPt="8 191" EndPt="595 191" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_4" PartClassifyType="OtherClassType" PartID="1010_LN_4">
		<General Area="8 235 595 239" BorderColor="0xffffff -1" StartPt="8 237" EndPt="595 237" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_5" PartClassifyType="OtherClassType" PartID="1010_LN_5">
		<General Area="8 281 595 285" BorderColor="0xffffff -1" StartPt="8 283" EndPt="595 283" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_6" PartClassifyType="OtherClassType" PartID="1010_LN_6">
		<General Area="8 326 595 330" BorderColor="0xffffff -1" StartPt="8 328" EndPt="595 328" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_7" PartClassifyType="OtherClassType" PartID="1010_LN_7">
		<General Area="8 372 595 376" BorderColor="0xffffff -1" StartPt="8 374" EndPt="595 374" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_8" PartClassifyType="OtherClassType" PartID="1010_LN_8">
		<General Area="8 416 595 420" BorderColor="0xffffff -1" StartPt="8 418" EndPt="595 418" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_9" PartClassifyType="OtherClassType" PartID="1010_LN_9">
		<General Area="8 462 595 466" BorderColor="0xffffff -1" StartPt="8 464" EndPt="595 464" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_10" PartClassifyType="OtherClassType" PartID="1010_LN_10">
		<General Area="8 508 595 512" BorderColor="0xffffff -1" StartPt="8 510" EndPt="595 510" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_11" PartClassifyType="OtherClassType" PartID="1010_LN_11">
		<General Area="8 553 595 557" BorderColor="0xffffff -1" StartPt="8 555" EndPt="595 555" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_12" PartClassifyType="OtherClassType" PartID="1010_LN_12">
		<General Area="8 599 595 603" BorderColor="0xffffff -1" StartPt="8 601" EndPt="595 601" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Line" PartName="LN_13" PartClassifyType="OtherClassType" PartID="1010_LN_13">
		<General Area="8 645 595 649" BorderColor="0xffffff -1" StartPt="8 647" EndPt="595 647" AutoAdsorption="20" LineWidth="3" DynamicSet="0" LineTranValue="0" IsMoveControl="0" IsCorlorAddr="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_1" PartClassifyType="InputAndShow" PartID="1010_NUM_1">
		<General Desc="NUM_0" Area="282 154 363 185" CharSize="1313131313131313" WordAddr="HSW929" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW929" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="4 0" DataLimit="0105 04 00 0 9999" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.0" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_2" PartClassifyType="InputAndShow" PartID="1010_NUM_2">
		<General Desc="NUM_0" Area="282 199 363 230" CharSize="1313131313131313" WordAddr="HSW939" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW939" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="4 0" DataLimit="0105 04 00 0 9999" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.1" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_3" PartClassifyType="InputAndShow" PartID="1010_NUM_3">
		<General Desc="NUM_0" Area="282 245 363 276" CharSize="1313131313131313" WordAddr="HSW949" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW949" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="4 0" DataLimit="0105 04 00 0 9999" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.2" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_4" PartClassifyType="InputAndShow" PartID="1010_NUM_4">
		<General Desc="NUM_0" Area="282 290 363 321" CharSize="1313131313131313" WordAddr="HSW959" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW959" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="4 0" DataLimit="0105 04 00 0 9999" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.3" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_5" PartClassifyType="InputAndShow" PartID="1010_NUM_5">
		<General Desc="NUM_0" Area="282 336 363 367" CharSize="1313131313131313" WordAddr="HSW969" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW969" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="4 0" DataLimit="0105 04 00 0 9999" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.4" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_6" PartClassifyType="InputAndShow" PartID="1010_NUM_6">
		<General Desc="NUM_0" Area="282 381 363 412" CharSize="1313131313131313" WordAddr="HSW979" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW979" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="4 0" DataLimit="0105 04 00 0 9999" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.5" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_7" PartClassifyType="InputAndShow" PartID="1010_NUM_7">
		<General Desc="NUM_0" Area="282 426 363 457" CharSize="1313131313131313" WordAddr="HSW989" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW989" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="4 0" DataLimit="0105 04 00 0 9999" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.6" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_8" PartClassifyType="InputAndShow" PartID="1010_NUM_8">
		<General Desc="NUM_0" Area="282 472 363 503" CharSize="1313131313131313" WordAddr="HSW999" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW999" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="4 0" DataLimit="0105 04 00 0 9999" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.7" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_9" PartClassifyType="InputAndShow" PartID="1010_NUM_9">
		<General Desc="NUM_0" Area="282 517 363 548" CharSize="1313131313131313" WordAddr="HSW1009" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1009" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="4 0" DataLimit="0105 04 00 0 9999" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.8" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_10" PartClassifyType="InputAndShow" PartID="1010_NUM_10">
		<General Desc="NUM_0" Area="282 563 363 594" CharSize="1313131313131313" WordAddr="HSW1019" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1019" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="4 0" DataLimit="0105 04 00 0 9999" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.9" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_11" PartClassifyType="InputAndShow" PartID="1010_NUM_11">
		<General Desc="NUM_0" Area="282 608 363 639" CharSize="1313131313131313" WordAddr="HSW1029" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1029" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="4 0" DataLimit="0105 04 00 0 9999" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.10" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_12" PartClassifyType="InputAndShow" PartID="1010_NUM_12">
		<General Desc="NUM_0" Area="282 654 363 685" CharSize="1313131313131313" WordAddr="HSW1039" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1039" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="4 0" DataLimit="0105 04 00 0 9999" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.11" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_13" PartClassifyType="InputAndShow" PartID="1010_NUM_13">
		<General Desc="NUM_0" Area="382 154 423 185" CharSize="1313131313131313" WordAddr="HSW930" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW930" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.0" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_14" PartClassifyType="InputAndShow" PartID="1010_NUM_14">
		<General Desc="NUM_0" Area="382 199 423 230" CharSize="1313131313131313" WordAddr="HSW940" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW940" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.1" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_15" PartClassifyType="InputAndShow" PartID="1010_NUM_15">
		<General Desc="NUM_0" Area="382 245 423 276" CharSize="1313131313131313" WordAddr="HSW950" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW950" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.2" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_16" PartClassifyType="InputAndShow" PartID="1010_NUM_16">
		<General Desc="NUM_0" Area="382 290 423 321" CharSize="1313131313131313" WordAddr="HSW960" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW960" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.3" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_17" PartClassifyType="InputAndShow" PartID="1010_NUM_17">
		<General Desc="NUM_0" Area="382 336 423 367" CharSize="1313131313131313" WordAddr="HSW970" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW970" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.4" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_18" PartClassifyType="InputAndShow" PartID="1010_NUM_18">
		<General Desc="NUM_0" Area="382 381 423 412" CharSize="1313131313131313" WordAddr="HSW980" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW980" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.5" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_19" PartClassifyType="InputAndShow" PartID="1010_NUM_19">
		<General Desc="NUM_0" Area="382 426 423 457" CharSize="1313131313131313" WordAddr="HSW990" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW990" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.6" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_20" PartClassifyType="InputAndShow" PartID="1010_NUM_20">
		<General Desc="NUM_0" Area="382 472 423 503" CharSize="1313131313131313" WordAddr="HSW1000" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1000" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.7" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_21" PartClassifyType="InputAndShow" PartID="1010_NUM_21">
		<General Desc="NUM_0" Area="382 517 423 548" CharSize="1313131313131313" WordAddr="HSW1010" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1010" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.8" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_22" PartClassifyType="InputAndShow" PartID="1010_NUM_22">
		<General Desc="NUM_0" Area="382 563 423 594" CharSize="1313131313131313" WordAddr="HSW1020" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1020" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.9" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_23" PartClassifyType="InputAndShow" PartID="1010_NUM_23">
		<General Desc="NUM_0" Area="382 608 423 639" CharSize="1313131313131313" WordAddr="HSW1030" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1030" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.10" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_24" PartClassifyType="InputAndShow" PartID="1010_NUM_24">
		<General Desc="NUM_0" Area="382 654 423 685" CharSize="1313131313131313" WordAddr="HSW1040" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1040" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.11" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_25" PartClassifyType="InputAndShow" PartID="1010_NUM_25">
		<General Desc="NUM_0" Area="444 154 485 185" CharSize="1313131313131313" WordAddr="HSW931" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW931" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 31" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.0" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_26" PartClassifyType="InputAndShow" PartID="1010_NUM_26">
		<General Desc="NUM_0" Area="444 199 485 230" CharSize="1313131313131313" WordAddr="HSW941" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW941" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 31" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.1" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_27" PartClassifyType="InputAndShow" PartID="1010_NUM_27">
		<General Desc="NUM_0" Area="444 245 485 276" CharSize="1313131313131313" WordAddr="HSW951" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW951" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 31" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.2" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_28" PartClassifyType="InputAndShow" PartID="1010_NUM_28">
		<General Desc="NUM_0" Area="444 290 485 321" CharSize="1313131313131313" WordAddr="HSW961" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW961" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 31" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.3" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_29" PartClassifyType="InputAndShow" PartID="1010_NUM_29">
		<General Desc="NUM_0" Area="444 336 485 367" CharSize="1313131313131313" WordAddr="HSW971" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW971" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 31" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.4" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_30" PartClassifyType="InputAndShow" PartID="1010_NUM_30">
		<General Desc="NUM_0" Area="444 381 485 412" CharSize="1313131313131313" WordAddr="HSW981" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW981" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 31" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.5" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_31" PartClassifyType="InputAndShow" PartID="1010_NUM_31">
		<General Desc="NUM_0" Area="444 426 485 457" CharSize="1313131313131313" WordAddr="HSW991" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW991" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 31" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.6" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_32" PartClassifyType="InputAndShow" PartID="1010_NUM_32">
		<General Desc="NUM_0" Area="444 472 485 503" CharSize="1313131313131313" WordAddr="HSW1001" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1001" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 31" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.7" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_33" PartClassifyType="InputAndShow" PartID="1010_NUM_33">
		<General Desc="NUM_0" Area="444 517 485 548" CharSize="1313131313131313" WordAddr="HSW1011" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1011" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 31" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.8" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_34" PartClassifyType="InputAndShow" PartID="1010_NUM_34">
		<General Desc="NUM_0" Area="444 563 485 594" CharSize="1313131313131313" WordAddr="HSW1021" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1021" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 31" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.9" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_35" PartClassifyType="InputAndShow" PartID="1010_NUM_35">
		<General Desc="NUM_0" Area="444 608 485 639" CharSize="1313131313131313" WordAddr="HSW1031" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1031" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 31" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.10" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_36" PartClassifyType="InputAndShow" PartID="1010_NUM_36">
		<General Desc="NUM_0" Area="444 654 485 685" CharSize="1313131313131313" WordAddr="HSW1041" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1041" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 31" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.11" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_37" PartClassifyType="InputAndShow" PartID="1010_NUM_37">
		<General Desc="NUM_0" Area="496 154 537 185" CharSize="1313131313131313" WordAddr="HSW932" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW932" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 23" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.0" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_38" PartClassifyType="InputAndShow" PartID="1010_NUM_38">
		<General Desc="NUM_0" Area="496 199 537 230" CharSize="1313131313131313" WordAddr="HSW942" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW942" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 23" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.1" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_39" PartClassifyType="InputAndShow" PartID="1010_NUM_39">
		<General Desc="NUM_0" Area="496 245 537 276" CharSize="1313131313131313" WordAddr="HSW952" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW952" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 23" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.2" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_40" PartClassifyType="InputAndShow" PartID="1010_NUM_40">
		<General Desc="NUM_0" Area="496 290 537 321" CharSize="1313131313131313" WordAddr="HSW962" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW962" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 23" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.3" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_41" PartClassifyType="InputAndShow" PartID="1010_NUM_41">
		<General Desc="NUM_0" Area="496 336 537 367" CharSize="1313131313131313" WordAddr="HSW972" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW972" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 23" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.4" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_42" PartClassifyType="InputAndShow" PartID="1010_NUM_42">
		<General Desc="NUM_0" Area="496 381 537 412" CharSize="1313131313131313" WordAddr="HSW982" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW982" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 23" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.5" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_43" PartClassifyType="InputAndShow" PartID="1010_NUM_43">
		<General Desc="NUM_0" Area="496 426 537 457" CharSize="1313131313131313" WordAddr="HSW992" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW992" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 23" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.6" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_44" PartClassifyType="InputAndShow" PartID="1010_NUM_44">
		<General Desc="NUM_0" Area="496 472 537 503" CharSize="1313131313131313" WordAddr="HSW1002" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1002" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 23" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.7" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_45" PartClassifyType="InputAndShow" PartID="1010_NUM_45">
		<General Desc="NUM_0" Area="496 517 537 548" CharSize="1313131313131313" WordAddr="HSW1012" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1012" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 23" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.8" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_46" PartClassifyType="InputAndShow" PartID="1010_NUM_46">
		<General Desc="NUM_0" Area="496 563 537 594" CharSize="1313131313131313" WordAddr="HSW1022" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1022" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 23" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.9" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_47" PartClassifyType="InputAndShow" PartID="1010_NUM_47">
		<General Desc="NUM_0" Area="496 608 537 639" CharSize="1313131313131313" WordAddr="HSW1032" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1032" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 23" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.10" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_48" PartClassifyType="InputAndShow" PartID="1010_NUM_48">
		<General Desc="NUM_0" Area="496 654 537 685" CharSize="1313131313131313" WordAddr="HSW1042" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1042" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 23" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.11" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_49" PartClassifyType="InputAndShow" PartID="1010_NUM_49">
		<General Desc="NUM_0" Area="549 154 590 185" CharSize="1313131313131313" WordAddr="HSW933" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW933" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 59" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.0" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_50" PartClassifyType="InputAndShow" PartID="1010_NUM_50">
		<General Desc="NUM_0" Area="549 199 590 230" CharSize="1313131313131313" WordAddr="HSW943" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW943" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 59" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.1" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_51" PartClassifyType="InputAndShow" PartID="1010_NUM_51">
		<General Desc="NUM_0" Area="549 245 590 276" CharSize="1313131313131313" WordAddr="HSW953" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW953" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 59" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.2" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_52" PartClassifyType="InputAndShow" PartID="1010_NUM_52">
		<General Desc="NUM_0" Area="549 290 590 321" CharSize="1313131313131313" WordAddr="HSW963" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW963" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 59" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.3" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_53" PartClassifyType="InputAndShow" PartID="1010_NUM_53">
		<General Desc="NUM_0" Area="549 336 590 367" CharSize="1313131313131313" WordAddr="HSW973" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW973" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 59" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.4" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_54" PartClassifyType="InputAndShow" PartID="1010_NUM_54">
		<General Desc="NUM_0" Area="549 381 590 412" CharSize="1313131313131313" WordAddr="HSW983" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW983" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 59" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.5" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_55" PartClassifyType="InputAndShow" PartID="1010_NUM_55">
		<General Desc="NUM_0" Area="549 426 590 457" CharSize="1313131313131313" WordAddr="HSW993" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW993" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 59" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.6" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_56" PartClassifyType="InputAndShow" PartID="1010_NUM_56">
		<General Desc="NUM_0" Area="549 472 590 503" CharSize="1313131313131313" WordAddr="HSW1003" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1003" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 59" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.7" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_57" PartClassifyType="InputAndShow" PartID="1010_NUM_57">
		<General Desc="NUM_0" Area="549 517 590 548" CharSize="1313131313131313" WordAddr="HSW1013" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1013" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 59" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.8" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_58" PartClassifyType="InputAndShow" PartID="1010_NUM_58">
		<General Desc="NUM_0" Area="549 563 590 594" CharSize="1313131313131313" WordAddr="HSW1023" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1023" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 59" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.9" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_59" PartClassifyType="InputAndShow" PartID="1010_NUM_59">
		<General Desc="NUM_0" Area="549 608 590 639" CharSize="1313131313131313" WordAddr="HSW1033" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1033" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 59" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.10" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_60" PartClassifyType="InputAndShow" PartID="1010_NUM_60">
		<General Desc="NUM_0" Area="549 654 590 685" CharSize="1313131313131313" WordAddr="HSW1043" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1043" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 0 59" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="1" TrigHideAddr="HSX1048.11" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Numeric" PartName="NUM_61" PartClassifyType="InputAndShow" PartID="1010_NUM_61">
		<General Desc="NUM_0" Area="170 58 210 92" CharSize="1313131313131313" WordAddr="HSW1046" Fast="0" HighLowChange="0" IsInput="1" WriteAddr="HSW1046" KbdScreen="1000" IsPopKeyBrod="0" FigureFile="" IsKeyBoardRemark="0" LaStartPt="0 0" BorderColor="0xf7e7ad 0" LaFrnColor="0x0 0" BgColor="0xfdf0c4 0" BmpIndex="-1" IsHideNum="0" HighZeroPad="0" IsShowPwd="0" ZeroNoDisplay="0" IsIndirectR="0" IsIndirectW="0" KbdContinue="0" KbdContinueNum="0" KbdContinueGroup="0" KbdContinueEnd="0" />
		<SVGColor svgfile="" dark="0x0 0" light="0xffffff 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0x0 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<DispFormat DispType="105" DigitCount="2 0" DataLimit="0105 02 00 1 12" IsVar="0" Zoom="0" Mutiple="1.000000000000000" Round="0" IsInputLabelL="0" IsInputLabelR="0" IsInputDefault="0" bShowRange="0" IsVar1="0" ColorHText="0x0 0" ColorHBag="0x0 0" ColorLText="0x0 0" ColorLBag="0x0 0" UseOutRangeText="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Extension IsCheck="0" AckTime="0" TouchState="1" Buzzer="1" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
	</PartInfo>
	<PartInfo PartType="Text" PartName="TXT_29" PartClassifyType="OtherClassType" PartID="1010_TXT_29">
		<General TextContent="Current:Current:Current:Current:Current:Current:Current:Current:" LaFrnColor="0x0 0" IsBackColor="0" BgColor="0xfdf0c4 0" CharSize="1313131313131313" Bold="0" StartPt="8 54" Width="144" Height="36" Area="8 54 152 90" />
	</PartInfo>
	<PartInfo PartType="BitSwitch" PartName="BS_0" PartClassifyType="Switch" PartID="1010_BS_0">
		<General Desc="BS_0" Area="603 603 686 644" OperateAddr="HSX1047.0" Fast="0" Monitor="1" MonitorAddr="HSX1047.0" FigureFile="" BorderColor="0xf7e7ad 0" BmpIndex="-1" LaStartPt="41 20" BitShowReverse="0" IsIndirectR="0" IsIndirectW="0" MinClickTime="0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" IsCheck="0" AckTime="0" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Lock Lockmate="0" UnDrawLock="0" LockMode="0" IsShowGrayScale="0" />
		<PartPwd IsUesPartPassword="0" IsSetLowerLev="0" PartPasswordLev="0" />
		<ClickPopTrig />
		<UserAuthority IsUseUserAuthority="0" IsPopUserLoginWin="0" PopType="0" IsHidePart="0" />
		<Label Status="0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0x0 0" hlight="0x0 0" shadow="0x0 0" shape="0xffffff 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
		<Label Status="1" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0x0 0" hlight="0x0 0" shadow="0x0 0" shape="0xffffff 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0x0 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_0" PartClassifyType="Switch" PartID="1010_BL_0">
		<General Desc="BL_0" Area="366 154 386 185" MonitorAddr="HSX1048.0" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_1" PartClassifyType="Switch" PartID="1010_BL_1">
		<General Desc="BL_0" Area="366 199 386 230" MonitorAddr="HSX1048.1" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_2" PartClassifyType="Switch" PartID="1010_BL_2">
		<General Desc="BL_0" Area="366 245 386 276" MonitorAddr="HSX1048.2" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_3" PartClassifyType="Switch" PartID="1010_BL_3">
		<General Desc="BL_0" Area="366 290 386 321" MonitorAddr="HSX1048.3" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_4" PartClassifyType="Switch" PartID="1010_BL_4">
		<General Desc="BL_0" Area="366 336 386 367" MonitorAddr="HSX1048.4" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_5" PartClassifyType="Switch" PartID="1010_BL_5">
		<General Desc="BL_0" Area="366 381 386 412" MonitorAddr="HSX1048.5" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_6" PartClassifyType="Switch" PartID="1010_BL_6">
		<General Desc="BL_0" Area="366 426 386 457" MonitorAddr="HSX1048.6" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_7" PartClassifyType="Switch" PartID="1010_BL_7">
		<General Desc="BL_0" Area="366 472 386 503" MonitorAddr="HSX1048.7" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_8" PartClassifyType="Switch" PartID="1010_BL_8">
		<General Desc="BL_0" Area="366 517 386 548" MonitorAddr="HSX1048.8" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_9" PartClassifyType="Switch" PartID="1010_BL_9">
		<General Desc="BL_0" Area="366 563 386 594" MonitorAddr="HSX1048.9" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_10" PartClassifyType="Switch" PartID="1010_BL_10">
		<General Desc="BL_0" Area="366 608 386 639" MonitorAddr="HSX1048.10" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_11" PartClassifyType="Switch" PartID="1010_BL_11">
		<General Desc="BL_0" Area="366 654 386 685" MonitorAddr="HSX1048.11" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_12" PartClassifyType="Switch" PartID="1010_BL_12">
		<General Desc="BL_0" Area="425 154 445 185" MonitorAddr="HSX1048.0" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_13" PartClassifyType="Switch" PartID="1010_BL_13">
		<General Desc="BL_0" Area="425 199 445 230" MonitorAddr="HSX1048.1" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_14" PartClassifyType="Switch" PartID="1010_BL_14">
		<General Desc="BL_0" Area="425 245 445 276" MonitorAddr="HSX1048.2" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_15" PartClassifyType="Switch" PartID="1010_BL_15">
		<General Desc="BL_0" Area="425 290 445 321" MonitorAddr="HSX1048.3" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_16" PartClassifyType="Switch" PartID="1010_BL_16">
		<General Desc="BL_0" Area="425 336 445 367" MonitorAddr="HSX1048.4" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_17" PartClassifyType="Switch" PartID="1010_BL_17">
		<General Desc="BL_0" Area="425 381 445 412" MonitorAddr="HSX1048.5" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_18" PartClassifyType="Switch" PartID="1010_BL_18">
		<General Desc="BL_0" Area="425 426 445 457" MonitorAddr="HSX1048.6" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_19" PartClassifyType="Switch" PartID="1010_BL_19">
		<General Desc="BL_0" Area="425 472 445 503" MonitorAddr="HSX1048.7" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_20" PartClassifyType="Switch" PartID="1010_BL_20">
		<General Desc="BL_0" Area="425 517 445 548" MonitorAddr="HSX1048.8" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_21" PartClassifyType="Switch" PartID="1010_BL_21">
		<General Desc="BL_0" Area="425 563 445 594" MonitorAddr="HSX1048.9" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_22" PartClassifyType="Switch" PartID="1010_BL_22">
		<General Desc="BL_0" Area="425 608 445 639" MonitorAddr="HSX1048.10" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_23" PartClassifyType="Switch" PartID="1010_BL_23">
		<General Desc="BL_0" Area="425 654 445 685" MonitorAddr="HSX1048.11" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID="—" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_24" PartClassifyType="Switch" PartID="1010_BL_24">
		<General Desc="BL_0" Area="533 154 553 185" MonitorAddr="HSX1048.0" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID=":" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_25" PartClassifyType="Switch" PartID="1010_BL_25">
		<General Desc="BL_0" Area="533 199 553 230" MonitorAddr="HSX1048.1" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID=":" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_26" PartClassifyType="Switch" PartID="1010_BL_26">
		<General Desc="BL_0" Area="533 245 553 276" MonitorAddr="HSX1048.2" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID=":" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_27" PartClassifyType="Switch" PartID="1010_BL_27">
		<General Desc="BL_0" Area="533 290 553 321" MonitorAddr="HSX1048.3" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID=":" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_28" PartClassifyType="Switch" PartID="1010_BL_28">
		<General Desc="BL_0" Area="533 336 553 367" MonitorAddr="HSX1048.4" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID=":" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_29" PartClassifyType="Switch" PartID="1010_BL_29">
		<General Desc="BL_0" Area="533 381 553 412" MonitorAddr="HSX1048.5" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID=":" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_30" PartClassifyType="Switch" PartID="1010_BL_30">
		<General Desc="BL_0" Area="533 426 553 457" MonitorAddr="HSX1048.6" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID=":" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_31" PartClassifyType="Switch" PartID="1010_BL_31">
		<General Desc="BL_0" Area="533 472 553 503" MonitorAddr="HSX1048.7" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID=":" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_32" PartClassifyType="Switch" PartID="1010_BL_32">
		<General Desc="BL_0" Area="533 517 553 548" MonitorAddr="HSX1048.8" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID=":" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_33" PartClassifyType="Switch" PartID="1010_BL_33">
		<General Desc="BL_0" Area="533 563 553 594" MonitorAddr="HSX1048.9" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID=":" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_34" PartClassifyType="Switch" PartID="1010_BL_34">
		<General Desc="BL_0" Area="533 608 553 639" MonitorAddr="HSX1048.10" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID=":" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="IndicatorLamp" PartName="BL_35" PartClassifyType="Switch" PartID="1010_BL_35">
		<General Desc="BL_0" Area="533 654 553 685" MonitorAddr="HSX1048.11" Fast="0" BmpIndex="-1" LaStartPt="10 15" BitShowReverse="0" FigureFile="" BorderColor="0xf7e7ad 0" TextAlign="0" TextArea="0 0" />
		<Extension TouchState="1" Buzzer="1" />
		<MoveZoom DataFormatMZ="0" MutipleMZ="1.000000000000000" />
		<TrigHide UseShowHide="0" HideType="0" IsHideAllTime="0" />
		<Glint UseGlint="0" Glintfrq="0" />
		<Label Status="0" Bold="0" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xffccaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xfa6508 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
		<Label Status="1" Bold="0" LaIndexID=":" CharSize="1313131313131313" LaFrnColor="0x0 0" svgfile="" dark="0x0 0" light="0xaaffaa 0" hlight="0x0 0" shadow="0x0 0" shape="0x0 0" gstartcolor="0xffffff 0" gmidcolor="0x0 0" gendcolor="0xff00 0" Pattern="1" FrnColor="0xfdf0c4 0" BgColor="0xfdf0c4 0" />
	</PartInfo>
	<PartInfo PartType="Rect" PartName="REC_1" PartClassifyType="OtherClassType" PartID="1010_REC_1">
		<General Area="170 16 210 50" Rx="0" BorderColor="0xffffff -1" Pattern="-1" BgColor="0x0 0" PatternNew="0" BgColorNew="0xfefab8 0" ChangeColor="0xffffff 0" IsCirleAngle="0" IsCorlorAddr="0" LineTranValue="0" IsTranValue="0" LineWidth="2" CirleAngle="1" IsMoveControl="0" />
	</PartInfo>
	<PartInfo PartType="Rect" PartName="REC_2" PartClassifyType="OtherClassType" PartID="1010_REC_2">
		<General Area="444 16 598 50" Rx="0" BorderColor="0xffffff -1" Pattern="-1" BgColor="0x0 0" PatternNew="0" BgColorNew="0xfefab8 0" ChangeColor="0xffffff 0" IsCirleAngle="0" IsCorlorAddr="0" LineTranValue="0" IsTranValue="0" LineWidth="2" CirleAngle="1" IsMoveControl="0" />
	</PartInfo>
	<PartInfo PartType="Rect" PartName="REC_3" PartClassifyType="OtherClassType" PartID="1010_REC_3">
		<General Area="170 58 210 92" Rx="0" BorderColor="0xffffff -1" Pattern="-1" BgColor="0x0 0" PatternNew="0" BgColorNew="0xfefab8 0" ChangeColor="0xffffff 0" IsCirleAngle="0" IsCorlorAddr="0" LineTranValue="0" IsTranValue="0" LineWidth="2" CirleAngle="1" IsMoveControl="0" />
	</PartInfo>
</ScrInfo>
