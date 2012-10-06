; Equates for keyboard routines in the kernel

kDown          .equ $01
kLeft          .equ $02
kRight         .equ $03
kUp            .equ $04
kEnter         .equ $09 \kEntry .equ $09 \kSolve .equ $09
kPlus          .equ $0A \kMem .equ $0A \kQuote .equ $0A
kMinus         .equ $0B \kLSqBracket .equ $0B \kW .equ $0B
kMul           .equ $0C \kRSqBracket .equ $0C \kR .equ $0C
kDiv           .equ $0D \kVarE .equ $0D \kM .equ $0D
kPower         .equ $0E \kPi .equ $0E \kH .equ $0E
kClear         .equ $0F
kChs           .equ $11 \kNeg .equ $11 \kAns .equ $11 \kQuestion .equ $11
k3             .equ $12 \kTheta .equ $12 \kL3 .equ $12
k6             .equ $13 \kL6 .equ $13 \kV .equ $13
k9             .equ $14 \kVarW .equ $14 \kQ .equ $14
kRParen        .equ $15 \kRBrace .equ $15 \kL .equ $15
kTan           .equ $16 \kInvTan .equ $16 \kG .equ $16
kVars          .equ $17 \kDistr .equ $17
kDecPnt        .equ $19 \kDot .equ $19 \kPeriod .equ $19 \kVarI .equ $19 \kImaginary .equ $19 \kColon .equ $19
k2             .equ $1A \kL2 .equ $1A \kZ .equ $1A
k5             .equ $1B \kL5 .equ $1B \kU .equ $1B
k8             .equ $1C \kVarV .equ $1C \kP .equ $1C
kLParen        .equ $1D \kLBrace .equ $1D \kK .equ $1D
kCos           .equ $1E \kInvCos .equ $1E \kF .equ $1E
kPrgm          .equ $1F \kDraw .equ $1F \kC .equ $1F
kStat          .equ $20 \kList .equ $20
k0             .equ $21 \kCatalog .equ $21 \kSpace .equ $21
k1             .equ $22 \kL1 .equ $22 \kY .equ $22
k4             .equ $23 \kL4 .equ $23 \kT .equ $23
k7             .equ $24 \kVarU .equ $24 \kO .equ $24
kComma         .equ $25 \kEE .equ $25 \kJ .equ $25
kSin           .equ $26 \kInvSin .equ $26 \kE .equ $26
kApps	       .equ $27 \kAngle .equ $27 \kB .equ $27
kGraphvar      .equ $28 \kXTThetaN .equ $28 \kLink .equ $28
kStore         .equ $2A \kRcl .equ $2A \kX .equ $2A
kLn            .equ $2B \kEx .equ $2B \kS .equ $2B
kLog           .equ $2C \k10x .equ $2C \kN .equ $2C
kSquare        .equ $2D \kXSqu .equ $2D \kSqRoot .equ $2D \kI .equ $2D
kRecip         .equ $2E \kXNeg .equ $2E \kMatrix .equ $2E \kD .equ $2E
kMath          .equ $2F \kA .equ $2F \kTest .equ $2F
kAlpha         .equ $30 \kALock .equ $30
kGraph         .equ $31 \kTable .equ $31 \kF5 .equ $31
kTrace         .equ $32 \kCalc .equ $32 \kF4 .equ $32
kZoom          .equ $33 \kFormat .equ $33 \kF3 .equ $33
kWindow        .equ $34 \kTblSet .equ $34 \kTableSet .equ $34 \kF2 .equ $34
kYEqu          .equ $35 \kStatPlot .equ $35 \kF1 .equ $35
k2nd           .equ $36
kMode          .equ $37 \kQuite .equ $37
kDel           .equ $38 \kIns .equ $38 \kDelete .equ $38