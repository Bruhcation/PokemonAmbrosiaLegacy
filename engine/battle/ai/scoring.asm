AIScoring: ; used only for BANK(AIScoring)

SubstituteImmuneEffects:
	db $01 ; unused sleep effect
	db EFFECT_SLEEP
	db EFFECT_POISON
	db EFFECT_PARALYZE
	db EFFECT_CONFUSE
	db EFFECT_LEECH_SEED
	db EFFECT_ACCURACY_DOWN
	db EFFECT_DEFENSE_DOWN
	db EFFECT_DEFENSE_DOWN_2
	db EFFECT_ATTACK_DOWN
	db EFFECT_SPEED_DOWN_2
	db EFFECT_TRANSFORM
	db EFFECT_TOXIC
	db $FF

AI_MagicGuardPokemon:
    db CLEFAIRY
    db CLEFABLE
    db ABRA
    db KADABRA
    db ALAKAZAM
    db SIGILYPH
    db ARCEUS
    db SOLOSIS
    db DUOSION
    db REUNICLUS
    db XERNEAS
    db YVELTAL
    db $FF

AI_LevitatePokemon:
    db GASTLY
    db HAUNTER
    db GENGAR
    db MISDREAVUS
    db MISMAGIUS
    db KOFFING
    db WEEZING
    db LATIAS
    db LATIOS
    db UNOWN
    db ROTOM
    db $FF

AI_WaterAbsorbPokemon:
    db WOOPER
    db QUAGSIRE
    db VAPOREON
    db LAPRAS
    db ARCTOVISH
    db PARAS
    db PARASECT
    db POLIWAG
    db POLIWHIRL
    db $FF

AI_VoltAbsorbPokemon:
    db CHINCHOU
    db LANTURN
    db ELECTABUZZ
    db ELECTIVIRE
    db ZAPDOS
    db JOLTEON
    db ARCTOZOLT
    db PIKACHU
    db RAICHU
    db MAREEP
    db FLAAFFY
    db AMPHAROS
    db $FF

AI_FireAbsorbPokemon:
    db MAGMAR
    db MAGMORTAR
    db FLAREON
    db MOLTRES
    db VULPIX
    db NINETALES
    db PONYTA
    db RAPIDASH
    db HOUNDOUR
    db HOUNDOOM
    db LITWICK
    db LAMPENT
    db CHANDELURE
    db LARVESTA
    db VOLCARONA
    db GROWLITHE
    db ARCANINE
    db $FF

AI_SturdyPokemon:
    db SKARMORY
    db GEODUDE
    db GRAVELER
    db GOLEM
    db MAGNEMITE
    db MAGNETON
    db MAGNEZONE
    db ONIX
    db STEELIX
    db BLASTOISE
    db FERROSEED
    db FERROTHORN
    db $FF

AI_ClearBodyPokemon:
    db TENTACOOL
    db TENTACRUEL
    db BELDUM
    db METANG
    db METAGROSS
    db MACHAMP
    db ENTEI
    db DIALGA
    db ARCEUS
    db $FF

AI_UberImmunePokemon:
    db ARCEUS
    db MEWTWO
    db GIRATINA
    db YVELTAL
    db XERNEAS
    db DIALGA
    db PALKIA
    db KYOGRE
    db GROUDON
    db RAYQUAZA
    db LUGIA
    db HO_OH
    db REGIGIGAS
    db $FF

AI_Basic:
; Don't do anything redundant:
;  -Using status-only moves if the player can't be statused
;  -Using moves that fail if they've already been used

	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld b, NUM_MOVES + 1
.checkmove
	dec b ; b is num moves on 1st pass
	ret z ; if b os 0 return we are done

	inc hl ; increment score to next move score
	ld a, [de] ; load the move struct
	and a
	ret z ; return if no move

	inc de ; increment to next move
	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	ld c, a ; load move effect into c

; Dismiss moves with special effects if they are
; useless or not a good choice right now.
; For example, healing moves, weather moves, Dream Eater...
	push hl
	push de
	push bc
	farcall AI_Redundant
	pop bc
	pop de
	pop hl
	jp nz, .discourage ; discourage if AI_Redundant - loop bck to check move

; Dismiss status-only moves if the player can't be statused.
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	push hl
	push de
	push bc
	ld hl, StatusOnlyEffects
	ld de, 1
	call IsInArray ; is the move status only
	pop bc
	pop de
	pop hl
	jr nc, .checkSub ; if not skip following

	ld a, [wBattleMonStatus]
	and a
	jp nz, .discourage ; discourage if the player is already statused - loop back to check move

; don't use if enemy is immune to status
    ld a, [wBattleMonSpecies]
    cp ARCEUS
    jp z, .discourage
    cp SYLVEON
    jp z, .discourage

.checkSub
; dismiss moves blocked by sub if sub is up
    ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_SUBSTITUTE, a	;check for substitute bit
	jr z, .checkLevitate	;if the substitute bit is not set, then skip out of this block
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	push hl
	push de
	push bc
	ld hl, SubstituteImmuneEffects
	ld de, 1
	call IsInArray	;see if a is found in the hl array (carry flag set if true)
	pop bc
	pop de
	pop hl
	jp c, .discourage ; discourage if sub is up and blocks move - loop back to check move

.checkLevitate
; Dismiss ground move if the player has levitate
	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	and TYPE_MASK
	cp GROUND
	jr nz, .checkWaterAbsorb
	ld a, [wBattleMonSpecies]
	push hl
	push de
	push bc
	ld hl, AI_LevitatePokemon
	ld de, 1
	call IsInArray
    pop bc
	pop de
	pop hl
    jp c, .discourage

.checkWaterAbsorb
    cp WATER
	jr nz, .checkVoltAbsorb
	ld a, [wBattleMonSpecies]
	push hl
	push de
	push bc
	ld hl, AI_WaterAbsorbPokemon
	ld de, 1
	call IsInArray
    pop bc
	pop de
	pop hl
    jp c, .discourage

.checkVoltAbsorb
    cp ELECTRIC
	jr nz, .checkFireAbsorb
	ld a, [wBattleMonSpecies]
	push hl
	push de
	push bc
	ld hl, AI_VoltAbsorbPokemon
	ld de, 1
	call IsInArray
    pop bc
	pop de
	pop hl
    jp c, .discourage

.checkFireAbsorb
    cp FIRE
	jr nz, .checkSafeguard
	ld a, [wBattleMonSpecies]
	push hl
	push de
	push bc
	ld hl, AI_FireAbsorbPokemon
	ld de, 1
	call IsInArray
    pop bc
	pop de
	pop hl
    jp c, .discourage

.checkSafeguard
; Dismiss Safeguard if it's already active.
;	ld a, [wPlayerScreens]
;	bit SCREENS_SAFEGUARD, a
;	jr z, .discourage

; switch if current move is
; JUDGEMENT, PSYBLAST or DRACO_METEOR (common mono-attackers)
; and its pp is 0
	ld a, [wEnemyMoveStruct + MOVE_ANIM]
    cp JUDGEMENT
    jr z, .checkPP
    cp PSYBLAST
    jr z, .checkPP
    cp DRACO_METEOR
    jr z, .checkPP
    jr .checkKO
.checkPP
    push hl
    push bc
    ld hl, wEnemyMonPP
    ld a, [wCurEnemyMoveNum]
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	and PP_MASK
	pop bc
	pop hl
	jp nz, .checkKO

; switch since pp is 0
    ld a, $1
    ld [wEnemyIsSwitching], a
	ret


; Greatly encourage a move if it will KO the player
; skip if enemy is slower and weakened and has priority

.checkKO
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jp z, .checkmove

    ld a, 1
	ldh [hBattleTurn], a
	push hl
	push de
	push bc
	callfar EnemyAttackDamage
	callfar BattleCommand_DamageCalc
	callfar BattleCommand_Stab
	ld a, [wCurDamage + 1]
	ld c, a ; c is curDamage upper
	ld a, [wCurDamage]
	ld b, a ; b is curDamage lower
	ld a, [wBattleMonHP + 1]
	cp c ; compare upper
	ld a, [wBattleMonHP]
	sbc b ; compare lower and set flag
	pop bc
	pop de
	pop hl
    jp nc, .checkmove

; don't encourage explosion as much
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	cp EFFECT_SELFDESTRUCT
	jr z, .lesserEncouragement

; if we are below 1/4 hp and have a healing move then lesser encourage so we can use it
    call AICheckEnemyQuarterHP
    jr c, .checkAcc
	ld b, EFFECT_HEAL
	call AIHasMoveEffect
	jr c, .lesserEncouragement

.checkAcc
; encourage more accurate moves if they can kill
	ld a, [wEnemyMoveStruct + MOVE_ACC]
	cp 100 percent
	jr c, .notAcc
	dec [hl]
	dec [hl]
.notAcc
	dec [hl]
    dec [hl]
.lesserEncouragement
    dec [hl]
    dec [hl]
    dec [hl]
    jp .checkmove

.discourage
	call AIDiscourageMove
	jp .checkmove

INCLUDE "data/battle/ai/status_only_effects.asm"

BoostingMoveEffects:
	db EFFECT_ATTACK_UP_2
	db EFFECT_SP_ATK_UP
	db EFFECT_SP_ATK_UP_2
	db EFFECT_SUBSTITUTE
	db EFFECT_CURSE
	db EFFECT_SERENITY
	db EFFECT_GEOMANCY
	db EFFECT_CALM_MIND
	db EFFECT_BULK_UP
	db EFFECT_DRAGON_DANCE
	db EFFECT_QUIVER_DANCE
	db EFFECT_SHELL_SMASH
	db -1

AI_Smart_Switch:
; Enemies can switch intelligently under certain conditions
; switch if unboosted enemy is FRZ and player sets up
; 50% chance to switch if unboosted enemy is SLP and player sets up
; don't switch if enemy is weakened, just let it die
; switch if enemy is choice locked into a NVE move
; switch if enemy accuracy at -2 or lower
; switch if enemy attack at -2 or lower and has unboosted special attack
; switch if enemy is cursed
; 50% chance to switch if enemy afflicted with toxic
; 50% chance to switch if enemy afflicted with leech seed

; possibly switch if enemy is setup bait
	ld a, [wEnemyMonStatus]
	and 1 << FRZ
	jp nz, .checkSetUpAndSwitchIfPlayerSetsUp
    ;ld a, [wEnemyMonStatus]
	;and SLP
	;jp nz, .checkSetUpAndSwitchIfPlayerSetsUp50

; switch if choice locked into a NVE move that cant 3hko (assumes ai only has the one move)
    call CanAI3HKO
    jr c, .not_encored
	ld hl, wEnemySubStatus5
	bit SUBSTATUS_ENCORED, [hl]
	jr z, .not_encored
    push hl
	ld a, 1
	ldh [hBattleTurn], a
	callfar BattleCheckTypeMatchup
	pop hl
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	jp c, .switch
	and a
	jp z, .switch
.not_encored

; don't switch if enemy is weakened, just let it die
	call AICheckEnemyQuarterHP
	ret nc

; switch if enemy accuracy at -2 or lower
    ld a, [wEnemyAccLevel]
	cp BASE_STAT_LEVEL - 1
	jp c, .switch

; switch if enemy attack at -2 or lower and unboosted special attack
    ld a, [wEnemySAtkLevel]
    cp BASE_STAT_LEVEL + 1
    jr nc, .magicGuard
    ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL - 1
	jp c, .switch

.magicGuard
; Pokemon who are immune to residual damage (magic guard) should not be considered
    ld a, [wEnemyMonSpecies]
    push hl
    push de
	push bc
	ld hl, AI_MagicGuardPokemon
	ld de, 1
	call IsInArray
	pop bc
	pop de
	pop hl
	ret c

; switch if enemy is cursed
    ld a, [wEnemySubStatus1]
	bit SUBSTATUS_CURSE, a
	jp nz, .switch

; if enemy afflicted with toxic
; 50% chance to switch when above 50% hp if not set up
; switch when below 50% hp
    ld a, [wEnemySubStatus5]
	bit SUBSTATUS_TOXIC, a
    jr z, .checkLeechSeed
	call AICheckEnemyHalfHP
	jp nc, .switch
	jp .checkSetUpAndSwitch50

.checkLeechSeed
; 50% chance to switch per turn if enemy afflicted with leech seed
    ld a, [wEnemySubStatus4]
	bit SUBSTATUS_LEECH_SEED, a
	jr nz, .switch50

    ret

.checkSetUpAndSwitchIfPlayerSetsUp
; don't switch if enemy mon is already set up
    ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL + 2
	ret nc
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 2
	ret nc
    ld a, [wEnemyDefLevel]
	cp BASE_STAT_LEVEL + 2
	ret nc
    ld a, [wEnemySDefLevel]
	cp BASE_STAT_LEVEL + 2
	ret nc

; switch if player attempts to set up
	ld a, [wPlayerMoveStruct + MOVE_EFFECT]
    push hl
    push de
	push bc
	ld hl, BoostingMoveEffects
	ld de, 1
	call IsInArray
	pop bc
	pop de
	pop hl
	jr c, .switch
	ret

;.checkSetUpAndSwitchIfPlayerSetsUp50
; don't switch if enemy mon is already set up
;    ld a, [wEnemyAtkLevel]
;	cp BASE_STAT_LEVEL + 2
;	ret nc
;   ld a, [wEnemySAtkLevel]
;	cp BASE_STAT_LEVEL + 2
;	ret nc
;   ld a, [wEnemyDefLevel]
;	cp BASE_STAT_LEVEL + 2
;	ret nc
;   ld a, [wEnemySDefLevel]
;	cp BASE_STAT_LEVEL + 2
;	ret nc

; switch if player attempts to set up
;	ld a, [wPlayerMoveStruct + MOVE_EFFECT]
;   push hl
;   push de
;	push bc
;	ld hl, BoostingMoveEffects
;	ld de, 1
;	call IsInArray
;	pop bc
;	pop de
;	pop hl
;	jr c, .switch50
;	ret

.checkSetUpAndSwitch50
; don't switch if enemy mon is already set up
    ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL + 2
	ret nc
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 2
	ret nc
    ld a, [wEnemyDefLevel]
	cp BASE_STAT_LEVEL + 2
	ret nc
    ld a, [wEnemySDefLevel]
	cp BASE_STAT_LEVEL + 2
	ret nc
	jr .switch50

.switch50
    call AI_50_50
	ret c
.switch
    ld a, $1
    ld [wEnemyIsSwitching], a
	ret

; AndrewNote - this is commented out because this is stupid and will not be used
AI_Setup:
    ret
; Use stat-modifying moves on turn 1.
; 50% chance to greatly encourage stat-up moves during the first turn of enemy's Pokemon.
; 50% chance to greatly encourage stat-down moves during the first turn of player's Pokemon.
; Almost 90% chance to greatly discourage stat-modifying moves otherwise.
;	ld hl, wEnemyAIMoveScores - 1
;	ld de, wEnemyMonMoves
;	ld b, NUM_MOVES + 1
;.checkmove
;	dec b
;	ret z
;	inc hl
;	ld a, [de]
;	and a
;	ret z
;	inc de
;	call AIGetEnemyMove
;	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
;	cp EFFECT_ATTACK_UP
;	jr c, .checkmove
;	cp EFFECT_EVASION_UP + 1
;	jr c, .statup
;	cp EFFECT_ATTACK_DOWN - 1
;	jr z, .checkmove
;	cp EFFECT_EVASION_DOWN + 1
;	jr c, .statdown
;	cp EFFECT_ATTACK_UP_2
;	jr c, .checkmove
;	cp EFFECT_EVASION_UP_2 + 1
;	jr c, .statup
;	cp EFFECT_ATTACK_DOWN_2 - 1
;	jr z, .checkmove
;	cp EFFECT_EVASION_DOWN_2 + 1
;	jr c, .statdown
;	jr .checkmove
;.statup
;	ld a, [wEnemyTurnsTaken]
;	and a
;	jr nz, .discourage
;	jr .encourage
;.statdown
;	ld a, [wPlayerTurnsTaken]
;	and a
;	jr nz, .discourage
;.encourage
;	call AI_50_50
;	jr c, .checkmove
;	dec [hl]
;	dec [hl]
;	jr .checkmove
;.discourage
;	call Random
;	cp 12 percent
;	jr c, .checkmove
;	inc [hl]
;	inc [hl]
;	jr .checkmove

; AndrewNote - this is commented out because this is made redundant by AI_Aggressive
AI_Types:
    ret
; Dismiss any move that the player is immune to.
; Encourage super-effective moves.
; Discourage not very effective moves unless
; all damaging moves are of the same type.
;	ld hl, wEnemyAIMoveScores - 1
;	ld de, wEnemyMonMoves
;	ld b, NUM_MOVES + 1
;.checkmove
;	dec b
;	ret z
;	inc hl
;	ld a, [de]
;	and a
;	ret z
;	inc de
;	call AIGetEnemyMove
;	push hl
;	push bc
;	push de
;	ld a, 1
;	ldh [hBattleTurn], a
;	callfar BattleCheckTypeMatchup
;	pop de
;	pop bc
;	pop hl
;	ld a, [wTypeMatchup]
;	and a
;	jr z, .immune
;	cp EFFECTIVE
;	jr z, .checkmove
;	jr c, .noteffective
; effective
;	ld a, [wEnemyMoveStruct + MOVE_POWER]
;	and a
;	jr z, .checkmove
;	dec [hl]
;	jr .checkmove
;.noteffective
; Discourage this move if there are any moves
; that do damage of a different type.
;	push hl
;	push de
;	push bc
;	ld a, [wEnemyMoveStruct + MOVE_TYPE]
;	and TYPE_MASK
;	ld d, a
;	ld hl, wEnemyMonMoves
;	ld b, NUM_MOVES + 1
;	ld c, 0
;.checkmove2
;	dec b
;	jr z, .movesdone
;	ld a, [hli]
;	and a
;	jr z, .movesdone
;	call AIGetEnemyMove
;	ld a, [wEnemyMoveStruct + MOVE_TYPE]
;	and TYPE_MASK
;	cp d
;	jr z, .checkmove2
;	ld a, [wEnemyMoveStruct + MOVE_POWER]
;	and a
;	jr nz, .damaging
;	jr .checkmove2
;.damaging
;	ld c, a
;.movesdone
;	ld a, c
;	pop bc
;	pop de
;	pop hl
;	and a
;	jr z, .checkmove
;	inc [hl]
;	jr .checkmove
;.immune
;	call AIDiscourageMove
;	jr .checkmove

