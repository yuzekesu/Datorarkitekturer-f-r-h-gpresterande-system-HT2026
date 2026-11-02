	.arch armv8-a
	.file	"multiply.c"
	.text
	.align	2
	.global	mult_std
	.type	mult_std, %function
mult_std:
.LFB4379:
	.cfi_startproc
	cmp	w3, 0
	ble	.L1
	mov	x4, 0
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
	.global	mult_vect
	.type	mult_vect, %function
mult_vect:
.LFB4380:
	.cfi_startproc
	cmp	w3, 0
	ble	.L5
	mov	x4, x0
	sub	w3, w3, #1
	lsr	w3, w3, 2
	add	x0, x0, 16
	add	x0, x0, x3, lsl 4
.L7:
	ldr	q0, [x4], 16
	ldr	q1, [x1], 16
	fmul	v0.4s, v0.4s, v1.4s
	str	q0, [x2], 16
	cmp	x4, x0
	bne	.L7
.L5:
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
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB4381:
	.cfi_startproc
	sub	sp, sp, #144
	.cfi_def_cfa_offset 144
	stp	x29, x30, [sp, 64]
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	add	x29, sp, 64
	stp	x19, x20, [sp, 80]
	stp	x21, x22, [sp, 96]
	stp	x23, x24, [sp, 112]
	stp	d8, d9, [sp, 128]
	.cfi_offset 19, -64
	.cfi_offset 20, -56
	.cfi_offset 21, -48
	.cfi_offset 22, -40
	.cfi_offset 23, -32
	.cfi_offset 24, -24
	.cfi_offset 72, -16
	.cfi_offset 73, -8
	mov	w19, w0
	mov	x20, x1
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x1, [x0]
	str	x1, [sp, 56]
	mov	x1, 0
	cmp	w19, 1
	bgt	.L31
	mov	x21, 33792
	movk	x21, 0x17d7, lsl 16
	mov	x1, x21
	mov	x0, 16
	bl	aligned_alloc
	mov	x19, x0
	mov	x1, x21
	mov	x0, 16
	bl	aligned_alloc
	mov	x20, x0
	mov	x1, x21
	mov	x0, 16
	bl	aligned_alloc
	mov	x21, x0
	mov	w23, 1
	mov	w22, 57600
	movk	w22, 0x5f5, lsl 16
