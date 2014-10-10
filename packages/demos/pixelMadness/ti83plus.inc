
#define EQU .EQU
#define equ .EQU

usermemoff        = $89EC
_ldhlind          = $4009
_newline          = $452E
_JForceCmd        = $402A
_homeup           = $4558

;======================================================================
; Include File for the TI-83 Plus
; Last Updated 10/27/1999 
;
; Copyright (c) 1999 Texas Instruments: The Licensed Materials are
; copyrighted by TI. LICENSEE agrees that it will 
; not delete the copyright notice, trademarks or
; protective notices from any copy made by LICENSEE.
;
; Warranty: TI does not warrant that the Licensed Materials will
; be free from errors or will meet your specific requirements.
; The Licensed Materials are made available "AS IS" to LICENSEE.
;
; Limitations: TI MAKES NO WARRANTY OR CONDITION, EITHER EXPRESS
; OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY IMPLIED
; WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE,
; REGARDING THE LICENSED MATERIALS.  IN NO EVENT SHALL
; TI OR ITS SUPPLIERS BE LIABLE FOR ANY INDIRECT, INCIDENTAL
; OR CONSEQUENTIAL DAMAGES, LOSS OF PROFITS, LOSS OF USE OR DATA, 
; OR INTERRUPTION OF BUSINESS, WHETHER THE ALLEGED DAMAGES ARE
; LABELED IN TORT, CONTRACT OR INDEMNITY.
;
;======================================================================
;           System Variable Equates
;======================================================================
;       Entry Points : RclSysTok, StoSysTok
;
XSCLt		EQU  2
YSCLt		EQU  3
XMINt		EQU  0Ah
XMAXt		EQU  0Bh
YMINt		EQU  0Ch
YMAXt		EQU  0Dh
TMINt		EQU  0Eh
TMAXt		EQU  0Fh
THETMINt	EQU  10h
THETMAXt	EQU  11h
TBLMINt		EQU  1Ah
PLOTSTARTt	EQU  1Bh
NMAXt		EQU  1Dh
NMINt		EQU  1Fh
TBLSTEPt	EQU  21h
TSTEPt		EQU  22h
THETSTEPt	EQU  23h
DELTAXt		EQU  26h
DELTAYt		EQU  27h
XFACTt		EQU  28h
YFACTt		EQU  29h
FINNt		EQU  2Bh
FINIt		EQU  2Ch
FINPVt		EQU  2Dh
FINPMTt		EQU  2Eh
FINFVt		EQU  2Fh
FINPYt		EQU  30h
FINCYt		EQU  31h
PLOTSTEPt	EQU  34h
XRESt		EQU  36h
;

;======================================================================
;           Run indicators
;======================================================================
;
busyPause	EQU	10101010b
busyNormal	EQU	11110000b
;
;======================================================================
; Macro to call base code from an app,
;======================================================================
;
rBR_CALL	EQU	28h		; NEEDED FOR APPS
BRT_JUMP0	EQU	50h
;
;======================================================================
;           Common subroutine RST numbers  
;======================================================================
;
rOP1TOOP2	EQU  08h
rFINDSYM	EQU  10h
rPUSHREALO1	EQU  18h
rMOV9TOOP1	EQU  20h
rFPADD	EQU  30h
;

;SYMBOLIC_DEBUG_START
;======================================================================
;           Entry points  
;======================================================================
;
_AbsO1O2Cp	EQU 410Eh
_AbsO1PAbsO2	EQU 405Ah
_ACos		EQU 40DEh
_ACosH		EQU 40F0h
_ACosRad	EQU 40D2h
_AdrLEle	EQU 462Dh
_AdrMEle	EQU 4609h
_AdrMRow	EQU 4606h
_AllEq		EQU 4876h
_AllocFPS	EQU 43A5h
_AllocFPS1	EQU 43A8h
_Angle		EQU 4102h
_AnsName	EQU 4B52h
_ApdSetup	EQU 4C93h
_AppGetCalc	EQU 4C78h
_AppGetCbl	EQU 4C75h
_Arc_Unarc	EQU 4FD8h
_ASin		EQU 40E4h
_ASinH		EQU 40EDh
_ASinRad	EQU 40DBh
_ATan		EQU 40E1h
_ATan2		EQU 40E7h
_ATan2Rad	EQU 40D8h
_ATanH		EQU 40EAh
_ATanRad	EQU 40D5h

_BinOPExec	EQU 4663h
_Bit_VertSplit	EQU 4FA8h
_BufClr		EQU 5074h
_BufCpy		EQU 5071h

_CAbs		EQU 4E97h
_CAdd		EQU 4E88h
_CanAlphIns	EQU 4C69h
_CDiv		EQU 4E94h
_CDivByReal	EQU 4EBBh
_CEtoX		EQU 4EA9h
_CFrac		EQU 4EC1h
_CheckSplitFlag	EQU 49F0h
_ChkFindSym	EQU 42F1h
_CIntgr		EQU 4EC4h
_CircCmd	EQU 47D4h
_CkInt		EQU 4234h
_CkOdd		EQU 4237h
_CkOP1C0	EQU 4225h
_CkOP1Cplx	EQU 40FCh
_CkOP1FP0	EQU 4228h
_CkOP1Pos	EQU 4258h
_CkOP1Real	EQU 40FFh
_CkOP2FP0	EQU 422Bh
_CkOP2Pos	EQU 4255h
_CkOP2Real	EQU 42DFh
_CkPosInt	EQU 4231h
_CkValidNum	EQU 4270h
_CleanAll	EQU 4A50h
_ClearRect	EQU 4D5Ch
_ClearRow	EQU 4CEDh
_CLine		EQU 4798h
_CLineS		EQU 479Bh
_CLN		EQU 4EA0h
_CLog		EQU 4EA3h
_CloseEditBufNoR	EQU 476Eh
_CloseProg	EQU 4A35h
_ClrGraphRef	EQU 4A38h
_ClrLCD		EQU 4543h
_ClrLCDFull	EQU 4540h
_ClrLp		EQU 41D1h
_ClrOP1S	EQU 425Eh
_ClrOP2S	EQU 425Bh
_ClrScrn	EQU 4549h
_ClrScrnFull	EQU 4546h
_ClrTxtShd	EQU 454Ch
_CMltByReal	EQU 4EB8h
_CmpSyms	EQU 4A4Ah
_CMult		EQU 4E8Eh
_Conj		EQU 4EB5h
_ConvDim	EQU 4B43h
_ConvDim00	EQU 4B46h
_ConvLcToLr	EQU 4A23h
_ConvLrToLc	EQU 4A56h
_ConvOP1	EQU 4AEFh
_COP1Set0	EQU 4105h
_Cos		EQU 40C0h
_CosH		EQU 40CCh
_CpHLDE		EQU 400Ch
_CPoint		EQU 4DC8h
_CPointS	EQU 47F5h
_CpOP1OP2	EQU 4111h
_CpOP4OP3	EQU 4108h
_CpyO1ToFPS1	EQU 445Ch
_CpyO1ToFPS2	EQU 446Bh
_CpyO1ToFPS3	EQU 4477h
_CpyO1ToFPS4	EQU 4489h
_CpyO1ToFPS5	EQU 4483h
_CpyO1ToFPS6	EQU 447Dh
_CpyO1ToFPS7	EQU 4480h
_CpyO1ToFPST	EQU 444Ah
_CpyO2ToFPS1	EQU 4459h
_CpyO2ToFPS2	EQU 4462h
_CpyO2ToFPS3	EQU 4474h
_CpyO2ToFPS4	EQU 4486h
_CpyO2ToFPST	EQU 4444h
_CpyO3ToFPS1	EQU 4453h
_CpyO3ToFPS2	EQU 4465h
_CpyO3ToFPST	EQU 4441h
_CpyO5ToFPS1	EQU 4456h
_CpyO5ToFPS3	EQU 4471h
_CpyO6ToFPS2	EQU 4468h
_CpyO6ToFPST	EQU 4447h
_CpyStack	EQU 4429h
_CpyTo1FPS1	EQU 4432h
_CpyTo1FPS2	EQU 443Bh
_CpyTo1FPS3	EQU 4408h
_CpyTo1FPS4	EQU 440Eh
_CpyTo1FPS5	EQU 43DEh
_CpyTo1FPS6	EQU 43E4h
_CpyTo1FPS7	EQU 43EAh
_CpyTo1FPS8	EQU 43EDh
_CpyTo1FPS9	EQU 43F6h
_CpyTo1FPST	EQU 4423h
_CpyTo2FPS1	EQU 442Fh
_CpyTo2FPS2	EQU 4438h
_CpyTo2FPS3	EQU 4402h
_CpyTo2FPS4	EQU 43F9h
_CpyTo2FPS5	EQU 43DBh
_CpyTo2FPS6	EQU 43E1h
_CpyTo2FPS7	EQU 43E7h
_CpyTo2FPS8	EQU 43F0h
_CpyTo2FPST	EQU 4420h
_CpyTo3FPS1	EQU 442Ch
_CpyTo3FPS2	EQU 4411h
_CpyTo3FPST	EQU 441Dh
_CpyTo4FPST	EQU 441Ah
_CpyTo5FPST	EQU 4414h
_CpyTo6FPS2	EQU 43FFh
_CpyTo6FPS3	EQU 43FCh
_CpyTo6FPST	EQU 4417h
_CpyToFPS1	EQU 445Fh
_CpyToFPS2	EQU 446Eh
_CpyToFPS3	EQU 447Ah
_CpyToFPST	EQU 444Dh
_CpyToStack	EQU 4450h
_Create0Equ	EQU 432Ah
_CreateAppVar	EQU 4E6Ah
_CreateCList	EQU 431Bh
_CreateCplx	EQU 430Ch
_CreateEqu	EQU 4330h
_CreatePair	EQU 4B0Dh
_CreatePict	EQU 4333h
_CreateProg	EQU 4339h
_CreateProtProg	EQU 4E6Dh
_CreateReal	EQU 430Fh
_CreateRList	EQU 4315h
_CreateRMat	EQU 4321h
_CreateStrng	EQU 4327h
_CRecip		EQU 4E91h
_CSqRoot	EQU 4E9Dh
_CSquare	EQU 4E8Bh
_CSub		EQU 4E85h
_CTenX		EQU 4EA6h
_CTrunc		EQU 4EBEh
_Cube		EQU 407Bh
_CursorOff	EQU 45BEh
_CursorOn	EQU 45C4h
_CXrootY	EQU 4EACh
_CYtoX		EQU 4EB2h

_DarkLine	EQU 47DDh
_DarkPnt	EQU 47F2h
_DataSize	EQU 436Ch
_DataSizeA	EQU 4369h
_DeallocFPS	EQU 439Fh
_DeallocFPS1	EQU 43A2h
_DecO1Exp	EQU 4267h
_DelListEl	EQU 4A2Fh
_DelMem		EQU 4357h
_DelRes		EQU 4A20h
_DelVar		EQU 4351h
_DelVarArc	EQU 4FC6h
_DelVarNoArc	EQU 4FC9h
_DisableApd	EQU 4C84h
_Disp		EQU 4F45h
_DispDone	EQU 45B5h
_DispEOL	EQU 45A6h
_DispHL		EQU 4507h
_DisplayImage	EQU 4D9Bh
_DispOP1A	EQU 4BF7h
_DivHLBy10	EQU 400Fh
_DivHLByA	EQU 4012h
_DrawCirc2	EQU 4C66h
_DrawCmd	EQU 48C1h
_DrawRectBorder	EQU 4D7Dh
_DrawRectBorderClear	EQU 4D8Ch
_DToR		EQU 4075h

_EditProg	EQU 4A32h
_EnableApd	EQU 4C87h
_EnoughMem	EQU 42FDh
_EOP1NotReal	EQU 4279h
_Equ_or_NewEqu	EQU 42C4h
_EraseEOL	EQU 4552h
_EraseRectBorder	EQU 4D86h
_ErrArgument	EQU 44ADh
_ErrBadGuess	EQU 44CBh
_ErrBreak	EQU 44BFh
_ErrD_OP1_0	EQU 42D3h
_ErrD_OP1_LE_0	EQU 42D0h
_ErrD_OP1Not_R	EQU 42CAh
_ErrD_OP1NotPos	EQU 42C7h
_ErrD_OP1NotPosInt	EQU 42CDh


_ErrDataType	EQU 44AAh
_ErrDimension	EQU 44B3h
_ErrDimMismatch	EQU 44B0h
_ErrDivBy0	EQU 4498h
_ErrDomain	EQU 449Eh
_ErrIncrement	EQU 44A1h
_ErrInvalid	EQU 44BCh
_ErrIterations	EQU 44C8h
_ErrLinkXmit	EQU 44D4h
_ErrMemory	EQU 44B9h
_ErrNon_Real	EQU 44A4h
_ErrNonReal	EQU 4A8Ch
_ErrNotEnoughMem	EQU 448Ch
_ErrOverflow	EQU 4495h
_ErrSignChange	EQU 44C5h
_ErrSingularMat	EQU 449Bh
_ErrStat	EQU 44C2h
_ErrStatPlot	EQU 44D1h
_ErrSyntax	EQU 44A7h
_ErrTolTooSmall	EQU 44CEh
_ErrUndefined	EQU 44B6h
_EToX		EQU 40B4h
_Exch9		EQU 43D5h
_ExLp		EQU 4222h
_ExpToHex	EQU 424Fh

_Factorial	EQU 4B85h
_FillRect	EQU 4D62h
_FillRectPattern	EQU 4D89h
_Find_Parse_Formula	EQU 4AF2h
_FindAlphaDn	EQU 4A47h
_FindAlphaUp	EQU 4A44h
_FindApp		EQU 4C4Eh
_FindAppDn		EQU 4C4Bh
_FindAppNumPages	EQU 509Bh
_FindAppUp		EQU 4C48h
_FindSym	EQU 42F4h
_FiveExec	EQU 467Eh
_FixTempCnt	EQU 4A3Bh
_FlashToRam	EQU 5017h
_ForceFullScreen	EQU 508Fh
_FormBase	EQU 50AAh
_FormDCplx	EQU 4996h
_FormEReal	EQU 4990h
_FormReal	EQU 4999h
_FourExec	EQU 467Bh
_FPAdd		EQU 4072h
_FPDiv		EQU 4099h
_FPMult		EQU 4084h
_FPRecip	EQU 4096h
_FPSquare	EQU 4081h
_FPSub		EQU 406Fh
_Frac		EQU 4093h

_GetBaseVer	EQU 4C6Fh
_GetCSC		EQU 4018h
_GetKey		EQU 4972h
_GetLToOP1	EQU 4636h
_GetMToOP1	EQU 4615h
_GetTokLen	EQU 4591h
_GrBufClr	EQU 4BD0h
_GrBufCpy	EQU 486Ah
_GrphCirc	EQU 47D7h

_HLTimes9	EQU 40F9h
_HorizCmd	EQU 48A6h
_HTimesL	EQU 4276h

_IBounds	EQU 4C60h
_IBoundsFull	EQU 4D98h
_ILine		EQU 47E0h
_IncLstSize	EQU 4A29h
_InsertList	EQU 4A2Ch
_InsertMem	EQU 42F7h
_Int		EQU 40A5h
_Intgr		EQU 405Dh
_InvCmd		EQU 48C7h
_InvertRect	EQU 4D5Fh
_InvOP1S	EQU 408Dh
_InvOP1SC	EQU 408Ah
_InvOP2S	EQU 4090h
_InvSub		EQU 4063h
_IOffset	EQU 4C63h
_IPoint		EQU 47E3h

_JError		EQU 44D7h
_JErrorNo	EQU 4000h
_JForceCmdNoChar	EQU 4027h
_JForceGraphKey	EQU 5005h
_JForceGraphNoKey	EQU 5002h

_KeyToString	EQU 45CAh

_LineCmd	EQU 48ACh
_LnX		EQU 40ABh
_Load_SFont	EQU 4783h
_LoadCIndPaged	EQU 501Dh
_LoadDEIndPaged	EQU 501Ah
_LoadPattern	EQU 4CB1h
_LogX		EQU 40AEh

_Max		EQU 4057h
_MemChk		EQU 42E5h
_MemClear	EQU 4C30h
_MemSet		EQU 4C33h
_Min		EQU 4054h
_Minus1		EQU 406Ch
_Mov10B		EQU 415Ch
_Mov18B		EQU 47DAh
_Mov7B		EQU 4168h
_Mov8B		EQU 4165h
_Mov9B		EQU 415Fh
_Mov9OP1OP2	EQU 417Dh
_Mov9OP2Cp	EQU 410Bh
_Mov9ToOP1	EQU 417Ah
_Mov9ToOP2	EQU 4180h
_MovFrOP1	EQU 4183h