; AndrewNote - this is commented out because it is stupid and wont be used
AI_Offensive:
    ret
; Greatly discourage non-damaging moves.
;	ld hl, wEnemyAIMoveScores - 1
;	ld de, wEnemyMonMoves
;	ld b, NUM_MOVES + 1
;.checkmove
;	dec b
;	ret z
;	inc hl
;	ld a, [de]
;	and a
;	ret z
;	inc de
;	call AIGetEnemyMove
;	ld a, [wEnemyMoveStruct + MOVE_POWER]
;	and a
;	jr nz, .checkmove
;	inc [hl]
;	inc [hl]
;	jr .checkmove

AI_Smart:
; Context-specific scoring.

	ld hl, wEnemyAIMoveScores
	ld de, wEnemyMonMoves
	ld b, NUM_MOVES + 1
.checkmove
	dec b
	ret z

	ld a, [de]
	inc de
	and a
	ret z

	push de
	push bc
	push hl
	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	ld hl, AI_Smart_EffectHandlers
	ld de, 3
	call IsInArray

	inc hl
	jr nc, .nextmove

	ld a, [hli]
	ld e, a
	ld d, [hl]

	pop hl
	push hl

	ld bc, .nextmove
	push bc

	push de
	ret

.nextmove
	pop hl
	pop bc
	pop de
	inc hl
	jr .checkmove

AI_Smart_EffectHandlers:
	dbw EFFECT_SLEEP,            AI_Smart_Sleep
	dbw EFFECT_LEECH_HIT,        AI_Smart_LeechHit
	dbw EFFECT_SELFDESTRUCT,     AI_Smart_Selfdestruct
	dbw EFFECT_DREAM_EATER,      AI_Smart_DreamEater
	dbw EFFECT_MIRROR_MOVE,      AI_Smart_MirrorMove
	dbw EFFECT_EVASION_UP_2,     AI_Smart_EvasionUp
	dbw EFFECT_ALWAYS_HIT,       AI_Smart_AlwaysHit
	dbw EFFECT_ACCURACY_DOWN,    AI_Smart_AccuracyDown
    dbw EFFECT_ATTACK_DOWN,      AI_Smart_StatDown
    dbw EFFECT_ATTACK_DOWN_2,    AI_Smart_StatDown
    dbw EFFECT_DEFENSE_DOWN,     AI_Smart_StatDown
    dbw EFFECT_DEFENSE_DOWN_2,   AI_Smart_StatDown
    dbw EFFECT_SPEED_DOWN_2,     AI_Smart_StatDown
	dbw EFFECT_RESET_STATS,      AI_Smart_ResetStats
	dbw EFFECT_FORCE_SWITCH,     AI_Smart_ForceSwitch
	dbw EFFECT_HEAL,             AI_Smart_Heal
	dbw EFFECT_TOXIC,            AI_Smart_Toxic
	dbw EFFECT_LIGHT_SCREEN,     AI_Smart_LightScreen
	dbw EFFECT_OHKO,             AI_Smart_Ohko
	dbw EFFECT_SUPER_FANG,       AI_Smart_SuperFang
	dbw EFFECT_TRAP_TARGET,      AI_Smart_TrapTarget
	dbw EFFECT_CONFUSE,          AI_Smart_Confuse
	dbw EFFECT_SP_DEF_UP_2,      AI_Smart_SpDefenseUp2
	dbw EFFECT_REFLECT,          AI_Smart_Reflect
	dbw EFFECT_PARALYZE,         AI_Smart_Paralyze
	dbw EFFECT_SPEED_DOWN_HIT,   AI_Smart_SpeedDownHit
	dbw EFFECT_SUBSTITUTE,       AI_Smart_Substitute
	dbw EFFECT_HYPER_BEAM,       AI_Smart_HyperBeam
	dbw EFFECT_MIMIC,            AI_Smart_Mimic
	dbw EFFECT_LEECH_SEED,       AI_Smart_LeechSeed
	dbw EFFECT_DISABLE,          AI_Smart_Disable
	dbw EFFECT_COUNTER,          AI_Smart_Counter
	dbw EFFECT_ENCORE,           AI_Smart_Encore
	dbw EFFECT_PAIN_SPLIT,       AI_Smart_PainSplit
	dbw EFFECT_SNORE,            AI_Smart_Snore
	dbw EFFECT_LOCK_ON,          AI_Smart_LockOn
	dbw EFFECT_SLEEP_TALK,       AI_Smart_SleepTalk
	dbw EFFECT_DESTINY_BOND,     AI_Smart_DestinyBond
	dbw EFFECT_REVERSAL,         AI_Smart_Reversal
	dbw EFFECT_SPITE,            AI_Smart_Spite
	dbw EFFECT_HEAL_BELL,        AI_Smart_HealBell
	dbw EFFECT_PRIORITY_HIT,     AI_Smart_PriorityHit
	dbw EFFECT_MEAN_LOOK,        AI_Smart_MeanLook
	dbw EFFECT_NIGHTMARE,        AI_Smart_Nightmare
	dbw EFFECT_CURSE,            AI_Smart_Curse
	dbw EFFECT_PROTECT,          AI_Smart_Protect
	dbw EFFECT_FORESIGHT,        AI_Smart_Foresight
	dbw EFFECT_PERISH_SONG,      AI_Smart_PerishSong
	dbw EFFECT_SANDSTORM,        AI_Smart_Sandstorm
	dbw EFFECT_ENDURE,           AI_Smart_Endure
	dbw EFFECT_ROLLOUT,          AI_Smart_Rollout
	dbw EFFECT_SWAGGER,          AI_Smart_Swagger
	dbw EFFECT_BULK_UP,          AI_Smart_BulkUp
	dbw EFFECT_ATTRACT,          AI_Smart_Attract
	dbw EFFECT_MAGNITUDE,        AI_Smart_Magnitude
	dbw EFFECT_BATON_PASS,       AI_Smart_BatonPass
	dbw EFFECT_RAPID_SPIN,       AI_Smart_RapidSpin
	dbw EFFECT_MORNING_SUN,      AI_Smart_MorningSun
	dbw EFFECT_SYNTHESIS,        AI_Smart_Synthesis
	dbw EFFECT_MOONLIGHT,        AI_Smart_Moonlight
	dbw EFFECT_HIDDEN_POWER,     AI_Smart_HiddenPower
	dbw EFFECT_RAIN_DANCE,       AI_Smart_RainDance
	dbw EFFECT_SUNNY_DAY,        AI_Smart_SunnyDay
	dbw EFFECT_BELLY_DRUM,       AI_Smart_BellyDrum
	dbw EFFECT_PSYCH_UP,         AI_Smart_PsychUp
	dbw EFFECT_MIRROR_COAT,      AI_Smart_MirrorCoat
	dbw EFFECT_TWISTER,          AI_Smart_Twister
	dbw EFFECT_EARTHQUAKE,       AI_Smart_Earthquake
	dbw EFFECT_FUTURE_SIGHT,     AI_Smart_FutureSight
	dbw EFFECT_GUST,             AI_Smart_Gust
	dbw EFFECT_STOMP,            AI_Smart_Stomp
	dbw EFFECT_SOLARBEAM,        AI_Smart_Solarbeam
	dbw EFFECT_THUNDER,          AI_Smart_Thunder
	dbw EFFECT_FLY,              AI_Smart_Fly
	dbw EFFECT_HOLY_ARMOUR,      AI_Smart_HolyArmour
	dbw EFFECT_SERENITY,         AI_Smart_Serenity
	dbw EFFECT_ATTACK_UP_2,      AI_Smart_SwordsDance
	dbw EFFECT_DEFENSE_UP_2,     AI_Smart_Barrier
	dbw EFFECT_SP_ATK_UP,        AI_Smart_Growth
	dbw EFFECT_SP_ATK_UP_2,      AI_Smart_NastyPlot
	dbw EFFECT_GEOMANCY,         AI_Smart_Geomancy
	dbw EFFECT_CALM_MIND,        AI_Smart_CalmMind
	dbw EFFECT_DRAGON_DANCE,     AI_Smart_DragonDance
	dbw EFFECT_CONFUSE_HIT,      AI_Smart_DynamicPunch
    dbw EFFECT_QUIVER_DANCE,     AI_Smart_QuiverDance
    dbw EFFECT_SPIKES,           AI_Smart_Spikes
    dbw EFFECT_SHELL_SMASH,      AI_Smart_ShellSmash
    dbw EFFECT_FLINCH_HIT,       AI_Smart_Flinch
    dbw EFFECT_KINGS_SHIELD,     AI_Smart_KingsShield
    dbw EFFECT_STATIC_DAMAGE,    AI_Smart_StaticDamage
    dbw EFFECT_ATTACK_DOWN,      AI_Smart_LesserStatChange
    dbw EFFECT_DEFENSE_UP,       AI_Smart_LesserStatChange
    dbw EFFECT_DEFENSE_DOWN,     AI_Smart_LesserStatChange
    dbw EFFECT_DEFENSE_DOWN_2,   AI_Smart_LesserStatChange
    dbw EFFECT_FOCUS_ENERGY,     AI_Smart_LesserStatChange
    dbw EFFECT_SAFEGUARD,        AI_Smart_LesserStatChange
	db -1 ; end

AI_Smart_Sleep:
; never use if player has substitute
    ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_SUBSTITUTE, a
	jr nz, .discourage

; never use if player has safeguard
	ld a, [wPlayerScreens]
	bit SCREENS_SAFEGUARD, a
	jr nz, .discourage

; Greatly encourage sleep inducing moves if the enemy has either Dream Eater or Nightmare.
; 50% chance to greatly encourage sleep inducing moves otherwise.

; don't use against Arceus as it is immune to status
    ld a, [wBattleMonSpecies]
    cp ARCEUS
    jr z, .discourage
    cp SYLVEON
    jr z, .discourage

; is the player behind a sub
    ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_SUBSTITUTE, a	;check for substitute bit
	jr nz, .discourage

; does player have a held item that would heal sleep
	push hl
	push de
	ld a, [wBattleMonItem]
	ld [wNamedObjectIndex], a
	ld b, a
	callfar GetItemHeldEffect
	ld a, b
	cp HELD_HEAL_STATUS
	pop de
	pop hl
	jr z, .discourage

; check if the move is Spore
	ld a, [wEnemyMoveStruct + MOVE_ANIM]
	cp SPORE
	jr nz, .notSpore
	jr .useMove

.notSpore
; if faster then continue
	call AICompareSpeed
	jr c, .continue

; discourage if faster player has picked substitute
	ld a, [wCurPlayerMove]
	cp SUBSTITUTE
	jr nc, .continue
	inc [hl]
	inc [hl]
	inc [hl]
	ret

.continue
	ld b, EFFECT_DREAM_EATER
	call AIHasMoveEffect
	jr c, .encourage

	ld b, EFFECT_NIGHTMARE
	call AIHasMoveEffect
	ret nc

; Pokemon with Bad Dreams ability should prioritise sleep more
    ld a, [wEnemyMonSpecies]
    cp DARKRAI
    jr z, .encourage
    cp HYPNO
    jr z, .encourage
    cp SPIRITOMB
    jr z, .encourage
    cp JYNX
    jr z, .encourage

.encourage
	call AI_50_50
	ret c
	dec [hl]
	dec [hl]
	ret
.discourage
    inc [hl]
    inc [hl]
    ret
.useMove
    dec [hl]
    dec [hl]
    dec [hl]
    dec [hl]
    dec [hl]
    dec [hl]
    dec [hl]
    dec [hl]
    dec [hl]
    ret

AI_Smart_LeechHit:
	push hl
	ld a, 1
	ldh [hBattleTurn], a
	callfar BattleCheckTypeMatchup
	pop hl

; 60% chance to discourage this move if not very effective.
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	jr c, .discourage

; Do nothing if effectiveness is neutral.
	ret z

; Do nothing if enemy's HP is full.
	call AICheckEnemyMaxHP
	ret c

; 80% chance to encourage this move otherwise.
	call AI_80_20
	ret c

	dec [hl]
	ret

.discourage
	call Random
	cp 39 percent + 1
	ret c

	inc [hl]
	ret

AI_Smart_LockOn:
	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_LOCK_ON, a
	jr nz, .player_locked_on

	push hl
	call AICheckEnemyQuarterHP
	jr nc, .discourage

	call AICheckEnemyHalfHP
	jr c, .skip_speed_check

	call AICompareSpeed
	jr nc, .discourage

.skip_speed_check
	ld a, [wPlayerEvaLevel]
	cp BASE_STAT_LEVEL + 3
	jr nc, .maybe_encourage
	cp BASE_STAT_LEVEL + 1
	jr nc, .do_nothing

	ld a, [wEnemyAccLevel]
	cp BASE_STAT_LEVEL - 2
	jr c, .maybe_encourage
	cp BASE_STAT_LEVEL
	jr c, .do_nothing

	ld hl, wEnemyMonMoves
	ld c, NUM_MOVES + 1
.checkmove
	dec c
	jr z, .discourage

	ld a, [hli]
	and a
	jr z, .discourage

	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_ACC]
	cp 71 percent - 1
	jr nc, .checkmove

	ld a, 1
	ldh [hBattleTurn], a

	push hl
	push bc
	farcall BattleCheckTypeMatchup
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	pop bc
	pop hl
	jr c, .checkmove

.do_nothing
	pop hl
	ret

.discourage
	pop hl
	inc [hl]
	ret

.maybe_encourage
	pop hl
	call AI_50_50
	ret c

	dec [hl]
	dec [hl]
	ret

.player_locked_on
	push hl
	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld c, NUM_MOVES + 1

.checkmove2
	inc hl
	dec c
	jr z, .dismiss

	ld a, [de]
	and a
	jr z, .dismiss

	inc de
	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_ACC]
	cp 71 percent - 1
	jr nc, .checkmove2

	dec [hl]
	dec [hl]
	jr .checkmove2

.dismiss
	pop hl
	jp AIDiscourageMove

AI_Smart_Selfdestruct:
; Selfdestruct, Explosion

; never use against ghost types
    ld a, [wBattleMonType1]
	cp GHOST
	jr z, .discourage
	ld a, [wBattleMonType2]
	cp GHOST
	jr z, .discourage

; Unless this is the enemy's last Pokemon...
	push hl
	farcall FindAliveEnemyMons
	pop hl
	jr nc, .notlastmon

; ...greatly discourage this move unless this is the player's last Pokemon too.
	push hl
	call AICheckLastPlayerMon
	pop hl
	jr nz, .discourage

.notlastmon
; if enemy's HP is below 25% just boom
	call AICheckEnemyQuarterHP
	jr nc, .encourage

; use if we are about to be KOd
    call ShouldAIBoost
    jr nc, .encourage

.continue
; Greatly discourage this move if enemy's HP is above 50%.
	call AICheckEnemyHalfHP
	jr c, .discourage

; if we are here we are below 1/2 hp and player is non boosted
; if we have no other move that can ko the player just boom

.encourage
    dec [hl]
    ret
.discourage
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_DreamEater:
; 90% chance to greatly encourage this move.
; The AI_Basic layer will make sure that
; Dream Eater is only used against sleeping targets.
	call Random
	cp 10 percent
	ret c
	dec [hl]
	dec [hl]
	dec [hl]
	ret

AI_Smart_EvasionUp:
; encourage to +4 and discourage after
	ld a, [wEnemyEvaLevel]
	cp BASE_STAT_LEVEL + 4
	jr nc, .discourage
	dec [hl]
	dec [hl]
	dec [hl]
	ret
.discourage
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

; Player is badly poisoned.
; 70% chance to greatly encourage this move.
; This would counter any previous discouragement.
.maybe_greatly_encourage
	call Random
	cp 31 percent + 1
	ret c

	dec [hl]
	dec [hl]
	ret

; Player is seeded.
; 50% chance to encourage this move.
; This would partly counter any previous discouragement.
.maybe_encourage
	call AI_50_50
	ret c

	dec [hl]
	ret

AI_Smart_AlwaysHit:
; 80% chance to greatly encourage this move if either...

; ...enemy's accuracy level has been lowered three or more stages
	ld a, [wEnemyAccLevel]
	cp BASE_STAT_LEVEL - 2
	jr c, .encourage

; ...or player's evasion level has been raised three or more stages.
	ld a, [wPlayerEvaLevel]
	cp BASE_STAT_LEVEL + 3
	ret c

.encourage
	call AI_80_20
	ret c

	dec [hl]
	dec [hl]
	ret

AI_Smart_MirrorMove:
; If the player did not use any move last turn...
	ld a, [wLastPlayerCounterMove]
	and a
	jr nz, .usedmove

; ...do nothing if enemy is slower than player
	call AICompareSpeed
	ret nc

; ...or dismiss this move if enemy is faster than player.
	jp AIDiscourageMove

; If the player did use a move last turn...
.usedmove
	push hl
	ld hl, UsefulMoves
	ld de, 1
	call IsInArray
	pop hl

