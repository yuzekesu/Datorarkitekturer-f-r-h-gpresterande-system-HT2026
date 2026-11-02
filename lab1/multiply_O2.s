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
.L1:
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
	ble	.L6
	sub	w3, w3, #1
	add	x4, x0, 16
	lsr	w3, w3, 2
	add	x3, x4, w3, uxtw 4
	.p2align 3,,7
.L8:
	ldr	q0, [x0], 16
	ldr	q1, [x1], 16
	fmul	v0.4s, v0.4s, v1.4s
	str	q0, [x2], 16
	cmp	x0, x3
	bne	.L8
.L6:
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
	sub	sp, sp, #144
	.cfi_def_cfa_offset 144
	adrp	x2, :got:__stack_chk_guard
	stp	x29, x30, [sp, 64]
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	add	x29, sp, 64
	ldr	x2, [x2, #:got_lo12:__stack_chk_guard]
	stp	x19, x20, [sp, 80]
	.cfi_offset 19, -64
	.cfi_offset 20, -56
	mov	w20, w0
	stp	x21, x22, [sp, 96]
	stp	x23, x24, [sp, 112]
	stp	d8, d9, [sp, 128]
	.cfi_offset 21, -48
	.cfi_offset 22, -40
	.cfi_offset 23, -32
	.cfi_offset 24, -24
	.cfi_offset 72, -16
	.cfi_offset 73, -8
	ldr	x0, [x2]
	str	x0, [sp, 56]
	mov	x0, 0
	cmp	w20, 1
	bgt	.L39
	mov	x1, 33792
	mov	x0, 16
	movk	x1, 0x17d7, lsl 16
	bl	aligned_alloc
	mov	x1, 33792
	mov	x20, x0
	movk	x1, 0x17d7, lsl 16
	mov	x0, 16
	bl	aligned_alloc
	mov	w19, 57600
	mov	x1, 33792
	mov	x21, x0
	movk	x1, 0x17d7, lsl 16
	mov	x0, 16
	bl	aligned_alloc
	mov	x22, x0
	movk	w19, 0x5f5, lsl 16
	mov	w23, 1
.L25:
	mov	w1, 12897
	mov	w0, 7130
	mov	w7, 1033
	mov	w6, 40193
	movk	w1, 0x3e15, lsl 16
	movk	w0, 0x3dfc, lsl 16
	fmov	s3, w1
	fmov	s2, w0
	mov	x2, 0
	movk	w7, 0x8102, lsl 16
	movk	w6, 0x317f, lsl 16
	mov	w5, 331
	.p2align 3,,7
.L14:
	smull	x3, w2, w7
	asr	w0, w2, 31
	smull	x1, w2, w6
	lsr	x3, x3, 32
	add	w3, w3, w2
	asr	x1, x1, 38
	sub	w1, w1, w0
	asr	w3, w3, 6
	sub	w3, w3, w0
	msub	w1, w1, w5, w2
	lsl	w4, w3, 7
	sub	w3, w4, w3
	sub	w3, w2, w3
	scvtf	s0, w1
	scvtf	s1, w3
	fmul	s0, s0, s2
	fmul	s1, s1, s3
	str	s0, [x21, x2, lsl 2]
	str	s1, [x20, x2, lsl 2]
	add	x2, x2, 1
	cmp	w19, w2
	bgt	.L14
	cmp	w19, 0
	sbfiz	x0, x19, 2, 32
	mov	x2, 4
	mov	w1, 0
	csel	x2, x0, x2, gt
	mov	x0, x22
	bl	memset
.L13:
	add	x1, sp, 8
	mov	w0, 1
	bl	clock_gettime
	mov	w0, 0
	cmp	w23, 0
	ble	.L40
	.p2align 3,,7
.L15:
	mov	x1, 0
	cmp	w19, 0
	ble	.L19
	.p2align 3,,7
.L17:
	ldr	s0, [x20, x1, lsl 2]
	ldr	s1, [x21, x1, lsl 2]
	fmul	s0, s0, s1
	str	s0, [x22, x1, lsl 2]
	add	x1, x1, 1
	cmp	w19, w1
	bgt	.L17
.L19:
	add	w0, w0, 1
	cmp	w0, w23
	bne	.L15
	add	x1, sp, 24
	mov	w0, 1
	bl	clock_gettime
	sub	w4, w19, #1
	add	x1, x20, 16
	mov	w0, 0
	lsr	w4, w4, 2
	add	x4, x1, w4, uxtw 4
	.p2align 3,,7
.L24:
	mov	x3, x21
	mov	x2, x22
	mov	x1, x20
	cmp	w19, 0
	ble	.L23
	.p2align 3,,7
.L20:
	ldr	q0, [x1], 16
	ldr	q1, [x3], 16
	fmul	v0.4s, v0.4s, v1.4s
	str	q0, [x2], 16
	cmp	x4, x1
	bne	.L20
.L23:
	add	w0, w0, 1
	cmp	w0, w23
	bne	.L24
.L21:
	add	x1, sp, 40
	mov	w0, 1
	bl	clock_gettime
	ldp	x2, x4, [sp, 8]
	adrp	x0, .LC3
	ldp	x7, x6, [sp, 24]
	adrp	x1, .LC0
	ldr	d2, [x0, #:lo12:.LC3]
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
	bne	.L41
	mov	w0, 0
	ldp	x29, x30, [sp, 64]
	ldp	x19, x20, [sp, 80]
	ldp	x21, x22, [sp, 96]
	ldp	x23, x24, [sp, 112]
	ldp	d8, d9, [sp, 128]
	add	sp, sp, 144
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
.L39:
	.cfi_restore_state
	mov	x21, x1
	mov	w2, 10
	mov	x1, 0
	ldr	x0, [x21, 8]
	bl	strtol
	mov	x24, x0
	mov	w19, w0
	cmp	w20, 2
	beq	.L27
	ldr	x0, [x21, 16]
	mov	w2, 10
	mov	x1, 0
	bl	strtol
	mov	w23, w0
.L12:
	sbfiz	x22, x24, 2, 32
	mov	x0, 16
	mov	x1, x22
	bl	aligned_alloc
	mov	x1, x22
	mov	x20, x0
	mov	x0, 16
	bl	aligned_alloc
	mov	x1, x22
	mov	x21, x0
	mov	x0, 16
	bl	aligned_alloc
	mov	x22, x0
	cmp	w24, 0
	bgt	.L25
	b	.L13
.L40:
	add	x1, sp, 24
	mov	w0, 1
	bl	clock_gettime
	b	.L21
.L27:
	mov	w23, 1
	b	.L12
.L41:
	bl	__stack_chk_fail
	.cfi_endproc
.LFE4381:
	.size	main, .-main
	.section	.rodata.cst8,"aM",@progbits,8
	.align	3
.LC3:
	.word	-400107883
	.word	1041313291
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04.3) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
