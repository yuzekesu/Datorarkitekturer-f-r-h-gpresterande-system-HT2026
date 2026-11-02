	.arch armv8-a
	.file	"multiply.c"
	.text
	.align	2
	.global	mult_std
	.type	mult_std, %function
mult_std:
.LFB4346:
	.cfi_startproc
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	str	x0, [sp, 24]
	str	x1, [sp, 16]
	str	x2, [sp, 8]
	str	w3, [sp, 4]
	str	wzr, [sp, 44]
	b	.L2
.L3:
	ldrsw	x0, [sp, 44]
	lsl	x0, x0, 2
	ldr	x1, [sp, 24]
	add	x0, x1, x0
	ldr	s1, [x0]
	ldrsw	x0, [sp, 44]
	lsl	x0, x0, 2
	ldr	x1, [sp, 16]
	add	x0, x1, x0
	ldr	s0, [x0]
	ldrsw	x0, [sp, 44]
	lsl	x0, x0, 2
	ldr	x1, [sp, 8]
	add	x0, x1, x0
	fmul	s0, s1, s0
	str	s0, [x0]
	ldr	w0, [sp, 44]
	add	w0, w0, 1
	str	w0, [sp, 44]
.L2:
	ldr	w1, [sp, 44]
	ldr	w0, [sp, 4]
	cmp	w1, w0
	blt	.L3
	nop
	nop
	add	sp, sp, 48
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE4346:
	.size	mult_std, .-mult_std
	.align	2
	.global	mult_vect
	.type	mult_vect, %function
mult_vect:
.LFB4347:
	.cfi_startproc
	sub	sp, sp, #160
	.cfi_def_cfa_offset 160
	str	x0, [sp, 24]
	str	x1, [sp, 16]
	str	x2, [sp, 8]
	str	w3, [sp, 4]
	str	wzr, [sp, 36]
	b	.L5
.L9:
	ldrsw	x0, [sp, 36]
	lsl	x0, x0, 2
	ldr	x1, [sp, 24]
	add	x0, x1, x0
	str	x0, [sp, 56]
	ldr	x0, [sp, 56]
	ldr	q0, [x0]
	str	q0, [sp, 64]
	ldrsw	x0, [sp, 36]
	lsl	x0, x0, 2
	ldr	x1, [sp, 16]
	add	x0, x1, x0
	str	x0, [sp, 48]
	ldr	x0, [sp, 48]
	ldr	q0, [x0]
	str	q0, [sp, 80]
	ldr	q0, [sp, 64]
	str	q0, [sp, 128]
	ldr	q0, [sp, 80]
	str	q0, [sp, 144]
	ldr	q1, [sp, 128]
	ldr	q0, [sp, 144]
	fmul	v0.4s, v1.4s, v0.4s
	str	q0, [sp, 96]
	ldrsw	x0, [sp, 36]
	lsl	x0, x0, 2
	ldr	x1, [sp, 8]
	add	x0, x1, x0
	str	x0, [sp, 40]
	ldr	q0, [sp, 96]
	str	q0, [sp, 112]
	ldr	x0, [sp, 40]
	ldr	q0, [sp, 112]
	str	q0, [x0]
	nop
	ldr	w0, [sp, 36]
	add	w0, w0, 4
	str	w0, [sp, 36]
.L5:
	ldr	w1, [sp, 36]
	ldr	w0, [sp, 4]
	cmp	w1, w0
	blt	.L9
	nop
	nop
	add	sp, sp, 160
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE4347:
	.size	mult_vect, .-mult_vect
	.section	.rodata
	.align	3
.LC0:
	.string	"Elapsed time std: %f\n"
	.align	3
.LC1:
	.string	"Elapsed time vec: %f\n"
	.align	3
.LC2:
	.string	"Speed-up vec/std: %.2f\n"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB4348:
	.cfi_startproc
	sub	sp, sp, #160
	.cfi_def_cfa_offset 160
	stp	x29, x30, [sp, 144]
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	add	x29, sp, 144
	str	w0, [sp, 12]
	str	x1, [sp]
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 136]
	mov	x1, 0
	ldr	w0, [sp, 12]
	cmp	w0, 1
	ble	.L11
	ldr	x0, [sp]
	add	x0, x0, 8
	ldr	x0, [x0]
	bl	atoi
	b	.L12
.L11:
	mov	w0, 57600
	movk	w0, 0x5f5, lsl 16
.L12:
	str	w0, [sp, 40]
	ldr	w0, [sp, 12]
	cmp	w0, 2
	ble	.L13
	ldr	x0, [sp]
	add	x0, x0, 16
	ldr	x0, [x0]
	bl	atoi
	b	.L14
.L13:
	mov	w0, 1
.L14:
	str	w0, [sp, 44]
	ldrsw	x0, [sp, 40]
	lsl	x0, x0, 2
	mov	x1, x0
	mov	x0, 16
	bl	aligned_alloc
	str	x0, [sp, 48]
	ldrsw	x0, [sp, 40]
	lsl	x0, x0, 2
	mov	x1, x0
	mov	x0, 16
	bl	aligned_alloc
	str	x0, [sp, 56]
	ldrsw	x0, [sp, 40]
	lsl	x0, x0, 2
	mov	x1, x0
	mov	x0, 16
	bl	aligned_alloc
	str	x0, [sp, 64]
	str	wzr, [sp, 28]
	b	.L15