; ...do nothing if he didn't use a useful move.
	ret nc

; If he did, 50% chance to encourage this move...
	call AI_50_50
	ret c

	dec [hl]

; ...and 90% chance to encourage this move again if the enemy is faster.
	call AICompareSpeed
	ret nc

	call Random
	cp 10 percent
	ret c

	dec [hl]
	ret

AI_Smart_AccuracyDown:
; discourage if enemy is immune to stat drops
    ld a, [wBattleMonSpecies]
    push bc
    push hl
    push de
	ld hl, AI_ClearBodyPokemon
	ld de, 1
	call IsInArray
	pop de
	pop hl
	pop bc
	jr c, .discourage

; discourage after player is at -3
    ld a, [wPlayerAccLevel]
    cp BASE_STAT_LEVEL - 2
    jr c, .discourage

; encourage slightly if player has full accuracy
    ld a, [wPlayerAccLevel]
    cp BASE_STAT_LEVEL
    ret c
    dec [hl]
    ret
.discourage
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_StatDown:
; discourage if enemy is immune to stat drops
    ld a, [wBattleMonSpecies]
    push bc
    push hl
    push de
	ld hl, AI_ClearBodyPokemon
	ld de, 1
	call IsInArray
	pop de
	pop hl
	pop bc
	ret nc

	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret


AI_Smart_ResetStats:
; 85% chance to encourage this move if any of enemy's stat levels is lower than -2.
	push hl
	ld hl, wEnemyAtkLevel
	ld c, NUM_LEVEL_STATS
.enemystatsloop
	dec c
	jr z, .enemystatsdone
	ld a, [hli]
	cp BASE_STAT_LEVEL - 2
	jr c, .encourage
	jr .enemystatsloop

; 85% chance to encourage this move if any of player's stat levels is higher than +2.
.enemystatsdone
	ld hl, wPlayerAtkLevel
	ld c, NUM_LEVEL_STATS
.playerstatsloop
	dec c
	jr z, .discourage
	ld a, [hli]
	cp BASE_STAT_LEVEL + 3
	jr c, .playerstatsloop

.encourage
	pop hl
	call Random
	cp 16 percent
	ret c
	dec [hl]
	ret

; Discourage this move if neither:
; Any of enemy's stat levels is	lower than -2.
; Any of player's stat levels is higher than +2.
.discourage
	pop hl
	inc [hl]
	ret

AI_Smart_Spikes:
; discourage if player has spikes on the field, otherwise encourage
	ld a, [wPlayerScreens]
	bit SCREENS_SPIKES, a
	jr nz, .discourage
	dec [hl]
	dec [hl]
	dec [hl]
	ret
.discourage
    inc [hl]
    inc [hl]
    inc [hl]
    inc [hl]
    ret

AI_Smart_ForceSwitch:
; Whirlwind, Roar.
; don't use on Uber Pokemon as they are immune
    ld a, [wBattleMonSpecies]
    push hl
    push de
   	push bc
   	ld hl, AI_UberImmunePokemon
   	ld de, 1
   	call IsInArray
   	pop bc
   	pop de
   	pop hl
   	jr c, .discourage

; don't use if player has only one pokemon left
	push hl
	call AICheckLastPlayerMon
	pop hl
	jr z, .discourage