_OneVar		EQU 4BA3h
_OP1ExOP2	EQU 421Fh
_OP1ExOP3	EQU 4219h
_OP1ExOP4	EQU 421Ch
_OP1ExOP5	EQU 420Dh
_OP1ExOP6	EQU 4210h
_OP1ExpToDec	EQU 4252h
_OP1Set0	EQU 41BFh
_OP1Set1	EQU 419Bh
_OP1Set2	EQU 41A7h
_OP1Set3	EQU 41A1h
_OP1Set4	EQU 419Eh
_OP1ToOP2	EQU 412Fh
_OP1ToOP3	EQU 4123h
_OP1ToOP4	EQU 4117h
_OP1ToOP5	EQU 4153h
_OP1ToOP6	EQU 4150h
_OP2ExOP4	EQU 4213h
_OP2ExOP5	EQU 4216h
_OP2ExOP6	EQU 4207h
_OP2Set0	EQU 41BCh
_OP2Set1	EQU 41ADh
_OP2Set2	EQU 41AAh
_OP2Set3	EQU 4198h
_OP2Set4	EQU 4195h
_OP2Set5	EQU 418Fh
_OP2Set60	EQU 4AB0h
_OP2Set8	EQU 418Ch
_OP2SetA	EQU 4192h
_OP2ToOP1	EQU 4156h
_OP2ToOP3	EQU 416Eh
_OP2ToOP4	EQU 411Ah
_OP2ToOP5	EQU 414Ah
_OP2ToOP6	EQU 414Dh
_OP3Set0	EQU 41B9h
_OP3Set1	EQU 4189h
_OP3Set2	EQU 41A4h
_OP3ToOP1	EQU 413Eh
_OP3ToOP2	EQU 4120h
_OP3ToOP4	EQU 4114h
_OP3ToOP5	EQU 4147h
_OP4Set0	EQU 41B6h
_OP4Set1	EQU 4186h
_OP4ToOP1	EQU 4138h
_OP4ToOP2	EQU 411Dh
_OP4ToOP3	EQU 4171h
_OP4ToOP5	EQU 4144h
_OP4ToOP6	EQU 4177h
_OP5ExOP6	EQU 420Ah
_OP5Set0	EQU 41B3h
_OP5ToOP1	EQU 413Bh
_OP5ToOP2	EQU 4126h
_OP5ToOP3	EQU 4174h
_OP5ToOP4	EQU 412Ch
_OP5ToOP6	EQU 4129h
_OP6ToOP1	EQU 4135h
_OP6ToOP2	EQU 4132h
_OP6ToOP5	EQU 4141h
_OutputExpr	EQU 4BB2h

_PagedGet	EQU 5023h
_ParseInp	EQU 4A9Bh
_PDspGrph	EQU 48A3h
_PixelTest	EQU 48B5h
_Plus1		EQU 4069h
_PointCmd	EQU 48B2h
_PointOn	EQU 4C39h
_PopOP1		EQU 437Eh
_PopOP3		EQU 437Bh
_PopOP5		EQU 4378h
_PopReal	EQU 4393h
_PopRealO1	EQU 4390h
_PopRealO2	EQU 438Dh
_PopRealO3	EQU 438Ah
_PopRealO4	EQU 4387h
_PopRealO5	EQU 4384h
_PopRealO6	EQU 4381h
_PosNo0Int	EQU 422Eh
_PtoR		EQU 40F3h
_PushOP1	EQU 43C9h
_PushOP3	EQU 43C3h
_PushOP5	EQU 43C0h
_PushReal	EQU 43BDh
_PushRealO1	EQU 43BAh
_PushRealO2	EQU 43B7h
_PushRealO3	EQU 43B4h
_PushRealO4	EQU 43B1h
_PushRealO5	EQU 43AEh
_PushRealO6	EQU 43ABh
_PutC		EQU 4504h
_PutMap		EQU 4501h
_PutPS		EQU 4510h
_PutS		EQU 450Ah
_PutTokString	EQU 4960h
_PutToL		EQU 4645h
_PutToMat	EQU 461Eh

_RandInit	EQU 4B7Fh
_Random		EQU 4B79h
_Rcl_StatVar	EQU 42DCh
_RclAns		EQU 4AD7h
_RclGDB2	EQU 47D1h
_RclN		EQU 4ADDh
_RclSysTok	EQU 4AE6h
_RclVarSym	EQU 4AE3h
_RclX		EQU 4AE0h
_RclY		EQU 4ADAh
_Rec1stByte	EQU 4EFAh
_Rec1stByteNC	EQU 4EFDh
_RecAByteIO	EQU 4F03h
_RedimMat	EQU 4A26h
_Regraph	EQU 488Eh
_ReloadAppEntryVecs	EQU 4C36h
_RestoreDisp	EQU 4870h
_RName		EQU 427Fh
_RndGuard	EQU 409Fh
_RnFx		EQU 40A2h
_Round		EQU 40A8h
_RToD		EQU 4078h
_RToP		EQU 40F6h
_RunIndicOff	EQU 4570h
_RunIndicOn	EQU 456Dh

_SaveDisp	EQU 4C7Bh
_SendAByte	EQU 4EE5h
_SetAllPlots	EQU 4FCCh
_SetFuncM	EQU 4840h
_SetNorm_Vals	EQU 49FCh
_SetParM	EQU 4849h
_SetPolM	EQU 4846h
_SetSeqM	EQU 4843h
_SetTblGraphDraw	EQU 4C00h
_SetupPagedPtr	EQU 5020h
_SetXXOP1	EQU 478Ch
_SetXXOP2	EQU 478Fh
_SetXXXXOP2	EQU 4792h
_SFont_Len	EQU 4786h
_Sin		EQU 40BDh
_SinCosRad	EQU 40BAh
_SinH		EQU 40CFh
_SinHCosH	EQU 40C6h
_SqRoot		EQU 409Ch
_SrchVLstDn	EQU 4F12h
_SrchVLstUp	EQU 4F0Fh
_SStringLength	EQU 4CB4h
_StMatEl	EQU 4AE9h
_StoAns		EQU 4ABFh
_StoGDB2	EQU 47CEh
_StoN		EQU 4ACBh
_StoOther	EQU 4AD4h
_StoR		EQU 4AC5h
_StoRand	EQU 4B7Ch
_StoSysTok	EQU 4ABCh
_StoT		EQU 4ACEh
_StoTheta	EQU 4AC2h
_StoX		EQU 4AD1h
_StoY		EQU 4AC8h
_StrCopy	EQU 44E3h
_StrLength	EQU 4C3Fh   

_Tan		EQU 40C3h
_TanH		EQU 40C9h
_TanLnF		EQU 48BBh
_TenX		EQU 40B7h
_ThetaName	EQU 427Ch
_ThreeExec	EQU 4675h
_Times2		EQU 4066h
_TimesPt5	EQU 407Eh
_TName		EQU 428Eh
_ToFrac		EQU 4657h
_Trunc		EQU 4060h

_UCLineS	EQU 4795h
_UnLineCmd	EQU 48AFh
_UnOPExec	EQU 4672h

_VertCmd	EQU 48A9h
_VPutMap	EQU 455Eh
_VPutS		EQU 4561h
_VPutSN		EQU 4564h
_VtoWHLDE	EQU 47FBh


_XftoI		EQU 4804h
_Xitof		EQU 47FEh
_XName		EQU 4288h
_XRootY		EQU 479Eh

_YftoI		EQU 4801h
_YName		EQU 428Bh
_YToX		EQU 47A1h

_Zero16D	EQU 41B0h
_ZeroOP		EQU 41CEh
_ZeroOP1	EQU 41C5h
_ZeroOP2	EQU 41C8h
_ZeroOP3	EQU 41CBh
_ZmDecml	EQU 484Fh
_ZmFit		EQU 485Bh
_ZmInt		EQU 484Ch
_ZmPrev		EQU 4852h
_ZmSquare	EQU 485Eh
_ZmStats	EQU 47A4h
_ZmTrig		EQU 4861h
_ZmUsr		EQU 4855h
_ZooDefault	EQU 4867h
;
;======================================================================
;           System-defined RAM Variable Address Equates
;======================================================================
;

ramStart             EQU  8000h
appData              EQU  8000h
ramCode              EQU  8100h
ramCodeEnd           EQU  822Fh
baseAppBrTab         EQU  8230h
bootTemp             EQU  8251h
appSearchPage        EQU  82A3h
tempSwapArea         EQU  82A5h
appID                EQU  838Dh
ramReturnData        EQU  83EDh
arcInfo              EQU  83EEh
savedArcInfo         EQU  8406h
appInfo              EQU  8432h
appBank_jump         EQU  843Ch
appPage              EQU  843Eh
kbdScanCode          EQU  843Fh
kbdKey               EQU  8444h
kbdGetKy             EQU  8445h
keyExtend            EQU  8446h
contrast             EQU  8447h
apdSubTimer          EQU  8448h
apdTimer             EQU  8449h
curTime              EQU  844Ah
curRow               EQU  844Bh
curCol               EQU  844Ch
curOffset            EQU  844Dh
curUnder             EQU  844Eh
curY                 EQU  844Fh
curType              EQU  8450h
curXRow              EQU  8451h
prevDData            EQU  8452h
lFont_record         EQU  845Ah
sFont_record         EQU  8462h
tokVarPtr            EQU  846Ah
tokLen               EQU  846Ch
indicMem             EQU  846Eh
indicCounter         EQU  8476h
indicBusy            EQU  8477h
OP1                  EQU  8478h
OP1M                 EQU  847Ah
OP2                  EQU  8483h
OP2M                 EQU  8485h
OP2EXT               EQU  848Ch
OP3                  EQU  848Eh
OP3M                 EQU  8490h
OP4                  EQU  8499h
OP4M                 EQU  849Bh
OP5                  EQU  84A4h
OP5M                 EQU  84A6h
OP6                  EQU  84AFh
OP6M                 EQU  84B1h
OP6EXT               EQU  84B8h
progToEdit           EQU  84BFh
nameBuff             EQU  84C7h
equ_edit_save        EQU  84D2h
iMathPtr1            EQU  84D3h
iMathPtr2            EQU  84D5h
iMathPtr3            EQU  84D7h
iMathPtr4            EQU  84D9h
iMathPtr5            EQU  84DBh
chkDelPtr1           EQU  84DDh
chkDelPtr2           EQU  84DFh
insDelPtr            EQU  84E1h
upDownPtr            EQU  84E3h
fOutDat              EQU  84E5h
asm_data_ptr1        EQU  84EBh
asm_data_ptr2        EQU  84EDh
asm_sym_ptr1         EQU  84EFh
asm_sym_ptr2         EQU  84F1h
asm_ram              EQU  84F3h
asm_ind_call         EQU  8507h
textShadow           EQU  8508h
textShadCur          EQU  8588h
textShadTop          EQU  858Ah
textShadAlph         EQU  858Bh
textShadIns          EQU  858Ch
cxMain               EQU  858Dh
cxPPutAway           EQU  858Fh
cxPutAway            EQU  8591h
cxRedisp             EQU  8593h
cxErrorEP            EQU  8595h
cxSizeWind           EQU  8597h
cxPage               EQU  8599h
cxCurApp             EQU  859Ah
cxPrev               EQU  859Bh
monQH                EQU  85AAh
monQT                EQU  85ABh
monQueue             EQU  85ACh
onSP                 EQU  85BCh
promptRow            EQU  85C0h
promptCol            EQU  85C1h
promptIns            EQU  85C2h
promptShift          EQU  85C3h
promptRet            EQU  85C4h
promptValid          EQU  85C6h
promptTop            EQU  85C8h
promptCursor         EQU  85CAh
promptTail           EQU  85CCh
promptBtm            EQU  85CEh
varType              EQU  85D0h
varCurrent           EQU  85D1h
varClass             EQU  85D9h
menuActive           EQU  85DCh
menuAppDepth         EQU  85DDh
MenuCurrent          EQU  85DEh
ProgCurrent          EQU  85E8h
userMenuSA           EQU  85FEh
ioPrompt             EQU  865Fh
dImageWidth          EQU  8660h
ioFlag               EQU  8670h
sndRecState          EQU  8672h
ioErrState           EQU  8673h
header               EQU  8674h
ioData               EQU  867Dh
ioNewData            EQU  8689h
bakHeader            EQU  868Bh
penCol               EQU  86D7h
penRow               EQU  86D8h
rclQueue             EQU  86D9h
rclQueueEnd          EQU  86DBh
errNo                EQU  86DDh
errSP                EQU  86DEh
errOffset            EQU  86E0h
saveSScreen          EQU  86ECh
bstCounter           EQU  89EEh
flags                EQU  89F0h
statVars             EQU  8A3Ah
anovaf_vars          EQU  8C17h
infVars              EQU  8C4Dh
curGStyle            EQU  8D17h
curGY                EQU  8D18h
curGX                EQU  8D19h
curGY2               EQU  8D1Ah
curGX2               EQU  8D1Bh
freeSaveY            EQU  8D1Ch
freeSaveX            EQU  8D1Dh
XOffset              EQU  8DA1h
YOffset              EQU  8DA2h
lcdTallP             EQU  8DA3h
pixWideP             EQU  8DA4h
pixWide_m_1          EQU  8DA5h
pixWide_m_2          EQU  8DA6h
lastEntryPTR         EQU  8DA7h
lastEntryStk         EQU  8DA9h
numLastEntries       EQU  8E29h
currLastEntry        EQU  8E2Ah
curInc               EQU  8E67h
uXmin                EQU  8E7Eh
uXmax                EQU  8E87h
uXscl                EQU  8E90h
uYmin                EQU  8E99h
uYmax                EQU  8EA2h
uYscl                EQU  8EABh
uThetMin             EQU  8EB4h
uThetMax             EQU  8EBDh
uThetStep            EQU  8EC6h
uTmin                EQU  8ECFh
uTmax                EQU  8ED8h
uTStep               EQU  8EE1h
uPlotStart           EQU  8EEAh
unMax                EQU  8EF3h
uu0                  EQU  8EFCh
uv0                  EQU  8F05h
unMin                EQU  8F0Eh
uu02                 EQU  8F17h
uv02                 EQU  8F20h
uw0                  EQU  8F29h
uPlotStep            EQU  8F32h
uXres                EQU  8F3Bh
uw02                 EQU  8F44h
Xmin                 EQU  8F50h
Xmax                 EQU  8F59h
Xscl                 EQU  8F62h
Ymin                 EQU  8F6Bh
Ymax                 EQU  8F74h
Yscl                 EQU  8F7Dh
ThetaMin             EQU  8F86h
ThetaMax             EQU  8F8Fh
ThetaStep            EQU  8F98h
TminPar              EQU  8FA1h
TmaxPar              EQU  8FAAh
Tstep                EQU  8FB3h
PlotStart            EQU  8FBCh
nMax                 EQU  8FC5h
u0                   EQU  8FCEh
v0                   EQU  8FD7h
nMin                 EQU  8FE0h
u02                  EQU  8FE9h
v02                  EQU  8FF2h
w0                   EQU  8FFBh
PlotStep             EQU  9004h
XresO                EQU  900Dh
w02                  EQU  9016h
un1                  EQU  901Fh
un2                  EQU  9028h
vn1                  EQU  9031h
vn2                  EQU  903Ah
wn1                  EQU  9043h
wn2                  EQU  904Ch
fin_N                EQU  9055h
fin_I                EQU  905Eh
fin_PV               EQU  9067h
fin_PMT              EQU  9070h
fin_FV               EQU  9079h
fin_PY               EQU  9082h
fin_CY               EQU  908Bh
cal_N                EQU  9094h
cal_I                EQU  909Dh
cal_PV               EQU  90A6h
cal_PMT              EQU  90AFh
cal_FV               EQU  90B8h
cal_PY               EQU  90C1h
smallEditRAM         EQU  90D3h
XFact                EQU  913Fh
YFact                EQU  9148h
Xres_int             EQU  9151h
deltaX               EQU  9152h
deltaY               EQU  915Bh
shortX               EQU  9164h
shortY               EQU  916Dh
lower                EQU  9176h
upper                EQU  917Fh
XOutSym              EQU  918Ch
XOutDat              EQU  918Eh
YOutSym              EQU  9190h
YOutDat              EQU  9192h
inputSym             EQU  9194h
inputDat             EQU  9196h
prevData             EQU  9198h
TblMin               EQU  92B3h
TblStep              EQU  92BCh
plotSScreen          EQU  9340h
seed1                EQU  9640h
seed2                EQU  9649h
cmdShadow            EQU  966Eh
cmdShadCur           EQU  96EEh
cmdShadAlph          EQU  96F0h
cmdShadIns           EQU  96F1h
cmdCursor            EQU  96F2h
editTop              EQU  96F4h
editCursor           EQU  96F6h
editTail             EQU  96F8h
editBtm              EQU  96FAh
editSym              EQU  9706h
editDat              EQU  9708h
winTop               EQU  97A5h
winBtm               EQU  97A6h
winLeftEdge          EQU  97A7h
winLeft              EQU  97A8h
winAbove             EQU  97AAh
winRow               EQU  97ACh
winCol               EQU  97AEh
fmtDigits            EQU  97B0h
fmtString            EQU  97B1h
fmtConv              EQU  97F2h
fmtLeft              EQU  9804h
fmtIndex             EQU  9806h
fmtMatSym            EQU  9808h
fmtMatMem            EQU  980Ah
EQS                  EQU  980Ch
tSymPtr1             EQU  9818h
tSymPtr2             EQU  981Ah
chkDelPtr3           EQU  981Ch
chkDelPtr4           EQU  981Eh
tempMem              EQU  9820h
fpBase               EQU  9822h
FPS                  EQU  9824h
OPBase               EQU  9826h
OPS                  EQU  9828h
pTempCnt             EQU  982Ah
cleanTmp             EQU  982Ch
pTemp                EQU  982Eh
progPtr              EQU  9830h
newDataPtr           EQU  9832h
pagedCount           EQU  9834h
pagedPN              EQU  9835h
pagedGetPtr          EQU  9836h
pagedPutPtr          EQU  9838h
pagedBuf             EQU  983Ah
appErr1              EQU  984Dh
appErr2              EQU  985Ah
flashByte1           EQU  9867h
flashByte2           EQU  9868h
freeArcBlock         EQU  9869h
arcPage              EQU  986Bh
arcPtr               EQU  986Ch
appRawKeyHandle      EQU  9870h
appBackUpScreen      EQU  9872h
customHeight         EQU  9B72h
localLanguage        EQU  9B73h
cursorHookPtr        EQU  9B7Ch
rawKeyHookPtr        EQU  9B84h
getKeyHookPtr        EQU  9B88h
fontHookPtr          EQU  9B9Ch
restartClr           EQU  9BD0h
localTokStr          EQU  9D65h
keyForStr            EQU  9D76h
keyToStrRam          EQU  9D77h
sedMonSp             EQU  9D88h
bpSave               EQU  9D8Ah
userMem              EQU  9D95h
symTable             EQU  0FE66h