.L16:
	ldr	w0, [sp, 28]
	mov	w1, 1033
	movk	w1, 0x8102, lsl 16
	smull	x1, w0, w1
	lsr	x1, x1, 32
	add	w1, w0, w1
	asr	w2, w1, 6
	asr	w1, w0, 31
	sub	w2, w2, w1
	mov	w1, w2
	lsl	w1, w1, 7
	sub	w1, w1, w2
	sub	w2, w0, w1
	scvtf	s0, w2
	ldrsw	x0, [sp, 28]
	lsl	x0, x0, 2
	ldr	x1, [sp, 48]
	add	x0, x1, x0
	mov	w1, 12897
	movk	w1, 0x3e15, lsl 16
	fmov	s1, w1
	fmul	s0, s0, s1
	str	s0, [x0]
	ldr	w0, [sp, 28]
	mov	w1, 40193
	movk	w1, 0x317f, lsl 16
	smull	x1, w0, w1
	lsr	x1, x1, 32
	asr	w2, w1, 6
	asr	w1, w0, 31
	sub	w1, w2, w1
	mov	w2, 331
	mul	w1, w1, w2
	sub	w1, w0, w1
	scvtf	s0, w1
	ldrsw	x0, [sp, 28]
	lsl	x0, x0, 2
	ldr	x1, [sp, 56]
	add	x0, x1, x0
	mov	w1, 7130
	movk	w1, 0x3dfc, lsl 16
	fmov	s1, w1
	fmul	s0, s0, s1
	str	s0, [x0]
	ldrsw	x0, [sp, 28]
	lsl	x0, x0, 2
	ldr	x1, [sp, 64]
	add	x0, x1, x0
	str	wzr, [x0]
	ldr	w0, [sp, 28]
	add	w0, w0, 1
	str	w0, [sp, 28]
.L15:
	ldr	w1, [sp, 28]
	ldr	w0, [sp, 40]
	cmp	w1, w0
	blt	.L16
	add	x0, sp, 88
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
	str	wzr, [sp, 32]
	b	.L17
.L18:
	ldr	w3, [sp, 40]
	ldr	x2, [sp, 64]
	ldr	x1, [sp, 56]
	ldr	x0, [sp, 48]
	bl	mult_std
	ldr	w0, [sp, 32]
	add	w0, w0, 1
	str	w0, [sp, 32]
.L17:
	ldr	w1, [sp, 32]
	ldr	w0, [sp, 44]
	cmp	w1, w0
	blt	.L18
	add	x0, sp, 104
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
	str	wzr, [sp, 36]
	b	.L19
.L20:
	ldr	w3, [sp, 40]
	ldr	x2, [sp, 64]
	ldr	x1, [sp, 56]
	ldr	x0, [sp, 48]
	bl	mult_vect
	ldr	w0, [sp, 36]
	add	w0, w0, 1
	str	w0, [sp, 36]
.L19:
	ldr	w1, [sp, 36]
	ldr	w0, [sp, 44]
	cmp	w1, w0
	blt	.L20
	add	x0, sp, 120
	mov	x1, x0
	mov	w0, 1
	bl	clock_gettime
	ldr	x1, [sp, 104]
	ldr	x0, [sp, 88]
	sub	x0, x1, x0
	fmov	d0, x0
	scvtf	d1, d0
	ldr	x1, [sp, 112]
	ldr	x0, [sp, 96]
	sub	x0, x1, x0
	fmov	d0, x0
	scvtf	d0, d0
	adrp	x0, .LC3
	ldr	d2, [x0, #:lo12:.LC3]
	fmul	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [sp, 72]
	ldr	x1, [sp, 120]
	ldr	x0, [sp, 104]
	sub	x0, x1, x0
	fmov	d0, x0
	scvtf	d1, d0
	ldr	x1, [sp, 128]
	ldr	x0, [sp, 112]
	sub	x0, x1, x0
	fmov	d0, x0
	scvtf	d0, d0
	adrp	x0, .LC3
	ldr	d2, [x0, #:lo12:.LC3]
	fmul	d0, d0, d2
	fadd	d0, d1, d0
	str	d0, [sp, 80]
	ldr	d0, [sp, 72]
	adrp	x0, .LC0
	add	x0, x0, :lo12:.LC0
	bl	printf
	ldr	d0, [sp, 80]
	adrp	x0, .LC1
	add	x0, x0, :lo12:.LC1
	bl	printf
	ldr	d0, [sp, 80]
	ldr	d1, [sp, 72]
	fdiv	d0, d1, d0
	adrp	x0, .LC2
	add	x0, x0, :lo12:.LC2
	bl	printf
	ldr	x0, [sp, 48]
	bl	free
	ldr	x0, [sp, 56]
	bl	free
	ldr	x0, [sp, 64]
	bl	free
	mov	w0, 0
	mov	w1, w0
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x3, [sp, 136]
	ldr	x2, [x0]
	subs	x3, x3, x2
	mov	x2, 0
	beq	.L22
	bl	__stack_chk_fail
.L22:
	mov	w0, w1
	ldp	x29, x30, [sp, 144]
	add	sp, sp, 160
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE4348:
	.size	main, .-main
	.section	.rodata
	.align	3
.LC3:
	.word	-400107883
	.word	1041313291
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04.3) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