; encourage this move if the player's attack levels are boosted.
	ld a, [wPlayerAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr nc, .encourage
	ld a, [wPlayerSAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr nc, .encourage

; discourage if non-boosted player can 2HKO from current HP
    call CanPlayer2HKO
    jr c, .discourage

; encourage if player has spikes on the field
	ld a, [wPlayerScreens]
	bit SCREENS_SPIKES, a
	jr nz, .encourage

.discourage
    inc [hl]
    inc [hl]
    inc [hl]
    ret
.encourage
	dec [hl]
	ret


AI_Smart_Heal:
AI_Smart_MorningSun:
AI_Smart_Synthesis:
AI_Smart_Moonlight:
; check if the move is Rest, it must be handled differently
	ld a, [wEnemyMoveStruct + MOVE_ANIM]
	cp REST
	jr nz, .nonRestHeal

; if it is Rest check if the enemy is afflicted with toxic
; if so cancel any switching and heal below 1/2 hp
    ld a, [wEnemySubStatus5]
	bit SUBSTATUS_TOXIC, a
    jr z, .restHeal
    ld a, $0
    ld [wEnemyIsSwitching], a
    jr .nonRestHeal

.restHeal
; for rest don't heal if player can 3hko from max hp, unless AI also knows sleep talk
; then don't use if player can 2hko from max hp
	ld b, EFFECT_SLEEP_TALK
	call AIHasMoveEffect
	jr c, .nonRestHeal
	jr c, .nonRestHeal
    call CanPlayer3HKOMaxHP
    jr c, .discourage

.nonRestHeal
; don't heal if player can 2 shot from max hp, no point
    call CanPlayer2HKOMaxHP
    jr c, .discourage

; Arceus and Mewtwo are fast and bulky enough to focus on set up and only heal below half
    ld a, [wEnemyMonSpecies]
    cp MEWTWO
    jr z, .healBelowHalf
    cp ARCEUS
    jr z, .healBelowHalf

; always heal when below 1/4 hp
    call AICheckEnemyQuarterHP
    jr nc, .encourage

; if faster than the player, heal if the player can 1hko
    call AICompareSpeed
    jr nc, .playerMovesFirst
    call CanPlayerKO
    jr c, .encourage
    jr .discourage

; if slower than the player, heal if player can 2hko
.playerMovesFirst
    call CanPlayer2HKO
    jr c, .encourage
    jr .discourage

.healBelowHalf
    call AICheckEnemyHalfHP
    jr c, .discourage
    ; fallthrough

.encourage
	dec [hl]
	dec [hl]
	dec [hl]
	dec [hl]
	ret
.discourage
    inc [hl]
    inc [hl]
    inc [hl]
    inc [hl]
    ret

AI_Smart_Toxic:
; never use if player has substitute
    ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_SUBSTITUTE, a
	jr nz, .discourage

; never use if player has safeguard
	ld a, [wPlayerScreens]
	bit SCREENS_SAFEGUARD, a
	jr nz, .discourage

; never use against steel types
    ld a, [wBattleMonType1]
	cp STEEL
	jr z, .discourage
	ld a, [wBattleMonType2]
	cp STEEL
	jr z, .discourage

; never use against poison types
    ld a, [wBattleMonType1]
	cp POISON
	jr z, .discourage
	ld a, [wBattleMonType2]
	cp POISON
	jr z, .discourage

; never use against Pokemon immune to status
    ld a, [wBattleMonSpecies]
    cp ARCEUS
    jr z, .discourage
    cp SYLVEON
    jr z, .discourage

; never use against Pokemon with magic guard
    ld a, [wBattleMonSpecies]
    push hl
    push de
   	push bc
   	ld hl, AI_MagicGuardPokemon
   	ld de, 1
   	call IsInArray
   	pop bc
   	pop de
   	pop hl
   	jr c, .discourage

; don't use if player below 50% HP
    call AICheckPlayerHalfHP
    jr nc, .discourage

; encourage slightly if we get here
    dec [hl]
	ret

.discourage
    inc [hl]
    inc [hl]
    inc [hl]
    ret


AI_Smart_LeechSeed:
; never use against grass types
    ld a, [wBattleMonType1]
	cp GRASS
	jr z, .discourage
	ld a, [wBattleMonType2]
	cp GRASS
	jr z, .discourage

; never use against Pokemon with magic guard
    ld a, [wBattleMonSpecies]
    push hl
    push de
   	push bc
   	ld hl, AI_MagicGuardPokemon
   	ld de, 1
   	call IsInArray
   	pop bc
   	pop de
   	pop hl
   	jr c, .discourage

; Discourage this move if player's HP is below 50%.
	call AICheckPlayerHalfHP
	jr nc, .discourage

	ret

.discourage
    inc [hl]
    inc [hl]
    ret

AI_Smart_LightScreen:
AI_Smart_Reflect:
; discourage if we will be koed
    call ShouldAIBoost
    ret c
    inc [hl]
    inc [hl]
    ret

AI_Smart_Ohko:
; Dismiss this move if player's level is higher than enemy's level.
; Else, discourage this move is player's HP is below 50%.

; don't use Fissure against a flying type
    ld a, [wEnemyMoveStruct + MOVE_ANIM]
	cp FISSURE
	jr nz, .notFissure
    ld a, [wBattleMonType1]
	cp FLYING
	jr z, .discourage
	ld a, [wBattleMonType2]
	cp FLYING
	jr z, .discourage

.notFissure
; don't use on Uber Pokemon as they are immune
    ld a, [wBattleMonSpecies]
    push hl
    push de
   	push bc
   	ld hl, AI_UberImmunePokemon
   	ld de, 1
   	call IsInArray
   	pop bc
   	pop de
   	pop hl
   	jr c, .discourage

	ld a, [wBattleMonLevel]
	ld b, a
	ld a, [wEnemyMonLevel]
	cp b
	jp c, AIDiscourageMove
	call AICheckPlayerHalfHP
	ret c
.discourage
	inc [hl]
	ret

AI_Smart_StaticDamage:
; don't use on Uber Pokemon as they are immune
    ld a, [wBattleMonSpecies]
    push hl
    push de
   	push bc
   	ld hl, AI_UberImmunePokemon
   	ld de, 1
   	call IsInArray
   	pop bc
   	pop de
   	pop hl
   	ret nc
   	inc [hl]
   	inc [hl]
   	inc [hl]
   	ret

AI_Smart_TrapTarget:
; Wrap, Fire Spin, Clamp

; 50% chance to discourage this move if the player is already trapped.
	ld a, [wPlayerWrapCount]
	and a
	jr nz, .discourage

; 50% chance to greatly encourage this move if player is either
; badly poisoned, in love, identified, stuck in Rollout, or has a Nightmare.
	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_TOXIC, a
	jr nz, .encourage

	ld a, [wPlayerSubStatus1]
	and 1 << SUBSTATUS_IN_LOVE | 1 << SUBSTATUS_ROLLOUT | 1 << SUBSTATUS_IDENTIFIED | 1 << SUBSTATUS_NIGHTMARE
	jr nz, .encourage

; Else, 50% chance to greatly encourage this move if it's the player's Pokemon first turn.
	ld a, [wPlayerTurnsTaken]
	and a
	jr z, .encourage

; 50% chance to discourage this move otherwise.
.discourage
	call AI_50_50
	ret c
	inc [hl]
	ret

.encourage
	call AICheckEnemyQuarterHP
	ret nc
	call AI_50_50
	ret c
	dec [hl]
	dec [hl]
	ret

AI_Smart_RazorWind:
	ld a, [wEnemySubStatus1]
	bit SUBSTATUS_PERISH, a
	jr z, .no_perish_count

	ld a, [wEnemyPerishCount]
	cp 3
	jr c, .discourage

.no_perish_count
	push hl
	ld hl, wPlayerUsedMoves
	ld c, NUM_MOVES

.checkmove
	ld a, [hli]
	and a
	jr z, .movesdone

	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	cp EFFECT_PROTECT
	jr z, .dismiss
	dec c
	jr nz, .checkmove

.movesdone
	pop hl
	ld a, [wEnemySubStatus3]
	bit SUBSTATUS_CONFUSED, a
	jr nz, .maybe_discourage

	call AICheckEnemyHalfHP
	ret c

.maybe_discourage
	call Random
	cp 79 percent - 1
	ret c

.discourage
	inc [hl]
	ret

.dismiss
	pop hl
	ld a, [hl]
	add 6
	ld [hl], a
	ret

AI_Smart_SpDefenseUp2:
; Discourage this move if enemy's HP is lower than 50%.
	call AICheckEnemyHalfHP
	jr nc, .discourage

; Discourage this move if enemy's special defense level is higher than +3.
	ld a, [wEnemySDefLevel]
	cp BASE_STAT_LEVEL + 4
	jr nc, .discourage

; 80% chance to greatly encourage this move if
; enemy's Special Defense level is lower than +2,
; and the player's Pokémon is Special-oriented.
	cp BASE_STAT_LEVEL + 2
	ret nc

	push hl
; Get the pointer for the player's Pokémon's base Attack
	ld a, [wBattleMonSpecies]
	ld hl, BaseData + BASE_ATK
	ld bc, BASE_DATA_SIZE
	call AddNTimes
; Get the Pokémon's base Attack
	ld a, BANK(BaseData)
	call GetFarByte
	ld d, a
; Get the pointer for the player's Pokémon's base Special Attack
	ld bc, BASE_SAT - BASE_ATK
	add hl, bc
; Get the Pokémon's base Special Attack
	ld a, BANK(BaseData)
	call GetFarByte
	pop hl
; If its base Attack is greater than its base Special Attack,
; don't encourage this move.
	cp d
	ret c

.encourage
	call AI_80_20
	ret c
	dec [hl]
	dec [hl]
	ret

.discourage
	inc [hl]
	ret

AI_Smart_Fly:
; Fly, Dig

; Greatly encourage this move if the player is
; flying or underground, and slower than the enemy.

	ld a, [wPlayerSubStatus3]
	and 1 << SUBSTATUS_FLYING | 1 << SUBSTATUS_UNDERGROUND
	ret z

	call AICompareSpeed
	ret nc

	dec [hl]
	dec [hl]
	dec [hl]
	ret

AI_Smart_SuperFang:
; Discourage this move if player's HP is below 25%.
	call AICheckPlayerQuarterHP
	ret c
	inc [hl]
	ret

AI_Smart_Paralyze:
; never use if player has substitute
    ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_SUBSTITUTE, a
	jr nz, .discourage

; never use if player has safeguard
	ld a, [wPlayerScreens]
	bit SCREENS_SAFEGUARD, a
	jr nz, .discourage

; never use thunderwave against ground types
	ld a, [wEnemyMoveStruct + MOVE_ANIM]
	cp THUNDER_WAVE
	jr nz, .glare
    ld a, [wBattleMonType1]
	cp GROUND
	jr z, .discourage
	ld a, [wBattleMonType2]
	cp GROUND
	jr z, .discourage

.glare
; never use glare against ghost types
	cp GLARE
	jr nz, .notGlare
    ld a, [wBattleMonType1]
	cp GHOST
	jr z, .discourage
	ld a, [wBattleMonType2]
	cp GHOST
	jr z, .discourage

.notGlare
; don't use against Arceus since it is immune to status
; always use against Mewtwo
    ld a, [wBattleMonSpecies]
    cp MEWTWO
    jr z, .encourage
    cp ARCEUS
    jr z, .discourage
    cp SYLVEON
    jr z, .discourage

; encourage if enemy is slower than player.
; 50% chance to discourage otherwise
	call AICompareSpeed
	jr c, .discourage50

.encourage
; needs to overcome encouragement to attack
; no good reason not to paralyze
rept 8
    dec [hl]
endr
    ret
.discourage50
    call AI_50_50
    ret c
.discourage
    inc [hl]
    inc [hl]
    inc [hl]
    inc [hl]
    ret

AI_Smart_SpeedDownHit:
; Icy Wind

; Almost 90% chance to greatly encourage this move if the following conditions all meet:
; Enemy's HP is higher than 25%.
; It's the first turn of player's Pokemon.
; Player is faster than enemy.

	ld a, [wEnemyMoveStruct + MOVE_ANIM]
	cp ICY_WIND
	ret nz
	call AICheckEnemyQuarterHP
	ret nc
	ld a, [wPlayerTurnsTaken]
	and a
	ret nz
	call AICompareSpeed
	ret c
	call Random
	cp 12 percent
	ret c
	dec [hl]
	dec [hl]
	ret

AI_Smart_Substitute:
; Dismiss this move if enemy's HP is below 50%.

	call AICheckEnemyHalfHP
	ret c
	jp AIDiscourageMove

AI_Smart_HyperBeam:
	call AICheckEnemyHalfHP
	jr c, .discourage

; 50% chance to encourage this move if enemy's HP is below 25%.
	call AICheckEnemyQuarterHP
	ret c
	call AI_50_50
	ret c
	dec [hl]
	ret

.discourage
; If enemy's HP is above 50%, discourage this move at random
	call Random
	cp 16 percent
	ret c
	inc [hl]
	call AI_50_50
	ret c
	inc [hl]
	ret

AI_Smart_Mimic:
; Discourage this move if the player did not use any move last turn.
	ld a, [wLastPlayerCounterMove]
	and a
	jr z, .dismiss

	call AICheckEnemyHalfHP
	jr nc, .discourage

	push hl
	ld a, [wLastPlayerCounterMove]
	call AIGetEnemyMove

	ld a, 1
	ldh [hBattleTurn], a
	callfar BattleCheckTypeMatchup

	ld a, [wTypeMatchup]
	cp EFFECTIVE
	pop hl
	jr c, .discourage
	jr z, .skip_encourage

	call AI_50_50
	jr c, .skip_encourage

	dec [hl]

.skip_encourage
	ld a, [wLastPlayerCounterMove]
	push hl
	ld hl, UsefulMoves
	ld de, 1
	call IsInArray

	pop hl
	ret nc
	call AI_50_50
	ret c
	dec [hl]
	ret

.dismiss
; Dismiss this move if the enemy is faster than the player.
	call AICompareSpeed
	jp c, AIDiscourageMove

.discourage
	inc [hl]
	ret

AI_Smart_Counter:
;	push hl
;	ld hl, wPlayerUsedMoves
;	ld c, NUM_MOVES
;	ld b, 0

;.playermoveloop
;	ld a, [hli]
;	and a
;	jr z, .skipmove

;	call AIGetEnemyMove

;	ld a, [wEnemyMoveStruct + MOVE_POWER]
;	and a
;	jr z, .skipmove

;	ld a, [wEnemyMoveStruct + MOVE_TYPE]
;	cp SPECIAL
;	jr nc, .skipmove

;	inc b

;.skipmove
;	dec c
;	jr nz, .playermoveloop

;	pop hl
;	ld a, b
;	and a
;	jr z, .discourage

;	cp 3
;	jr nc, .encourage

	ld a, [wLastPlayerCounterMove]
	;and a
	;jr z, .done

	call AIGetEnemyMove

	;ld a, [wEnemyMoveStruct + MOVE_POWER]
	;and a
	;jr z, .done

	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	cp SPECIAL
	jr nc, .done

.encourage
	dec [hl]
	dec [hl]
	dec [hl]
	dec [hl]
.done
	ret

AI_Smart_Encore:
	call AICompareSpeed
	jr nc, .discourage

; don't use if player already encored
	ld hl, wPlayerSubStatus5
	bit SUBSTATUS_ENCORED, [hl]
	jr nz, .discourage

; don't use on Uber Pokemon as they are immune
    ld a, [wBattleMonSpecies]
    push hl
    push de
   	push bc
   	ld hl, AI_UberImmunePokemon
   	ld de, 1
   	call IsInArray
   	pop bc
   	pop de
   	pop hl
   	jr c, .discourage

	ld a, [wLastPlayerMove]
	and a
	jp z, AIDiscourageMove

	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr z, .weakmove

	push hl
	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	and TYPE_MASK
	ld hl, wEnemyMonType1
	predef CheckTypeMatchup

	pop hl
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	jr nc, .weakmove

	and a
	ret nz
	jr .encourage

.weakmove
	push hl
	ld a, [wLastPlayerCounterMove]
	ld hl, EncoreMoves
	ld de, 1
	call IsInArray
	pop hl
	jr nc, .discourage

.encourage
	dec [hl]
	dec [hl]
	dec [hl]
	ret

.discourage
	inc [hl]
	inc [hl]
	inc [hl]
	ret

INCLUDE "data/battle/ai/encore_moves.asm"

AI_Smart_PainSplit:
; Discourage this move if [enemy's current HP * 2 > player's current HP].

	push hl
	ld hl, wEnemyMonHP
	ld b, [hl]
	inc hl
	ld c, [hl]
	sla c
	rl b
	ld hl, wBattleMonHP + 1
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
	pop hl
	ret nc
	inc [hl]
	ret

AI_Smart_Snore:
AI_Smart_SleepTalk:
; Greatly encourage this move if enemy is fast asleep.
; Greatly discourage this move otherwise.

	ld a, [wEnemyMonStatus]
	and SLP
	cp 1
	jr z, .discourage

	dec [hl]
	dec [hl]
	dec [hl]
	dec [hl]
	dec [hl]
	dec [hl]
	ret

.discourage
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_Spite:
	ld a, [wLastPlayerCounterMove]
	and a
	jr nz, .usedmove

	call AICompareSpeed
	jp c, AIDiscourageMove

	call AI_50_50
	ret c
	inc [hl]
	ret

.usedmove
	push hl
	ld b, a
	ld c, NUM_MOVES
	ld hl, wBattleMonMoves
	ld de, wBattleMonPP

.moveloop
	ld a, [hli]
	cp b
	jr z, .foundmove

	inc de
	dec c
	jr nz, .moveloop

	pop hl
	ret

.foundmove
	pop hl
	ld a, [de]
	cp 6
	jr c, .encourage
	cp 15
	jr nc, .discourage

	call Random
	cp 39 percent + 1
	ret nc

.discourage
	inc [hl]
	ret

.encourage
	call Random
	cp 39 percent + 1
	ret c
	dec [hl]
	dec [hl]
	ret

.dismiss ; unreferenced
	jp AIDiscourageMove

AI_Smart_DestinyBond:
AI_Smart_Reversal:
; Discourage this move if enemy's HP is above 25%.

	call AICheckEnemyQuarterHP
	ret nc
	inc [hl]
	ret

AI_Smart_HealBell:
; Dismiss this move if none of the opponent's Pokemon is statused.
; Encourage this move if the enemy is statused.
; 50% chance to greatly encourage this move if the enemy is fast asleep or frozen.

	push hl
	ld a, [wOTPartyCount]
	ld b, a
	ld c, 0
	ld hl, wOTPartyMon1HP
	ld de, PARTYMON_STRUCT_LENGTH

.loop
	push hl
	ld a, [hli]
	or [hl]
	jr z, .next

	; status
	dec hl
	dec hl
	dec hl
	ld a, [hl]
	or c
	ld c, a

.next
	pop hl
	add hl, de
	dec b
	jr nz, .loop

	pop hl
	ld a, c
	and a
	jr z, .no_status

	ld a, [wEnemyMonStatus]
	and a
	jr z, .ok
	dec [hl]
.ok
	and 1 << FRZ | SLP
	ret z
	call AI_50_50
	ret c
	dec [hl]
	dec [hl]
	ret

.no_status
	ld a, [wEnemyMonStatus]
	and a
	ret nz
	jp AIDiscourageMove


AI_Smart_PriorityHit:
; if faster than the player then do nothing
	call AICompareSpeed
	ret c

; never use extremespeed against a ghost type
	ld a, [wEnemyMoveStruct + MOVE_ANIM]
	cp EXTREMESPEED
	jr nz, .notESpeed
    ld a, [wBattleMonType1]
	cp GHOST
	jp z, AIDiscourageMove
	ld a, [wBattleMonType2]
	cp GHOST
	jp z, AIDiscourageMove

.notESpeed
; Dismiss this move if the player is flying or underground.
	ld a, [wPlayerSubStatus3]
	and 1 << SUBSTATUS_FLYING | 1 << SUBSTATUS_UNDERGROUND
	jp nz, AIDiscourageMove

; massive encourage if player can KO and player is attacking, unless we have sash
; this needs to overcome encouragement from other moves which do more damage and can KO
	call CanPlayerKO
	jr nc, .continue
    call DoesEnemyHaveIntactFocusSashOrSturdy
    jr c, .continue

; has player picked a damaging move, if not then don't encourage.
    ld a, [wCurPlayerMove]
	call AIGetPlayerMove
	ld a, [wPlayerMoveStruct + MOVE_POWER]
    and a
	jr z, .continue

.encourage
rept 9
	dec [hl]
endr

.continue
; Greatly encourage this move if it will KO the player.
	ld a, 1
	ldh [hBattleTurn], a
	push hl
	callfar EnemyAttackDamage
	callfar BattleCommand_DamageCalc
	callfar BattleCommand_Stab
	pop hl
	ld a, [wCurDamage + 1]
	ld c, a
	ld a, [wCurDamage]
	ld b, a
	ld a, [wBattleMonHP + 1]
	cp c
	ld a, [wBattleMonHP]
	sbc b
	ret nc
	dec [hl]
	dec [hl]
	dec [hl]
	ret

AI_Smart_Disable:
	call AICompareSpeed
	jr nc, .discourage

	push hl
	ld a, [wLastPlayerCounterMove]
	ld hl, UsefulMoves
	ld de, 1
	call IsInArray

	pop hl
	jr nc, .notencourage

	call Random
	cp 39 percent + 1
	ret c
	dec [hl]
	ret

.notencourage
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	ret nz

.discourage
	call Random
	cp 8 percent
	ret c
	inc [hl]
	ret

AI_Smart_MeanLook:
; discourage if player is already trapped
    ld a, [wEnemySubStatus5]
	bit SUBSTATUS_CANT_RUN, a
	jr nz, .discourage

; discourage if this is the players last mon
	push hl
	call AICheckLastPlayerMon
	pop hl
	jp z, AIDiscourageMove

; if we are Wobbuffet just encourage at this point
	ld a, [wEnemyMonSpecies]
	cp WOBBUFFET
	jr nz, .notWobbuffet
rept 5
	dec [hl]
endr
	ret
.notWobbuffet

; discourage if below half health
	call AICheckEnemyHalfHP
	jr nc, .discourage

; 80% chance to greatly encourage this move if the enemy is badly poisoned (buggy).
; Should check wPlayerSubStatus5 instead.
	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_TOXIC, a
	jr nz, .encourage

; 80% chance to greatly encourage this move if the player is either
; in love, identified, stuck in Rollout, or has a Nightmare.
	ld a, [wPlayerSubStatus1]
	and 1 << SUBSTATUS_IN_LOVE | 1 << SUBSTATUS_ROLLOUT | 1 << SUBSTATUS_IDENTIFIED | 1 << SUBSTATUS_NIGHTMARE
	jr nz, .encourage

; Otherwise, discourage this move unless the player only has not very effective moves against the enemy.
	push hl
	callfar CheckPlayerMoveTypeMatchups
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE + 1 ; not very effective
	pop hl
	ret nc

.discourage
	inc [hl]
	ret

.encourage
	call AI_80_20
	ret c
	dec [hl]
	dec [hl]
	dec [hl]
	ret

AICheckLastPlayerMon:
	ld a, [wPartyCount]
	ld b, a
	ld c, 0
	ld hl, wPartyMon1HP
	ld de, PARTYMON_STRUCT_LENGTH

.loop
	ld a, [wCurBattleMon]
	cp c
	jr z, .skip

	ld a, [hli]
	or [hl]
	ret nz
	dec hl

.skip
	add hl, de
	inc c
	dec b
	jr nz, .loop

	ret

AI_Smart_Nightmare:
; 50% chance to encourage this move.
; The AI_Basic layer will make sure that
; Dream Eater is only used against sleeping targets.

	call AI_50_50
	ret c
	dec [hl]
	ret

AI_Smart_FlameWheel:
; Use this move if the enemy is frozen.

	ld a, [wEnemyMonStatus]
	bit FRZ, a
	ret z
rept 5
	dec [hl]
endr
	ret

AI_Smart_BulkUp:
; don't go past +4
    ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL + 4
	jr c, .continue
    ld a, [wEnemyDefLevel]
	cp BASE_STAT_LEVEL + 4
	jr nc, .discourage

.continue
; don't use if we are at risk of being KOd, just attack them
    call ShouldAIBoost
    jr nc, .discourage

.continue2
; encourage to +2, strongly encourage if player has boosted Atk
    ld a, [wEnemyAtkLevel]
    cp BASE_STAT_LEVEL + 2
    jr nc, .checkToxic ;
	ld a, [wPlayerAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr nc, .greatly_encourage
	jr .encourage

; discourage after +1 if afflicted with toxic
.checkToxic
    ld a, BATTLE_VARS_SUBSTATUS5
	call GetBattleVar
	bit SUBSTATUS_TOXIC, a
    jr nz, .discourage

; discourage after +1 if player has boosted special attack
    ld a, [wPlayerSAtkLevel]
	cp BASE_STAT_LEVEL + 1
	jr nc, .discourage
    ret

.approve
	dec [hl]
	dec [hl]
.greatly_encourage
	dec [hl]
.encourage
	dec [hl]
	ret
.discourage
    inc [hl]
    inc [hl]
    inc [hl]
    inc [hl]
    ret

AI_Smart_Curse:
	ld a, [wEnemyMonType1]
	cp GHOST
	jp z, .ghost_curse
	ld a, [wEnemyMonType2]
	cp GHOST
	jp z, .ghost_curse

; don't go past +4
    ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL + 4
	jr c, .continue
    ld a, [wEnemyDefLevel]
	cp BASE_STAT_LEVEL + 4
	jr nc, .discourage

.continue
; don't use if we are at risk of being KOd, just attack them
    call ShouldAIBoost
    jr nc, .discourage

.continue2
; encourage to +2, strongly encourage if player has boosted Atk
    ld a, [wEnemyAtkLevel]
    cp BASE_STAT_LEVEL + 2
    jr nc, .checkToxic ;
	ld a, [wPlayerAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr nc, .greatly_encourage
	jr .encourage

; discourage after +1 if afflicted with toxic
.checkToxic
    ld a, BATTLE_VARS_SUBSTATUS5
	call GetBattleVar
	bit SUBSTATUS_TOXIC, a
    jr nz, .discourage

; discourage after +1 if player has boosted special attack
    ld a, [wPlayerSAtkLevel]
	cp BASE_STAT_LEVEL + 1
	jr nc, .discourage

    ret

.approve
	dec [hl]
	dec [hl]
.greatly_encourage
	dec [hl]
.encourage
	dec [hl]
	ret
.discourage
    inc [hl]
    inc [hl]
    inc [hl]
    inc [hl]
    ret

.ghost_curse
	ld a, [wPlayerSubStatus1]
	bit SUBSTATUS_CURSE, a
	jp nz, AIDiscourageMove

	push hl
	farcall FindAliveEnemyMons
	pop hl
	jr nc, .notlastmon

	push hl
	call AICheckLastPlayerMon
	pop hl
	jr nz, .approve

	jr .ghost_continue

.notlastmon
	push hl
	call AICheckLastPlayerMon
	pop hl
	jr z, .maybe_greatly_encourage

.ghost_continue
	call AICheckEnemyQuarterHP
	jp nc, .approve

	call AICheckEnemyHalfHP
	jr nc, .greatly_encourage

	call AICheckEnemyMaxHP
	ret nc

	ld a, [wPlayerTurnsTaken]
	and a
	ret nz

.maybe_greatly_encourage
	call AI_50_50
	ret c

	dec [hl]
	dec [hl]
	ret

AI_Smart_KingsShield:
; discourage if the enemy already used Protecting move
	ld a, [wEnemyProtectCount]
	and a
	jr nz, .discourage

; discourage if already in defense mode
    ld a, [wEnemyDefLevel]
    cp BASE_STAT_LEVEL + 2
    jr nc, .discourage

; if we are here we are in attack stance

; can we ko the player, if not use kings shield
    call CanAIKO
    jr nc, .massiveEncourage

; if player can't 2HKO then just attack
    call CanPlayer2HKO
    jr nc, .discourage

; here we are in attack stance, can ko the player, but player can at least 2hko us
; if the players last move was non-damaging, 50% chance to not use kings shield
    ld a, [wCurPlayerMove]
	call AIGetPlayerMove
	ld a, [wPlayerMoveStruct + MOVE_POWER]
    and a
	jr nz, .massiveEncourage

    call Random
    cp 50 percent
    jr c, .discourage

.massiveEncourage
; this must overcome encouragement from a potential ko
rept 10
	dec [hl]
endr
    ret

.discourage
    inc [hl]
    inc [hl]
    inc [hl]
    ret

AI_Smart_Protect:
; Greatly discourage this move if the enemy already used Protect.
	ld a, [wEnemyProtectCount]
	and a
	jr nz, .greatly_discourage

; Discourage this move if the player is locked on.
	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_LOCK_ON, a
	jr nz, .discourage

; Encourage this move if the player's Fury Cutter is boosted enough.
;	ld a, [wPlayerFuryCutterCount]
;	cp 3
;	jr nc, .encourage

; Encourage this move if the player has charged a two-turn move.
	ld a, [wPlayerSubStatus3]
	bit SUBSTATUS_CHARGED, a
	jr nz, .encourage

; Encourage this move if the player is affected by Toxic, Leech Seed, or Curse.
	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_TOXIC, a
	jr nz, .encourage
	ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_LEECH_SEED, a
	jr nz, .encourage
	ld a, [wPlayerSubStatus1]
	bit SUBSTATUS_CURSE, a
	jr nz, .encourage

; Discourage this move if the player's Rollout count is not boosted enough.
	bit SUBSTATUS_ROLLOUT, a
	jr z, .discourage
	ld a, [wPlayerRolloutCount]
	cp 3
	jr c, .discourage

; 80% chance to encourage this move otherwise.
.encourage
	call AI_80_20
	ret c

	dec [hl]
	ret

.greatly_discourage
	inc [hl]

.discourage
	call Random
	cp 8 percent
	ret c

	inc [hl]
	inc [hl]
	ret

AI_Smart_Foresight:
; 60% chance to encourage this move if the enemy's accuracy is sharply lowered.
	ld a, [wEnemyAccLevel]
	cp BASE_STAT_LEVEL - 2
	jr c, .encourage

; 60% chance to encourage this move if the player's evasion is sharply raised.
	ld a, [wPlayerEvaLevel]
	cp BASE_STAT_LEVEL + 3
	jr nc, .encourage

; 60% chance to encourage this move if the player is a Ghost type.
	ld a, [wBattleMonType1]
	cp GHOST
	jr z, .encourage
	ld a, [wBattleMonType2]
	cp GHOST
	jr z, .encourage

; 92% chance to discourage this move otherwise.
	call Random
	cp 8 percent
	ret c

	inc [hl]
	ret

.encourage
	call Random
	cp 39 percent + 1
	ret c

	dec [hl]
	dec [hl]
	ret

AI_Smart_PerishSong:
	push hl
	callfar FindAliveEnemyMons
	pop hl
	jr c, .no ; if this is the last enemy mon dont use

	ld a, [wPlayerSubStatus5]
	bit SUBSTATUS_CANT_RUN, a
	jr nz, .yes ; if player is trapped then 50% chance to encourage

	push hl
	callfar CheckPlayerMoveTypeMatchups
	ld a, [wEnemyAISwitchScore]
	cp BASE_AI_SWITCH_SCORE ; scores >= base NVE or neutral
	pop hl
	ret c ; don't do anything if the player has no shown any SE moves

	call AI_50_50 ; otherwise 50% chance to discourage
	ret c

	inc [hl]
	ret

.yes
	call AI_50_50
	ret c

	dec [hl]
	ret

.no
	ld a, [hl]
	add 5
	ld [hl], a
	ret

AI_Smart_Sandstorm:
; encourage if AI benefits from ability
    ld a, [wEnemyMonSpecies]
    cp EXCADRILL
    jr z, .encourage
    cp GARCHOMP
    jr z, .encourage
    cp GLISCOR
    jr z, .encourage

; discourage if we will be koed
    call ShouldAIBoost
    jr nc, .discourage

; Greatly discourage this move if the player is immune to Sandstorm damage.
	ld a, [wBattleMonType1]
	push hl
	ld hl, .SandstormImmuneTypes
	ld de, 1
	call IsInArray
	pop hl
	jr c, .greatly_discourage

	ld a, [wBattleMonType2]
	push hl
	ld hl, .SandstormImmuneTypes
	ld de, 1
	call IsInArray
	pop hl
	jr c, .greatly_discourage

; Discourage this move if player's HP is below 50%.
	call AICheckPlayerHalfHP
	jr nc, .discourage

; 50% chance to encourage this move otherwise.
	call AI_50_50
	ret c

	dec [hl]
	ret

.greatly_discourage
	inc [hl]
.discourage
	inc [hl]
	ret
.encourage
    dec [hl]
    dec [hl]
    dec [hl]
    ret

.SandstormImmuneTypes:
	db ROCK
	db GROUND
	db STEEL
	db -1 ; end

AI_Smart_Endure:
; Greatly discourage this move if the enemy already used Protect.
	ld a, [wEnemyProtectCount]
	and a
	jr nz, .greatly_discourage

; Greatly discourage this move if the enemy's HP is full.
	call AICheckEnemyMaxHP
	jr c, .greatly_discourage

; Discourage this move if the enemy's HP is at least 25%.
	call AICheckEnemyQuarterHP
	jr c, .discourage

; If the enemy has Reversal...
	ld b, EFFECT_REVERSAL
	call AIHasMoveEffect
	jr nc, .no_reversal

; ...80% chance to greatly encourage this move.
	call AI_80_20
	ret c

	dec [hl]
	dec [hl]
	dec [hl]
	ret

.no_reversal
; If the enemy is not locked on, do nothing.
	ld a, [wEnemySubStatus5]
	bit SUBSTATUS_LOCK_ON, a
	ret z

; 50% chance to greatly encourage this move.
	call AI_50_50
	ret c

	dec [hl]
	dec [hl]
	ret

.greatly_discourage
	inc [hl]
.discourage
	inc [hl]
	ret

AI_Smart_FuryCutter:
; Encourage this move based on Fury Cutter's count.

	ld a, [wEnemyFuryCutterCount]
	and a
	jr z, AI_Smart_Rollout
	dec [hl]

	cp 2
	jr c, AI_Smart_Rollout
	dec [hl]
	dec [hl]

	cp 3
	jr c, AI_Smart_Rollout
	dec [hl]
	dec [hl]
	dec [hl]

	; fallthrough

AI_Smart_Rollout:
; Rollout, Fury Cutter

; 80% chance to discourage this move if the enemy is in love, confused, or paralyzed.
	ld a, [wEnemySubStatus1]
	bit SUBSTATUS_IN_LOVE, a
	jr nz, .maybe_discourage

	ld a, [wEnemySubStatus3]
	bit SUBSTATUS_CONFUSED, a
	jr nz, .maybe_discourage

	ld a, [wEnemyMonStatus]
	bit PAR, a
	jr nz, .maybe_discourage

; 80% chance to discourage this move if the enemy's HP is below 25%,
; or if accuracy or evasion modifiers favour the player.
	call AICheckEnemyQuarterHP
	jr nc, .maybe_discourage

	ld a, [wEnemyAccLevel]
	cp BASE_STAT_LEVEL
	jr c, .maybe_discourage
	ld a, [wPlayerEvaLevel]
	cp BASE_STAT_LEVEL + 1
	jr nc, .maybe_discourage

; 80% chance to greatly encourage this move otherwise.
	call Random
	cp 79 percent - 1
	ret nc
	dec [hl]
	dec [hl]
	ret

.maybe_discourage
	call AI_80_20
	ret c
	inc [hl]
	ret

AI_Smart_Attract:
; 80% chance to encourage this move during the first turn of player's Pokemon.
; 80% chance to discourage this move otherwise.

	ld a, [wPlayerTurnsTaken]
	and a
	jr z, .first_turn

	call AI_80_20
	ret c
	inc [hl]
	ret

.first_turn
	call Random
	cp 79 percent - 1
	ret nc
	dec [hl]
	ret

AI_Smart_Safeguard:
; 80% chance to discourage this move if player's HP is below 50%.

	call AICheckPlayerHalfHP
	ret c
	call AI_80_20
	ret c
	inc [hl]
	ret

AI_Smart_Magnitude:
AI_Smart_Earthquake:
; Greatly encourage this move if the player is underground and the enemy is faster.
	ld a, [wLastPlayerCounterMove]
	cp DIG
	ret nz

	ld a, [wPlayerSubStatus3]
	bit SUBSTATUS_UNDERGROUND, a
	jr z, .could_dig

	call AICompareSpeed
	ret nc
	dec [hl]
	dec [hl]
	ret

.could_dig
	; Try to predict if the player will use Dig this turn.

	; 50% chance to encourage this move if the enemy is slower than the player.
	call AICompareSpeed
	ret c

	call AI_50_50
	ret c

	dec [hl]
	ret

AI_Smart_BatonPass:
; Discourage this move if the player hasn't shown super-effective moves against the enemy.
; Consider player's type(s) if its moves are unknown.
; AndrewNote - WTF, why would you do this, baton pass is not to escape an enemy!!

; discourage if we don't have any other mons to pass to
	push hl
	farcall FindAliveEnemyMons
	pop hl
	jr nc, .notlastmon
	inc [hl]
	inc [hl]
	ret

.notlastmon
; encourage if we have good stat boosts to pass
    ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr nc, .encourage
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr nc, .encourage
    ld a, [wEnemySpdLevel]
	cp BASE_STAT_LEVEL + 2
	jr nc, .encourage
	jr .continue
.encourage
	dec [hl]
	dec [hl]
.continue
; I hard code the recipient to be the second mon
; this allows for a dedicated baton pass strategy
; except for in the battle tower - normal switch logic here is fine
    ld a, [wInBattleTowerBattle]
	and a
	jr z, .notBattleTower
    xor a
    ld [wEnemySwitchMonIndex], a
    ret

.notBattleTower
    ld a, 2
    ld [wEnemySwitchMonIndex], a
    ret

	;push hl
	;callfar CheckPlayerMoveTypeMatchups
	;ld a, [wEnemyAISwitchScore]
	;cp BASE_AI_SWITCH_SCORE
	;pop hlc
	;ret c
	;inc [hl]
	;ret

AI_Smart_Pursuit:
; 50% chance to greatly encourage this move if player's HP is below 25%.
; 80% chance to discourage this move otherwise.

	call AICheckPlayerQuarterHP
	jr nc, .encourage
	call AI_80_20
	ret c
	inc [hl]
	ret

.encourage
	call AI_50_50
	ret c
	dec [hl]
	dec [hl]
	ret

AI_Smart_RapidSpin:
; 80% chance to greatly encourage this move if the enemy is
; trapped (Bind effect), seeded, or scattered with spikes.

	ld a, [wEnemyWrapCount]
	and a
	jr nz, .encourage

	ld a, [wEnemySubStatus4]
	bit SUBSTATUS_LEECH_SEED, a
	jr nz, .encourage

	ld a, [wEnemyScreens]
	bit SCREENS_SPIKES, a
	ret z

.encourage
	call AI_80_20
	ret c

	dec [hl]
	dec [hl]
	ret

AI_Smart_HiddenPower:
	push hl
	ld a, 1
	ldh [hBattleTurn], a

; Calculate Hidden Power's type and base power based on enemy's DVs.
	callfar HiddenPowerDamage
	callfar BattleCheckTypeMatchup
	pop hl

; Discourage Hidden Power if not very effective.
	ld a, [wTypeMatchup]
	cp EFFECTIVE
	jr c, .bad

; Discourage Hidden Power if its base power	is lower than 50.
	ld a, d
	cp 50
	jr c, .bad

; Encourage Hidden Power if super-effective.
	ld a, [wTypeMatchup]
	cp EFFECTIVE + 1
	jr nc, .good

; Encourage Hidden Power if its base power is 70.
	ld a, d
	cp 70
	ret c

.good
	dec [hl]
	ret

.bad
	inc [hl]
	ret

AI_Smart_RainDance:
; encourage the move if AI is a swift swim mon
    ld a, [wEnemyMonSpecies]
    cp KINGDRA
    jr z, .encourage
    cp GOLDUCK
    jr z, .encourage
    cp POLIWRATH
    jr z, .encourage
; discourage if we will be koed
    call ShouldAIBoost
    jr nc, .discourage
; Greatly discourage this move if it would favour the player type-wise.
; Particularly, if the player is a Water-type.
	ld a, [wBattleMonType1]
	cp WATER
	jr z, AIBadWeatherType
	cp FIRE
	jr z, AIGoodWeatherType

	ld a, [wBattleMonType2]
	cp WATER
	jr z, AIBadWeatherType
	cp FIRE
	jr z, AIGoodWeatherType

	push hl
	ld hl, RainDanceMoves
	jr AI_Smart_WeatherMove
.encourage
    dec [hl]
    dec [hl]
    dec [hl]
    ret
.discourage
    inc [hl]
    inc [hl]
    inc [hl]
    ret

INCLUDE "data/battle/ai/rain_dance_moves.asm"

AI_Smart_SunnyDay:
; encourage if AI is a Chlorophyll mon
    ld a, [wEnemyMonSpecies]
    cp VENUSAUR
    jr z, .encourage
    cp VICTREEBEL
    jr z, .encourage
    cp EXEGGUTOR
    jr z, .encourage
; discourage if we will be koed
    call ShouldAIBoost
    jr nc, .discourage
; Greatly discourage this move if it would favour the player type-wise.
; Particularly, if the player is a Fire-type.
	ld a, [wBattleMonType1]
	cp FIRE
	jr z, AIBadWeatherType
	cp WATER
	jr z, AIGoodWeatherType

	ld a, [wBattleMonType2]
	cp FIRE
	jr z, AIBadWeatherType
	cp WATER
	jr z, AIGoodWeatherType

	push hl
	ld hl, SunnyDayMoves
	jp AI_Smart_WeatherMove
.encourage
    dec [hl]
    dec [hl]
    dec [hl]
    ret
.discourage
    inc [hl]
    inc [hl]
    inc [hl]
    ret

AI_Smart_WeatherMove:
; Rain Dance, Sunny Day

; Greatly discourage this move if the enemy doesn't have
; one of the useful Rain Dance or Sunny Day moves.
	call AIHasMoveInArray
	pop hl
	jr nc, AIBadWeatherType

; Greatly discourage this move if player's HP is below 50%.
	call AICheckPlayerHalfHP
	jr nc, AIBadWeatherType

; 50% chance to encourage this move otherwise.
	call AI_50_50
	ret c

	dec [hl]
	ret

AIBadWeatherType:
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AIGoodWeatherType:
; Rain Dance, Sunny Day

; Greatly encourage this move if it would disfavour the player type-wise and player's HP is above 50%...
	call AICheckPlayerHalfHP
	ret nc

; ...as long as one of the following conditions meet:
; It's the first turn of the player's Pokemon.
	ld a, [wPlayerTurnsTaken]
	and a
	jr z, .good

; Or it's the first turn of the enemy's Pokemon.
	ld a, [wEnemyTurnsTaken]
	and a
	ret nz

.good
	dec [hl]
	dec [hl]
	ret

INCLUDE "data/battle/ai/sunny_day_moves.asm"

AI_Smart_BellyDrum:
; Dismiss this move if enemy's attack is higher than +2 or if enemy's HP is below 50%.
; Else, discourage this move if enemy's HP is not full.

	ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL + 3
	jr nc, .discourage

	call AICheckEnemyMaxHP
	ret c

	inc [hl]

	call AICheckEnemyHalfHP
	ret c

.discourage
	ld a, [hl]
	add 5
	ld [hl], a
	ret

AI_Smart_PsychUp:
	push hl
	ld hl, wEnemyAtkLevel
	ld b, NUM_LEVEL_STATS
	ld c, 100

; Calculate the sum of all enemy's stat level modifiers. Add 100 first to prevent underflow.
; Put the result in c. c will range between 58 and 142.
.enemy_loop
	ld a, [hli]
	sub BASE_STAT_LEVEL
	add c
	ld c, a
	dec b
	jr nz, .enemy_loop

; Calculate the sum of all player's stat level modifiers. Add 100 first to prevent underflow.
; Put the result in d. d will range between 58 and 142.
	ld hl, wPlayerAtkLevel
	ld b, NUM_LEVEL_STATS
	ld d, 100

.player_loop
	ld a, [hli]
	sub BASE_STAT_LEVEL
	add d
	ld d, a
	dec b
	jr nz, .player_loop

; Greatly discourage this move if enemy's stat levels are higher than player's (if c>=d).
	ld a, c
	sub d
	pop hl
	jr nc, .discourage

; Else, 80% chance to encourage this move unless player's accuracy level is lower than -1...
	ld a, [wPlayerAccLevel]
	cp BASE_STAT_LEVEL - 1
	ret c

; ...or enemy's evasion level is higher than +0.
	ld a, [wEnemyEvaLevel]
	cp BASE_STAT_LEVEL + 1
	ret nc

	call AI_80_20
	ret c

	dec [hl]
	ret

.discourage
	inc [hl]
	inc [hl]
	ret

AI_Smart_MirrorCoat:
;	push hl
;	ld hl, wPlayerUsedMoves
;	ld c, NUM_MOVES
;	ld b, 0

;.playermoveloop
;	ld a, [hli]
;	and a
;	jr z, .skipmove

;	call AIGetEnemyMove

;	ld a, [wEnemyMoveStruct + MOVE_POWER]
;	and a
;	jr z, .skipmove

;	ld a, [wEnemyMoveStruct + MOVE_TYPE]
;	cp SPECIAL
;	jr c, .skipmove

;	inc b

;.skipmove
;	dec c
;	jr nz, .playermoveloop

;	pop hl
;	ld a, b
;	and a
;	jr z, .discourage

;	cp 3
;	jr nc, .encourage

	ld a, [wLastPlayerCounterMove]
	;and a
	;jr z, .done

	call AIGetEnemyMove

	;ld a, [wEnemyMoveStruct + MOVE_POWER]
	;and a
	;jr z, .done

	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	cp SPECIAL
	jr c, .done

.encourage
	dec [hl]
	dec [hl]
	dec [hl]
	dec [hl]
.done
	ret

AI_Smart_Twister:
AI_Smart_Gust:
; Greatly encourage this move if the player is flying and the enemy is faster.
	ld a, [wLastPlayerCounterMove]
	cp FLY
	ret nz
	cp SKY_CLEAVE
	ret nz

	ld a, [wPlayerSubStatus3]
	bit SUBSTATUS_FLYING, a
	jr z, .couldFly

	call AICompareSpeed
	ret nc

	dec [hl]
	dec [hl]
	ret

; Try to predict if the player will use Fly this turn.
.couldFly

; 50% chance to encourage this move if the enemy is slower than the player.
	call AICompareSpeed
	ret c
	call AI_50_50
	ret c
	dec [hl]
	ret

AI_Smart_FutureSight:
; Greatly encourage this move if the player is
; flying or underground, and slower than the enemy.

	call AICompareSpeed
	ret nc

	ld a, [wPlayerSubStatus3]
	and 1 << SUBSTATUS_FLYING | 1 << SUBSTATUS_UNDERGROUND
	ret z

	dec [hl]
	dec [hl]
	ret

AI_Smart_Stomp:
; 80% chance to encourage this move if the player has used Minimize.

	ld a, [wPlayerMinimized]
	and a
	ret z

	call AI_80_20
	ret c

	dec [hl]
	ret

AI_Smart_Solarbeam:
; 80% chance to encourage this move when it's sunny.
; 90% chance to discourage this move when it's raining.

	ld a, [wBattleWeather]
	cp WEATHER_SUN
	jr z, .encourage

	cp WEATHER_RAIN
	ret nz

	call Random
	cp 10 percent
	ret c

	inc [hl]
	inc [hl]
	ret

.encourage
	call AI_80_20
	ret c

	dec [hl]
	dec [hl]
	ret

AI_Smart_Thunder:
; 90% chance to discourage this move when it's sunny.

	ld a, [wBattleWeather]
	cp WEATHER_SUN
	ret nz

	call Random
	cp 10 percent
	ret c

	inc [hl]
	ret

AI_Smart_HolyArmour:
; don't go past +4
    ld a, [wEnemySDefLevel]
	cp BASE_STAT_LEVEL + 4
	jr nc, .discourage

; strongly encourage to +2
    ld a, [wEnemyDefLevel]
	cp BASE_STAT_LEVEL + 2
	jr c, .strongEncourage
    ld a, [wEnemySDefLevel]
	cp BASE_STAT_LEVEL + 2
	jr c, .strongEncourage

; strongly encourage if player has boosted offenses
	ld a, [wPlayerSAtkLevel]
	cp BASE_STAT_LEVEL + 1
	jr nc, .strongEncourage
	ld a, [wPlayerAtkLevel]
	cp BASE_STAT_LEVEL + 1
	jr nc, .strongEncourage

; otherwise encourage to +4
    ld a, [wEnemySDefLevel]
	cp BASE_STAT_LEVEL + 4
	jr c, .encourage

.strongEncourage
    dec [hl]
    dec [hl]
.encourage
	dec [hl]
	ret
.discourage
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_Serenity:
; don't go past +4
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 4
	jr nc, .discourage

; strongly encourage if player has boosted SpAtk
	ld a, [wPlayerSAtkLevel]
	cp BASE_STAT_LEVEL + 1
	jr nc, .strongEncourage

; encourage to +2
    ld a, [wEnemySAtkLevel]
    cp BASE_STAT_LEVEL + 2
    jr c, .encourage
	ld a, [wEnemySDefLevel]
    cp BASE_STAT_LEVEL + 2
    jr c, .encourage

; discourage after +2 if afflicted with toxic
    ld a, BATTLE_VARS_SUBSTATUS5
	call GetBattleVar
	bit SUBSTATUS_TOXIC, a
    jr nz, .discourage
    ret

.strongEncourage
    dec [hl]
.encourage
    dec [hl]
	dec [hl]
	ret
.discourage
    inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_QuiverDance:
; don't go past +4
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 4
	jr c, .continue
    ld a, [wEnemySDefLevel]
	cp BASE_STAT_LEVEL + 4
	jp nc, .discourage

.continue
; don't use if we are at risk of being KOd by boosted player, just attack them
; only care about being OHKOd as qd increases speed
    call DoesEnemyHaveIntactFocusSashOrSturdy
    jr c, .skip

; if the player has not picked a damaging move then boost if we cant 3hko
    ld a, [wCurPlayerMove]
	call AIGetPlayerMove
	ld a, [wPlayerMoveStruct + MOVE_POWER]
    and a
	jr nz, .checkKO
	call CanAI2HKO
	jr nc, .skip

.checkKO
    call CanPlayerKO
    jr c, .discourage

.skip
; encourage to +2, strongly encourage if player has boosted SpAtk
    ld a, [wEnemySAtkLevel]
    cp BASE_STAT_LEVEL + 2
    jr nc, .checkToxic ;
	ld a, [wPlayerSAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr nc, .strongEncourage
	jr .encourage

; discourage after +1 if afflicted with toxic
.checkToxic
; Pokemon who are immune to residual damage (magic guard) should not be considered
    ld a, [wEnemyMonSpecies]
    push hl
    push de
   	push bc
   	ld hl, AI_MagicGuardPokemon
   	ld de, 1
   	call IsInArray
   	pop bc
   	pop de
   	pop hl
   	ret c

    ld a, [wEnemySubStatus5]
	bit SUBSTATUS_TOXIC, a
    jr nz, .discourage
    ret

.strongEncourage
    dec [hl]
.encourage
    dec [hl]
	dec [hl]
	ret
.discourage
    inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_CalmMind:
; don't go past +4
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 4
	jr c, .continue
    ld a, [wEnemySDefLevel]
	cp BASE_STAT_LEVEL + 4
	jp nc, .discourage

; don't use if we are at risk of being KOd, just attack them
.continue
    call ShouldAIBoost
    jr nc, .discourage

; encourage to +2, strongly encourage if player has boosted SpAtk
    ld a, [wEnemySAtkLevel]
    cp BASE_STAT_LEVEL + 2
    jr nc, .checkToxic ;
	ld a, [wPlayerSAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr nc, .strongEncourage
	jr .encourage

; discourage after +2 if afflicted with toxic
.checkToxic
; Pokemon who are immune to residual damage (magic guard) should not be considered
    ld a, [wEnemyMonSpecies]
    push hl
    push de
   	push bc
   	ld hl, AI_MagicGuardPokemon
   	ld de, 1
   	call IsInArray
   	pop bc
   	pop de
   	pop hl
   	ret c

    ld a, [wEnemySubStatus5]
	bit SUBSTATUS_TOXIC, a
    jr nz, .discourage
    ret

.strongEncourage
    dec [hl]
.encourage
    dec [hl]
	dec [hl]
	ret
.discourage
    inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_DragonDance:
; don't go past +4
	ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL + 4
	jr nc, .discourage

; don't use if we are at risk of being KOd, just attack them
; only care about being OHKOd as dd increases speed
; unless we have an intact sash or sturdy, then can boost
    call DoesEnemyHaveIntactFocusSashOrSturdy
    jr c, .continue

; if the player has not picked a damaging move then boost if we can't 3HKO already
    ld a, [wCurPlayerMove]
	call AIGetPlayerMove
	ld a, [wPlayerMoveStruct + MOVE_POWER]
    and a
	jr nz, .checkKO
	call CanAI2HKO
	jr nc, .continue

.checkKO
    call CanPlayerKO
    jr c, .discourage

.continue
; discourage if enemy is paralyzed
    ld a, [wEnemyMonStatus]
	and 1 << PAR
	jr nz, .discourage

; encourage to get to +2
	ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr c, .encourage

; discourage after +1 if afflicted with toxic
; Pokemon who are immune to residual damage (magic guard) should not be considered
    ld a, [wEnemyMonSpecies]
    push hl
    push de
	push bc
	ld hl, AI_MagicGuardPokemon
	ld de, 1
	call IsInArray
	pop bc
	pop de
	pop hl
	ret c

    ld a, [wEnemySubStatus5]
	bit SUBSTATUS_TOXIC, a
    jr nz, .discourage
    ret

.encourage
	dec [hl]
	dec [hl]
	ret
.discourage
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_SwordsDance:
; don't go past +4
	ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL + 4
	jr nc, .discourage

; don't use if we are at risk of being KOd, just attack them
    call ShouldAIBoost
    jr nc, .discourage

; encourage to get to +2
	ld a, [wEnemyAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr c, .encourage

; discourage after +1 if afflicted with toxic
; Pokemon who are immune to residual damage (magic guard) should not be considered
    ld a, [wEnemyMonSpecies]
    push hl
    push de
	push bc
	ld hl, AI_MagicGuardPokemon
	ld de, 1
	call IsInArray
	pop bc
	pop de
	pop hl
	ret c

    ld a, [wEnemySubStatus5]
	bit SUBSTATUS_TOXIC, a
    jr nz, .discourage
    ret

.encourage
	dec [hl]
	dec [hl]
	ret
.discourage
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_Barrier:
; don't go past +4
    ld a, [wEnemyDefLevel]
	cp BASE_STAT_LEVEL + 4
	jr nc, .discourage

; discourage if player has boosted SpAtk
	ld a, [wPlayerSAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr nc, .discourage

; discourage if afflicted with toxic
    ld a, BATTLE_VARS_SUBSTATUS5
	call GetBattleVar
	bit SUBSTATUS_TOXIC, a
    jr nz, .discourage

; strongly encourage if player has boosted attack
	ld a, [wPlayerAtkLevel]
	cp BASE_STAT_LEVEL + 1
	jr nc, .strongEncourage

; strongly encourage to +2 if player mon has higher attack than special attack
; otherwise discourage
    ld a, [wEnemyDefLevel]
	cp BASE_STAT_LEVEL + 2
	ret nc
	push hl
	push bc
	push de
; Get the pointer for the player's Pokémon's base Attack
	ld a, [wBattleMonSpecies]
	ld hl, BaseData + BASE_ATK
	ld bc, BASE_DATA_SIZE
	call AddNTimes
; Get the Pokémon's base Attack
	ld a, BANK(BaseData)
	call GetFarByte
	ld d, a
; Get the pointer for the player's Pokémon's base Special Attack
	ld bc, BASE_SAT - BASE_ATK
	add hl, bc
; Get the Pokémon's base Special Attack
	ld a, BANK(BaseData)
	call GetFarByte
	pop de
	pop bc
	pop hl
; If its base Attack is not greater than its base Special Attack, discourage.
	cp d
	jr nc, .discourage

.strongEncourage
    dec [hl]
    dec [hl]
.encourage
	dec [hl]
	ret
.discourage
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_Geomancy:
; don't go past +4
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 4
	jp nc, .discourage

; don't use if we are at risk of being KOd, just attack them
; as a two turn move we care about being 2HKOd
    call CanPlayer2HKO
    jr c, .discourage

; encourage to get to +2
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr c, .encourage

; discourage after +2 if afflicted with toxic
    ld a, BATTLE_VARS_SUBSTATUS5
	call GetBattleVar
	bit SUBSTATUS_TOXIC, a
    jr nz, .discourage
    ret

.encourage
    dec [hl]
	dec [hl]
	ret
.discourage
    inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_Growth:
; don't go past +4
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 4
	jp nc, .discourage

; don't use if we are at risk of being KOd, just attack them
    call ShouldAIBoost
    jr nc, .discourage

; encourage to get to +1
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 1
	jr c, .encourage

; discourage after +1 if afflicted with toxic
    ld a, BATTLE_VARS_SUBSTATUS5
	call GetBattleVar
	bit SUBSTATUS_TOXIC, a
    jr nz, .discourage
    ret

.encourage
    dec [hl]
	dec [hl]
	ret
.discourage
    inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_NastyPlot:
; don't go past +4
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 4
	jp nc, .discourage

; Deoxys should not use Nasty Plot against dark types
    ld a, [wEnemyMonSpecies]
    cp DEOXYS
    jr nz, .notDeoxys
    ld a, [wBattleMonType1]
    cp DARK
    jr z, .discourage
    ld a, [wBattleMonType2]
    cp DARK
    jr z, .discourage

.notDeoxys
; don't use if we are at risk of being KOd, just attack them
    call ShouldAIBoost
    jr nc, .discourage

; encourage to get to +2
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr c, .encourage

; discourage after +2 if afflicted with toxic
; Pokemon who are immune to residual damage (magic guard) should not be considered
    ld a, [wEnemyMonSpecies]
    push hl
    push de
	push bc
	ld hl, AI_MagicGuardPokemon
	ld de, 1
	call IsInArray
	pop bc
	pop de
	pop hl
	ret c

    ld a, [wEnemySubStatus5]
	bit SUBSTATUS_TOXIC, a
    jr nz, .discourage
    ret

.encourage
    dec [hl]
	dec [hl]
	ret
.discourage
    inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_DynamicPunch:
; encourage dynamic punch for machamp
    ld a, [wEnemyMonSpecies]
    cp MACHAMP
    ret nz

; never use against ghost types
    ld a, [wBattleMonType1]
	cp GHOST
	ret z
	ld a, [wBattleMonType2]
	cp GHOST
	ret z

; don't encourage if already confused
	ld a, [wPlayerSubStatus3]
	bit SUBSTATUS_CONFUSED, a
	ret nz

    dec [hl]
    dec [hl]
    ret

AI_Smart_ShellSmash:
; don't go past +4
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 4
	jp nc, .discourage

; Smeargle should use once and not again
    ld a, [wEnemyMonSpecies]
    cp SMEARGLE
    jr nz, .notSmeargle
    ld a, [wEnemySAtkLevel]
    cp BASE_STAT_LEVEL + 2
    jr c, .encourage
    jr .discourage

.notSmeargle
; is the player behind a sub, then don't use
    ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_SUBSTITUTE, a	;check for substitute bit
	jr nz, .discourage

; encourage to get to +2
    ld a, [wEnemySAtkLevel]
	cp BASE_STAT_LEVEL + 2
	jr c, .encourage

; discourage after +2 if not at max hp
    call AICheckEnemyMaxHP
    jr nc, .discourage
    ret

.encourage
; this needs to be enough to overcome encouragement from having a move that can KO
    dec [hl]
	dec [hl]
    dec [hl]
	dec [hl]
    dec [hl]
	dec [hl]
    dec [hl]
	dec [hl]
	ret
.discourage
    inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ret

AI_Smart_Flinch:
; do nothing if slower than player
    call AICompareSpeed
    ret nc

; encourage if enemy is paralyzed
    ld a, [wBattleMonStatus]
	and 1 << PAR
	jr nz, .smallEncourage

; encourage if we have serene grace
    ld a, [wEnemyMonSpecies]
    cp SHAYMIN
    jr z, .encourage
    cp TOGEKISS
    jr z, .encourage

    ret
.encourage
    dec [hl]
.smallEncourage
    dec [hl]
    ret

AI_Smart_Confuse:
AI_Smart_Swagger:
; never use if player has substitute
    ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_SUBSTITUTE, a
	jr nz, .discourage

; never use if player has safeguard
	ld a, [wPlayerScreens]
	bit SCREENS_SAFEGUARD, a
	jr nz, .discourage

; don't use against Arceus since it is immune to status
    ld a, [wBattleMonSpecies]
    cp ARCEUS
    jr nz, .continue
    cp SYLVEON
    jr nz, .continue
    inc [hl]
    inc [hl]
    ret

.continue
; discourage if already confused
	ld a, [wPlayerSubStatus3]
	bit SUBSTATUS_CONFUSED, a
	jr nz, .discourage

; encourage if enemy is paralyzed
    ld a, [wBattleMonStatus]
	and 1 << PAR
	ret z

	dec [hl]
	dec [hl]
    ret
.discourage
    inc [hl]
    inc [hl]
    ret

AI_Smart_LesserStatChange:
    call AICheckEnemyMaxHP
    jr nc, .discourage
    call ShouldAIBoost
    jr nc, .discourage
    ret
.discourage
    inc [hl]
    inc [hl]
    inc [hl]
    ret

; AndrewNote - functions which check if the player can KO the AI

; decide if AI should use boosting moves
; don't boost if player will just KO anyway
; returns carry if the AI can boost
ShouldAIBoost:
; if evasion is >= +4 then go for the boost - only used by Patches
	ld a, [wEnemyEvaLevel]
	cp BASE_STAT_LEVEL + 2
	jr nc, .boost

; if the player has roar/whirlwind and we aren't immune to it then 50% to not boost
    ld a, [wEnemyMonSpecies]
    push hl
    push de
   	push bc
   	ld hl, AI_UberImmunePokemon
   	ld de, 1
   	call IsInArray
   	pop bc
   	pop de
   	pop hl
   	jr c, .noForceSwitch
    ld b, EFFECT_FORCE_SWITCH
	call PlayerHasMoveEffect
	jr nc, .noForceSwitch
	call Random
	cp 50 percent
	jr c, .dontBoost

.noForceSwitch
; who moves first
    call AICompareSpeed
    jr nc, .playerMovesFirst

; if AI moves first consider if player can 1HKO
; first if the AI has an intact focus sash or sturdy it can boost, unless player has priority move
    call DoesEnemyHaveIntactFocusSashOrSturdy
    jr c, .boost

    call CanPlayerKO
    jr c, .decideNotToBoost
    jr .boost

.playerMovesFirst
; if player moves first consider if they can 2HKO
    call CanPlayer2HKO
    jr c, .decideNotToBoost
    jr .boost

.decideNotToBoost
; is player SLP or FRZ, if so we can boost
	ld a, [wBattleMonStatus]
	and 1 << FRZ | SLP
	jr nz, .boost

; is the player behind a sub, if so don't boost, just attack
    ld a, [wPlayerSubStatus4]
	bit SUBSTATUS_SUBSTITUTE, a	;check for substitute bit
	jr nz, .dontBoost

; was the players last move a damaging one, if so don't boost
; if so the player may be setting up, if we are not currently able to 3HKO then boost
    ld a, [wCurPlayerMove]
	call AIGetPlayerMove
	ld a, [wPlayerMoveStruct + MOVE_POWER]
    and a
	jr nz, .dontBoost
	call CanAI2HKO
	jr c, .dontBoost

.boost
    scf
    ret
.dontBoost
    xor a ; clear carry flag
    ret

DoesEnemyHaveIntactFocusSashOrSturdy:
; does player have priority move
	ld b, EFFECT_PRIORITY_HIT
	call PlayerHasMoveEffect
	jr c, .no

; Is the AI at full HP
    call AICheckEnemyMaxHP
    jr nc, .no

; focus sash
	push hl
	push de
	ld a, [wEnemyMonItem]
	ld [wNamedObjectIndex], a
	ld b, a
	callfar GetItemHeldEffect
	ld a, b
	cp HELD_FOCUS_BAND
	pop de
	pop hl
	jr z, .yes

; sturdy
    push bc
    push hl
    push de
	ld hl, AI_SturdyPokemon
	ld de, 1
	call IsInArray
	pop de
	pop hl
	pop bc
	jr c, .yes

.no
    xor a ; clear carry flag
    ret
.yes
    scf
    ret


; return carry if the player has a move that can 1HKO the AI Pokemon from current HP
; used to decide if the AI should use setup moves
CanPlayerKO:
    ld de, wBattleMonMoves ; load player moves
	ld b, NUM_MOVES + 1
.loopPlayerKOMoves
	dec b ; b is num moves on 1st pass
	jr z, .done ; if b is 0 return we are done
	ld a, [de] ; load the move
	and a
	jr z, .done ; return if no move
	inc de ; increment to next move
	call AIGetPlayerMove
	ld a, [wPlayerMoveStruct + MOVE_POWER]
	and a
	jr z, .loopPlayerKOMoves ; skip moves with 0 power
    ld a, 0
	ldh [hBattleTurn], a
	push hl
	push de
	push bc
	callfar PlayerAttackDamage
	callfar BattleCommand_DamageCalc
	callfar BattleCommand_Stab
	ld a, [wCurDamage + 1]
	ld c, a ; c is curDamage upper
	ld a, [wCurDamage]
	ld b, a ; b is curDamage lower
	ld a, [wEnemyMonHP + 1]
	cp c ; compare upper
	ld a, [wEnemyMonHP]
    sbc b ; compare lower and set flag
	pop bc
	pop de
	pop hl
    jp nc, .loopPlayerKOMoves
; skip moves that can't be used on consecutive turns, except hyper beam
	ld a, [wPlayerMoveStruct + MOVE_EFFECT]
	cp EFFECT_SELFDESTRUCT
	jr z, .loopPlayerKOMoves
	cp EFFECT_SKY_ATTACK
	jr z, .loopPlayerKOMoves
	cp EFFECT_SOLARBEAM
	jr z, .loopPlayerKOMoves
    scf
    ret
.done
    xor a ; clear carry flag
    ret

; return carry if the player has a move that can 2HKO the AI Pokemon from current HP
; used to decide if the AI should use setup moves
CanPlayer2HKO:
    ld de, wBattleMonMoves ; load player moves
	ld b, NUM_MOVES + 1
.loopPlayer2HKOMoves
	dec b ; b is num moves on 1st pass
	jr z, .done ; if b is 0 return we are done
	ld a, [de] ; load the move
	and a
	jr z, .done ; return if no move
	inc de ; increment to next move
	call AIGetPlayerMove
	ld a, [wPlayerMoveStruct + MOVE_POWER]
	and a
	jr z, .loopPlayer2HKOMoves ; skip moves with 0 power
    ld a, 0
	ldh [hBattleTurn], a
	push hl
	push de
	push bc
	callfar PlayerAttackDamage
	callfar BattleCommand_DamageCalc
	callfar BattleCommand_Stab
; double current damage
	ld hl, wCurDamage + 1
	ld a, [hld]
	ld h, [hl]
	ld l, a
	add hl, hl
	ld a, h
	ld [wCurDamage], a
	ld a, l
	ld [wCurDamage + 1], a
; continue
	ld a, [wCurDamage + 1]
	ld c, a ; c is curDamage upper
	ld a, [wCurDamage]
	ld b, a ; b is curDamage lower
	ld a, [wEnemyMonHP + 1]
	cp c ; compare upper
	ld a, [wEnemyMonHP]
    sbc b ; compare lower and set flag
	pop bc
	pop de
	pop hl
    jp nc, .loopPlayer2HKOMoves
; skip moves that can't be used on consecutive turns
	ld a, [wPlayerMoveStruct + MOVE_EFFECT]
	cp EFFECT_SELFDESTRUCT
	jr z, .loopPlayer2HKOMoves
	cp EFFECT_HYPER_BEAM
	jr z, .loopPlayer2HKOMoves
	cp EFFECT_SKY_ATTACK
	jr z, .loopPlayer2HKOMoves
	cp EFFECT_SOLARBEAM
	jr z, .loopPlayer2HKOMoves
	scf
    ret
.done
    xor a ; clear carry flag
    ret

; return carry if the player has a move that can 2HKO the AI Pokemon from Max HP
; used to decide if the AI should use recovery moves
CanPlayer2HKOMaxHP:
    ld de, wBattleMonMoves ; load player moves
	ld b, NUM_MOVES + 1
.loopPlayer2HKOMaxHPMoves
	dec b ; b is num moves on 1st pass
	jr z, .done ; if b is 0 return we are done
	ld a, [de] ; load the move
	and a
	jr z, .done ; return if no move
	inc de ; increment to next move
	call AIGetPlayerMove
	ld a, [wPlayerMoveStruct + MOVE_POWER]
	and a
	jr z, .loopPlayer2HKOMaxHPMoves ; skip moves with 0 power
    ld a, 0
	ldh [hBattleTurn], a
	push hl
	push de
	push bc
	callfar PlayerAttackDamage
	callfar BattleCommand_DamageCalc
	callfar BattleCommand_Stab
; double current damage
	ld hl, wCurDamage + 1
	ld a, [hld]
	ld h, [hl]
	ld l, a
	add hl, hl
	ld a, h
	ld [wCurDamage], a
	ld a, l
	ld [wCurDamage + 1], a
; continue
	ld a, [wCurDamage + 1]
	ld c, a ; c is curDamage upper
	ld a, [wCurDamage]
	ld b, a ; b is curDamage lower
	ld a, [wEnemyMonMaxHP + 1]
	cp c ; compare upper
	ld a, [wEnemyMonMaxHP]
    sbc b ; compare lower and set flag
	pop bc
	pop de
	pop hl
    jp nc, .loopPlayer2HKOMaxHPMoves
; skip moves that can't be used on consecutive turns
	ld a, [wPlayerMoveStruct + MOVE_EFFECT]
	cp EFFECT_SELFDESTRUCT
	jr z, .loopPlayer2HKOMaxHPMoves
	cp EFFECT_HYPER_BEAM
	jr z, .loopPlayer2HKOMaxHPMoves
	cp EFFECT_SKY_ATTACK
	jr z, .loopPlayer2HKOMaxHPMoves
	cp EFFECT_SOLARBEAM
	jr z, .loopPlayer2HKOMaxHPMoves
    scf
    ret
.done
    xor a ; clear carry flag
    ret

; return carry if the player has a move that can 3HKO the AI Pokemon from Max HP
; used to decide if the AI should use rest
CanPlayer3HKOMaxHP:
    ld de, wBattleMonMoves ; load player moves
	ld b, NUM_MOVES + 1
.loopPlayer3HKOMaxHPMoves
	dec b ; b is num moves on 1st pass
	jr z, .done ; if b is 0 return we are done
	ld a, [de] ; load the move
	and a
	jr z, .done ; return if no move
	inc de ; increment to next move
	call AIGetPlayerMove
	ld a, [wPlayerMoveStruct + MOVE_POWER]
	and a
	jr z, .loopPlayer3HKOMaxHPMoves ; skip moves with 0 power
    ld a, 0
	ldh [hBattleTurn], a
	push hl
	push de
	push bc
	callfar PlayerAttackDamage
	callfar BattleCommand_DamageCalc
	callfar BattleCommand_Stab
; triple current damage
	ld hl, wCurDamage + 1
	ld a, [hld]
	ld h, [hl]
	ld l, a
	ld b, h
	ld c, l
	add hl, hl
	add hl, bc
	ld a, h
	ld [wCurDamage], a
	ld a, l
	ld [wCurDamage + 1], a
; continue
	ld a, [wCurDamage + 1]
	ld c, a ; c is curDamage upper
	ld a, [wCurDamage]
	ld b, a ; b is curDamage lower
	ld a, [wEnemyMonMaxHP + 1]
	cp c ; compare upper
	ld a, [wEnemyMonMaxHP]
    sbc b ; compare lower and set flag
	pop bc
	pop de
	pop hl
    jp nc, .loopPlayer3HKOMaxHPMoves
; skip moves that can't be used on consecutive turns
	ld a, [wPlayerMoveStruct + MOVE_EFFECT]
	cp EFFECT_SELFDESTRUCT
	jr z, .loopPlayer3HKOMaxHPMoves
	cp EFFECT_HYPER_BEAM
	jr z, .loopPlayer3HKOMaxHPMoves
	cp EFFECT_SKY_ATTACK
	jr z, .loopPlayer3HKOMaxHPMoves
	cp EFFECT_SOLARBEAM
	jr z, .loopPlayer3HKOMaxHPMoves
	scf
    ret
.done
    xor a ; clear carry flag
    ret

; return carry if the AI has a move that can 1HKO the player Pokemon from current HP
CanAIKO:
    ld de, wEnemyMonMoves ; load player moves
	ld b, NUM_MOVES + 1
.loopAIKOMoves
	dec b ; b is num moves on 1st pass
	jr z, .done ; if b is 0 return we are done
	ld a, [de] ; load the move
	and a
	jr z, .done ; return if no move
	inc de ; increment to next move
	call AIGetEnemyMove
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr z, .loopAIKOMoves ; skip moves with 0 power

    ld a, 1
	ldh [hBattleTurn], a
	push hl
	push de
	push bc
	callfar EnemyAttackDamage
	callfar BattleCommand_DamageCalc
	callfar BattleCommand_Stab
	ld a, [wCurDamage + 1]
	ld c, a ; c is curDamage upper
	ld a, [wCurDamage]
	ld b, a ; b is curDamage lower
	ld a, [wBattleMonHP + 1]
	cp c ; compare upper
	ld a, [wBattleMonHP]
    sbc b ; compare lower and set flag
	pop bc
	pop de
	pop hl
    jp nc, .loopAIKOMoves
; skip moves that can't be used on consecutive turns, except hyper beam
	ld a, [wPlayerMoveStruct + MOVE_EFFECT]
	cp EFFECT_SELFDESTRUCT
	jr z, .loopAIKOMoves
	cp EFFECT_SKY_ATTACK
	jr z, .loopAIKOMoves
	cp EFFECT_SOLARBEAM
	jr z, .loopAIKOMoves
    scf
    ret
.done
    xor a ; clear carry flag
    ret

; return carry if the AI has a move that can 2HKO the player Pokemon from current HP
CanAI2HKO:
    ld de, wEnemyMonMoves ; load AI moves
	ld b, NUM_MOVES + 1
.loopAI3HKOMoves
	dec b ; b is num moves on 1st pass
	jr z, .done ; if b is 0 return we are done
	ld a, [de] ; load the move
	and a
	jr z, .done ; return if no move
	inc de ; increment to next move
	call AIGetEnemyMove
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr z, .loopAI3HKOMoves ; skip moves with 0 power

    ld a, 1
	ldh [hBattleTurn], a
	push hl
	push de
	push bc
	callfar EnemyAttackDamage
	callfar BattleCommand_DamageCalc
	callfar BattleCommand_Stab
; double current damage
	ld hl, wCurDamage + 1
	ld a, [hld]
	ld h, [hl]
	ld l, a
	add hl, hl
	ld a, h
	ld [wCurDamage], a
	ld a, l
	ld [wCurDamage + 1], a
; continue
	ld a, [wCurDamage + 1]
	ld c, a ; c is curDamage upper
	ld a, [wCurDamage]
	ld b, a ; b is curDamage lower
	ld a, [wBattleMonHP + 1]
	cp c ; compare upper
	ld a, [wBattleMonHP]
    sbc b ; compare lower and set flag
	pop bc
	pop de
	pop hl
    jp nc, .loopAI3HKOMoves
; skip moves that can't be used on consecutive turns, except hyper beam
	ld a, [wPlayerMoveStruct + MOVE_EFFECT]
	cp EFFECT_SELFDESTRUCT
	jr z, .loopAI3HKOMoves
	cp EFFECT_HYPER_BEAM
	jr z, .loopAI3HKOMoves
	cp EFFECT_SKY_ATTACK
	jr z, .loopAI3HKOMoves
	cp EFFECT_SOLARBEAM
	jr z, .loopAI3HKOMoves
    scf
    ret
.done
    xor a ; clear carry flag
    ret

; return carry if the AI has a move that can 3HKO the player Pokemon from current HP
CanAI3HKO:
    ld de, wEnemyMonMoves ; load AI moves
	ld b, NUM_MOVES + 1
.loopAI3HKOMoves
	dec b ; b is num moves on 1st pass
	jr z, .done ; if b is 0 return we are done
	ld a, [de] ; load the move
	and a
	jr z, .done ; return if no move
	inc de ; increment to next move
	call AIGetEnemyMove
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jr z, .loopAI3HKOMoves ; skip moves with 0 power

    ld a, 1
	ldh [hBattleTurn], a
	push hl
	push de
	push bc
	callfar EnemyAttackDamage
	callfar BattleCommand_DamageCalc
	callfar BattleCommand_Stab
; triple current damage
	ld hl, wCurDamage + 1
	ld a, [hld]
	ld h, [hl]
	ld l, a
	ld b, h
	ld c, l
	add hl, hl
	add hl, bc
	ld a, h
	ld [wCurDamage], a
	ld a, l
	ld [wCurDamage + 1], a
; continue
	ld a, [wCurDamage + 1]
	ld c, a ; c is curDamage upper
	ld a, [wCurDamage]
	ld b, a ; b is curDamage lower
	ld a, [wBattleMonHP + 1]
	cp c ; compare upper
	ld a, [wBattleMonHP]
    sbc b ; compare lower and set flag
	pop bc
	pop de
	pop hl
    jp nc, .loopAI3HKOMoves
; skip moves that can't be used on consecutive turns, except hyper beam
	ld a, [wPlayerMoveStruct + MOVE_EFFECT]
	cp EFFECT_SELFDESTRUCT
	jr z, .loopAI3HKOMoves
	cp EFFECT_HYPER_BEAM
	jr z, .loopAI3HKOMoves
	cp EFFECT_SKY_ATTACK
	jr z, .loopAI3HKOMoves
	cp EFFECT_SOLARBEAM
	jr z, .loopAI3HKOMoves
    scf
    ret
.done
    xor a ; clear carry flag
    ret

AICompareSpeed:
; Return carry if enemy is faster than player.
	push bc
	ld a, [wEnemyMonSpeed + 1]
	ld b, a
	ld a, [wBattleMonSpeed + 1]
	cp b
	ld a, [wEnemyMonSpeed]
	ld b, a
	ld a, [wBattleMonSpeed]
	sbc b
	pop bc
	ret

AICheckPlayerMaxHP:
	push hl
	push de
	push bc
	ld de, wBattleMonHP
	ld hl, wBattleMonMaxHP
	jr AICheckMaxHP

AICheckEnemyMaxHP:
	push hl
	push de
	push bc
	ld de, wEnemyMonHP
	ld hl, wEnemyMonMaxHP
	; fallthrough

AICheckMaxHP:
; Return carry if hp at de matches max hp at hl.

	ld a, [de]
	inc de
	cp [hl]
	jr nz, .not_max

	inc hl
	ld a, [de]
	cp [hl]
	jr nz, .not_max

	pop bc
	pop de
	pop hl
	scf
	ret

.not_max
	pop bc
	pop de
	pop hl
	and a
	ret

AICheckPlayerHalfHP:
	push hl
	ld hl, wBattleMonHP
	ld b, [hl]
	inc hl
	ld c, [hl]
	sla c
	rl b
	inc hl
	inc hl
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
	pop hl
	ret

AICheckEnemyHalfHP:
	push hl
	push de
	push bc
	ld hl, wEnemyMonHP
	ld b, [hl]
	inc hl
	ld c, [hl]
	sla c
	rl b
	inc hl
	inc hl
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
	pop bc
	pop de
	pop hl
	ret

AICheckEnemyQuarterHP:
	push hl
	push de
	push bc
	ld hl, wEnemyMonHP
	ld b, [hl]
	inc hl
	ld c, [hl]
	sla c
	rl b
	sla c
	rl b
	inc hl
	inc hl
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
	pop bc
	pop de
	pop hl
	ret

AICheckPlayerQuarterHP:
	push hl
	ld hl, wBattleMonHP
	ld b, [hl]
	inc hl
	ld c, [hl]
	sla c
	rl b
	sla c
	rl b
	inc hl
	inc hl
	ld a, [hld]
	cp c
	ld a, [hl]
	sbc b
	pop hl
	ret

AIHasMoveEffect:
; Return carry if the enemy has move b.

	push hl
	ld hl, wEnemyMonMoves
	ld c, NUM_MOVES

.checkmove
	ld a, [hli]
	and a
	jr z, .no

	call AIGetEnemyMove

	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	cp b
	jr z, .yes

	dec c
	jr nz, .checkmove

.no
	pop hl
	and a
	ret

.yes
	pop hl
	scf
	ret

PlayerHasMoveEffect:
; Return carry if the player has move b.

	push hl
	ld hl, wBattleMonMoves
	ld c, NUM_MOVES

.checkmove
	ld a, [hli]
	and a
	jr z, .no

	call AIGetPlayerMove

	ld a, [wPlayerMoveStruct + MOVE_EFFECT]
	cp b
	jr z, .yes

	dec c
	jr nz, .checkmove

.no
	pop hl
	and a
	ret

.yes
	pop hl
	scf
	ret

AIHasMoveInArray:
; Return carry if the enemy has a move in array hl.

	push hl
	push de
	push bc

.next
	ld a, [hli]
	cp -1
	jr z, .done

	ld b, a
	ld c, NUM_MOVES + 1
	ld de, wEnemyMonMoves

.check
	dec c
	jr z, .next

	ld a, [de]
	inc de
	cp b
	jr nz, .check

	scf

.done
	pop bc
	pop de
	pop hl
	ret

INCLUDE "data/battle/ai/useful_moves.asm"

; AndrewNote - this used to be AI_Opportunist
; this used to discourage 0 power moves if the player is below 1/4 hp
; that is no longer needed as AI_Basic now encourages any attack once it can KO the player
; this no discourages most 0 power moves if the player can KO the AI
AI_Final_Attack:
; Discourage stall moves if the player can KO us
    call ShouldAIBoost
    ret nc

	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld c, NUM_MOVES + 1
.checkmove
	inc hl
	dec c
	jr z, .done

	ld a, [de]
	inc de
	and a
	jr z, .done

	push hl
	push de
	push bc
	ld hl, StallMoves
	ld de, 1
	call IsInArray

	pop bc
	pop de
	pop hl
	jr nc, .checkmove

	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	jr .checkmove

.done
	ret

INCLUDE "data/battle/ai/stall_moves.asm"


AI_Aggressive:
; discourage all damaging moves except the one that deals the most damage

; Figure out which attack does the most damage and put it in c.
	ld hl, wEnemyMonMoves
	ld bc, 0
	ld de, 0
.checkmove
	inc b
	ld a, b
	cp NUM_MOVES + 1
	jp z, .gotstrongestmove

	ld a, [hli]
	and a
	jp z, .gotstrongestmove

	push hl
	push de
	push bc
	call AIGetEnemyMove
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	and a
	jp z, .nodamage
	call AIDamageCalc
	pop bc
	pop de
	pop hl

; Update current move if damage is highest so far

; don't encourage explosion
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	cp EFFECT_SELFDESTRUCT
	jr z, .checkmove

; don't encourage ground moves vs levitate Pokemon
; Dismiss ground move if the player has levitate
	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	and TYPE_MASK
	cp GROUND
	jr nz, .waterAbsorb
	ld a, [wBattleMonSpecies]
	push hl
	push de
	push bc
	ld hl, AI_LevitatePokemon
	ld de, 1
	call IsInArray
    pop bc
	pop de
	pop hl
    jp c, .checkmove

.waterAbsorb
    cp WATER
	jr nz, .voltAbsorb
	ld a, [wBattleMonSpecies]
	push hl
	push de
	push bc
	ld hl, AI_WaterAbsorbPokemon
	ld de, 1
	call IsInArray
    pop bc
	pop de
	pop hl
    jp c, .checkmove

.voltAbsorb
    cp ELECTRIC
	jr nz, .fireAbsorb
	ld a, [wBattleMonSpecies]
	push hl
	push de
	push bc
	ld hl, AI_VoltAbsorbPokemon
	ld de, 1
	call IsInArray
    pop bc
	pop de
	pop hl
    jp c, .checkmove

.fireAbsorb
    cp ELECTRIC
	jr nz, .continue
	ld a, [wBattleMonSpecies]
	push hl
	push de
	push bc
	ld hl, AI_FireAbsorbPokemon
	ld de, 1
	call IsInArray
    pop bc
	pop de
	pop hl
    jp c, .checkmove

.continue
	ld a, [wCurDamage + 1]
	cp e
	ld a, [wCurDamage]
	sbc d
	jp c, .checkmove

	ld a, [wCurDamage + 1]
	ld e, a
	ld a, [wCurDamage]
	ld d, a
	ld c, b
	jp .checkmove

.nodamage
	pop bc
	pop de
	pop hl
	jp .checkmove

.gotstrongestmove
; Nothing we can do if no attacks did damage.
	ld a, c
	and a
	jr z, .done

; Discourage moves that do less damage unless they're reckless too.
	ld hl, wEnemyAIMoveScores - 1
	ld de, wEnemyMonMoves
	ld b, 0
.checkmove2
	inc b
	ld a, b
	cp NUM_MOVES + 1
	jr z, .done

; Ignore this move if it is the highest damaging one.
	cp c
	ld a, [de]
	inc de
	inc hl
	jr z, .checkmove2

	call AIGetEnemyMove

; Ignore this move if its power is 0 or 1.
; Moves such as Seismic Toss, Hidden Power,
; Counter and Fissure have a base power of 1.
	ld a, [wEnemyMoveStruct + MOVE_POWER]
	cp 2
	jr c, .checkmove2

; Ignore this move if it is reckless.
	;push hl
	;push de
	;push bc
	;ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	;ld hl, RecklessMoves
	;ld de, 1
	;call IsInArray
	;pop bc
	;pop de
	;pop hl
	;jr c, .checkmove2

; If we made it this far, discourage this move.
	inc [hl]
	jr .checkmove2

.done
	ret

INCLUDE "data/battle/ai/reckless_moves.asm"

AIDamageCalc:
	ld a, 1
	ldh [hBattleTurn], a
	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
	ld de, 1
	ld hl, ConstantDamageEffects
	call IsInArray
	jr nc, .notconstant
	callfar BattleCommand_ConstantDamage
	ret

.notconstant
	callfar EnemyAttackDamage
	callfar BattleCommand_DamageCalc
	callfar BattleCommand_Stab
	ret

INCLUDE "data/battle/ai/constant_damage_effects.asm"

AI_Cautious:
    ret
; 90% chance to discourage moves with residual effects after the first turn.
;	ld a, [wEnemyTurnsTaken]
;	and a
;	ret z
;	ld hl, wEnemyAIMoveScores - 1
;	ld de, wEnemyMonMoves
;	ld c, NUM_MOVES + 1
;.loop
;	inc hl
;	dec c
;	ret z
;	ld a, [de]
;	inc de
;	and a
;	ret z
;	push hl
;	push de
;	push bc
;	ld hl, ResidualMoves
;	ld de, 1
;	call IsInArray
;	pop bc
;	pop de
;	pop hl
;	jr nc, .loop
;	call Random
;	cp 90 percent + 1
;	ret nc
;	inc [hl]
;	jr .loop

INCLUDE "data/battle/ai/residual_moves.asm"


AI_Status:
    ret
; Dismiss status moves that don't affect the player.
;	ld hl, wEnemyAIMoveScores - 1
;	ld de, wEnemyMonMoves
;	ld b, NUM_MOVES + 1
;.checkmove
;	dec b
;	ret z
;	inc hl
;	ld a, [de]
;	and a
;	ret z
;	inc de
;	call AIGetEnemyMove
;	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
;	cp EFFECT_TOXIC
;	jr z, .poisonimmunity
;	cp EFFECT_POISON
;	jr z, .poisonimmunity
;	cp EFFECT_SLEEP
;	jr z, .typeimmunity
;	cp EFFECT_PARALYZE
;	jr z, .typeimmunity
;	ld a, [wEnemyMoveStruct + MOVE_POWER]
;	and a
;	jr z, .checkmove
;	jr .typeimmunity
;.poisonimmunity
;	ld a, [wBattleMonType1]
;	cp POISON
;	jr z, .immune
;	ld a, [wBattleMonType2]
;	cp POISON
;	jr z, .immune
;.typeimmunity
;	push hl
;	push bc
;	push de
;	ld a, 1
;	ldh [hBattleTurn], a
;	callfar BattleCheckTypeMatchup
;	pop de
;	pop bc
;	pop hl
;	ld a, [wTypeMatchup]
;	and a
;	jr nz, .checkmove
;.immune
;	call AIDiscourageMove
;	jr .checkmove


AI_Risky:
    ret
; Use any move that will KO the target.
; Risky moves will often be an exception (see below).
;	ld hl, wEnemyAIMoveScores - 1
;	ld de, wEnemyMonMoves
;	ld c, NUM_MOVES + 1
;.checkmove
;	inc hl
;	dec c
;	ret z
;	ld a, [de]
;	inc de
;	and a
;	ret z
;	push de
;	push bc
;	push hl
;	call AIGetEnemyMove
;	ld a, [wEnemyMoveStruct + MOVE_POWER]
;	and a
;	jr z, .nextmove
; Don't use risky moves at max hp.
;	ld a, [wEnemyMoveStruct + MOVE_EFFECT]
;	ld de, 1
;	ld hl, RiskyEffects
;	call IsInArray
;	jr nc, .checkko
;	call AICheckEnemyMaxHP
;	jr c, .nextmove
; Else, 80% chance to exclude them.
;	call Random
;	cp 79 percent - 1
;	jr c, .nextmove
;.checkko
;	call AIDamageCalc
;	ld a, [wCurDamage + 1]
;	ld e, a
;	ld a, [wCurDamage]
;	ld d, a
;	ld a, [wBattleMonHP + 1]
;	cp e
;	ld a, [wBattleMonHP]
;	sbc d
;	jr nc, .nextmove
;	pop hl
;rept 5
;	dec [hl]
;endr
;	push hl
;.nextmove
;	pop hl
;	pop bc
;	pop de
;	jr .checkmove

INCLUDE "data/battle/ai/risky_effects.asm"


AI_None:
	ret

AIDiscourageMove:
	ld a, [hl]
	add 10
	ld [hl], a
	ret

AIGetEnemyMove:
; Load attributes of move a into ram

	push hl
	push de
	push bc
	dec a
	ld hl, Moves
	ld bc, MOVE_LENGTH
	call AddNTimes

	ld de, wEnemyMoveStruct
	ld a, BANK(Moves)
	call FarCopyBytes

	pop bc
	pop de
	pop hl
	ret

AIGetPlayerMove:
; Load attributes of move a into ram

	push hl
	push de
	push bc
	dec a
	ld hl, Moves
	ld bc, MOVE_LENGTH
	call AddNTimes

	ld de, wPlayerMoveStruct
	ld a, BANK(Moves)
	call FarCopyBytes

	pop bc
	pop de
	pop hl
	ret

AI_80_20:
	call Random
	cp 20 percent - 1
	ret

AI_50_50:
	call Random
	cp 50 percent + 1
	ret

; ============================================
; ====== EFFECT COMMAND EXCESS FUNCTIONS =====
; ============================================
; These are functions used in effect_commands.asm
; they are defined here as that file is out of space

Levitate:
    ldh a, [hBattleTurn]
	and a
	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	jr nz, .checkType
	ld a, [wPlayerMoveStruct + MOVE_TYPE]
.checkType
	and TYPE_MASK
	cp GROUND
	jr z, .getPokemon
	ret
.getPokemon
	ldh a, [hBattleTurn]
	and a
	ld a, [wEnemyMonSpecies]
	jr z, .checkLevitate
	ld a, [wBattleMonSpecies]
.checkLevitate
	ld hl, AI_LevitatePokemon
	ld de, 1
	call IsInArray
    jr c, .found
    ret
.found
	ld hl, LevitateText
	call StdBattleTextbox
    ret z

WaterAbsorb:
    ldh a, [hBattleTurn]
	and a
	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	jr nz, .checkType
	ld a, [wPlayerMoveStruct + MOVE_TYPE]
.checkType
	and TYPE_MASK
	cp WATER
	jr z, .getPokemon
	ret
.getPokemon
	ldh a, [hBattleTurn]
	and a
	ld a, [wEnemyMonSpecies]
	jr z, .check
	ld a, [wBattleMonSpecies]
.check
	ld hl, AI_WaterAbsorbPokemon
	ld de, 1
	call IsInArray
    jr c, .found
    ret
.found
	ld hl, ElementAbsorbText
	call StdBattleTextbox
    ret z

VoltAbsorb:
    ldh a, [hBattleTurn]
	and a
	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	jr nz, .checkType
	ld a, [wPlayerMoveStruct + MOVE_TYPE]
.checkType
	and TYPE_MASK
	cp ELECTRIC
	jr z, .getPokemon
	ret
.getPokemon
	ldh a, [hBattleTurn]
	and a
	ld a, [wEnemyMonSpecies]
	jr z, .check
	ld a, [wBattleMonSpecies]
.check
	ld hl, AI_VoltAbsorbPokemon
	ld de, 1
	call IsInArray
    jr c, .found
    ret
.found
	ld hl, ElementAbsorbText
	call StdBattleTextbox
    ret z

FireAbsorb:
    ldh a, [hBattleTurn]
	and a
	ld a, [wEnemyMoveStruct + MOVE_TYPE]
	jr nz, .checkType
	ld a, [wPlayerMoveStruct + MOVE_TYPE]
.checkType
	and TYPE_MASK
	cp FIRE
	jr z, .getPokemon
	ret
.getPokemon
	ldh a, [hBattleTurn]
	and a
	ld a, [wEnemyMonSpecies]
	jr z, .check
	ld a, [wBattleMonSpecies]
.check
	ld hl, AI_FireAbsorbPokemon
	ld de, 1
	call IsInArray
    jr c, .found
    ret
.found
	ld hl, ElementAbsorbText
	call StdBattleTextbox
    ret z

DreamEaterMiss:
; Return z if we're trying to eat the dream of
; a monster that isn't sleeping.
	ld a, BATTLE_VARS_MOVE_EFFECT
	call GetBattleVar
	cp EFFECT_DREAM_EATER
	ret nz
	ld a, BATTLE_VARS_STATUS_OPP
	call GetBattleVar
	and SLP
	ret

ProtectMiss:
; Return nz if the opponent is protected.
	ld a, BATTLE_VARS_SUBSTATUS1_OPP
	call GetBattleVar
	bit SUBSTATUS_PROTECT, a
	ret z
	ld c, 40
	call DelayFrames
; 'protecting itself!'
	ld hl, ProtectingItselfText
	call StdBattleTextbox
	ld c, 40
	call DelayFrames
	ld a, 1
	and a
	ret

LockOnMiss:
; Return nz if we are locked-on and aren't trying to use Earthquake,
; Fissure or Magnitude on a monster that is flying.
	ld a, BATTLE_VARS_SUBSTATUS5_OPP
	call GetBattleVarAddr
	bit SUBSTATUS_LOCK_ON, [hl]
	res SUBSTATUS_LOCK_ON, [hl]
	ret z
	ld a, BATTLE_VARS_SUBSTATUS3_OPP
	call GetBattleVar
	bit SUBSTATUS_FLYING, a
	jr z, .LockedOn
	ld a, BATTLE_VARS_MOVE_ANIM
	call GetBattleVar
	cp EARTHQUAKE
	ret z
	cp FISSURE
	ret z
	cp MAGNITUDE
	ret z
.LockedOn:
	ld a, 1
	and a
	ret

FlyDigMovesMiss:
; Check for moves that can hit underground/flying opponents.
; Return z if the current move can hit the opponent.
	ld a, BATTLE_VARS_SUBSTATUS3_OPP
	call GetBattleVar
	and 1 << SUBSTATUS_FLYING | 1 << SUBSTATUS_UNDERGROUND
	ret z
	bit SUBSTATUS_FLYING, a
	jr z, .DigMoves
	ld a, BATTLE_VARS_MOVE_ANIM
	call GetBattleVar
	cp GUST
	ret z
	cp WHIRLWIND
	ret z
	cp THUNDER
	ret z
	ret
.DigMoves:
	ld a, BATTLE_VARS_MOVE_ANIM
	call GetBattleVar
	cp EARTHQUAKE
	ret z
	cp FISSURE
	ret z
	cp MAGNITUDE
	ret

ThunderRain:
; Return z if the current move always hits in rain, and it is raining.
	ld a, BATTLE_VARS_MOVE_EFFECT
	call GetBattleVar
	cp EFFECT_THUNDER
	jr z, .checkRain
	cp EFFECT_HURRICANE
	jr z, .checkRain
	ret
.checkRain
	ld a, [wBattleWeather]
	cp WEATHER_RAIN
	ret

XAccuracy:
	ld a, BATTLE_VARS_SUBSTATUS4
	call GetBattleVar
	bit SUBSTATUS_X_ACCURACY, a
	ret

RainSwitch:
	ld a, WEATHER_RAIN
	ld [wBattleWeather], a
	ld a, 255
	ld [wWeatherCount], a
    ld a, [wBattleHasJustStarted]
    and a
    ret nz
    ld de, RAIN_DANCE
	farcall Call_PlayBattleAnim
	ld hl, DownpourText
	jp StdBattleTextbox

SunSwitch:
    ld a, WEATHER_SUN
	ld [wBattleWeather], a
	ld a, 255
	ld [wWeatherCount], a
    ld a, [wBattleHasJustStarted]
    and a
    ret nz
    ld de, SUNNY_DAY
	farcall Call_PlayBattleAnim
	ld hl, SunGotBrightText
	jp StdBattleTextbox

SandSwitch:
    ld a, WEATHER_SANDSTORM
	ld [wBattleWeather], a
	ld a, 255
	ld [wWeatherCount], a
    ld a, [wBattleHasJustStarted]
    and a
    ret nz
    ld de, ANIM_IN_SANDSTORM
	farcall Call_PlayBattleAnim
	ld hl, SandstormBrewedText
	jp StdBattleTextbox

SpikesSwitch:
	ld hl, wEnemyScreens
	ldh a, [hBattleTurn]
	and a
	jr z, .got_screens
	ld hl, wPlayerScreens
.got_screens
	set SCREENS_SPIKES, [hl]
    ld a, [wBattleHasJustStarted]
    and a
    jr nz, .skipAnim
    ld de, SPIKES
	farcall Call_PlayBattleAnim
.skipAnim
	ld hl, SpikesText
	jp StdBattleTextbox

ReflectSwitch:
    ld hl, wPlayerScreens
	ld bc, wPlayerReflectCount
	ldh a, [hBattleTurn]
	and a
	jr z, .got_screens_pointer
	ld hl, wEnemyScreens
	ld bc, wEnemyReflectCount
.got_screens_pointer
	set SCREENS_REFLECT, [hl]
	ld a, FIELD_EFFECT_DURATION
	ld [bc], a
    ld a, [wBattleHasJustStarted]
    and a
    jr nz, .skipAnim
    ld de, REFLECT
	farcall Call_PlayBattleAnim
.skipAnim
    ld hl, ReflectEffectText
	jp StdBattleTextbox

LightScreenSwitch:
    ld hl, wPlayerScreens
	ld bc, wPlayerLightScreenCount
	ldh a, [hBattleTurn]
	and a
	jr z, .got_screens_pointer
	ld hl, wEnemyScreens
	ld bc, wEnemyLightScreenCount
.got_screens_pointer
	set SCREENS_LIGHT_SCREEN, [hl]
	ld a, FIELD_EFFECT_DURATION
	ld [bc], a
    ld a, [wBattleHasJustStarted]
    and a
    jr nz, .skipAnim
    ld de, LIGHT_SCREEN
	farcall Call_PlayBattleAnim
.skipAnim
    ld hl, LightScreenEffectText
	jp StdBattleTextbox

SafeguardSwitch:
    ld hl, wPlayerScreens
	ld bc, wPlayerSafeguardCount
	ldh a, [hBattleTurn]
	and a
	jr z, .got_screens_pointer
	ld hl, wEnemyScreens
	ld bc, wEnemySafeguardCount
.got_screens_pointer
	set SCREENS_SAFEGUARD, [hl]
	ld a, FIELD_EFFECT_DURATION
	ld [bc], a
    ld a, [wBattleHasJustStarted]
    and a
    jr nz, .skipAnim
    ld de, SAFEGUARD
	farcall Call_PlayBattleAnim
.skipAnim
    ld hl, CoveredByVeilText
	jp StdBattleTextbox

ClearField:
	ld a, 1
	ld [wWeatherCount], a
	ld hl, wPlayerScreens
	ld bc, wPlayerSafeguardCount
	ldh a, [hBattleTurn]
	and a
	jr nz, .gotScreens
	ld hl, wEnemyScreens
	ld bc, wEnemySafeguardCount
.gotScreens
	ld a, 1
	ld [bc], a
	inc bc
	ld [bc], a
	inc bc
	ld [bc], a
	res SCREENS_SPIKES, [hl]
	ld hl, ClearFieldText
	jp StdBattleTextbox