;SYMBOLIC_DEBUG_END
;
;======================================================================
;           Error handler equates/macros 
;======================================================================
;
APP_PUSH_ERRORH EQU	59h
APP_POP_ERRORH	EQU	5Ch
;
;======================================================================
;           System and State Flags
;======================================================================
;

trigFlags	EQU  0		;Trigonometry mode settings
trigDeg 	EQU    2	; 1=degrees, 0=radians

kbdFlags	EQU  0		;Keyboard scan
kbdSCR		EQU    3	; 1=scan code ready
kbdKeyPress	EQU    4	; 1=key has been pressed

doneFlags	EQU  0		;display "Done"
donePrgm	EQU    5	; 1=display "Done" after prgm

ioDelFlag	EQU  0
inDelete	EQU    0	;1 = DELETE SCREEN 

;----------------------------------------------------------------------
editFlags	EQU  1
editOpen	EQU    2	; 1=edit buffer is open

monFlags	EQU  1		;monitor flags
monAbandon	EQU    4	; 1=don't start any long process
				; in put away (#715)
;----------------------------------------------------------------------
plotFlags	EQU  2		;plot generation flags
plotLoc 	EQU    1	; 0=bkup & display, 1=display only
plotDisp	EQU    2	; 1=plot is in display, 0=text in display


grfModeFlags	EQU  2		;graph mode settings
grfFuncM	EQU    4	; 1=function graph
grfPolarM	EQU    5	; 1=polar graph
grfParamM	EQU    6	; 1=parametric graph
grfRecurM       EQU    7        ; 1=RECURSION graph

graphFlags	EQU  3
graphDraw	EQU    0	; 0=graph is valid, 1=redraw graph

grfDBFlags	EQU  4
grfDot		EQU    0	; 0=line, 1=dot
grfSimul	EQU    1	; 0=sequential, 1=simultaneous
grfGrid 	EQU    2	; 0=no grid, 1=grid
grfPolar	EQU    3	; 0=rectangular, 1=polar coordinates
grfNoCoord	EQU    4	; 0=display coordinates, 1=off
grfNoAxis	EQU    5	; 0=axis, 1=no axis
grfLabel	EQU    6	; 0=off, 1=axis label

textFlags	EQU  5		;Text output flags
textEraseBelow	EQU    1	; 1=erase line below small char
textScrolled	EQU    2	; 1=screen scrolled
textInverse	EQU    3	; 1=display inverse bit-map
textInsMode	EQU    4	; 0=overstrike, 1=insert mode

ParsFlag2	EQU  7		;PARSER flags
numOP1		EQU    0	; 1=RESULT IN OP1, 0=NO RESULT

newDispF        EQU  8		;Derivative mode flags
preClrForMode   EQU    0	; 1=HELP BLINK ON MODE SCREEN

apdFlags	EQU  8		;Automatic power-down
apdAble 	EQU    2	; 1=APD enabled
apdRunning	EQU    3	; 1=APD clock running


web_err_mask    EQU  60h

onFlags 	EQU  9		;on key flags
onInterrupt	EQU    4	; 1=on key interrupt request

statFlags	EQU  9		;statistics flags
statsValid	EQU    6	; 1=stats are valid

fmtFlags	EQU  10		;numeric format flags
fmtExponent	EQU    0	; 1=show exponent, 0=no exponent
fmtEng		EQU    1	; 1=engineering notion, 0=scientific
fmtHex		EQU    2	; 1=hexadecimal
fmtOct		EQU    3	; 1=octal
fmtBin		EQU    4	; 1=binary
;
numMode         EQU  10
fmtReal         EQU    5
fmtRect         EQU    6
fmtPolar        EQU    7

realMode        EQU    5
rectMode        EQU    6
polarMode       EQU    7
;					;   if Hex and Oct both = 1
;					;   then Bin=0 means >Frac
;					;	 Bin=1 means >DMS
fmtBaseMask     EQU  00011100B		; mask to base flags
fmtBaseShift    EQU  2			; offset to base flags
;
;       CHECK IF THESE ARE USED BY NUMFORM,
;
;               EQU  6
;               EQU  7

fmtOverride	EQU  11		;copy of fmtFlags with conversion override

fmtEditFlags	EQU  12		;numeric editing flags
fmtEdit 	EQU    0	; 1=format number for editing

curFlags	EQU  12		;Cursor
curAble 	EQU    2	; 1=cursor flash is enabled
curOn		EQU    3	; 1=cursor is showing
curLock 	EQU    4	; 1=cursor is locked off

appFlags	EQU  13		;application flags
appWantIntrpt	EQU    0		; 1=want ON key interrupts
appTextSave	EQU    1		; 1=save characters in textShadow
appAutoScroll	EQU    2		; 1=auto-scroll text on last line
appMenus	EQU    3		; 1=process keys that bring up menus
					; 0=check Lock menu flag
appLockMenus	EQU    4		; 1=ignore menu keys
					; 0=switch to home screen and bring up menu
appCurGraphic	EQU    5		; 1=graphic cursor
appCurWord	EQU    6		; 1=text cursor covers entire word
appExit 	EQU    7		; 1=application handles [EXIT] key itself

appWantIntrptF	EQU	1<<appWantIntrpt
appTextSaveF	EQU	1<<appTextSave
appAutoScrollF	EQU	1<<appAutoScroll
appMenusF	EQU	1<<appMenus
appLockMenusF	EQU	1<<appLockMenus
appCurGraphicF	EQU	1<<appCurGraphic
appCurWordF	EQU	1<<appCurWord
appExitF	EQU	1<<appExit


seqFlags        EQU  15              ; Sequential Graph flags
webMode         EQU    0             ; 0 = NORMAL SEQ MODE, 1 = WEB MODE
webVert         EQU    1             ;
sequv           EQU    2             ; U vs V
seqvw           EQU    3             ; V vs W
sequw           EQU    4             ; U vs W


promptFlags	EQU  17		;prompt line flags
promptEdit	EQU    0	; 1=editing in prompt buffer

indicFlags	EQU  18		;Indicator flags
indicRun	EQU    0	; 1=run indicator ON
indicInUse	EQU    1	; indicator save area in use=1, free=0
indicOnly	EQU    2	; interrupt handler only checks run indicator

shiftFlags	EQU  18		;[2nd] and [ALPHA] flags
shift2nd	EQU    3	; 1=[2nd] has been pressed
shiftAlpha	EQU    4	; 1=[ALPHA] has been pressed
shiftLwrAlph	EQU    5	; 1=lower case, 0=upper case
shiftALock	EQU    6	; 1=alpha lock has been pressed
shiftKeepAlph	EQU    7	; 1=cannot cancel alpha shift


tblFlags        EQU  19		;table flags.
autoFill        EQU    4	; 1=prompt, 0=fillAuto
autoCalc        EQU    5	; 1=prompt, 0=CalcAuto
reTable         EQU    6	; 0=table is ok, 1=must recompute table.

sGrFlags	EQU  20
grfSplit        EQU    0	; 1=Split Graph, 0=Normal
vertSplit       EQU    1	; 1=Vertical (left-right) Split
grfSChanged     EQU    2	; 1=Graph just changed Split <-> normal
grfSplitOverride EQU   3	; 1 = ignore graph split flag if set
write_on_graph  EQU    4	; 1 = TEXT OR EQU WRITING TO GRAPH SCREEN
g_style_active  EQU    5	; 1 = GRAPH STYLES ARE ENABLED, USE THEM
cmp_mod_box     EQU    6	; 1 = DOING MOD BOX PLOT COMPUTATION
textWrite       EQU    7
;

newIndicFlags   EQU  21
extraIndic      EQU    0
saIndic         EQU    1

smartFlags      EQU  23
;
;----------------------------------------------------------------------
; Note: Fix these Equates if smartFlags are moved                            
;----------------------------------------------------------------------
;
smarter_mask    EQU  3
smarter_test    EQU  1
smartGraph      EQU  0
smartGraph_inv  EQU  1                                                 

;----------------------------------------------------------------------
;           Available for ASM programming
;----------------------------------------------------------------------

asm_Flag1       EQU  33          ; ASM CODING
asm_Flag2       EQU  34          ; ASM CODING
asm_Flag3       EQU  35          ; ASM CODING

;----------------------------------------------------------------------
;
getSendFlg	EQU  36
comFailed	EQU  1	      ; 1 = Get/Send Communication Failed
;
appLwrCaseFlag  EQU  36
lwrCaseActive   EQU  3
;
apiFlg3		EQU  42 
;
apiFlg4		EQU  43
fullScrnDraw	EQU    2	; DRAW INTO LAST ROW/COL OF SCREEN

groupFlags	EQU  38
inGroup		EQU  1		;1 = IN GROUP CONTEXT


xapFlag0        EQU  46      ; external app flags
xapFlag1        EQU  47
xapFlag2        EQU  48
xapFlag3        EQU  49

fontFlags	EQU  50
fracDrawLFont	EQU    2
fracTallLFont	EQU    3
customFont	EQU    7  

plotFlag3	EQU  60  
bufferOnly	EQU    0
useFastCirc	EQU    4

;
varTypeMask	EQU  1FH             
varGraphRef	EQU    6

;
;======================================================================
;           Character Font equates  
;======================================================================
;
LrecurN         EQU     001h
LrecurU 	EQU	002h
LrecurV 	EQU	003h
LrecurW		EQU	004h
Lconvert	EQU	005h
LsqUp		EQU	006h
LsqDown		EQU	007h
Lintegral	EQU	008h
Lcross		EQU	009h
LboxIcon 	EQU     00Ah
LcrossIcon 	EQU     00Bh
LdotIcon 	EQU     00Ch
LsubT   	EQU     00Dh		;small capital T for parametric mode.
LcubeR  	EQU     00Eh		;slightly different 3 for cubed root.
LhexF		EQU	00Fh
Lroot		EQU	010h
Linverse	EQU	011h
Lsquare		EQU	012h
Langle		EQU	013h
Ldegree		EQU	014h
Lradian		EQU	015h
Ltranspose	EQU	016h
LLE		EQU	017h
LNE		EQU	018h
LGE		EQU	019h
Lneg		EQU	01Ah
Lexponent	EQU	01Bh
Lstore		EQU	01Ch
Lten		EQU	01Dh
LupArrow	EQU	01Eh
LdownArrow	EQU	01Fh
Lspace		EQU	020h
Lexclam		EQU	021h
Lquote		EQU	022h
Lpound		EQU	023h
Lfourth		EQU     024h
Lpercent	EQU	025h
Lampersand	EQU	026h
Lapostrophe	EQU	027h
LlParen		EQU	028h
LrParen		EQU	029h
Lasterisk	EQU	02Ah
LplusSign	EQU	02Bh
Lcomma		EQU	02Ch
Ldash		EQU	02Dh
Lperiod		EQU	02Eh
Lslash		EQU	02Fh
L0		EQU	030h
L1		EQU	031h
L2		EQU	032h
L3		EQU	033h
L4		EQU	034h
L5		EQU	035h
L6		EQU	036h
L7		EQU	037h
L8		EQU	038h
L9		EQU	039h
Lcolon		EQU	03Ah
Lsemicolon	EQU	03Bh
LLT		EQU	03Ch
LEQ		EQU	03Dh
LGT		EQU	03Eh
Lquestion	EQU	03Fh
LatSign		EQU	040h
LcapA	EQU	041h
LcapB	EQU	042h
LcapC	EQU	043h
LcapD	EQU	044h
LcapE	EQU	045h
LcapF	EQU	046h
LcapG	EQU	047h
LcapH	EQU	048h
LcapI	EQU	049h
LcapJ	EQU	04Ah
LcapK	EQU	04Bh
LcapL	EQU	04Ch
LcapM	EQU	04Dh
LcapN	EQU	04Eh
LcapO	EQU	04Fh
LcapP	EQU	050h
LcapQ	EQU	051h
LcapR	EQU	052h
LcapS	EQU	053h
LcapT	EQU	054h
LcapU	EQU	055h
LcapV	EQU	056h
LcapW	EQU	057h
LcapX	EQU	058h
LcapY	EQU	059h
LcapZ	EQU	05Ah
Ltheta  EQU     05Bh
Lbackslash	EQU	05Ch
LrBrack		EQU	05Dh
Lcaret		EQU	05Eh
Lunderscore	EQU	05Fh
Lbackquote	EQU	060h
La	EQU	061h
Lb	EQU	062h
Lc	EQU	063h
Ld	EQU	064h
Le	EQU	065h
Lf	EQU	066h
Lg	EQU	067h
Lh	EQU	068h
Li	EQU	069h
Lj	EQU	06Ah
Lk	EQU	06Bh
Ll	EQU	06Ch
Lm	EQU	06Dh
Ln	EQU	06Eh
Lo	EQU	06Fh
Lp	EQU	070h
Lq	EQU	071h
Lr	EQU	072h
Ls	EQU	073h
Lt	EQU	074h
Lu	EQU	075h
Lv	EQU	076h
Lw	EQU	077h
Lx	EQU	078h
Ly	EQU	079h
Lz	EQU	07Ah
LlBrace	EQU	07Bh
Lbar	EQU	07Ch
LrBrace	EQU	07Dh
Ltilde	EQU	07Eh
LinvEQ	EQU	07Fh
Lsub0	EQU	080h
Lsub1	EQU	081h
Lsub2	EQU	082h
Lsub3	EQU	083h
Lsub4	EQU	084h
Lsub5	EQU	085h
Lsub6	EQU	086h
Lsub7	EQU	087h
Lsub8	EQU	088h
Lsub9	EQU	089h
LcapAAcute	EQU	08Ah
LcapAGrave	EQU	08Bh
LcapACaret	EQU	08Ch
LcapADier	EQU	08Dh
LaAcute		EQU	08Eh
LaGrave		EQU	08Fh
LaCaret		EQU	090h
LaDier		EQU	091h
LcapEAcute	EQU	092h
LcapEGrave	EQU	093h
LcapECaret	EQU	094h
LcapEDier	EQU	095h
LeAcute		EQU	096h
LeGrave		EQU	097h
LeCaret		EQU	098h
LeDier		EQU	099h
LcapIAcute	EQU	09Ah
LcapIGrave	EQU	09Bh
LcapICaret	EQU	09Ch
LcapIDier	EQU	09Dh
LiAcute		EQU	09Eh
LiGrave		EQU	09Fh
LiCaret		EQU	0A0h
LiDier		EQU	0A1h
LcapOAcute	EQU	0A2h
LcapOGrave	EQU	0A3h
LcapOCaret	EQU	0A4h
LcapODier	EQU	0A5h
LoAcute		EQU	0A6h
LoGrave		EQU	0A7h
LoCaret		EQU	0A8h
LoDier		EQU	0A9h
LcapUAcute	EQU	0AAh
LcapUGrave	EQU	0ABh
LcapUCaret	EQU	0ACh
LcapUDier	EQU	0ADh
LuAcute		EQU	0AEh
LuGrave		EQU	0AFh
LuCaret		EQU	0B0h
LuDier		EQU	0B1h
LcapCCed	EQU	0B2h
LcCed		EQU	0B3h
LcapNTilde	EQU	0B4h
LnTilde		EQU	0B5h
Laccent		EQU	0B6h
Lgrave		EQU	0B7h
Ldieresis	EQU	0B8h
LquesDown	EQU	0B9h
LexclamDown	EQU	0BAh
Lalpha		EQU	0BBh
Lbeta		EQU	0BCh
Lgamma		EQU	0BDh
LcapDelta	EQU	0BEh
Ldelta		EQU	0BFh
Lepsilon	EQU	0C0h
LlBrack 	EQU     0C1h
Llambda		EQU	0C2h
Lmu		EQU	0C3h
Lpi		EQU	0C4h
Lrho		EQU	0C5h
LcapSigma	EQU	0C6h
Lsigma		EQU	0C7h
Ltau		EQU	0C8h
Lphi		EQU	0C9h
LcapOmega	EQU	0CAh
LxMean		EQU	0CBh
LyMean		EQU	0CCh
LsupX		EQU	0CDh
Lellipsis	EQU	0CEh
Lleft		EQU	0CFh
Lblock		EQU	0D0h
Lper		EQU	0D1h
Lhyphen		EQU	0D2h
Larea		EQU	0D3h
Ltemp		EQU	0D4h
Lcube		EQU	0D5h
Lenter		EQU	0D6h
LimagI		EQU	0D7h
Lphat		EQU	0D8h
Lchi		EQU	0D9h
LstatF		EQU     0DAh
Llne		EQU	0DBh
LlistL		EQU	0DCh
LfinanN 	EQU	0DDh
L2_r_paren 	EQU	0DEh
LblockArrow     EQU     0DFh
LcurO   	EQU     0E0h
LcurO2  	EQU     0E1h
LcurOcapA       EQU     0E2h
LcurOa  	EQU     0E3h
LcurI   	EQU     0E4h
LcurI2  	EQU     0E5h
LcurIcapA       EQU     0E6h
LcurIa  	EQU     0E7h
LGline          EQU     0E8h    ; = 0
LGthick         EQU     0E9h    ; = 1
LGabove         EQU     0EAh    ; = 2
LGbelow         EQU     0EBh    ; = 3
LGpath          EQU     0ECh    ; = 4
LGanimate       EQU     0EDh    ; = 5
LGdot           EQU     0EEh    ; = 6
LUpBlk          EQU     0EFh    ;Up arrow and Block in solver
LDnBlk          EQU     0F0h    ;Down arrow and Block in solver
LcurFull        EQU     0F1h    ;note: must be last char (PutMap checks)
;
;======================================================================
;           Keypress Equates
;======================================================================
;           Keyboard key names
;
;
kRight          EQU       001h
kLeft           EQU       002h
kUp             EQU       003h
kDown           EQU       004h
kEnter          EQU       005h
kAlphaEnter     EQU       006h
kAlphaUp        EQU       007h
kAlphaDown      EQU       008h
kClear          EQU       009h
kDel            EQU       00Ah
kIns            EQU       00Bh
kRecall         EQU       00Ch
kLastEnt        EQU       00Dh
kBOL            EQU       00Eh
kEOL            EQU       00Fh
;
kSelAll         EQU       010h
kUnselAll       EQU       011h
kLtoTI82        EQU       012h
kBackup         EQU       013h
kRecieve        EQU       014h
kLnkQuit        EQU       015h
kTrans          EQU       016h
kRename         EQU       017h
kOverw          EQU       018h
kOmit           EQU       019h
kCont           EQU       01Ah
kSendID         EQU       01Bh
kSendSW         EQU       01Ch
kYes            EQU       01Dh
kNoWay          EQU       01Eh
kvSendType      EQU       01Fh
kOverWAll       EQU       020h
;
kNo             EQU       025h
kKReset         EQU       026h
kApp            EQU       027h
;
kDoug           EQU       028h
kListflag       EQU       029h
menuStart       EQU       02Bh
;
kAreYouSure     EQU       02Bh
kAppsMenu       EQU       02Ch
kPrgm           EQU       02Dh
kZoom           EQU       02Eh
kDraw           EQU       02Fh
kSPlot          EQU       030h
kStat           EQU       031h
kMath           EQU       032h
kTest           EQU       033h
kChar           EQU       034h
kVars           EQU       035h
kMem            EQU       036h
kMatrix         EQU       037h
kDist           EQU       038h
kAngle          EQU       039h
kList           EQU       03Ah
kCalc           EQU       03Bh
kFin            EQU       03Ch
;
menuEnd         EQU       kFin
;
kCatalog        EQU       03Eh
kInputDone      EQU       03Fh
kOff            EQU       kInputDone
;
kQuit           EQU       040h
appStart        EQU       kQuit

;
kLinkIO         EQU       041h
kMatrixEd       EQU       042h
kStatEd         EQU       043h
kGraph          EQU       044h
kMode           EQU       045h
kPrgmEd         EQU       046h        ; PROGRAM EDIT
kPrgmCr         EQU       047h        ; PROGRAM CREATE
kWindow         EQU       048h        ; RANGE EDITOR
kYequ           EQU       049h        ; EQUATION EDITOR
kTable          EQU       04Ah        ; TABLE EDITOR
kTblSet         EQU       04Bh        ; TABLE SET
kChkRAM         EQU       04Ch        ; CHECK RAM
kDelMem         EQU       04Dh        ; DELETE MEM
kResetMem       EQU       04Eh        ; RESET MEM
kResetDef	EQU	  04Fh        ; RESET DEFAULT
kPrgmInput      EQU       050h        ; PROGRAM INPUT
kZFactEd        EQU       051h        ; ZOOM FACTOR EDITOR
kError          EQU       052h        ; ERROR
kSolveTVM       EQU       053h        ; TVM SOLVER
kSolveRoot	EQU	  054h        ; SOLVE EDITOR
kStatP          EQU       055h        ; stat plot
kInfStat 	EQU	  056h	      ; Inferential Statistic
kFormat         EQU       057h        ; FORMAT
kExtApps        EQU       058h        ; External Applications.     NEW
kNewApps        EQU       059h        ; New Apps for Cerberus.
;
append          EQU       kNewApps
;
echoStart1      EQU       05Ah
;
kTrace          EQU       05Ah
kZFit           EQU       05Bh
kZIn            EQU       05Ch
kZOut           EQU       05Dh
kZPrev          EQU       05Eh
kBox            EQU       05Fh
kDecml          EQU       060h
kSetZm          EQU       061h
kSquar          EQU       062h
kStd            EQU       063h
kTrig           EQU       064h
kUsrZm          EQU       065h
kZSto           EQU       066h
kZInt           EQU       067h
kZStat          EQU       068h
;
echoStart2      EQU       069h
;
kSelect         EQU       069h
kCircl          EQU       06Ah
kClDrw          EQU       06Bh
kLine           EQU       06Ch
kPen            EQU       06Dh
kPtChg          EQU       06Eh
kPtOff          EQU       06Fh
kPtOn           EQU       070h
kVert           EQU       071h
kHoriz          EQU       072h
kText           EQU       073h
kTanLn          EQU       074h
;
kEval           EQU       075h
kInters         EQU       076h
kDYDX           EQU       077h
kFnIntg         EQU       078h
kRootG          EQU       079h
kDYDT           EQU       07Ah
kDXDT           EQU       07Bh
kDRDo           EQU       07Ch
KGFMin          EQU       07Dh
KGFMax          EQU       07Eh
;
;
EchoStart       EQU       07Fh
;
kListName       EQU       07Fh
kAdd            EQU       080h
kSub            EQU       081h
kMul            EQU       082h
kDiv            EQU       083h
kExpon          EQU       084h
kLParen         EQU       085h
kRParen         EQU       086h
kLBrack         EQU       087h
kRBrack         EQU       088h
kShade          EQU       089h
kStore          EQU       08Ah
kComma          EQU       08Bh
kChs            EQU       08Ch
kDecPnt         EQU       08Dh
k0              EQU       08Eh
k1              EQU       08Fh
k2              EQU       090h
k3              EQU       091h
k4              EQU       092h
k5              EQU       093h
k6              EQU       094h
k7              EQU       095h
k8              EQU       096h
k9              EQU       097h
kEE             EQU       098h
kSpace          EQU       099h
kCapA           EQU       09Ah
kCapB           EQU       09Bh
kCapC           EQU       09Ch
kCapD           EQU       09Dh
kCapE           EQU       09Eh
kCapF           EQU       09Fh
kCapG           EQU       0A0h
kCapH           EQU       0A1h
kCapI           EQU       0A2h
kCapJ           EQU       0A3h
kCapK           EQU       0A4h
kCapL           EQU       0A5h
kCapM           EQU       0A6h
kCapN           EQU       0A7h
kCapO           EQU       0A8h
kCapP           EQU       0A9h
kCapQ           EQU       0AAh
kCapR           EQU       0ABh
kCapS           EQU       0ACh
kCapT           EQU       0ADh
kCapU           EQU       0AEh
kCapV           EQU       0AFh
kCapW           EQU       0B0h
kCapX           EQU       0B1h
kCapY           EQU       0B2h
kCapZ           EQU       0B3h
kVarx           EQU       0B4h
kPi             EQU       0B5h
kInv            EQU       0B6h
kSin            EQU       0B7h
kASin           EQU       0B8h
kCos            EQU       0B9h
kACos           EQU       0BAh
kTan            EQU       0BBh
kATan           EQU       0BCh
kSquare         EQU       0BDh
kSqrt           EQU       0BEh
kLn             EQU       0BFh
kExp            EQU       0C0h
kLog            EQU       0C1h
kALog           EQU       0C2h
kToABC          EQU       0C3h
;
kClrTbl         EQU       0C4h
;
kAns            EQU       0C5h
kColon          EQU       0C6h
;
kNDeriv         EQU       0C7h
kFnInt          EQU       0C8h
kRoot           EQU       0C9h
;
kQuest          EQU       0CAh
kQuote          EQU       0CBh
kTheta          EQU       0CCh
kIf             EQU       0CDh
kThen           EQU       0CEh
kElse           EQU       0CFh
kFor            EQU       0D0h
kWhile          EQU       0D1h
kRepeat         EQU       0D2h
kEnd            EQU       0D3h
kPause          EQU       0D4h
kLbl            EQU       0D5h
kGoto           EQU       0D6h
kISG            EQU       0D7h
kDSL            EQU       0D8h
kMenu           EQU       0D9h
kExec           EQU       0DAh
kReturn         EQU       0DBh
kStop           EQU       0DCh
kInput          EQU       0DDh
kPrompt         EQU       0DEh
kDisp           EQU       0DFh
kDispG          EQU       0E0h
kDispT          EQU       0E1h
kOutput         EQU       0E2h
kGetKey         EQU       0E3h
kClrHome        EQU       0E4h
kPrtScr         EQU       0E5h
kSinH           EQU       0E6h
kCosH           EQU       0E7h
kTanH           EQU       0E8h
kASinH          EQU       0E9h
kACosH          EQU       0EAh
kATanH          EQU       0EBh
kLBrace         EQU       0ECh
kRBrace         EQU       0EDh
kI              EQU       0EEh
kCONSTeA        EQU       0EFh
kPlot3          EQU       0F0h
kFMin           EQU       0F1h
kFMax           EQU       0F2h
kL1A            EQU       0F3h
kL2A            EQU       0F4h
kL3A            EQU       0F5h
kL4A            EQU       0F6h
kL5A            EQU       0F7h
kL6A            EQU       0F8h
kunA            EQU       0F9h
kvnA            EQU       0FAh
kwnA            EQU       0FBh
;
;======================================================================
;       THIS KEY MEANS THAT IT IS A 2 BYTE KEYCODE
;       THERE ARE 2 OF THESE KEYS; BE CAREFUL WITH USAGE
;======================================================================
;
kExtendEcho2    EQU       0FCh
;
;======================================================================;
;       THIS KEY MEANS THAT THE KEY PRESS IS ONE THAT ECHOS
;       INTO A BUFFER, AND IT IS A 2 BYTE KEY CODE, GO LOOK AT
;       (EXTECHO) FOR THE KEY VALUE 
;======================================================================
;
kExtendEcho     EQU       0FEh
;

kE1BT           EQU       0

kDrawInv        EQU       kE1BT
kDrawF          EQU       kE1BT+1
kPixelOn        EQU       kE1BT+2
kPixelOff       EQU       kE1BT+3
kPxlTest        EQU       kE1BT+4
kRCGDB          EQU       kE1BT+5
kRCPic          EQU       kE1BT+6
kSTGDB          EQU       kE1BT+7
kSTPic          EQU       kE1BT+8
kAbs            EQU       kE1BT+9
kTEqu           EQU       kE1BT+10    ; ==
kTNoteQ         EQU       kE1BT+11    ; <>
kTGT            EQU       kE1BT+12    ; >
kTGTE           EQU       kE1BT+13    ; > =
kTLT            EQU       kE1BT+14    ; <
kTLTE           EQU       kE1BT+15    ; < =

kAnd            EQU       kE1BT+16
kOr             EQU       kE1BT+17
kXor            EQU       kE1BT+18
kNot            EQU       kE1BT+19

kLR1            EQU       kE1BT+20

kXRoot          EQU       kE1BT+21
kCube           EQU       kE1BT+22
kCbRt           EQU       kE1BT+23    ; Cube ROOT
kToDec          EQU       kE1BT+24
;
kCubicR         EQU       kE1BT+25
kQuartR         EQU       kE1BT+26
;
kPlot1          EQU       kE1BT+27
kPlot2          EQU       kE1BT+28
;

kRound          EQU       kE1BT+29
kIPart          EQU       kE1BT+30
kFPart          EQU       kE1BT+31
kInt            EQU       kE1BT+32

kRand           EQU       kE1BT+33
kNPR            EQU       kE1BT+34
kNCR            EQU       kE1BT+35
kXFactorial     EQU       kE1BT+36

kRad            EQU       kE1BT+37
kDegr           EQU       kE1BT+38    ; DEGREES CONV
kAPost          EQU       kE1BT+39
kToDMS          EQU       kE1BT+40
kRToPo          EQU       kE1BT+41    ; R
kRToPr          EQU       kE1BT+42
kPToRx          EQU       kE1BT+43
kPToRy          EQU       kE1BT+44

kRowSwap        EQU       kE1BT+45
kRowPlus        EQU       kE1BT+46
kTimRow         EQU       kE1BT+47
kTRowP          EQU       kE1BT+48

kSortA          EQU       kE1BT+49
kSortD          EQU       kE1BT+50
kSeq            EQU       kE1BT+51

kMin            EQU       kE1BT+52
kMax            EQU       kE1BT+53
kMean           EQU       kE1BT+54
kMedian         EQU       kE1BT+55
kSum            EQU       kE1BT+56
kProd           EQU       kE1BT+57

kDet            EQU       kE1BT+58
kTransp         EQU       kE1BT+59
kDim            EQU       kE1BT+60
kFill           EQU       kE1BT+61
kIdent          EQU       kE1BT+62
kRandm          EQU       kE1BT+63
kAug            EQU       kE1BT+64

kOneVar         EQU       kE1BT+65
kTwoVar         EQU       kE1BT+66
kLR             EQU       kE1BT+67
kLRExp          EQU       kE1BT+68
kLRLn           EQU       kE1BT+69
kLRPwr          EQU       kE1BT+70
kMedMed         EQU       kE1BT+71
kQuad           EQU       kE1BT+72
kClrLst         EQU       kE1BT+73
kHist           EQU       kE1BT+74
kxyLine         EQU       kE1BT+75
kScatter        EQU       kE1BT+76

kmRad           EQU       kE1BT+77
kmDeg           EQU       kE1BT+78
kmNormF         EQU       kE1BT+79
kmSci           EQU       kE1BT+80
kmEng           EQU       kE1BT+81
kmFloat         EQU       kE1BT+82

kFix            EQU       kE1BT+83
kSplitOn        EQU       kE1BT+84
kFullScreen     EQU       kE1BT+85
kStndrd         EQU       kE1BT+86
kParam          EQU       kE1BT+87
kPolar          EQU       kE1BT+88
kSeqG           EQU       kE1BT+89
kAFillOn        EQU       kE1BT+90
kAFillOff       EQU       kE1BT+91
kACalcOn        EQU       kE1BT+92
kACalcOff       EQU       kE1BT+93
kFNOn           EQU       kE1BT+94
kFNOff          EQU       kE1BT+95

kPlotsOn        EQU       kE1BT+96
kPlotsOff       EQU       kE1BT+97

kPixelChg       EQU       kE1BT+98

kSendMBL        EQU       kE1BT+99
kRecvMBL        EQU       kE1BT+100

kBoxPlot        EQU       kE1BT+101
kBoxIcon        EQU       kE1BT+102
kCrossIcon      EQU       kE1BT+103
kDotIcon        EQU       kE1BT+104

kE2BT           EQU       kE1BT+105

kSeqential      EQU       kE2BT
kSimulG         EQU       kE2BT+1
kPolarG         EQU       kE2BT+2
kRectG          EQU       kE2BT+3
kCoordOn        EQU       kE2BT+4
kCoordOff       EQU       kE2BT+5
kDrawLine       EQU       kE2BT+6
kDrawDot        EQU       kE2BT+7
kAxisOn         EQU       kE2BT+8
kAxisOff        EQU       kE2BT+9
kGridOn         EQU       kE2BT+10
kGridOff        EQU       kE2BT+11
kLblOn          EQU       kE2BT+12
kLblOff         EQU       kE2BT+13

kL1             EQU       kE2BT+14
kL2             EQU       kE2BT+15
kL3             EQU       kE2BT+16
kL4             EQU       kE2BT+17
kL5             EQU       kE2BT+18
kL6             EQU       kE2BT+19

;
;======================================================================
;           These keys are layed on top of existing keys to
;           enable localization in the inferential stats editor
;======================================================================
;
kinfData        EQU       kL1
kinfStats       EQU       kL1+1
kinfYes         EQU       kL1+2
kinfNo          EQU       kL1+3
kinfCalc        EQU       kL1+4
kinfDraw        EQU       kL1+5
kinfAlt1ne      EQU       kL1+6
kinfAlt1lt      EQU       kL1+7
kinfAlt1gt      EQU       kL1+8
kinfAlt2ne      EQU       kL1+9
kinfAlt2lt      EQU       kL1+10
kinfAlt2gt      EQU       kL1+11
kinfAlt3ne      EQU       kL1+12
kinfAlt3lt      EQU       kL1+13
kinfAlt3gt      EQU       kL1+14
kinfAlt4ne      EQU       kL1+15
kinfAlt4lt      EQU       kL1+16
kinfAlt4gt      EQU       kL1+17
kinfAlt5ne      EQU       kL1+18
kinfAlt5lt      EQU       kL1+19
kinfAlt5gt      EQU       kL1+20
kinfAlt6ne      EQU       kL1+21
kinfAlt6lt      EQU       kL1+22
kinfAlt6gt      EQU       kL1+23
;
;
kMatA           EQU       kE2BT+20
kMatB           EQU       kE2BT+21
kMatC           EQU       kE2BT+22
kMatD           EQU       kE2BT+23
kMatE           EQU       kE2BT+24

kXmin           EQU       kE2BT+25
kXmax           EQU       kE2BT+26
kXscl           EQU       kE2BT+27
kYmin           EQU       kE2BT+28
kYmax           EQU       kE2BT+29
kYscl           EQU       kE2BT+30
kTmin           EQU       kE2BT+31
kTmax           EQU       kE2BT+32
kTStep          EQU       kE2BT+33
kOmin           EQU       kE2BT+34
kOmax           EQU       kE2BT+35
kOStep          EQU       kE2BT+36
ku0             EQU       kE2BT+37
kv0             EQU       kE2BT+38
knMin           EQU       kE2BT+39
knMax           EQU       kE2BT+40
kDeltaY         EQU       kE2BT+41
kDeltaX         EQU       kE2BT+42

kZXmin          EQU       kE2BT+43
kZXmax          EQU       kE2BT+44
kZXscl          EQU       kE2BT+45
kZYmin          EQU       kE2BT+46
kZYmax          EQU       kE2BT+47
kZYscl          EQU       kE2BT+48
kZTmin          EQU       kE2BT+49
kZTmax          EQU       kE2BT+50
kZTStep         EQU       kE2BT+51
kZOmin          EQU       kE2BT+52
kZOmax          EQU       kE2BT+53
kZOStep         EQU       kE2BT+54
kZu0            EQU       kE2BT+55
kZv0            EQU       kE2BT+56
kZnMin          EQU       kE2BT+57
kZnMax          EQU       kE2BT+58

kDelLast        EQU       kE2BT+59
kSinReg         EQU       kE2BT+60
kConstE         EQU       kE2BT+61

kPic1           EQU       kE2BT+62
kPic2           EQU       kE2BT+63
kPic3           EQU       kE2BT+64

kDelVar         EQU       kE2BT+65
kGetCalc        EQU       kE2BT+66
kRealM          EQU       kE2BT+67
kPolarM         EQU       kE2BT+68
kRectM          EQU       kE2BT+69
kuv             EQU       kE2BT+70    ; U vs V
kvw             EQU       kE2BT+71    ; V vs W
kuw             EQU       kE2BT+72    ; U vs W
kFinPMTend      EQU       kE2BT+73
kFinPMTbeg      EQU       kE2BT+74
;
kGraphStyle     EQU       kE2BT+75
;
kExprOn         EQU       kE2BT+76
kExprOff        EQU       kE2BT+77
kStatA          EQU       kE2BT+78
kStatB          EQU       kE2BT+79
kStatC          EQU       kE2BT+80
kCorr           EQU       kE2BT+81
kStatD          EQU       kE2BT+82
kStatE          EQU       kE2BT+83
kRegEq          EQU       kE2BT+84
kMinX           EQU       kE2BT+85
kQ1             EQU       kE2BT+86
kMD             EQU       kE2BT+87
kQ3             EQU       kE2BT+88
kMaxX           EQU       kE2BT+89
kStatX1         EQU       kE2BT+90
kStatY1         EQU       kE2BT+91
kStatX2         EQU       kE2BT+92
kStatY2         EQU       kE2BT+93
kStatX3         EQU       kE2BT+94
kStatY3         EQU       kE2BT+95
kTblMin         EQU       kE2BT+96
kTblStep        EQU       kE2BT+97
kSetupLst       EQU       kE2BT+98
kClrAllLst      EQU       kE2BT+99
kLogistic       EQU       kE2BT+100
kZTest          EQU       kE2BT+101
kTTest          EQU       kE2BT+102
k2SampZTest     EQU       kE2BT+103
k2SampTTest     EQU       kE2BT+104
k1PropZTest     EQU       kE2BT+105
k2PropZTest     EQU       kE2BT+106
kChiTest        EQU       kE2BT+107
k2SampFTest     EQU       kE2BT+108
kZIntVal        EQU       kE2BT+109
kTIntVal        EQU       kE2BT+110
k2SampTInt      EQU       kE2BT+111
k2SampZInt      EQU       kE2BT+112
k1PropZInt      EQU       kE2BT+113
k2PropZInt      EQU       kE2BT+114
kDNormal        EQU       kE2BT+115
kInvNorm        EQU       kE2BT+116
kDT             EQU       kE2BT+117
kChi            EQU       kE2BT+118
kDF             EQU       kE2BT+119
kBinPDF         EQU       kE2BT+120
kBinCDF         EQU       kE2BT+121
kPoiPDF         EQU       kE2BT+122
kPoiCDF         EQU       kE2BT+123
kun             EQU       kE2BT+124
kvn             EQU       kE2BT+125
kwn             EQU       kE2BT+126
kRecn           EQU       kE2BT+127
kPlotStart      EQU       kE2BT+128
kZPlotStart     EQU       kE2BT+129   ; recursion n
kXFact          EQU       kE2BT+130   ; PlotStart
kYFact          EQU       kE2BT+131   ; ZPlotStart
kANOVA          EQU       kE2BT+132   ; XFact
kMaxY           EQU       kE2BT+133   ; YFact
kWebOn          EQU       kE2BT+134   ; MinY
kWebOff         EQU       kE2BT+135   ; MaxY
kTblInput       EQU       kE2BT+136   ; WEB ON
kGeoPDF         EQU       kE2BT+137   ; WEB OFF
kGeoCDF         EQU       kE2BT+138   ; WEB OFF
kShadeNorm      EQU       kE2BT+139
kShadeT         EQU       kE2BT+140
kShadeChi       EQU       kE2BT+141
kShadeF         EQU       kE2BT+142
kPlotStep       EQU       kE2BT+143
kZPlotStep      EQU       kE2BT+144
kLinRegtTest    EQU       kE2BT+145
KMGT		EQU	  kE2BT+146   ; VERT SPLIT
kSelectA        EQU       kE2BT+147
kZFitA          EQU       kE2BT+148
kE2BT_End       EQU       kZFitA
;
;
;======================================================================
;           More 2 Byte Keys 
;======================================================================

kE2BT2		EQU       0

kGDB1		EQU       kE2BT2
kGDB2		EQU       kE2BT2+1
kGDB3		EQU       kE2BT2+2
kY1		EQU       kE2BT2+3
kY2		EQU       kE2BT2+4
kY3		EQU       kE2BT2+5
kY4		EQU       kE2BT2+6
kY5		EQU       kE2BT2+7
kY6		EQU       kE2BT2+8
kY7		EQU       kE2BT2+9
kY8		EQU       kE2BT2+10
kY9		EQU       kE2BT2+11
kY0		EQU       kE2BT2+12
kX1T		EQU       kE2BT2+13
kY1T		EQU       kE2BT2+14
kX2T		EQU       kE2BT2+15
kY2T		EQU       kE2BT2+16
kX3T		EQU       kE2BT2+17
kY3T		EQU       kE2BT2+18
kX4T		EQU       kE2BT2+19
kY4T		EQU       kE2BT2+20
kX5T		EQU       kE2BT2+21
kY5T		EQU       kE2BT2+22
kX6T		EQU       kE2BT2+23
kY6T		EQU       kE2BT2+24
kR1		EQU       kE2BT2+25
kR2		EQU       kE2BT2+26
kR3		EQU       kE2BT2+27
kR4		EQU       kE2BT2+28
kR5		EQU       kE2BT2+29
kR6		EQU       kE2BT2+30
kGDB4		EQU       kE2BT2+31
kGDB5		EQU       kE2BT2+32
kGDB6		EQU       kE2BT2+33
kPic4		EQU       kE2BT2+34
kPic5		EQU       kE2BT2+35
kPic6		EQU       kE2BT2+36
kGDB7		EQU       kE2BT2+37
kGDB8		EQU       kE2BT2+38
kGDB9		EQU       kE2BT2+39
kGDB0		EQU       kE2BT2+40
kPic7		EQU       kE2BT2+41
kPic8		EQU       kE2BT2+42
kPic9		EQU       kE2BT2+43
kPic0		EQU       kE2BT2+44
kStatN		EQU       kE2BT2+45
kXMean		EQU       kE2BT2+46
kConj		EQU       kE2BT2+47
kReal		EQU       kE2BT2+48
kFAngle		EQU       kE2BT2+49
kLCM		EQU       kE2BT2+50
kGCD		EQU       kE2BT2+51
kRandInt	EQU       kE2BT2+52
kRandNorm	EQU       kE2BT2+53
kToPolar	EQU       kE2BT2+54
kToRect		EQU       kE2BT2+55
kYMean		EQU       kE2BT2+56
kStdX		EQU       kE2BT2+57
kStdX1		EQU       kE2BT2+58
kw0		EQU       kE2BT2+59
kMatF		EQU       kE2BT2+60
kMatG		EQU       kE2BT2+61
kMatRH		EQU       kE2BT2+62
kMatI		EQU       kE2BT2+63
kMatJ		EQU       kE2BT2+64
kYMean1		EQU       kE2BT2+65
kStdY		EQU       kE2BT2+66
kStdY1		EQU       kE2BT2+67
kMatToLst	EQU       kE2BT2+68
kLstToMat	EQU       kE2BT2+69
kCumSum		EQU       kE2BT2+70
kDeltaLst	EQU       kE2BT2+71
kStdDev		EQU       kE2BT2+72
kVariance	EQU       kE2BT2+73
kLength		EQU       kE2BT2+74
kEquToStrng	EQU       kE2BT2+75
kStrngToEqu	EQU       kE2BT2+76
kExpr		EQU       kE2BT2+77
kSubStrng	EQU       kE2BT2+78
kInStrng	EQU       kE2BT2+79
kStr1		EQU       kE2BT2+80
kStr2		EQU       kE2BT2+81
kStr3		EQU       kE2BT2+82
kStr4           EQU       kE2BT2+83
kStr5           EQU       kE2BT2+84
kStr6           EQU       kE2BT2+85
kStr7           EQU       kE2BT2+86
kStr8           EQU       kE2BT2+87
kStr9           EQU       kE2BT2+88
kStr0           EQU       kE2BT2+89
kFinN           EQU       kE2BT2+90
kFinI           EQU       kE2BT2+91
kFinPV          EQU       kE2BT2+92
kFinPMT         EQU       kE2BT2+93
kFinFV          EQU       kE2BT2+94
kFinPY          EQU       kE2BT2+95
kFinCY          EQU       kE2BT2+96
kFinFPMT        EQU       kE2BT2+97
kFinFI          EQU       kE2BT2+98
kFinFPV         EQU       kE2BT2+99
kFinFN          EQU       kE2BT2+100
kFinFFV         EQU       kE2BT2+101
kFinNPV         EQU       kE2BT2+102
kFinIRR         EQU       kE2BT2+103
kFinBAL         EQU       kE2BT2+104
kFinPRN         EQU       kE2BT2+105
kFinINT         EQU       kE2BT2+106
kSumX           EQU       kE2BT2+107
kSumX2          EQU       kE2BT2+108
kFinToNom       EQU       kE2BT2+109
kFinToEff       EQU       kE2BT2+110
kFinDBD         EQU       kE2BT2+111
kStatVP         EQU       kE2BT2+112
kStatZ          EQU       kE2BT2+113
kStatT          EQU       kE2BT2+114
kStatChi        EQU       kE2BT2+115
kStatF          EQU       kE2BT2+116
kStatDF         EQU       kE2BT2+117
kStatPhat       EQU       kE2BT2+118
kStatPhat1      EQU       kE2BT2+119
kStatPhat2      EQU       kE2BT2+120
kStatMeanX1     EQU       kE2BT2+121
kStatMeanX2     EQU       kE2BT2+122
kStatStdX1      EQU       kE2BT2+123
kStatStdX2      EQU       kE2BT2+124
kStatStdXP      EQU       kE2BT2+125
kStatN1         EQU       kE2BT2+126
kStatN2         EQU       kE2BT2+127
kStatLower      EQU       kE2BT2+128
kStatUpper      EQU       kE2BT2+129
kuw0            EQU       kE2BT2+130
kImag           EQU       kE2BT2+131
kSumY           EQU       kE2BT2+132
kXres           EQU       kE2BT2+133
kStat_s         EQU       kE2BT2+134
kSumY2          EQU       kE2BT2+135
kSumXY          EQU       kE2BT2+136
kuXres          EQU       kE2BT2+137
kModBox		EQU       kE2BT2+138
kNormProb	EQU       kE2BT2+139
kNormalPDF      EQU       kE2BT2+140
kTPDF           EQU       kE2BT2+141
kChiPDF         EQU       kE2BT2+142
kFPDF           EQU       kE2BT2+143
kMinY           EQU       kE2BT2+144   ; MinY
kRandBin        EQU       kE2BT2+145
kRef            EQU       kE2BT2+146
kRRef           EQU       kE2BT2+147
kLRSqr          EQU       kE2BT2+148
kBRSqr          EQU       kE2BT2+149
kDiagOn         EQU       kE2BT2+150
kDiagOff        EQU       kE2BT2+151
kun1            EQU       kE2BT2+152   ; FOR RCL USE WHEN GOTTEN FROM 82
kvn1            EQU       kE2BT2+153   ; FOR RCL USE WHEN GOTTEN FROM 82
;
k83_00End       EQU	kvn1            ;end of original keys...
kArchive        EQU     k83_00End + 1
kUnarchive      EQU     k83_00End + 2
kAsm            EQU     k83_00End + 3   ; Asm(
kAsmPrgm        EQU     k83_00End + 4   ; AsmPrgm
kAsmComp        EQU     k83_00End + 5   ; AsmComp(
;
kcapAAcute	EQU       k83_00End + 6
kcapAGrave	EQU       k83_00End + 7
kcapACaret	EQU       k83_00End + 8
kcapADier	EQU       k83_00End + 9
kaAcute		EQU       k83_00End + 10
kaGrave		EQU       k83_00End + 11
kaCaret		EQU       k83_00End + 12
kaDier		EQU       k83_00End + 13
kcapEAcute	EQU       k83_00End + 14
kcapEGrave	EQU       k83_00End + 15
kcapECaret	EQU       k83_00End + 16
kcapEDier	EQU       k83_00End + 17
keAcute		EQU       k83_00End + 18
keGrave		EQU       k83_00End + 19
keCaret		EQU       k83_00End + 20
keDier		EQU       k83_00End + 21
kcapIAcute	EQU       k83_00End + 22
kcapIGrave	EQU       k83_00End + 23
kcapICaret	EQU       k83_00End + 24
kcapIDier	EQU       k83_00End + 25
kiAcute		EQU       k83_00End + 26
kiGrave		EQU       k83_00End + 27
kiCaret		EQU       k83_00End + 28
kiDier		EQU       k83_00End + 29
kcapOAcute	EQU       k83_00End + 30
kcapOGrave	EQU       k83_00End + 31
kcapOCaret	EQU       k83_00End + 32
kcapODier	EQU       k83_00End + 33
koAcute		EQU       k83_00End + 34
koGrave		EQU       k83_00End + 35
koCaret		EQU       k83_00End + 36
koDier		EQU       k83_00End + 37
kcapUAcute	EQU       k83_00End + 38
kcapUGrave	EQU       k83_00End + 39
kcapUCaret	EQU       k83_00End + 40
kcapUDier	EQU       k83_00End + 41
kuAcute		EQU       k83_00End + 42
kuGrave		EQU       k83_00End + 43
kuCaret		EQU       k83_00End + 44
kuDier		EQU       k83_00End + 45
kcapCCed	EQU       k83_00End + 46
kcCed		EQU       k83_00End + 47
kcapNTilde	EQU       k83_00End + 48
knTilde		EQU       k83_00End + 49
kaccent		EQU       k83_00End + 50
kgrave		EQU       k83_00End + 51
kdieresis	EQU       k83_00End + 52
kquesDown	EQU       k83_00End + 53
kexclamDown     EQU       k83_00End + 54
kalpha          EQU       k83_00End + 55
kbeta           EQU      k83_00End +  56
kgamma          EQU      k83_00End +  57
kcapDelta       EQU      k83_00End +  58
kdelta          EQU      k83_00End +  59
kepsilon        EQU      k83_00End +  60
klambda         EQU      k83_00End +  61
kmu             EQU      k83_00End +  62
kpi2            EQU      k83_00End +  63
krho            EQU      k83_00End +  64
kcapSigma       EQU      k83_00End +  65
ksigma          EQU      k83_00End +  66
ktau            EQU      k83_00End +  67
kphi            EQU      k83_00End +  68
kcapOmega       EQU      k83_00End +  69
kphat           EQU      k83_00End +  70
kchi2           EQU      k83_00End +  71
kstatF2         EQU      k83_00End +  72
kLa		EQU     k83_00End + 73
kLb		EQU     k83_00End + 74
kLc		EQU     k83_00End + 75
kLd		EQU     k83_00End + 76
kLe		EQU     k83_00End + 77
kLf		EQU     k83_00End + 78
kLg		EQU     k83_00End + 79
kLh		EQU     k83_00End + 80
kLi		EQU     k83_00End + 81
kLj		EQU     k83_00End + 82
kLk		EQU     k83_00End + 83
kLl		EQU     k83_00End + 84
kLm		EQU     k83_00End + 85
kLsmalln	EQU    k83_00End +  86
kLo		EQU    k83_00End +  87
kLp		EQU    k83_00End +  88
kLq		EQU    k83_00End +  89
kLsmallr	EQU    k83_00End +  90
kLs		EQU    k83_00End +  91
kLt		EQU    k83_00End +  92
kLu		EQU    k83_00End +  93
kLv		EQU    k83_00End +  94
kLw		EQU    k83_00End +  95
kLx		EQU    k83_00End +  96
kLy		EQU    k83_00End +  97
kLz		EQU    k83_00End +  98
kGarbageC	EQU  k83_00End +  99 ; GarbageCollect
;
kE2BT2_End	EQU     kGarbageC
;
;======================================================================
;           TI-83 Plus Context Equates
;======================================================================
;
cxCmd           EQU     kQuit                   ;home screen
cxMatEdit       EQU     kMatrixEd               ;matrix editor
cxPrgmEdit      EQU     kPrgmEd                 ;program editor
cxEquEdit       EQU     kYequ                   ;equation editor
cxGrRange       EQU     kWindow                 ;graph range editor
cxGrZfact       EQU     kZFactEd                ;graph zoom factors editor
cxGraph         EQU     kGraph                  ;graph mode
cxStatEdit      EQU     kStatEd                 ;statistics list editor
cxPrgmInput     EQU     kPrgmInput              ;programmed input
cxError         EQU     kError                  ;error handler
cxLinkIO        EQU     kLinkIO                 ;LINK I/O interface
cxMem           EQU     kResetMem               ;reset memory
cxDefMem        EQU     kResetDef               ;reset default
cxRAMApp        EQU     kChkRAM                 ;RAM usage screen
cxMode          EQU     kMode                   ;mode settings screen
cxErase         EQU     kDelMem                 ;memory erase
cxPrgmCreate    EQU     kPrgmCr                 ;PROGRAM CREATE
cxTableEditor   EQU     kTable                  ;TABLE EDITOR
cxTableSet      EQU     kTblSet                 ;TABLE SET UP
cxStatPlot      EQU     kStatP                  ;STAT PLOTS
cxInfStat	EQU	kInfStat		;Inferential Statistic
cxFormat        EQU     kFormat                 ;FORMAT CONTEXT
cxSolveTVM      EQU     kSolveTVM               ;Solve TVM
cxSolveRoot     EQU     kSolveRoot              ;Solve Root
lastOldApp      EQU     kExtApps                ;external applications
cxextapps       EQU     kExtApps
cxNewApps       EQU     kNewApps                ;new cerberus applications
cxGroup         EQU     cxNewApps+0             ;1st new app.
cxUnGroup       EQU     cxNewApps+1             ;2nd new app.
lastNewApp      EQU     cxUnGroup               ;last new app for this ver

;
;======================================================================
;           Scan Code Equates
;======================================================================;
skDown          EQU	01h
skLeft          EQU	02h
skRight         EQU	03h
skUp            EQU	04h
skEnter         EQU	09h
skAdd           EQU	0Ah
skSub           EQU	0Bh
skMul           EQU	0Ch
skDiv           EQU	0Dh
skPower         EQU	0Eh
skClear         EQU	0Fh
skChs           EQU	11h
sk3             EQU	12h
sk6             EQU	13h
sk9             EQU	14h
skRParen        EQU	15h
skTan           EQU	16h
skVars          EQU	17h
skDecPnt        EQU	19h
sk2             EQU	1Ah
sk5             EQU	1Bh
sk8             EQU	1Ch
skLParen        EQU	1Dh
skCos           EQU	1Eh
skPrgm          EQU	1Fh
skStat          EQU	20h
sk0             EQU	21h
sk1             EQU	22h
sk4             EQU	23h
sk7             EQU	24h
skComma         EQU	25h
skSin           EQU	26h
skApps        	EQU	27h
skGraphvar      EQU	28h
skStore         EQU	2Ah
skLn            EQU	2Bh
skLog           EQU	2Ch
skSquare        EQU	2Dh
skRecip         EQU	2Eh
skMath          EQU	2Fh
skAlpha         EQU	30h
skGraph         EQU	31h
skTrace         EQU	32h
skZoom          EQU	33h
skWindow        EQU	34h
skYEqu          EQU	35h
sk2nd           EQU	36h
skMode          EQU	37h
skDel           EQU	38h
;
;======================================================================
;           Tokens
;======================================================================
;
EOSSTART        EQU       0
;
;
;   DISPLAY CONVERSIONS COME IMMEDIATELY BEFORE 'TSTORE'
;
DCONV   EQU     01h
;
tToDMS          EQU       DCONV       ; 01h
tToDEC          EQU       DCONV+1     ; 02h
tToAbc          EQU       DCONV+2     ; 03h    > A b/c
;
tStore          EQU       DCONV+3     ; 04h Lstore                01
;
tBoxPlot        EQU       05h
;
BRACKS          EQU       06h
;
tLBrack         EQU       BRACKS      ; 06h '['
tRBrack         EQU       BRACKS+1    ; 07h ']'
tLBrace         EQU       BRACKS+2    ; 08h '{'
tRBrace         EQU       BRACKS+3    ; 09h '}'
;
tPOST1          EQU       BRACKS+4
;
tFromRad        EQU       tPOST1       ; 0Ah Lradian
tFromDeg        EQU       tPOST1+1     ; 0Bh Ldegree
tRecip          EQU       tPOST1+2     ; 0Ch Linverse
tSqr            EQU       tPOST1+3     ; 0Dh Lsquare
tTrnspos        EQU       tPOST1+4     ; 0Eh Ltranspose
tCube           EQU       tPOST1+5     ; 0Fh '^3'
;
tLParen         EQU       10h         ; 10h '('
tRParen         EQU       11h         ; 11h ')'
;
;
IMUN            EQU       12h
;
tRound          EQU       IMUN        ; 12h 'round'
tPxTst          EQU       IMUN+1      ; 13h 'PXL-TEST'
tAug            EQU       IMUN+2      ; 14h 'aug'
tRowSwap        EQU       IMUN+3      ; 15h 'rSwap'
tRowPlus        EQU       IMUN+4      ; 16h 'rAdd'
tmRow           EQU       IMUN+5      ; 17h 'multR'
tmRowPlus       EQU       IMUN+6      ; 18h 'mRAdd'
tMax            EQU       IMUN+7      ; 19h 'max'
tMin            EQU       IMUN+8      ; 1Ah 'min'
tRToPr          EQU       IMUN+9      ; 1Bh 'R>Pr
tRToPo          EQU       IMUN+10     ; 1Ch 'R>Po
tPToRx          EQU       IMUN+11     ; 1Dh 'P>Rx
tPToRy          EQU       IMUN+12     ; 1Eh 'P>Ry
tMedian         EQU       IMUN+13     ; 1Fh 'MEDIAN
tRandM          EQU       IMUN+14     ; 20h 'randM'
tMean           EQU       IMUN+15     ; 21h
tRoot           EQU       IMUN+16     ; 22h 'ROOT'
tSeries         EQU       IMUN+17     ; 23h 'seq'
tFnInt          EQU       IMUN+18     ; 24h 'fnInt'
tNDeriv         EQU       IMUN+19     ; 25h 'fnIr'
tEvalF          EQU       IMUN+20     ; 26h
tFmin           EQU       IMUN+21     ; 27h
tFmax           EQU       IMUN+22     ; 28h
;
tEOSEL          EQU       IMUN+23
;
tSpace          EQU       tEOSEL       ; 29h   ' '
tString         EQU       tEOSEL+1     ; 2Ah  '"'
tComma          EQU       tEOSEL+2     ; 2Bh  ','
;
;
tii             EQU       2Ch         ; i
;
;======================================================================
;           Postfix Functions
;======================================================================
;
tPost           EQU       2Dh
;
tFact           EQU       tPost       ; 2Dh '!'
;
tCubicR         EQU       2Eh
tQuartR         EQU       2Fh

;======================================================================
;           Number Tokens 
;======================================================================
;
NUMS            EQU       30h
;
t0              EQU       NUMS        ; 30h
t1              EQU       NUMS+1      ; 31h
t2              EQU       NUMS+2      ; 32h
t3              EQU       NUMS+3      ; 33h
t4              EQU       NUMS+4      ; 34h
t5              EQU       NUMS+5      ; 35h
t6              EQU       NUMS+6      ; 36h
t7              EQU       NUMS+7      ; 37h
t8              EQU       NUMS+8      ; 38h
t9              EQU       NUMS+9      ; 39h
tDecPt          EQU       NUMS+10     ; 3Ah
tee             EQU       NUMS+11     ; 3Bh
;
;======================================================================
;            BINARY OP
;======================================================================
;
tOr             EQU       3Ch         ; 3Ch  '_or_'
tXor            EQU       3Dh         ; 3Dh
;
tColon          EQU       3Eh         ; 3Eh ':'
tEnter          EQU       3Fh         ; 3Fh  Lenter
;
tAnd            EQU       40h         ; 40h  '_and_'       
;
;======================================================================
;            LETTER TOKENS   
;======================================================================

;
LET             EQU       41h
;
tA              EQU       LET         ; 41h
tB              EQU       LET+1       ; 42h
tC              EQU       LET+2       ; 43h
tD              EQU       LET+3       ; 44h
tE              EQU       LET+4       ; 45h
tF              EQU       LET+5       ; 46h
tG              EQU       LET+6       ; 47h
tH              EQU       LET+7       ; 48h
tI              EQU       LET+8       ; 49h
tJ              EQU       LET+9       ; 4Ah
tK              EQU       LET+10      ; 4Bh
tL              EQU       LET+11      ; 4Ch
tM              EQU       LET+12      ; 4Dh
tN              EQU       LET+13      ; 4Eh
tO              EQU       LET+14      ; 4Fh
tP              EQU       LET+15      ; 50h
tQ              EQU       LET+16      ; 51h
tR              EQU       LET+17      ; 52h
tS              EQU       LET+18      ; 53h
tT              EQU       LET+19      ; 54h
tU              EQU       LET+20      ; 55h
tV              EQU       LET+21      ; 56h
tW              EQU       LET+22      ; 57h
tX              EQU       LET+23      ; 58h
tY              EQU       LET+24      ; 59h
tZ              EQU       LET+25      ; 5Ah
tTheta          EQU       LET+26      ; 5Bh
;
;======================================================================
;   THESE VAR TOKENS ARE 1ST OF A DOUBLE TOKEN 
;======================================================================

;
vToks   EQU     LET+27    ;
;
;       USER MATRIX TOKEN, 2ND TOKEN NEEDED FOR NAME
;
tVarMat         EQU       vToks       ; 5Ch
;
;       USER LIST TOKEN, 2ND TOKEN NEEDED FOR NAME
;
tVarLst         EQU       vToks+1     ; 5Dh
;
;       USER EQUATION TOKEN, 2ND TOKEN NEEDED FOR NAME
;
tVarEqu         EQU       vToks+2     ; 5Eh
tProg           EQU       vToks+3     ; 5Fh
;
;       USER PICT TOKEN, 2ND TOKEN NEEDED FOR NAME
;
tVarPict        EQU       vToks+4     ; 60h
;
;       USER GDB TOKEN, 2ND TOKEN NEEDED FOR NAME
;
tVarGDB         EQU       vToks+5     ; 61h
tVarOut         EQU       vToks+6     ; 62h
tVarSys         EQU       vToks+7     ; 63h
;
;
;======================================================================
;            Mode Setting Commands
;======================================================================

;
MODESA          EQU       vToks+8     ; 64h
;
tRad            EQU       MODESA      ; 64h 'Radian'
tDeg            EQU       MODESA+1    ; 65h 'Degree'
tNormF          EQU       MODESA+2    ; 66h 'Normal'
tSci            EQU       MODESA+3    ; 67h 'Sci'
tEng            EQU       MODESA+4    ; 68h 'Eng'
tFloat          EQU       MODESA+5    ; 69h 'Float'
;
CMPS            EQU       6Ah
;
tEQ             EQU       CMPS        ; 6Ah '=='
tLT             EQU       CMPS+1      ; 6Bh '<'
tGT             EQU       CMPS+2      ; 6Ch '>'
tLE             EQU       CMPS+3      ; 6Dh LLE
tGE             EQU       CMPS+4      ; 6Eh LGE
tNE             EQU       CMPS+5      ; 6Fh LNE
;
;======================================================================
;            BINARY OP
;======================================================================
;
tAdd            EQU       70h         ; 70h '+'
tSub            EQU       71h         ; 71h '-'
tAns            EQU       72h         ; 72h
;
;======================================================================
;            Mode Setting Commands
;======================================================================
;
MODES           EQU       73h
;
tFix            EQU       MODES       ; 73h 'Fix_'
tSplitOn        EQU       MODES+1     ; 74h
tFullScreen     EQU       MODES+2     ; 75h
tStndrd         EQU       MODES+3     ; 76h 'Func'
tParam          EQU       MODES+4     ; 77h 'Param'
tPolar          EQU       MODES+5     ; 78h 'Pol'
tSeqG           EQU       MODES+6     ; 79h
tAFillOn        EQU       MODES+7     ; 7Ah 'AUTO FILL ON
tAFillOff       EQU       MODES+8     ; 7Bh
tACalcOn        EQU       MODES+9     ; 7Ch
tACalcOff       EQU       MODES+10    ; 7Dh 'AutoFill OFF
;
;       GRAPH FORMAT TOKENS ARE 2 BYTE TOKENS
;
tGFormat        EQU       MODES+11    ; 7Eh
;
tBoxIcon        EQU       7Fh
tCrossIcon      EQU       80h
tDotIcon        EQU       81h
;
;======================================================================
;            (More) BINARY OP
;======================================================================
;
tMul            EQU       82h         ; 82h  '*'
tDiv            EQU       83h         ; 83h  '/'
;
;======================================================================
;            SOME GRAPH COMMANDS
;======================================================================
;
GRCMDS          EQU       84h
;
tTrace          EQU       GRCMDS      ; 84h 'Trace'
tClDrw          EQU       GRCMDS+1    ; 85h 'ClDrw'
tZoomStd        EQU       GRCMDS+2    ; 86h 'ZStd'
tZoomtrg        EQU       GRCMDS+3    ; 87h 'Ztrg'
tZoomBox        EQU       GRCMDS+4    ; 88h 'ZBOX'
tZoomIn         EQU       GRCMDS+5    ; 89h 'ZIn'
tZoomOut        EQU       GRCMDS+6    ; 8Ah 'ZOut'
tZoomSqr        EQU       GRCMDS+7    ; 8Bh 'ZSqr'
tZoomInt        EQU       GRCMDS+8    ; 8Ch 'ZInt'
tZoomPrev       EQU       GRCMDS+9    ; 8Dh 'ZPrev'
tZoomDec        EQU       GRCMDS+10   ; 8Eh 'ZDecm'
tZoomStat       EQU       GRCMDS+11   ; 8Fh 'ZStat
tUsrZm          EQU       GRCMDS+12   ; 90h 'ZRcl'
tPrtScrn        EQU       GRCMDS+13   ; 91h 'PrtScrn'
tZoomSto        EQU       GRCMDS+14   ; 92h  ZOOM STORE
tText           EQU       GRCMDS+15   ; 93h
;
;======================================================================
;           BINARY OP  (Combination & Permutation)
;======================================================================
;
tnPr            EQU       GRCMDS+16   ; 94h '_nPr_'
tnCr            EQU       GRCMDS+17   ; 95h '_nCr_'
;
;======================================================================
;           MORE GRAPH COMMANDS
;======================================================================
;
tYOn            EQU       GRCMDS+18   ; 96h 'FnOn_'
tYOff           EQU       GRCMDS+19   ; 97h 'FnOff_'
tStPic          EQU       GRCMDS+20   ; 98h 'StPic_'
tRcPic          EQU       GRCMDS+21   ; 99h 'RcPic_'
tStoDB          EQU       GRCMDS+22   ; 9Ah 'StGDB_'
tRclDB          EQU       GRCMDS+23   ; 9Bh 'RcGDB_'
tLine           EQU       GRCMDS+24   ; 9Ch 'Line'
tVert           EQU       GRCMDS+25   ; 9Dh 'Vert_'
tPtOn           EQU       GRCMDS+26   ; 9Eh 'PtOn'
tPtOff          EQU       GRCMDS+27   ; 9Fh 'PtOff'
;
;======================================================================
;           TOKEN A0 CANNOT BE AN EOS FUNCTION
;           SINCE LOW MULT=A0 ALREADY
;======================================================================
;
tPtChg          EQU       GRCMDS+28   ; A0h 'PtChg'
tPXOn           EQU       GRCMDS+29   ; A1h
tPXOff          EQU       GRCMDS+30   ; A2h
tPXChg          EQU       GRCMDS+31   ; A3h
tShade          EQU       GRCMDS+32   ; A4h 'Shade'
tCircl          EQU       GRCMDS+33   ; A5h 'Circl'
tHorz           EQU       GRCMDS+34   ; A6h 'HORIZONTAL'
tTanLn          EQU       GRCMDS+35   ; A7h 'TanLn'
tDrInv          EQU       GRCMDS+36   ; A8h 'DrInv_'
tDrawF          EQU       GRCMDS+37   ; A9h 'DrawF_'
;
tVarStrng       EQU       0AAh
;
;======================================================================
;           Functions with No Arguments                                    
;======================================================================
;
NOARG   EQU     0ABh
;
tRand           EQU       NOARG       ; ABh 'rand'
tPi             EQU       NOARG+1     ; ACh  Lpi
tGetKey         EQU       NOARG+2     ; ADh 'getKy'
;
;
tAPost          EQU       tGetKey+1   ; APOSTROPHY
tQuest          EQU       tAPost+1    ; QUESTION MARK
;
;
UNARY   EQU     tQuest+1              ; B0h
;
tChs            EQU       UNARY       ; B0h
tInt            EQU       UNARY+1     ; B1h
tAbs            EQU       UNARY+2     ; B2h
tDet            EQU       UNARY+3     ; B3h
tIdent          EQU       UNARY+4     ; B4h
tDim            EQU       UNARY+5     ; B5h
tSum            EQU       UNARY+6     ; B6h
tProd           EQU       UNARY+7     ; B7h
tNot            EQU       UNARY+8     ; B8h
tIPart          EQU       UNARY+9     ; B9h
tFPart          EQU       UNARY+10    ; BAh
;
;
;======================================================================
;           NEW 2 BYTE TOKENS
;======================================================================
;
t2ByteTok       EQU       0BBh         ;
;
;
UNARYLR EQU     UNARY+12
;
tSqrt           EQU       UNARYLR     ; BCh
tCubRt          EQU       UNARYLR+1   ; BDh
tLn             EQU       UNARYLR+2   ; BEh
tExp            EQU       UNARYLR+3   ; BFh
tLog            EQU       UNARYLR+4   ; C0h
tALog           EQU       UNARYLR+5   ; C1h
tSin            EQU       UNARYLR+6   ; C2h
tASin           EQU       UNARYLR+7   ; C3h
tCos            EQU       UNARYLR+8   ; C4h
tACos           EQU       UNARYLR+9   ; C5h
tTan            EQU       UNARYLR+10  ; C6h
tATan           EQU       UNARYLR+11  ; C7h
tSinH           EQU       UNARYLR+12  ; C8h
tASinH          EQU       UNARYLR+13  ; C9h
tCoshH          EQU       UNARYLR+14  ; CAh
tACosH          EQU       UNARYLR+15  ; CBh
tTanH           EQU       UNARYLR+16  ; CCh
tATanH          EQU       UNARYLR+17  ; CDh
; 
;======================================================================
;           SOME PROGRAMMING COMMANDS                                      
;======================================================================
;
PROGTOK EQU     UNARYLR+18
;
tIf             EQU       PROGTOK     ; CEh
tThen           EQU       PROGTOK+1   ; CFh
tElse           EQU       PROGTOK+2   ; D0h
tWhile          EQU       PROGTOK+3   ; D1h
tRepeat         EQU       PROGTOK+4   ; D2h
tFor            EQU       PROGTOK+5   ; D3h
tEnd            EQU       PROGTOK+6   ; D4h
tReturn         EQU       PROGTOK+7   ; D5h
tLbl            EQU       PROGTOK+8   ; D6h   'Lbl_'
tGoto           EQU       PROGTOK+9   ; D7h   'Goto_'
tPause          EQU       PROGTOK+10  ; D8h   'Pause_'
tStop           EQU       PROGTOK+11  ; D9h   'Stop'
tISG            EQU       PROGTOK+12  ; DAh   'IS>'
tDSL            EQU       PROGTOK+13  ; DBh   'DS<'
tInput          EQU       PROGTOK+14  ; DCh   'Input_'
tPrompt         EQU       PROGTOK+15  ; DDh   'Prompt_'
tDisp           EQU       PROGTOK+16  ; DEh   'Disp_'
tDispG          EQU       PROGTOK+17  ; DFh   'DispG'
;
tOutput         EQU       PROGTOK+18  ; E0h    'Outpt'
tClLCD          EQU       PROGTOK+19  ; E1h    'ClLCD'
tConst          EQU       PROGTOK+20  ; E2h    'Fill'
tSortA          EQU       PROGTOK+21  ; E3h    'sortA_'
tSortD          EQU       PROGTOK+22  ; E4h    'sortD_'
tDispTab        EQU       PROGTOK+23  ; E5h    'Disp Table
tMenu           EQU       PROGTOK+24  ; E6h    'Menu'
tSendMBL        EQU       PROGTOK+25  ; E7h    'SEND'
tGetMBL         EQU       PROGTOK+26  ; E8h    'GET'
;
;======================================================================
;           STAT PLOT COMMANDS                                             
;======================================================================
;
statPCmd        EQU       PROGTOK+27
;
tPlotOn         EQU       statPCmd    ; E9h     ' PLOTSON'
tPlotOff        EQU       statPCmd+1   ; EAh     ' PLOTSOFF
;
tListName       EQU       0EBh        ; LIST DESIGNATOR
;
tPlot1          EQU       0ECh
tPlot2          EQU       0EDh
tPlot3          EQU       0EEh
;
tUnused01       EQU       0EFh        ;        available?
;
tPower          EQU       0F0h        ;        '^'
tXRoot          EQU       0F1h        ;        LsupX,Lroot

STATCMD         EQU       0F2h
;
tOneVar         EQU       STATCMD     ; F2h    'OneVar_'
tTwoVar         EQU       STATCMD+1   ; F3h
tLR             EQU       STATCMD+2   ; F4h    'LinR(A+BX
tLRExp          EQU       STATCMD+3   ; F5h    'ExpR_'
tLRLn           EQU       STATCMD+4   ; F6h    'LnR_'
tLRPwr          EQU       STATCMD+5   ; F7h    'PwrR_'
tMedMed         EQU       STATCMD+6   ; F8h
tQuad           EQU       STATCMD+7   ; F9h
tClrLst         EQU       STATCMD+8   ; FAh    'CLEAR LIST
tClrTbl         EQU       STATCMD+9   ; FBh    CLEAR TABLE
tHist           EQU       STATCMD+10  ; FCh    'Hist_'
txyLine         EQU       STATCMD+11  ; FDh    'xyline_'
tScatter        EQU       STATCMD+12  ; FEh    'Scatter_'
tLR1            EQU       STATCMD+13  ; FFh    'LINR(AX+B

;       
;======================================================================
;           2ND HALF OF GRAPH FORMAT TOKENS
;======================================================================
;           Format settings commands
;
GFMT            EQU       0
;
tSeq            EQU       GFMT        ; 'SeqG'
tSimulG         EQU       GFMT+1      ; 'SimulG'
tPolarG         EQU       GFMT+2      ; 'PolarGC'
tRectG          EQU       GFMT+3      ; 'RectGC'
tCoordOn        EQU       GFMT+4      ; 'CoordOn'
tCoordOff       EQU       GFMT+5      ; 'CoordOff'
tDrawLine       EQU       GFMT+6      ; 'DrawLine'
tDrawDot        EQU       GFMT+7      ; 'DrawDot'
tAxisOn         EQU       GFMT+8      ; 'AxesOn'
tAxisOff        EQU       GFMT+9      ; 'AxesOff'
tGridOn         EQU       GFMT+10     ; 'GridOn'
tGridOff        EQU       GFMT+11     ; 'GridOff'
tLblOn          EQU       GFMT+12     ; 'LabelOn'
tLblOff         EQU       GFMT+13     ; 'LabelOff'
tWebOn          EQU       GFMT+14     ; 'WebOn'
tWebOff         EQU       GFMT+15     ; 'WebOFF'
tuv             EQU       GFMT+16     ; U vs V
tvw             EQU       GFMT+17     ; V vs W
tuw             EQU       GFMT+18     ; U vs W
;
;======================================================================
;           2ND HALF OF USER MATRIX TOKENS                                 
;======================================================================
;
tMatA           EQU       00h         ; MAT A
tMatB           EQU       01h         ; MAT B
tMatC           EQU       02h         ; MAT C
tMatD           EQU       03h         ; MAT D
tMatE           EQU       04h         ; MAT E
tMatF           EQU       05h         ; MAT F
tMatG           EQU       06h         ; MAT G
tMatH           EQU       07h         ; MAT H
tMatI           EQU       08h         ; MAT I
tMatJ           EQU       09h         ; MAT J
;      
;======================================================================
;           2ND HALF OF USER LIST TOKENS
;======================================================================
;
tL1             EQU       00h         ; LIST 1
tL2             EQU       01h         ; LIST 2
tL3             EQU       02h         ; LIST 3
tL4             EQU       03h         ; LIST 4
tL5             EQU       04h         ; LIST 5
tL6             EQU       05h         ; LIST 6

;
;======================================================================
;           2ND HALF OF USER EQUATION TOKENS
;======================================================================
;
;       "Y" EQUATIONS HAVE BIT 4 SET
;
tY1             EQU       10h         ; Y1
tY2             EQU       11h         ; Y2
tY3             EQU       12h         ; Y3
tY4             EQU       13h         ; Y4
tY5             EQU       14h         ; Y5
tY6             EQU       15h         ; Y6
tY7             EQU       16h         ; Y7
tY8             EQU       17h         ; Y8
tY9             EQU       18h         ; Y9
tY0             EQU       19h         ; Y0
;
;       PARAM EQUATIONS HAVE BIT 5 SET
;
tX1T            EQU       20h         ; X1t
tY1T            EQU       21h         ; Y1t
tX2T            EQU       22h         ; X2t
tY2T            EQU       23h         ; Y2t
tX3T            EQU       24h         ; X3t
tY3T            EQU       25h         ; Y3t
tX4T            EQU       26h         ; X4t
tY4T            EQU       27h         ; Y4t
tX5T            EQU       28h         ; X5t
tY5T            EQU       29h         ; Y5t
tX6T            EQU       2Ah         ; X6t
tY6T            EQU       2Bh         ; Y6t
;
;       POLAR EQUATIONS HAVE BIT 6 SET
;
tR1             EQU       40h         ; R1
tR2             EQU       41h         ; R2
tR3             EQU       42h         ; R3
tR4             EQU       43h         ; R4
tR5             EQU       44h         ; R5
tR6             EQU       45h         ; R6
;
;       RECURSION EQUATIONS HAVE BIT 7 SET
;
tun             EQU       80h         ; Un
tvn             EQU       81h         ; Vn
twn             EQU       82h         ; Wn
;
;======================================================================
;           2ND HALF OF USER PICTURE TOKENS                                
;======================================================================
;
tPic1           EQU       00h         ; PIC1
tPic2           EQU       01h         ; PIC2
tPic3           EQU       02h         ; PIC3
tPic4           EQU       03h         ; PIC4
tPic5           EQU       04h         ; PIC5
tPic6           EQU       05h         ; PIC6
tPic7           EQU       06h         ; PIC7
tPic8           EQU       07h         ; PIC8
tPic9           EQU       08h         ; PIC9
tPic0           EQU       09h         ; PIC0
; 
;======================================================================
;           2ND HALF OF USER GRAPH DATABASE TOKENS                         
;======================================================================
;
tGDB1           EQU       00h         ; GDB1
tGDB2           EQU       01h         ; GDB2
tGDB3           EQU       02h         ; GDB3
tGDB4           EQU       03h         ; GDB4
tGDB5           EQU       04h         ; GDB5
tGDB6           EQU       05h         ; GDB6
tGDB7           EQU       06h         ; GDB7
tGDB8           EQU       07h         ; GDB8
tGDB9           EQU       08h         ; GDB9
tGDB0           EQU       09h         ; GDB0
;  
;======================================================================
;           2ND HALF OF STRING VARS                                        
;======================================================================
;
tStr1           EQU       00h
tStr2           EQU       01h
tStr3           EQU       02h
tStr4           EQU       03h
tStr5           EQU       04h
tStr6           EQU       05h
tStr7           EQU       06h
tStr8           EQU       07h
tStr9           EQU       08h
tStr0           EQU       09h

; 
;======================================================================
;           2ND HALF OF SYSTEM OUTPUT ONLY VARIABLES                       
;======================================================================
;
;
;   OPEN        EQU       00h
;
tRegEq          EQU       01h         ; REGRESSION EQUATION
;
tStatN          EQU       02h         ; STATISTICS N
;
tXMean          EQU       03h         ; X MEAN
tSumX           EQU       04h         ; SUM(X)
tSumXSqr        EQU       05h         ; SUM(X^2)
tStdX           EQU       06h         ; STANDARD DEV X
tStdPX          EQU       07h         ; STANDARD DEV POP X
tMinX           EQU       08h         ; Min X VALUE
tMaxX           EQU       09h         ; Max X VALUE
;
tMinY           EQU       0Ah         ; Min Y VALUE
tMaxY           EQU       0Bh         ; Max Y VALUE
tYmean          EQU       0Ch         ; Y MEAN
tSumY           EQU       0Dh         ; SUM(Y)
tSumYSqr        EQU       0Eh         ; SUM(Y^2)
tStdY           EQU       0Fh         ; STANDARD DEV Y
tStdPY          EQU       10h         ; STANDARD DEV POP Y
;
tSumXY          EQU       11h         ; SUM(XY)
tCorr           EQU       12h         ; CORRELATION
tMedX           EQU       13h         ; MED(X)
tQ1             EQU       14h         ; 1ST QUADRANT OF X
tQ3             EQU       15h         ; 3RD QUADRANT OF X
tQuadA          EQU       16h         ; 1ST TERM OF QUAD POLY REG/ Y-INT
tQuadB          EQU       17h         ; 2ND TERM OF QUAD POLY REG/ SLOPE
tQuadC          EQU       18h         ; 3RD TERM OF QUAD POLY REG
tCubeD          EQU       19h         ; 4TH TERM OF CUBIC POLY REG
tQuartE         EQU       1Ah         ; 5TH TERM OF QUART POLY REG
tMedX1          EQU       1Bh         ; x1 FOR MED-MED
tMedX2          EQU       1Ch         ; x2 FOR MED-MED
tMedX3          EQU       1Dh         ; x3 FOR MED-MED
tMedY1          EQU       1Eh         ; y1 FOR MED-MED
tMedY2          EQU       1Fh         ; y2 FOR MED-MED
tMedY3          EQU       20h         ; y3 FOR MED-MED
;
tRecurn		EQU       21h		; RECURSION N
tStatP          EQU       22h
tStatZ          EQU       23h
tStatT          EQU       24h
tStatChi        EQU       25h
tStatF          EQU       26h
tStatDF         EQU       27h
tStatPhat       EQU       28h
tStatPhat1      EQU       29h
tStatPhat2      EQU       2Ah
tStatMeanX1     EQU       2Bh
tStatStdX1      EQU       2Ch
tStatN1         EQU       2Dh
tStatMeanX2     EQU       2Eh
tStatStdX2      EQU       2Fh
tStatN2         EQU       30h
tStatStdXP      EQU       31h
tStatLower      EQU       32h
tStatUpper      EQU       33h
tStat_s         EQU       34h
tLRSqr          EQU       35h         ; r^2
tBRSqr          EQU       36h         ; R^2
;
;======================================================================
;       These next tokens are only used to access the data
;       they are display only and the user cannot access them at all
;======================================================================
;
tF_DF    EQU     37h       ; ANOFAV FACTOR DF
tF_SS    EQU     38h       ; ANOFAV FACTOR SS
tF_MS    EQU     39h       ; ANOFAV FACTOR MS
tE_DF    EQU     3Ah       ; ANOFAV ERROR DF
tE_SS    EQU     3Bh       ; ANOFAV ERROR SS
tE_MS    EQU     3Ch       ; ANOFAV ERROR MS
;
;
;======================================================================
;           2ND HALF OF SYSTEM INPUT/OUTPUT VARIABLES
;======================================================================
;      SYSTEM VARIABLE EQUATES
;
tuXscl       EQU  0
tuYscl       EQU  1
tXscl        EQU  2
tYscl        EQU  3
tRecuru0     EQU  4        ; U 1ST INITIAL COND
tRecurv0     EQU  5        ; V 1ST INITIAL COND
tun1         EQU  6        ; U(N-1)    ; NOT USED
tvn1         EQU  7        ; V(N-1)    ; NOT USED
tuRecuru0    EQU  8        ;
tuRecurv0    EQU  9        ;
;
tXmin        EQU  0Ah
tXmax        EQU  0Bh
tYmin        EQU  0Ch
tYmax        EQU  0Dh
tTmin        EQU  0Eh
tTmax        EQU  0Fh
tThetaMin    EQU  10h
tThetaMax    EQU  11h
tuXmin       EQU  12h
tuXmax       EQU  13h
tuYmin       EQU  14h
tuYmax       EQU  15h
tuThetMin    EQU  16h
tuThetMax    EQU  17h
tuTmin       EQU  18h
tuTmax       EQU  19h
tTblMin      EQU  1Ah
tPlotStart   EQU  1Bh
tuPlotStart  EQU  1Ch
tnMax        EQU  1Dh
tunMax       EQU  1Eh
tnMin        EQU  1Fh
tunMin       EQU  20h
;
tTblStep	EQU  21h
tTStep		EQU  22h
tThetaStep	EQU  23h
tuTStep		EQU  24h
tuThetStep	EQU  25h
;
tDeltaX		EQU  26h
tDeltaY		EQU  27h
;
tXFact		EQU  28h
tYFact		EQU  29h
;
tTblInput       EQU       2Ah
;
tFinN           EQU       2Bh
tFinI           EQU       2Ch
tFinPV          EQU       2Dh
tFinPMT         EQU       2Eh
tFinFV          EQU       2Fh
tFinPY          EQU       30h
tFinCY          EQU       31h
;
tRecurw0        EQU       32h         ; w0(1)
tuRecurw0       EQU       33h
;
tPlotStep       EQU       34h
tuPlotStep      EQU       35h
;
tXres           EQU       36h
tuXres          EQU       37h
;
tRecuru02       EQU       38h         ; u0(2)
tuRecuru02      EQU       39h
tRecurv02       EQU       3Ch         ; v0(2)
tuRecurv02      EQU       3Dh
tRecurw02       EQU       3Eh         ; w0(2)
tuRecurw02      EQU       3Fh
;
;======================================================================
;           2nd byte of t2ByteTok tokens
;======================================================================
;
tFinNPV         EQU       00h         ;
tFinIRR         EQU       01h         ;
tFinBAL         EQU       02h         ;
tFinPRN         EQU       03h         ;
tFinINT         EQU       04h         ;
tFinToNom       EQU       05h         ;
tFinToEff       EQU       06h         ;
tFinDBD         EQU       07h         ;
tLCM            EQU       08h         ;
tGCD            EQU       09h         ;
tRandInt        EQU       0Ah         ;
tRandBin        EQU       0Bh         ;
tSubStrng       EQU       0Ch         ;
tStdDev         EQU       0Dh         ;
tVariance       EQU       0Eh         ;
tInStrng        EQU       0Fh         ;
tDNormal        EQU       10h         ;
tInvNorm        EQU       11h         ;
tDT             EQU       12h         ;
tChI            EQU       13h         ;
tDF             EQU       14h         ;
tBINPDF         EQU       15h         ;
tBINCDF         EQU       16h         ;
tPOIPDF         EQU       17h         ;
tPOICDF         EQU       18h         ;
tGEOPDF         EQU       19h         ;
tGEOCDF         EQU       1Ah         ;
tNormalPDF      EQU       1Bh         ;
tTPDF           EQU       1Ch         ;
tChiPDF         EQU       1Dh         ;
tFPDF           EQU       1Eh         ;
tRandNorm       EQU       1Fh         ;
tFinFPMT        EQU       20h         ;
tFinFI          EQU       21h         ;
tFinFPV         EQU       22h         ;
tFinFN          EQU       23h         ;
tFinFFV         EQU       24h         ;
tConj           EQU       25h         ;
tReal           EQU       26h         ;
tImag           EQU       27h         ;
tAngle          EQU       28h         ;
tCumSum         EQU       29h         ;
tExpr           EQU       2Ah         ;
tLength         EQU       2Bh         ;
tDeltaLst       EQU       2Ch         ;
tRef            EQU       2Dh         ;
tRRef           EQU       2Eh         ;
tToRect         EQU       2Fh         ;
tToPolar        EQU       30h         ;
tConste         EQU       31h         ;
tSinReg         EQU       32h         ;
tLogistic       EQU       33h         ;
tLinRegTTest    EQU       34h         ;
tShadeNorm      EQU       35h         ;
tShadeT         EQU       36h         ;
tShadeChi       EQU       37h         ;
tShadeF         EQU       38h         ;
tMatToLst       EQU       39h         ;
tLstToMat       EQU       3Ah         ;
tZTest          EQU       3Bh         ;
tTTest          EQU       3Ch         ;
t2SampZTest     EQU       3Dh         ;
t1PropZTest     EQU       3Eh         ;
t2PropZTest     EQU       3Fh         ;
tChiTest        EQU       40h         ;
tZIntVal        EQU       41h         ;
t2SampZInt      EQU       42h         ;
t1PropZInt      EQU       43h         ;
t2PropZInt      EQU       44h         ;
tGraphStyle     EQU       45h         ;
t2SampTTest     EQU       46h         ;
t2SampFTest     EQU       47h         ;
tTIntVal        EQU       48h         ;
t2SampTInt      EQU       49h         ;
tSetupLst       EQU       4Ah         ;
tFinPMTend      EQU       4Bh         ;
tFinPMTbeg      EQU       4Ch         ;
tRealM          EQU       4Dh         ;
tPolarM         EQU       4Eh         ;
tRectM          EQU       4Fh         ;
tExprOn         EQU       50h         ;
tExprOff        EQU       51h         ;
tClrAllLst      EQU       52h         ;
tGetCalc        EQU       53h         ;
tDelVar         EQU       54h         ;
tEquToStrng     EQU       55h         ;
tStrngToEqu     EQU       56h         ;
tDelLast        EQU       57h         ;
tSelect         EQU       58h         ;
tANOVA          EQU       59h         ;
tModBox         EQU       5Ah         ;
tNormProb       EQU       5Bh         ;
;
;
tMGT            EQU       64h         ; VERTICAL SPLIT
tZFit           EQU       65h         ; ZOOM FIT
tDiag_on        EQU       66h         ; DIANOSTIC DISPLAY ON
tDiag_off       EQU       67h         ; DIANOSTIC DISPLAY OFF
tOkEnd2v0       EQU       67h         ;end of 2byte tokens for version 0.
tArchive        EQU       68h         ;archive
tUnarchive      EQU       69h         ;unarchive
tasm		EQU	  6Ah
tasmComp	EQU	  6Bh	      ; asm compile
tasmPrgm	EQU	  6Ch	      ; signifies a program is asm
tasmCmp 	EQU	  6Dh	      ; asm program is compiled
;
tLcapAAcute     EQU       6Eh
tLcapAGrave     EQU       6Fh
tLcapACaret     EQU       70h
tLcapADier      EQU       71h
tLaAcute        EQU       72h
tLaGrave        EQU       73h
tLaCaret        EQU       74h
tLaDier         EQU       75h
tLcapEAcute     EQU       76h
tLcapEGrave     EQU       77h
tLcapECaret     EQU       78h
tLcapEDier      EQU       79h
tLeAcute        EQU       7Ah
tLeGrave        EQU       7Bh
tLeCaret        EQU       7Ch
tLeDier         EQU       7Dh
;
tLcapIGrave     EQU       7Fh
tLcapICaret     EQU       80h
tLcapIDier      EQU       81h
tLiAcute        EQU       82h
tLiGrave        EQU       83h
tLiCaret        EQU       84h
tLiDier         EQU       85h
tLcapOAcute     EQU       86h
tLcapOGrave     EQU       87h
tLcapOCaret     EQU       88h
tLcapODier      EQU       89h
tLoAcute        EQU       8Ah
tLoGrave        EQU       8Bh
tLoCaret        EQU       8Ch
tLoDier         EQU       8Dh
tLcapUAcute     EQU       8Eh
tLcapUGrave     EQU       8Fh
tLcapUCaret     EQU       90h
tLcapUDier      EQU       91h
tLuAcute        EQU       92h
tLuGrave        EQU       93h
tLuCaret        EQU       94h
tLuDier         EQU       95h
tLcapCCed       EQU       96h
tLcCed          EQU       97h
tLcapNTilde     EQU       98h
tLnTilde        EQU       99h
tLaccent        EQU       9Ah
tLgrave         EQU       9Bh
tLdieresis      EQU       9Ch
tLquesDown      EQU       9Dh
tLexclamDown    EQU       9Eh
tLalpha         EQU       9Fh
tLbeta          EQU      0a0h
tLgamma         EQU      0a1h
tLcapDelta      EQU      0a2h
tLdelta         EQU      0a3h
tLepsilon       EQU      0a4h
tLlambda        EQU      0a5h
tLmu            EQU      0a6h
tLpi            EQU      0a7h
tLrho           EQU      0a8h
tLcapSigma      EQU      0a9h
;
;
tLphi           EQU      0aBh
tLcapOmega      EQU      0aCh
tLphat          EQU      0aDh
tLchi           EQU      0aEh
tLstatF         EQU      0aFh
;

tLa      EQU     0b0h
tLb      EQU     0b1h
tLc      EQU     0b2h
tLd      EQU     0b3h
tLsmalle EQU     0b4h
tLf      EQU     0b5h
tLsmallg EQU     0b6h
tLh      EQU     0b7h
tLi      EQU     0b8h
tLj      EQU     0b9h
tLk      EQU     0bAh
;

tLl      EQU     0bCh
tLm      EQU     0bDh
tLsmalln EQU     0bEh
tLo      EQU     0bFh
tLp      EQU     0c0h
tLq      EQU     0c1h
tLsmallr EQU     0c2h
tLs      EQU     0c3h
tLsmallt EQU     0c4h
tLu      EQU     0c5h
tLv      EQU     0c6h
tLw      EQU     0c7h
tLx      EQU     0c8h
tLy      EQU     0c9h
tLz      EQU     0cAh
tLsigma         EQU      0cbh
tLtau           EQU      0cch
tLcapIAcute     EQU      0cdh
;
;
tGarbagec EQU    0Ceh
LastToken       EQU      0Ceh         ;tLAST TOKEN IN THIS VERSION...
;
;======================================================================
;           Data Type Equates                                                    
;======================================================================
;
RealObj         EQU       0
ListObj         EQU       1
MatObj          EQU       2
EquObj          EQU       3
StrngObj        EQU       4
ProgObj         EQU       5
ProtProgObj     EQU       6
PictObj         EQU       7
GDBObj          EQU       8
UnknownObj      EQU       9
UnknownEquObj   EQU       0Ah
NewEquObj       EQU       0Bh
CplxObj         EQU       0Ch
CListObj        EQU       0Dh
UndefObj        EQU       0Eh
WindowObj       EQU       0Fh
ZStoObj         EQU       10h
TblRngObj       EQU       11h
LCDObj          EQU       12h
BackupObj       EQU       13h
AppObj		EQU	  14h		;application, only used in menus/link
AppVarObj	EQU	  15h		;application variable
TempProgObj     EQU       16h           ;program, home deletes when finished
GroupObj        EQU       17h           ;group.
; 
;======================================================================
;           I/O equates                                                          
;======================================================================
;
D0D1_bits	EQU  03h
D0LD1L		EQU  03h
D0LD1H		EQU  01h
D0HD1L		EQU  02h
D0HD1H		EQU  00h
bport		EQU  0			; 4-BIT LINK PORT (I/O) 
;
;======================================================================
;           DEVICE CODES                                                       
;======================================================================
;
;
TI82DEV		EQU  82h
PC82DEV		EQU  02h
MAC82DEV	EQU  12h
;
TI83FDEV	EQU  73h
LINK83FDEV	EQU  23h
;
TI83DEV		EQU  83h
PC83DEV		EQU  03h
MAC83DEV	EQU  13h
;
TI85DEV		EQU  95h      ; DIFF THEN REAL 85 SO ME TALK
PC85DEV		EQU  05h
MAC85DEV	EQU  15h
;
TI73DEV		EQU  74h      ; Device x3 is always an 83
PC73DEV		EQU  07h
MAC73DEV	EQU  17h
;
LINK73FDEV	EQU  23h
PC83FDEV	EQU  23h
;
;======================================================================
;           System Error Codes                                                  
;======================================================================
;
E_EDITF		EQU	7		;allow re-entering application
E_EDIT		EQU	1<<E_EDITF
E_Mask		EQU	7Fh

E_Overflow	EQU	1+E_EDIT
E_DivBy0	EQU	2+E_EDIT
E_SingularMat	EQU	3+E_EDIT
E_Domain	EQU	4+E_EDIT
E_Increment	EQU	5+E_EDIT
E_Break		EQU	6+E_EDIT
E_NonReal       EQU     7+E_EDIT
E_Syntax        EQU     8+E_EDIT
E_DataType      EQU     9+E_EDIT
E_Argument      EQU     10+E_EDIT
E_DimMismatch   EQU     11+E_EDIT
E_Dimension     EQU     12+E_EDIT
E_Undefined     EQU     13+E_EDIT
E_Memory        EQU     14+E_EDIT
E_Invalid       EQU     15+E_EDIT
E_IllegalNest   EQU     16+E_EDIT
E_Bound         EQU     17+E_EDIT
E_GraphRange    EQU     18+E_EDIT
E_Zoom          EQU     19+E_EDIT
E_Label         EQU     20
E_Stat          EQU     21
E_Solver        EQU     22+E_EDIT
E_Singularity   EQU     23+E_EDIT
E_SignChange    EQU     24+E_EDIT
E_Iterations    EQU     25+E_EDIT
E_BadGuess      EQU     26+E_EDIT
E_StatPlot      EQU     27
E_TolTooSmall   EQU     28+E_EDIT
E_Reserved      EQU     29+E_EDIT
E_Mode          EQU     30+E_EDIT
E_LnkErr        EQU     31+E_EDIT
E_LnkMemErr     EQU     32+E_EDIT
E_LnkTransErr   EQU     33+E_EDIT
E_LnkDupErr     EQU     34+E_EDIT
E_LnkMemFull    EQU     35+E_EDIT
E_Unknown       EQU     36+E_EDIT

E_Scale         EQU     37+E_EDIT
E_IdNotFound    EQU     38
E_NoMode        EQU     39+E_EDIT
E_Validation    EQU     40
E_Length        EQU     41+E_EDIT
E_Application   EQU     42+E_EDIT
E_AppErr1       EQU     43+E_EDIT
E_AppErr2       EQU     44+E_EDIT
E_ExpiredApp	EQU	45
E_BadAddr	EQU	46
E_Archived      EQU     47+E_EDIT
E_Version       EQU     48
E_ArchFull      EQU     49
E_Variable      EQU     50+E_EDIT
E_Duplicate     EQU     51+E_EDIT
HigErrNum       EQU     51


; obsolete error numbers34              ;first LINK error
E_LinkIOChkSum	EQU	34
E_LinkIOTimeOut	EQU	35
E_LinkIOBusy	EQU	36
E_LinkIOVer	EQU	37

;
;======================================================================
;           EQUATES TO RAM LOCATIONS FOR STAT VARS 
;======================================================================
;
;
FPLEN	EQU	9		;Length of a floating-point number.
StatN   EQU     statVars
XMean   EQU     StatN      + FPLEN
SumX    EQU     XMean      + FPLEN
SumXSqr EQU     SumX       + FPLEN
StdX    EQU     SumXSqr    + FPLEN
StdPX   EQU     StdX       + FPLEN
MinX    EQU     StdPX      + FPLEN
MaxX    EQU     MinX       + FPLEN
MinY    EQU     MaxX       + FPLEN
MaxY    EQU     MinY       + FPLEN
YMean   EQU     MaxY       + FPLEN
SumY    EQU     YMean      + FPLEN
SumYSqr EQU     SumY       + FPLEN
StdY    EQU     SumYSqr    + FPLEN
StdPY   EQU     StdY       + FPLEN
SumXY   EQU     StdPY      + FPLEN
Corr    EQU     SumXY      + FPLEN
MedX    EQU     Corr       + FPLEN
Q1      EQU     MedX       + FPLEN
Q3      EQU     Q1         + FPLEN
QuadA   EQU     Q3         + FPLEN
QuadB   EQU     QuadA      + FPLEN
QuadC   EQU     QuadB      + FPLEN
CubeD   EQU     QuadC      + FPLEN
QuartE  EQU     CubeD      + FPLEN
MedX1   EQU     QuartE     + FPLEN
MedX2   EQU     MedX1      + FPLEN
MedX3   EQU     MedX2      + FPLEN
MedY1   EQU     MedX3      + FPLEN
MedY2   EQU     MedY1      + FPLEN
MedY3   EQU     MedY2      + FPLEN
PStat   EQU     MedY3      + 2*FPLEN
ZStat   EQU     PStat      + FPLEN
TStat   EQU     ZStat      + FPLEN
ChiStat EQU     TStat      + FPLEN
FStat   EQU     ChiStat    + FPLEN
DF      EQU     FStat      + FPLEN
Phat    EQU     DF         + FPLEN
Phat1   EQU     Phat       + FPLEN
Phat2   EQU     Phat1      + FPLEN
MeanX1  EQU     Phat2      + FPLEN
StdX1   EQU     MeanX1     + FPLEN
StatN1  EQU     StdX1      + FPLEN
MeanX2  EQU     StatN1     + FPLEN
StdX2   EQU     MeanX2     + FPLEN
StatN2  EQU     StdX2      + FPLEN
StdXP2  EQU     StatN2     + FPLEN
SLower  EQU     StdXP2     + FPLEN
SUpper  EQU     SLower     + FPLEN
SStat   EQU     SUpper     + FPLEN

F_DF	EQU     anovaf_vars
F_SS	EQU     F_DF + FPLEN
F_MS	EQU     F_SS + FPLEN
E_DF	EQU     F_MS + FPLEN
E_SS	EQU     E_DF + FPLEN
E_MS	EQU     E_SS + FPLEN


