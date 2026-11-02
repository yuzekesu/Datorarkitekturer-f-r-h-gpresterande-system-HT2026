	.arch armv8-a
	.file	"multiply.c"
	.text
	.align	2
	.p2align 4,,11
	.global	mult_std
	.type	mult_std, %function
mult_std:
.LFB4379:
	.cfi_startproc
	cmp	w3, 0
	ble	.L1
	add	x5, x0, 4
	sub	w6, w3, #1
	sub	x5, x2, x5
	add	x4, x1, 4
	cmp	x5, 8
	sub	x4, x2, x4
	ccmp	w6, 3, 0, hi
	ccmp	x4, 8, 0, hi
	bls	.L7
	lsr	w5, w3, 2
	mov	x4, 0
	lsl	x5, x5, 4
	.p2align 3,,7
.L4:
	ldr	q0, [x0, x4]
	ldr	q1, [x1, x4]
	fmul	v0.4s, v0.4s, v1.4s
	str	q0, [x2, x4]
	add	x4, x4, 16
	cmp	x4, x5
	bne	.L4
	and	w4, w3, -4
	tst	x3, 3
	beq	.L1
	uxtw	x6, w4
	add	w7, w4, 1
	lsl	x5, x6, 2
	ldr	s0, [x0, x6, lsl 2]
	ldr	s1, [x1, x6, lsl 2]
	fmul	s0, s0, s1
	str	s0, [x2, x6, lsl 2]
	cmp	w3, w7
	ble	.L1
	add	x6, x5, 4
	add	w4, w4, 2
	ldr	s0, [x0, x6]
	ldr	s1, [x1, x6]
	fmul	s0, s0, s1
	str	s0, [x2, x6]
	cmp	w3, w4
	ble	.L1
	add	x3, x5, 8
	ldr	s0, [x0, x3]
	ldr	s1, [x1, x3]
	fmul	s0, s0, s1
	str	s0, [x2, x3]
.L1:
	ret
	.p2align 2,,3
.L7:
	mov	x4, 0
	.p2align 3,,7
.L3:
	ldr	s0, [x0, x4, lsl 2]
	ldr	s1, [x1, x4, lsl 2]
	fmul	s0, s0, s1
	str	s0, [x2, x4, lsl 2]
	add	x4, x4, 1
	cmp	w3, w4
	bgt	.L3
	ret
	.cfi_endproc
.LFE4379:
	.size	mult_std, .-mult_std
	.align	2
	.p2align 4,,11
	.global	mult_vect
	.type	mult_vect, %function
mult_vect:
.LFB4380:
	.cfi_startproc
	cmp	w3, 0
	ble	.L11
	sub	w3, w3, #1
	add	x4, x0, 16
	lsr	w3, w3, 2
	add	x3, x4, w3, uxtw 4
	.p2align 3,,7
.L13:
	ldr	q0, [x0], 16
	ldr	q1, [x1], 16
	fmul	v0.4s, v0.4s, v1.4s
	str	q0, [x2], 16
	cmp	x0, x3
	bne	.L13
.L11:
	ret
	.cfi_endproc
.LFE4380:
	.size	mult_vect, .-mult_vect
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC0:
	.string	"Elapsed time std: %f\n"
	.align	3
.LC1:
	.string	"Elapsed time vec: %f\n"
	.align	3
.LC2:
	.string	"Speed-up vec/std: %.2f\n"
	.section	.text.startup,"ax",@progbits
	.align	2
	.p2align 4,,11
	.global	main
	.type	main, %function