.L19:
	mov	x3, 0
	mov	w7, 1033
	movk	w7, 0x8102, lsl 16
	adrp	x0, .LC3
	ldr	s2, [x0, #:lo12:.LC3]
	mov	w6, 40193
	movk	w6, 0x317f, lsl 16
	mov	w5, 331
	adrp	x0, .LC4
	ldr	s1, [x0, #:lo12:.LC4]
.L13:
	smull	x0, w3, w7
	lsr	x0, x0, 32
	add	w0, w0, w3
	asr	w0, w0, 6
	asr	w2, w3, 31
	sub	w0, w0, w2
	lsl	w1, w0, 7
	sub	w0, w1, w0
	sub	w0, w3, w0
	scvtf	s0, w0
	fmul	s0, s0, s2
	str	s0, [x19, x3, lsl 2]
	smull	x4, w3, w6
	asr	x4, x4, 38
	sub	w4, w4, w2
	msub	w4, w4, w5, w3
	scvtf	s0, w4
	fmul	s0, s0, s1
	str	s0, [x20, x3, lsl 2]
	str	wzr, [x21, x3, lsl 2]
	add	x3, x3, 1
	cmp	w22, w3
	bgt	.L13
.L12:
	add	x1, sp, 8
	mov	w0, 1
	bl	clock_gettime
	cmp	w23, 0
	ble	.L14
.L20:
	mov	w24, 0
.L15:
	mov	w3, w22
	mov	x2, x21
	mov	x1, x20
	mov	x0, x19
	bl	mult_std
	add	w24, w24, 1
	cmp	w24, w23
	bne	.L15
	add	x1, sp, 24
	mov	w0, 1
	bl	clock_gettime
	mov	w24, 0
.L17:
	mov	w3, w22
	mov	x2, x21
	mov	x1, x20
	mov	x0, x19
	bl	mult_vect
	add	w24, w24, 1
	cmp	w24, w23
	bne	.L17
.L18:
	add	x1, sp, 40
	mov	w0, 1
	bl	clock_gettime
	ldr	x1, [sp, 24]
	ldr	x2, [sp, 32]
	ldr	x0, [sp, 16]
	sub	x0, x2, x0
	fmov	d9, x0
	scvtf	d9, d9
	adrp	x0, .LC5
	ldr	d1, [x0, #:lo12:.LC5]
	fmul	d9, d9, d1
	ldr	x0, [sp, 8]
	sub	x0, x1, x0
	fmov	d0, x0
	scvtf	d0, d0
	fadd	d9, d9, d0
	ldr	x0, [sp, 48]
	sub	x0, x0, x2
	fmov	d8, x0
	scvtf	d8, d8
	fmul	d8, d8, d1
	ldr	x0, [sp, 40]
	sub	x0, x0, x1
	fmov	d0, x0
	scvtf	d0, d0
	fadd	d8, d8, d0
	fmov	d0, d9
	adrp	x1, .LC0
	add	x1, x1, :lo12:.LC0
	mov	w0, 1
	bl	__printf_chk
	fmov	d0, d8
	adrp	x1, .LC1
	add	x1, x1, :lo12:.LC1
	mov	w0, 1
	bl	__printf_chk
	fdiv	d0, d9, d8
	adrp	x1, .LC2
	add	x1, x1, :lo12:.LC2
	mov	w0, 1
	bl	__printf_chk
	mov	x0, x19
	bl	free
	mov	x0, x20
	bl	free
	mov	x0, x21
	bl	free
	adrp	x0, :got:__stack_chk_guard
	ldr	x0, [x0, #:got_lo12:__stack_chk_guard]
	ldr	x2, [sp, 56]
	ldr	x1, [x0]
	subs	x2, x2, x1
	mov	x1, 0
	bne	.L32
	mov	w0, 0
	ldp	d8, d9, [sp, 128]
	ldp	x19, x20, [sp, 80]
	ldp	x21, x22, [sp, 96]
	ldp	x23, x24, [sp, 112]
	ldp	x29, x30, [sp, 64]
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
.L31:
	.cfi_restore_state
	mov	w2, 10
	ldr	x0, [x20, 8]
	bl	strtol
	mov	x24, x0
	mov	w22, w0
	cmp	w19, 2
	bgt	.L33
	sbfiz	x21, x0, 2, 32
	mov	x1, x21
	mov	x0, 16
	bl	aligned_alloc
	mov	x19, x0
	mov	x1, x21
	mov	x0, 16
	bl	aligned_alloc
	mov	x20, x0
	mov	x1, x21
	mov	x0, 16
	bl	aligned_alloc
	mov	x21, x0
	cmp	w24, 0
	ble	.L34
	mov	w23, 1
	b	.L19
.L33:
	mov	w2, 10
	mov	x1, 0
	ldr	x0, [x20, 16]
	bl	strtol
	mov	w23, w0
	sbfiz	x21, x24, 2, 32
	mov	x1, x21
	mov	x0, 16
	bl	aligned_alloc
	mov	x19, x0
	mov	x1, x21
	mov	x0, 16
	bl	aligned_alloc
	mov	x20, x0
	mov	x1, x21
	mov	x0, 16
	bl	aligned_alloc
	mov	x21, x0
	cmp	w24, 0
	bgt	.L19
	b	.L12
.L14:
	add	x1, sp, 24
	mov	w0, 1
	bl	clock_gettime
	b	.L18
.L34:
	add	x1, sp, 8
	mov	w0, 1
	bl	clock_gettime
	mov	w23, 1
	b	.L20
.L32:
	bl	__stack_chk_fail
	.cfi_endproc
.LFE4381:
	.size	main, .-main
	.section	.rodata.cst4,"aM",@progbits,4
	.align	2
.LC3:
	.word	1041576545
	.align	2
.LC4:
	.word	1039932378
	.section	.rodata.cst8,"aM",@progbits,8
	.align	3
.LC5:
	.word	-400107883
	.word	1041313291
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04.3) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