main:
.LFB4381:
	.cfi_startproc
	sub	sp, sp, #160
	.cfi_def_cfa_offset 160
	adrp	x2, :got:__stack_chk_guard
	stp	x29, x30, [sp, 64]
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	add	x29, sp, 64
	ldr	x2, [x2, #:got_lo12:__stack_chk_guard]
	stp	x19, x20, [sp, 80]
	.cfi_offset 19, -80
	.cfi_offset 20, -72
	mov	w19, w0
	stp	x21, x22, [sp, 96]
	stp	x23, x24, [sp, 112]
	stp	d8, d9, [sp, 144]
	ldr	x0, [x2]
	str	x0, [sp, 56]
	mov	x0, 0
	cmp	w19, 1
	.cfi_offset 21, -64
	.cfi_offset 22, -56
	.cfi_offset 23, -48
	.cfi_offset 24, -40
	.cfi_offset 72, -16
	.cfi_offset 73, -8
	bgt	.L49
	mov	x1, 33792
	mov	x0, 16
	movk	x1, 0x17d7, lsl 16
	bl	aligned_alloc
	mov	x1, 33792
	mov	x20, x0
	movk	x1, 0x17d7, lsl 16
	mov	x0, 16
	bl	aligned_alloc
	mov	x21, x0
	mov	x1, 33792
	mov	x0, 16
	movk	x1, 0x17d7, lsl 16
	bl	aligned_alloc
	mov	w4, 57600
	mov	x22, x0
	movk	w4, 0x5f5, lsl 16
	mov	w5, w4
	mov	w23, w4
	mov	w24, 1
.L34:
	lsr	w2, w5, 2
	add	x3, x20, 16
	sub	w1, w2, #1
	adrp	x6, .LC3
	movi	v6.4s, 0x4
	mov	x0, x20
	add	x1, x3, w1, uxtw 4
	adrp	x3, .LC4
	ldr	q3, [x6, #:lo12:.LC3]
	ldr	q4, [x3, #:lo12:.LC4]
	adrp	x3, .LC5
	ldr	q5, [x3, #:lo12:.LC5]
	.p2align 3,,7
.L20:
	mov	v0.16b, v3.16b
	add	v3.4s, v3.4s, v6.4s
	smull2	v2.2d, v0.4s, v4.4s
	smull	v1.2d, v0.2s, v4.2s
	uzp2	v1.4s, v1.4s, v2.4s
	add	v1.4s, v1.4s, v0.4s
	sshr	v1.4s, v1.4s, 6
	shl	v2.4s, v1.4s, 7
	sub	v1.4s, v2.4s, v1.4s
	sub	v0.4s, v0.4s, v1.4s
	scvtf	v0.4s, v0.4s
	fmul	v0.4s, v0.4s, v5.4s
	str	q0, [x0], 16
	cmp	x0, x1
	bne	.L20
	and	w1, w5, -4
	mov	w3, w1
	cmp	w1, w5
	beq	.L21
.L19:
	mov	w0, 1033
	mov	w1, 12897
	movk	w0, 0x8102, lsl 16
	movk	w1, 0x3e15, lsl 16
	fmov	s1, w1
	add	w7, w3, 1
	smull	x0, w3, w0
	sbfiz	x2, x3, 2, 32
	lsr	x0, x0, 32
	add	w0, w3, w0
	asr	w0, w0, 6
	sub	w0, w0, w3, asr 31
	lsl	w1, w0, 7
	sub	w0, w1, w0
	sub	w0, w3, w0
	scvtf	s0, w0
	fmul	s0, s0, s1
	str	s0, [x20, w3, sxtw 2]
	cmp	w7, w23
	bge	.L22
	mov	w6, 127
	add	x1, x20, x2
	add	w3, w3, 2
	udiv	w0, w7, w6
	msub	w0, w0, w6, w7
	scvtf	s0, w0
	fmul	s0, s0, s1
	str	s0, [x1, 4]
	cmp	w23, w3
	ble	.L22
	udiv	w0, w3, w6
	msub	w0, w0, w6, w3
	scvtf	s0, w0
	fmul	s0, s0, s1
	str	s0, [x1, 8]
.L22:
	cmp	w23, 3
	ble	.L41
	lsr	w2, w5, 2
	and	w1, w5, -4
.L21:
	adrp	x3, .LC3
	sub	w2, w2, #1
	movi	v7.4s, 0x4
	add	x0, x21, 16
	ldr	q2, [x3, #:lo12:.LC3]
	adrp	x3, .LC6
	add	x2, x0, w2, uxtw 4
	mov	x0, x21
	ldr	q3, [x3, #:lo12:.LC6]
	adrp	x3, .LC7
	ldr	q6, [x3, #:lo12:.LC7]
	adrp	x3, .LC8
	ldr	q5, [x3, #:lo12:.LC8]
	.p2align 3,,7
.L24:
	mov	v0.16b, v2.16b
	add	v2.4s, v2.4s, v7.4s
	smull	v1.2d, v0.2s, v3.2s
	smull2	v4.2d, v0.4s, v3.4s
	uzp2	v1.4s, v1.4s, v4.4s
	sshr	v1.4s, v1.4s, 6
	mls	v0.4s, v1.4s, v6.4s
	scvtf	v0.4s, v0.4s
	fmul	v0.4s, v0.4s, v5.4s
	str	q0, [x0], 16
	cmp	x0, x2
	bne	.L24
	mov	w0, w1
	cmp	w1, w5
	beq	.L25
.L23:
	mov	w1, 40193
	mov	w3, 331
	movk	w1, 0x317f, lsl 16
	mov	w2, 7130
	movk	w2, 0x3dfc, lsl 16
	fmov	s1, w2
	smull	x1, w0, w1
	add	w5, w0, 1
	sbfiz	x2, x0, 2, 32
	asr	x1, x1, 38
	sub	w1, w1, w0, asr 31
	msub	w1, w1, w3, w0
	scvtf	s0, w1
	fmul	s0, s0, s1
	str	s0, [x21, w0, sxtw 2]
	cmp	w5, w23
	bge	.L25
	udiv	w1, w5, w3
	add	x2, x21, x2
	add	w0, w0, 2
	msub	w1, w1, w3, w5
	scvtf	s0, w1
	fmul	s0, s0, s1
	str	s0, [x2, 4]
	cmp	w0, w23
	bge	.L25
	udiv	w1, w0, w3
	msub	w0, w1, w3, w0
	scvtf	s0, w0
	fmul	s0, s0, s1
	str	s0, [x2, 8]
.L25:
	cmp	w23, 0
	ubfiz	x2, x4, 2, 32
	mov	x0, 4
	csel	x2, x2, x0, gt
	mov	w1, 0
	mov	x0, x22
	bl	memset
	add	x1, sp, 8
	mov	w0, 1
	bl	clock_gettime
	cmp	w24, 0
	ble	.L26
	lsr	w2, w23, 2
	sub	w19, w23, #1
	sub	w2, w2, #1
	and	w6, w23, -4
	add	x2, x2, 1
	mov	w4, 0
	lsl	x2, x2, 4
	.p2align 3,,7
.L27:
	cmp	w19, 2
	bls	.L42
	mov	x1, 0
	.p2align 3,,7
.L28:
	ldr	q0, [x20, x1]
	ldr	q1, [x21, x1]
	fmul	v0.4s, v0.4s, v1.4s
	str	q0, [x22, x1]
	add	x1, x1, 16
	cmp	x1, x2
	bne	.L28
	mov	w1, w6
	cmp	w6, w23
	beq	.L29
.L31:
	sxtw	x0, w1
	add	w5, w1, 1
	sbfiz	x3, x1, 2, 32
	ldr	s0, [x21, x0, lsl 2]
	ldr	s1, [x20, x0, lsl 2]
	fmul	s0, s0, s1
	str	s0, [x22, x0, lsl 2]
	cmp	w5, w23
	bge	.L29
	add	x0, x3, 4
	add	w1, w1, 2
	ldr	s0, [x21, x0]
	ldr	s1, [x20, x0]
	fmul	s0, s0, s1
	str	s0, [x22, x0]
	cmp	w1, w23
	bge	.L29
	add	x1, x3, 8
	ldr	s0, [x20, x1]
	ldr	s1, [x21, x1]
	fmul	s0, s0, s1
	str	s0, [x22, x1]
.L29:
	add	w4, w4, 1
	cmp	w4, w24
	bne	.L27
	add	x1, sp, 24
	mov	w0, 1
	bl	clock_gettime
	lsr	w4, w19, 2
	add	x0, x20, 16
	mov	w5, 0
	add	x4, x0, w4, uxtw 4
	.p2align 3,,7
.L35:
	mov	x3, x21
	mov	x2, x22
	mov	x1, x20
	.p2align 3,,7
.L32:
	ldr	q0, [x1], 16
	ldr	q1, [x3], 16
	fmul	v0.4s, v0.4s, v1.4s
	str	q0, [x2], 16
	cmp	x4, x1
	bne	.L32
	add	w5, w5, 1
	cmp	w5, w24
	bne	.L35
.L33:
	add	x1, sp, 40
	mov	w0, 1
	bl	clock_gettime
	ldp	x2, x4, [sp, 8]
	adrp	x0, .LC9
	ldp	x7, x6, [sp, 24]
	adrp	x1, .LC0
	ldr	d2, [x0, #:lo12:.LC9]
	add	x1, x1, :lo12:.LC0
	mov	w0, 1
	sub	x3, x7, x2
	sub	x5, x6, x4
	ldp	x2, x4, [sp, 40]
	scvtf	d1, x5
	scvtf	d9, x3
	fmadd	d9, d1, d2, d9
	sub	x3, x4, x6
	sub	x2, x2, x7
	scvtf	d0, x3
	scvtf	d8, x2
	fmadd	d8, d0, d2, d8
	fmov	d0, d9
	bl	__printf_chk
	fmov	d0, d8
	adrp	x1, .LC1
	mov	w0, 1
	add	x1, x1, :lo12:.LC1
	bl	__printf_chk
	fdiv	d0, d9, d8
	adrp	x1, .LC2
	add	x1, x1, :lo12:.LC2
	mov	w0, 1
	bl	__printf_chk
	mov	x0, x20
	bl	free
	mov	x0, x21
	bl	free
	mov	x0, x22
	bl	free
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 56]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L50
	mov	w0, 0
	ldp	x29, x30, [sp, 64]
	ldp	x19, x20, [sp, 80]
	ldp	x21, x22, [sp, 96]
	ldp	x23, x24, [sp, 112]
	ldp	d8, d9, [sp, 144]
	add	sp, sp, 160
	.cfi_remember_state
	.cfi_restore 29
	.cfi_restore 30
	.cfi_restore 23
	.cfi_restore 24
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_restore 72
	.cfi_restore 73
	.cfi_def_cfa_offset 0
	ret
.L42:
	.cfi_restore_state
	mov	w1, 0
	b	.L31
.L49:
	mov	x20, x1
	mov	w2, 10
	mov	x1, 0
	ldr	x0, [x20, 8]
	str	x25, [sp, 128]
	.cfi_offset 25, -32
	bl	strtol
	mov	x25, x0
	mov	w23, w0
	cmp	w19, 2
	beq	.L38
	ldr	x0, [x20, 16]
	mov	w2, 10
	mov	x1, 0
	bl	strtol
	mov	w24, w0
.L17:
	sbfiz	x19, x25, 2, 32
	mov	x0, 16
	mov	x1, x19
	bl	aligned_alloc
	mov	x1, x19
	mov	x20, x0
	mov	x0, 16
	bl	aligned_alloc
	mov	x1, x19
	mov	x21, x0
	mov	x0, 16
	bl	aligned_alloc
	mov	x22, x0
	cmp	w25, 0
	ble	.L18
	mov	w4, w25
	mov	w5, w25
	cmp	w25, 3
	ble	.L39
	ldr	x25, [sp, 128]
	.cfi_remember_state
	.cfi_restore 25
	b	.L34
.L18:
	.cfi_restore_state
	add	x1, sp, 8
	mov	w0, 1
	bl	clock_gettime
	cmp	w24, 0
	ble	.L51
	add	x1, sp, 24
	mov	w0, 1
	bl	clock_gettime
	ldr	x25, [sp, 128]
	.cfi_remember_state
	.cfi_restore 25
	b	.L33
.L51:
	.cfi_restore_state
	ldr	x25, [sp, 128]
	.cfi_restore 25
.L26:
	add	x1, sp, 24
	mov	w0, 1
	bl	clock_gettime
	b	.L33
.L39:
	.cfi_offset 25, -32
	mov	w3, 0
	ldr	x25, [sp, 128]
	.cfi_remember_state
	.cfi_restore 25
	b	.L19
.L38:
	.cfi_restore_state
	mov	w24, 1
	b	.L17
.L41:
	.cfi_restore 25
	mov	w0, 0
	b	.L23
.L50:
	str	x25, [sp, 128]
	.cfi_offset 25, -32
	bl	__stack_chk_fail
	.cfi_endproc
.LFE4381:
	.size	main, .-main
	.section	.rodata.cst16,"aM",@progbits,16
	.align	4
.LC3:
	.word	0
	.word	1
	.word	2
	.word	3
	.align	4
.LC4:
	.word	-2130574327
	.word	-2130574327
	.word	-2130574327
	.word	-2130574327
	.align	4
.LC5:
	.word	1041576545
	.word	1041576545
	.word	1041576545
	.word	1041576545
	.align	4
.LC6:
	.word	830446849
	.word	830446849
	.word	830446849
	.word	830446849
	.align	4
.LC7:
	.word	331
	.word	331
	.word	331
	.word	331
	.align	4
.LC8:
	.word	1039932378
	.word	1039932378
	.word	1039932378
	.word	1039932378
	.section	.rodata.cst8,"aM",@progbits,8
	.align	3
.LC9:
	.word	-400107883
	.word	1041313291
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04.3) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
