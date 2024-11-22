	.file	"main.cpp"
	.text
	.p2align 4
	.globl	_Z4getV7uint288
	.type	_Z4getV7uint288, @function
_Z4getV7uint288:
.LFB2524:
	.cfi_startproc
	endbr64
	xorl	%eax, %eax
	xorl	%edi, %edi
	xorl	%esi, %esi
	.p2align 4,,10
	.p2align 3
.L3:
	movl	%eax, %edx
	sarl	$5, %edx
	movslq	%edx, %rdx
	movl	8(%rsp,%rdx,4), %ecx
	movl	%eax, %edx
	andl	$31, %edx
	btq	%rdx, %rcx
	jnc	.L2
	addl	$1, %esi
	movl	%eax, %edi
.L2:
	addl	$1, %eax
	cmpl	$288, %eax
	jne	.L3
	movl	%esi, %eax
	leal	0(,%rdi,8), %edx
	sall	$4, %eax
	subl	%edi, %edx
	subl	%esi, %eax
	leal	-15(%rdx,%rax), %eax
	ret
	.cfi_endproc
.LFE2524:
	.size	_Z4getV7uint288, .-_Z4getV7uint288
	.p2align 4
	.globl	_Z4getL7uint288
	.type	_Z4getL7uint288, @function
_Z4getL7uint288:
.LFB2525:
	.cfi_startproc
	endbr64
	xorl	%edx, %edx
	xorl	%r8d, %r8d
	.p2align 4,,10
	.p2align 3
.L11:
	movl	%edx, %eax
	movl	%edx, %ecx
	addl	$1, %edx
	sarl	$5, %eax
	andl	$31, %ecx
	cltq
	movl	8(%rsp,%rax,4), %eax
	shrq	%cl, %rax
	andl	$1, %eax
	addl	%eax, %r8d
	cmpl	$288, %edx
	jne	.L11
	movl	%r8d, %eax
	ret
	.cfi_endproc
.LFE2525:
	.size	_Z4getL7uint288, .-_Z4getL7uint288
	.p2align 4
	.globl	_Z9min_indexiii
	.type	_Z9min_indexiii, @function
_Z9min_indexiii:
.LFB2526:
	.cfi_startproc
	endbr64
	cmpl	%esi, %edi
	jge	.L16
	xorl	%eax, %eax
	cmpl	%edx, %edi
	setge	%al
	addl	%eax, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L16:
	xorl	%eax, %eax
	cmpl	%edx, %esi
	setge	%al
	addl	$1, %eax
	ret
	.cfi_endproc
.LFE2526:
	.size	_Z9min_indexiii, .-_Z9min_indexiii
	.p2align 4
	.globl	_Z9min_indexii
	.type	_Z9min_indexii, @function
_Z9min_indexii:
.LFB2527:
	.cfi_startproc
	endbr64
	xorl	%eax, %eax
	cmpl	%esi, %edi
	setge	%al
	ret
	.cfi_endproc
.LFE2527:
	.size	_Z9min_indexii, .-_Z9min_indexii
	.section	.text._Z6getDBC7uint288,"axG",@progbits,_Z6getDBC7uint288,comdat
	.p2align 4
	.weak	_Z6getDBC7uint288
	.type	_Z6getDBC7uint288, @function
_Z6getDBC7uint288:
.LFB2528:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	xorl	%edi, %edi
	xorl	%esi, %esi
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$232, %rsp
	.cfi_def_cfa_offset 288
	movq	%fs:40, %rax
	movq	%rax, 216(%rsp)
	xorl	%eax, %eax
	movl	320(%rsp), %eax
	movdqu	288(%rsp), %xmm0
	movdqu	304(%rsp), %xmm1
	movl	%eax, 208(%rsp)
	xorl	%eax, %eax
	movaps	%xmm0, 176(%rsp)
	movaps	%xmm1, 192(%rsp)
.L23:
	movl	%eax, %edx
	sarl	$5, %edx
	movslq	%edx, %rdx
	movl	176(%rsp,%rdx,4), %ecx
	movl	%eax, %edx
	andl	$31, %edx
	btq	%rdx, %rcx
	jnc	.L22
	addl	$1, %esi
	movl	%eax, %edi
.L22:
	addl	$1, %eax
	cmpl	$288, %eax
	jne	.L23
	movl	%esi, %eax
	leal	0(,%rdi,8), %edx
	leaq	128(%rsp), %rbp
	movl	$257, %ebx
	sall	$4, %eax
	subl	%edi, %edx
	leaq	B(%rip), %r12
	movq	%rbp, %rdi
	subl	%esi, %eax
	leaq	288(%rsp), %rsi
	leal	-15(%rdx,%rax), %eax
	movl	%eax, 8+w_min0(%rip)
	call	_ZN7uint2885mul_2Ev@PLT
	movl	160(%rsp), %eax
	movq	%rbp, %rdi
	movdqu	128(%rsp), %xmm2
	movdqu	144(%rsp), %xmm3
	leaq	B(%rip), %rsi
	leaq	1526580+pow23_256(%rip), %rbp
	movl	%eax, 32+B(%rip)
	movaps	%xmm2, B(%rip)
	movaps	%xmm3, 16+B(%rip)
	call	_ZN7uint2885mul_3Ev@PLT
	movl	160(%rsp), %eax
	movdqu	128(%rsp), %xmm4
	movdqa	B(%rip), %xmm6
	movdqa	16+B(%rip), %xmm7
	movdqu	144(%rsp), %xmm5
	movl	%eax, 32+six_n(%rip)
	movl	32+B(%rip), %eax
	movaps	%xmm4, six_n(%rip)
	movaps	%xmm5, 16+six_n(%rip)
	movl	%eax, 32+record_outer(%rip)
	movaps	%xmm6, record_outer(%rip)
	movaps	%xmm7, 16+record_outer(%rip)
	jmp	.L25
.L115:
	subl	$1, %ebx
	subq	$5940, %rbp
	cmpl	$-1, %ebx
	je	.L114
.L25:
	movq	%rbp, %rsi
	movq	%r12, %rdi
	call	_ZgeRK7uint288S1_@PLT
	testb	%al, %al
	je	.L115
.L24:
	leaq	5832+pow23_256(%rip), %rbp
	movl	$162, %r13d
	leaq	B(%rip), %r12
	jmp	.L28
.L117:
	subl	$1, %r13d
	subq	$36, %rbp
	cmpl	$-1, %r13d
	je	.L116
.L28:
	movq	%rbp, %rsi
	movq	%r12, %rdi
	call	_ZgeRK7uint288S1_@PLT
	testb	%al, %al
	je	.L117
	movl	%ebx, bBound(%rip)
	movl	%r13d, %ebx
	movl	%r13d, %eax
	imulq	$954437177, %rbx, %rbx
	movl	%r13d, 76(%rsp)
	shrq	$34, %rbx
	testl	%r13d, %r13d
	je	.L29
	leaq	4+bBound(%rip), %rbp
	subl	$1, %eax
	movl	$36, %r12d
	movl	$256, %r14d
	leaq	4(%rbp), %rdx
	leaq	B(%rip), %r13
	leaq	(%rdx,%rax,4), %rax
	movq	%rax, (%rsp)
.L34:
	testl	%r14d, %r14d
	js	.L30
	movslq	%r14d, %r15
	leaq	pow23_256(%rip), %rax
	imulq	$5940, %r15, %r15
	addq	%r12, %r15
	addq	%rax, %r15
	jmp	.L33
.L31:
	subq	$5940, %r15
	cmpl	$-1, %r14d
	je	.L118
.L33:
	movq	%r15, %rsi
	movq	%r13, %rdi
	call	_ZgeRK7uint288S1_@PLT
	movl	%r14d, %edx
	subl	$1, %r14d
	testb	%al, %al
	je	.L31
	movl	%edx, 0(%rbp)
.L32:
	addq	$4, %rbp
	addq	$36, %r12
	cmpq	(%rsp), %rbp
	jne	.L34
.L29:
	movl	32+six_n(%rip), %eax
	movdqa	six_n(%rip), %xmm0
	movq	$0, 104(%rsp)
	movdqa	16+six_n(%rip), %xmm1
	movl	$1, 116(%rsp)
	movl	%eax, 32+record_outer(%rip)
	leaq	bBound(%rip), %rax
	movq	%rax, 96(%rsp)
	leal	(%rbx,%rbx,8), %eax
	leal	36(%rax,%rax), %eax
	movl	$0, 112(%rsp)
	movl	%eax, 124(%rsp)
	movaps	%xmm0, record_outer(%rip)
	movaps	%xmm1, 16+record_outer(%rip)
.L37:
	leaq	record_outer(%rip), %rax
	leaq	32+temp_outer(%rip), %rdi
	movdqa	(%rax), %xmm2
	leaq	temp_outer(%rip), %rax
	movaps	%xmm2, (%rax)
	leaq	16+record_outer(%rip), %rax
	movdqa	(%rax), %xmm4
	leaq	16+temp_outer(%rip), %rax
	movaps	%xmm4, (%rax)
	leaq	32+record_outer(%rip), %rax
	movl	(%rax), %eax
	movaps	%xmm4, (%rsp)
	movl	%eax, (%rdi)
	movq	96(%rsp), %rax
	movl	(%rax), %edx
	movl	%edx, %eax
	sarl	$5, %eax
	cmpl	$-32, %edx
	jl	.L39
	addl	$3, %eax
	movl	$0, 72(%rsp)
	sall	$5, %eax
	movl	$32, (%rsp)
	movl	%eax, 120(%rsp)
.L40:
	leaq	temp_outer(%rip), %rdi
	call	_ZN7uint28813mod_2_33_3_19Ev@PLT
	movq	96(%rsp), %r10
	movl	112(%rsp), %r14d
	leaq	pow23_256(%rip), %rdi
	movq	%rax, n0(%rip)
	leaq	pow23_1(%rip), %rax
	movq	%rax, 48(%rsp)
	movslq	72(%rsp), %rax
	movq	%r10, %r11
	movl	%r14d, %r15d
	imulq	$5940, %rax, %rdx
	imulq	$1080, %rax, %rax
	addq	%rdx, %rdi
	movq	%rdi, 80(%rsp)
	movq	104(%rsp), %rdi
	addq	$2, %rax
	movq	%rax, 88(%rsp)
	movq	%rdi, 56(%rsp)
	movl	116(%rsp), %edi
	movl	%edi, 68(%rsp)
	.p2align 4,,10
	.p2align 3
.L67:
	cmpl	76(%rsp), %r15d
	jg	.L66
	imull	$22, %r15d, %eax
	movslq	68(%rsp), %r10
	movq	88(%rsp), %rdi
	movq	80(%rsp), %r14
	movq	48(%rsp), %r12
	movl	72(%rsp), %ebx
	addq	56(%rsp), %r14
	movq	%r10, 24(%rsp)
	movl	%eax, 44(%rsp)
	leaq	(%r10,%r10,2), %rax
	leaq	(%rdi,%rax,2), %rbp
	leaq	w_rec(%rip), %rax
	addq	%rax, %rbp
	movslq	%r15d, %rax
	leaq	(%rax,%rax,2), %rax
	addq	%rax, %rax
	movq	%rax, 32(%rsp)
	movl	%r15d, %eax
	movq	%r11, %r15
	movl	%eax, %r11d
	jmp	.L65
	.p2align 4,,10
	.p2align 3
.L43:
	movl	%r13d, %ebx
	addq	$5940, %r14
	addq	$152, %r12
	addq	$1080, %rbp
	cmpl	%r13d, (%rsp)
	je	.L119
.L65:
	leal	(%r11,%rbx), %eax
	leal	1(%rbx), %r13d
	testl	%eax, %eax
	jle	.L41
	leal	1(%rbx), %r13d
	cmpl	(%r15), %ebx
	jg	.L43
	movq	n0(%rip), %rax
	xorl	%edx, %edx
	leal	1(%rbx), %r13d
	leaq	w_rec(%rip), %rdi
	divq	(%r12)
	movq	%rax, %rsi
	movabsq	$-6148914691236517205, %rax
	mulq	%rsi
	movq	32(%rsp), %rax
	shrq	$2, %rdx
	leaq	(%rdx,%rdx,2), %rcx
	addq	%rcx, %rcx
	subq	%rcx, %rsi
	movslq	%r13d, %rcx
	imulq	$1080, %rcx, %r8
	movq	%rsi, %rdx
	movzwl	-2(%rbp), %esi
	addq	%r8, %rax
	addq	%rdi, %rax
	movzwl	2(%rax), %r9d
	movw	%r9w, 40(%rsp)
	cmpq	$1, %rdx
	jbe	.L120
	movzwl	0(%rbp), %r9d
	cmpq	$2, %rdx
	je	.L121
	movzwl	%r9w, %r10d
	movl	%r10d, %edi
	movzwl	%si, %r10d
	addl	$1, %r10d
	movl	%r10d, 64(%rsp)
	leal	1(%rsi), %r10d
	cmpl	$3, %edx
	je	.L122
	movl	%edi, %edx
	movl	64(%rsp), %edi
	cmpl	%edi, %edx
	jle	.L57
	cmpw	%si, 40(%rsp)
	jbe	.L59
	movq	24(%rsp), %rdi
	movl	$8466, %esi
	leaq	(%rdi,%rdi,2), %rdx
	leaq	w_rec(%rip), %rdi
	leaq	(%r8,%rdx,2), %rdx
	addq	%rdi, %rdx
	movw	%r10w, (%rdx)
	movzwl	(%rax), %eax
	movw	%si, 4(%rdx)
	addl	$1, %eax
	movw	%ax, 2(%rdx)
	.p2align 4,,10
	.p2align 3
.L41:
	cmpl	%ebx, (%r15)
	jne	.L43
	leaq	288(%rsp), %rdi
	movq	%r14, %rsi
	movl	%r11d, 40(%rsp)
	call	_ZgeRK7uint288S1_@PLT
	movq	24(%rsp), %rdi
	movl	40(%rsp), %r11d
	leal	0(,%rbx,8), %edx
	subl	%ebx, %edx
	testb	%al, %al
	movslq	%r13d, %rax
	leaq	(%rdi,%rdi,2), %rcx
	je	.L62
	imulq	$1080, %rax, %rax
	leaq	w_rec(%rip), %rdi
	leaq	(%rax,%rcx,2), %rax
	movzwl	(%rdi,%rax), %ecx
	movl	%ecx, %eax
	sall	$4, %eax
	subl	%ecx, %eax
	addl	%edx, %eax
	addl	44(%rsp), %eax
	cmpl	%eax, 8+w_min0(%rip)
	jbe	.L43
	movl	%ebx, w_min0(%rip)
	movl	%r11d, 4+w_min0(%rip)
	movl	%eax, 8+w_min0(%rip)
	movl	$1, 12+w_min0(%rip)
	jmp	.L43
.L118:
	movl	$-2, %r14d
	jmp	.L32
	.p2align 4,,10
	.p2align 3
.L120:
	movzwl	(%rax), %eax
	movzwl	%r9w, %edx
	movzwl	%si, %r9d
	addl	$1, %edx
	movl	%eax, %r10d
	cmpl	%r9d, %eax
	jle	.L45
	cmpl	%r9d, %edx
	jle	.L50
	movq	24(%rsp), %rax
	leaq	(%rax,%rax,2), %rax
	leaq	(%r8,%rax,2), %rax
.L111:
	addq	%rdi, %rax
	movw	%si, (%rax)
	movzwl	0(%rbp), %edi
	leal	1(%rdi), %edx
	movw	%dx, 2(%rax)
	movl	$291, %edx
	movw	%dx, 4(%rax)
	jmp	.L41
	.p2align 4,,10
	.p2align 3
.L62:
	imulq	$1080, %rax, %rax
	leaq	w_rec(%rip), %rdi
	leaq	(%rax,%rcx,2), %rax
	addq	%rdi, %rax
	movzwl	(%rax), %ecx
	subl	$1, %ecx
	movl	%ecx, %esi
	sall	$4, %esi
	subl	%ecx, %esi
	leal	-7(%rdx,%rsi), %ecx
	movzwl	2(%rax), %esi
	movl	%esi, %eax
	sall	$4, %eax
	subl	%esi, %eax
	movl	44(%rsp), %esi
	addl	%edx, %eax
	movl	8+w_min0(%rip), %edx
	leal	(%rsi,%rax), %edi
	addl	%ecx, %esi
	cmpl	%esi, %edx
	jbe	.L63
	movl	%ebx, w_min0(%rip)
	movl	%r11d, 4+w_min0(%rip)
	cmpl	%eax, %ecx
	jg	.L112
	movl	%esi, 8+w_min0(%rip)
	movl	$2, 12+w_min0(%rip)
	jmp	.L43
	.p2align 4,,10
	.p2align 3
.L50:
	imulq	$1080, %rcx, %rcx
	movq	24(%rsp), %rax
	leaq	w_rec(%rip), %rdi
	movl	$5155, %r9d
	leaq	(%rax,%rax,2), %rax
	leaq	(%rcx,%rax,2), %rax
	addq	%rdi, %rax
	movzwl	40(%rsp), %edi
	addl	$1, %edi
	movw	%di, (%rax)
	movzwl	0(%rbp), %edi
	movw	%r9w, 4(%rax)
	leal	1(%rdi), %edx
	movw	%dx, 2(%rax)
	jmp	.L41
	.p2align 4,,10
	.p2align 3
.L45:
	cmpl	%eax, %edx
	jle	.L50
	movq	24(%rsp), %rax
	leaq	w_rec(%rip), %rdi
	movl	$547, %ecx
	leaq	(%rax,%rax,2), %rax
	leaq	(%r8,%rax,2), %rax
	addq	%rdi, %rax
	movw	%r10w, (%rax)
	movzwl	0(%rbp), %edi
	movw	%cx, 4(%rax)
	leal	1(%rdi), %edx
	movw	%dx, 2(%rax)
	jmp	.L41
	.p2align 4,,10
	.p2align 3
.L121:
	cmpw	%r9w, %si
	ja	.L48
	cmpw	%si, 40(%rsp)
	jb	.L50
	movq	24(%rsp), %rax
	leaq	w_rec(%rip), %rdi
	leaq	(%rax,%rax,2), %rax
	leaq	(%r8,%rax,2), %rax
	jmp	.L111
	.p2align 4,,10
	.p2align 3
.L63:
	cmpl	%edi, %edx
	jbe	.L43
	movl	%ebx, w_min0(%rip)
	movl	%r11d, 4+w_min0(%rip)
.L112:
	movl	%edi, 8+w_min0(%rip)
	movl	$3, 12+w_min0(%rip)
	jmp	.L43
	.p2align 4,,10
	.p2align 3
.L122:
	movl	%edi, %eax
	movl	64(%rsp), %edi
	cmpl	%edi, %eax
	jle	.L53
	cmpw	%si, 40(%rsp)
	jbe	.L55
	movq	24(%rsp), %rax
	leaq	w_rec(%rip), %rdi
	leaq	(%rax,%rax,2), %rax
	leaq	(%r8,%rax,2), %rax
	movl	$8481, %r8d
	addq	%rdi, %rax
	movw	%r10w, (%rax)
	movzwl	-2(%rbp), %edi
	movw	%r8w, 4(%rax)
	leal	1(%rdi), %edx
	movw	%dx, 2(%rax)
	jmp	.L41
	.p2align 4,,10
	.p2align 3
.L57:
	cmpw	%r9w, 40(%rsp)
	jb	.L59
.L60:
	movq	24(%rsp), %rax
	leaq	w_rec(%rip), %rdi
	movl	$8451, %ecx
	leaq	(%rax,%rax,2), %rax
	leaq	(%r8,%rax,2), %rax
	addq	%rdi, %rax
	movw	%r10w, (%rax)
	movzwl	0(%rbp), %edx
	movw	%cx, 4(%rax)
	movw	%dx, 2(%rax)
	jmp	.L41
	.p2align 4,,10
	.p2align 3
.L59:
	imulq	$1080, %rcx, %rcx
	movq	24(%rsp), %rax
	leaq	w_rec(%rip), %rdi
	leaq	(%rax,%rax,2), %rax
	leaq	(%rcx,%rax,2), %rax
	addq	32(%rsp), %rcx
	addq	%rdi, %rax
	movw	%r10w, (%rax)
	movzwl	2(%rdi,%rcx), %edx
	movw	%dx, 2(%rax)
	movl	$8452, %edx
	movw	%dx, 4(%rax)
	jmp	.L41
	.p2align 4,,10
	.p2align 3
.L119:
	movl	%r11d, %eax
	addq	$8, 48(%rsp)
	movq	%r15, %r11
	movl	%eax, %r15d
	movq	48(%rsp), %rax
	addq	$4, %r11
	leaq	144+pow23_1(%rip), %rdi
	addl	$1, 68(%rsp)
	addl	$1, %r15d
	addq	$36, 56(%rsp)
	cmpq	%rax, %rdi
	jne	.L67
.L66:
	leaq	temp_outer(%rip), %rsi
	movq	%rsi, %rdi
	call	_ZN7uint2889rshift_32ERS_@PLT
	addl	$32, (%rsp)
	movl	(%rsp), %eax
	addl	$32, 72(%rsp)
	cmpl	120(%rsp), %eax
	jne	.L40
.L39:
	leaq	record_outer(%rip), %rdi
	call	_ZN7uint2888div_3_18Ev@PLT
	addl	$18, 112(%rsp)
	movl	112(%rsp), %eax
	addq	$72, 96(%rsp)
	addl	$18, 116(%rsp)
	addq	$648, 104(%rsp)
	cmpl	%eax, 124(%rsp)
	jne	.L37
	movl	12+w_min0(%rip), %eax
	movl	w_min0(%rip), %r9d
	movl	4+w_min0(%rip), %r8d
	cmpl	$2, %eax
	je	.L68
	ja	.L69
	testl	%eax, %eax
	je	.L123
	leal	1(%r9), %ecx
	leal	1(%r8), %edi
	movslq	%ecx, %rax
	movslq	%edi, %rdx
	leaq	w_rec(%rip), %r10
	imulq	$1080, %rax, %rax
	leaq	(%rdx,%rdx,2), %rdx
	leaq	(%rax,%rdx,2), %rax
	movzwl	(%r10,%rax), %edx
	movq	%rdx, %rax
	leaq	(%rdx,%rdx,2), %rsi
	leaq	now_DBC(%rip), %rdx
	leaq	(%rdx,%rsi,2), %rdx
	movw	%r9w, (%rdx)
	movw	%r8w, 2(%rdx)
	movb	$0, 4(%rdx)
	leal	1(%rax), %edx
	subl	$1, %eax
	movl	%edx, 4+w_min(%rip)
	xorl	%edx, %edx
.L73:
	leaq	now_DBC(%rip), %rsi
	jmp	.L91
.L125:
	shrw	$12, %di
	cmpw	$1, %di
	je	.L124
	cmpw	$2, %di
	jne	.L77
	movslq	%eax, %rdi
	leal	-1(%r9), %r11d
	subl	$1, %eax
	leaq	(%rdi,%rdi,2), %rdi
	leaq	(%rsi,%rdi,2), %rdi
	movw	%r11w, (%rdi)
	movw	%r8w, 2(%rdi)
	movb	$0, 4(%rdi)
.L77:
	sarl	$8, %ecx
	movl	%ecx, %edi
	andl	$15, %edi
	cmpl	$3, %edi
	je	.L78
.L130:
	andl	$12, %ecx
	jne	.L79
	cmpl	$1, %edi
	je	.L88
	cmpl	$2, %edi
	jne	.L113
.L89:
	subl	$1, %r8d
	xorl	%edx, %edx
.L82:
	testl	%eax, %eax
	js	.L74
.L128:
	leal	1(%r8), %edi
	leal	1(%r9), %ecx
.L91:
	movslq	%ecx, %rcx
	movslq	%edi, %rdi
	imulq	$1080, %rcx, %rcx
	leaq	(%rdi,%rdi,2), %rdi
	leaq	(%rcx,%rdi,2), %rcx
	movzwl	4(%r10,%rcx), %ecx
	movl	%ecx, %edi
	testl	%edx, %edx
	je	.L125
	sarl	$4, %ecx
	andl	$15, %ecx
	cmpl	$1, %ecx
	je	.L126
	cmpl	$2, %ecx
	jne	.L85
	movslq	%eax, %rcx
	leal	-1(%r9), %r11d
	subl	$1, %eax
	leaq	(%rcx,%rcx,2), %rcx
	leaq	(%rsi,%rcx,2), %rcx
	movw	%r11w, (%rcx)
	movw	%r8w, 2(%rcx)
	movb	$1, 4(%rcx)
.L85:
	movl	%edi, %ecx
	andl	$15, %ecx
	cmpw	$3, %cx
	je	.L86
.L131:
	andl	$12, %edi
	jne	.L87
	cmpw	$1, %cx
	je	.L88
	cmpw	$2, %cx
	je	.L89
	jmp	.L82
	.p2align 4,,10
	.p2align 3
.L48:
	cmpw	%r9w, 40(%rsp)
	jbe	.L50
	movq	24(%rsp), %rax
	addl	$1, %r9d
	leaq	w_rec(%rip), %rdi
	movl	$8995, %r10d
	leaq	(%rax,%rax,2), %rax
	leaq	(%r8,%rax,2), %rax
	addq	%rdi, %rax
	movw	%r9w, (%rax)
	movzwl	0(%rbp), %edi
	movw	%r10w, 4(%rax)
	leal	1(%rdi), %edx
	movw	%dx, 2(%rax)
	jmp	.L41
	.p2align 4,,10
	.p2align 3
.L53:
	cmpw	%r9w, 40(%rsp)
	jnb	.L60
.L55:
	imulq	$1080, %rcx, %rcx
	movq	24(%rsp), %rax
	leaq	w_rec(%rip), %rdi
	leaq	(%rax,%rax,2), %rax
	leaq	(%rcx,%rax,2), %rax
	addq	32(%rsp), %rcx
	addq	%rdi, %rax
	movw	%r10w, (%rax)
	movzwl	2(%rdi,%rcx), %edx
	movl	$8468, %edi
	movw	%di, 4(%rax)
	addl	$1, %edx
	movw	%dx, 2(%rax)
	jmp	.L41
.L69:
	cmpl	$3, %eax
	jne	.L127
	leal	1(%r9), %ecx
	leal	1(%r8), %edi
	movslq	%ecx, %rax
	movslq	%edi, %rdx
	leaq	w_rec(%rip), %r10
	imulq	$1080, %rax, %rax
	leaq	(%rdx,%rdx,2), %rdx
	leaq	(%rax,%rdx,2), %rax
	movzwl	2(%r10,%rax), %edx
	movq	%rdx, %rax
	leaq	(%rdx,%rdx,2), %rsi
	leaq	now_DBC(%rip), %rdx
	leaq	(%rdx,%rsi,2), %rdx
	movw	%r9w, (%rdx)
	movw	%r8w, 2(%rdx)
	movb	$0, 4(%rdx)
	leal	1(%rax), %edx
	subl	$1, %eax
	movl	%edx, 4+w_min(%rip)
	movl	$1, %edx
	jmp	.L73
	.p2align 4,,10
	.p2align 3
.L79:
	cmpl	$4, %edi
	jne	.L82
	subl	$1, %r8d
	movl	$1, %edx
	testl	%eax, %eax
	jns	.L128
.L74:
	movq	216(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L129
	addq	$232, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	xorl	%eax, %eax
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L87:
	.cfi_restore_state
	cmpw	$4, %cx
	sete	%cl
	movzbl	%cl, %ecx
	subl	%ecx, %r8d
	jmp	.L82
.L88:
	subl	$1, %r9d
.L113:
	xorl	%edx, %edx
	jmp	.L82
.L124:
	movslq	%eax, %rdi
	leal	-1(%r8), %r11d
	sarl	$8, %ecx
	subl	$1, %eax
	leaq	(%rdi,%rdi,2), %rdi
	leaq	(%rsi,%rdi,2), %rdi
	movw	%r9w, (%rdi)
	movw	%r11w, 2(%rdi)
	movb	$0, 4(%rdi)
	movl	%ecx, %edi
	andl	$15, %edi
	cmpl	$3, %edi
	jne	.L130
.L78:
	subl	$1, %r9d
	movl	$1, %edx
	jmp	.L82
.L126:
	movslq	%eax, %rcx
	leal	-1(%r8), %r11d
	subl	$1, %eax
	leaq	(%rcx,%rcx,2), %rcx
	leaq	(%rsi,%rcx,2), %rcx
	movw	%r9w, (%rcx)
	movw	%r11w, 2(%rcx)
	movb	$1, 4(%rcx)
	movl	%edi, %ecx
	andl	$15, %ecx
	cmpw	$3, %cx
	jne	.L131
.L86:
	subl	$1, %r9d
	jmp	.L82
.L127:
	movl	$-1, %eax
	leal	1(%r8), %edi
	leal	1(%r9), %ecx
	xorl	%edx, %edx
	leaq	w_rec(%rip), %r10
	jmp	.L73
.L30:
	subl	$1, %r14d
	jmp	.L32
.L114:
	xorl	%ebx, %ebx
	jmp	.L24
.L116:
	movl	%ebx, bBound(%rip)
	xorl	%ebx, %ebx
	movl	$0, 76(%rsp)
	jmp	.L29
.L68:
	leal	1(%r9), %ecx
	leal	1(%r8), %edi
	movslq	%ecx, %rax
	movslq	%edi, %rdx
	leaq	w_rec(%rip), %r10
	imulq	$1080, %rax, %rax
	leaq	(%rdx,%rdx,2), %rdx
	leaq	(%rax,%rdx,2), %rax
	xorl	%edx, %edx
	movzwl	(%r10,%rax), %eax
	movl	%eax, 4+w_min(%rip)
	subl	$1, %eax
	jmp	.L73
.L123:
	subq	$48, %rsp
	.cfi_def_cfa_offset 336
	leaq	w_min(%rip), %rdi
	movdqu	336(%rsp), %xmm6
	movl	368(%rsp), %eax
	movdqu	352(%rsp), %xmm7
	movups	%xmm6, (%rsp)
	movups	%xmm7, 16(%rsp)
	movl	%eax, 32(%rsp)
	call	_ZN3DBCaSE7uint288@PLT
	addq	$48, %rsp
	.cfi_def_cfa_offset 288
	leaq	w_min(%rip), %rdi
	call	_ZN3DBC6simDBCEv@PLT
	jmp	.L74
.L129:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE2528:
	.size	_Z6getDBC7uint288, .-_Z6getDBC7uint288
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"\350\257\267\350\276\223\345\205\245\345\200\215\347\202\271\347\232\204\345\200\215\346\225\260\357\274\232"
.LC1:
	.string	"\346\234\200\344\274\230DBC\357\274\232"
.LC2:
	.string	"DBC\345\212\240\346\263\225\346\225\260\351\207\217\357\274\232"
.LC3:
	.string	"DBC\350\256\241\347\256\227\346\227\266\351\227\264\357\274\232"
.LC4:
	.string	"("
.LC6:
	.string	"s)"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB2529:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pxor	%xmm0, %xmm0
	pushq	%rbx
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	movl	$1000, %ebx
	subq	$136, %rsp
	.cfi_def_cfa_offset 160
	movq	%fs:40, %rax
	movq	%rax, 120(%rsp)
	xorl	%eax, %eax
	leaq	48(%rsp), %rbp
	movaps	%xmm0, 48(%rsp)
	movaps	%xmm0, 64(%rsp)
	movaps	%xmm0, 80(%rsp)
	movaps	%xmm0, 96(%rsp)
	movq	$0, 112(%rsp)
	call	_Z4initv@PLT
	leaq	.LC0(%rip), %rsi
	leaq	_ZSt4cout(%rip), %rdi
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc@PLT
	movq	%rbp, %rsi
	leaq	_ZSt3cin(%rip), %rdi
	call	_ZStrsIcSt11char_traitsIcEERSt13basic_istreamIT_T0_ES6_PS3_@PLT
	movq	%rbp, %rsi
	movq	%rsp, %rdi
	call	_ZN7uint288C1EPc@PLT
	call	clock@PLT
	movq	%rax, %rbp
	.p2align 4,,10
	.p2align 3
.L133:
	subq	$48, %rsp
	.cfi_def_cfa_offset 208
	movdqa	48(%rsp), %xmm1
	movdqa	64(%rsp), %xmm2
	movl	80(%rsp), %eax
	movups	%xmm1, (%rsp)
	movl	%eax, 32(%rsp)
	movups	%xmm2, 16(%rsp)
	call	_Z6getDBC7uint288
	addq	$48, %rsp
	.cfi_def_cfa_offset 160
	subl	$1, %ebx
	jne	.L133
	call	clock@PLT
	leaq	.LC1(%rip), %rsi
	leaq	_ZSt4cout(%rip), %rdi
	movq	%rax, %rbx
	call	_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc@PLT
	leaq	w_min(%rip), %rdi
	subq	%rbp, %rbx
	call	_ZN3DBC5printEv@PLT
	movl	$18, %edx
	leaq	.LC2(%rip), %rsi
	leaq	_ZSt4cout(%rip), %rdi
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	movl	4+w_min(%rip), %eax
	leaq	_ZSt4cout(%rip), %rdi
	leal	-1(%rax), %esi
	call	_ZNSolsEi@PLT
	movq	%rax, %rdi
	call	_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@PLT
	movl	$18, %edx
	leaq	.LC3(%rip), %rsi
	leaq	_ZSt4cout(%rip), %rdi
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	movq	%rbx, %rsi
	leaq	_ZSt4cout(%rip), %rdi
	call	_ZNSo9_M_insertIlEERSoT_@PLT
	movl	$1, %edx
	leaq	.LC4(%rip), %rsi
	movq	%rax, %rbp
	movq	%rax, %rdi
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	movq	%rbp, %rdi
	pxor	%xmm0, %xmm0
	cvtsi2ssq	%rbx, %xmm0
	divss	.LC5(%rip), %xmm0
	cvtss2sd	%xmm0, %xmm0
	call	_ZNSo9_M_insertIdEERSoT_@PLT
	movl	$2, %edx
	leaq	.LC6(%rip), %rsi
	movq	%rax, %rbp
	movq	%rax, %rdi
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	movq	%rbp, %rdi
	call	_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_@PLT
	movq	120(%rsp), %rax
	xorq	%fs:40, %rax
	jne	.L137
	addq	$136, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 24
	xorl	%eax, %eax
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	ret
.L137:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE2529:
	.size	main, .-main
	.p2align 4
	.type	_GLOBAL__sub_I_n, @function
_GLOBAL__sub_I_n:
.LFB3038:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	leaq	_ZStL8__ioinit(%rip), %rdi
	call	_ZNSt8ios_base4InitC1Ev@PLT
	movq	_ZNSt8ios_base4InitD1Ev@GOTPCREL(%rip), %rdi
	leaq	__dso_handle(%rip), %rdx
	leaq	_ZStL8__ioinit(%rip), %rsi
	call	__cxa_atexit@PLT
	leaq	n(%rip), %rdi
	call	_ZN7uint288C1Ev@PLT
	leaq	B(%rip), %rdi
	call	_ZN7uint288C1Ev@PLT
	leaq	six_n(%rip), %rdi
	call	_ZN7uint288C1Ev@PLT
	leaq	record_outer(%rip), %rdi
	call	_ZN7uint288C1Ev@PLT
	leaq	temp_outer(%rip), %rdi
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	jmp	_ZN7uint288C1Ev@PLT
	.cfi_endproc
.LFE3038:
	.size	_GLOBAL__sub_I_n, .-_GLOBAL__sub_I_n
	.section	.init_array,"aw"
	.align 8
	.quad	_GLOBAL__sub_I_n
	.globl	bBound
	.bss
	.align 32
	.type	bBound, @object
	.size	bBound, 1080
bBound:
	.zero	1080
	.globl	n0
	.align 8
	.type	n0, @object
	.size	n0, 8
n0:
	.zero	8
	.globl	temp_outer
	.align 32
	.type	temp_outer, @object
	.size	temp_outer, 36
temp_outer:
	.zero	36
	.globl	record_outer
	.align 32
	.type	record_outer, @object
	.size	record_outer, 36
record_outer:
	.zero	36
	.globl	six_n
	.align 32
	.type	six_n, @object
	.size	six_n, 36
six_n:
	.zero	36
	.globl	B
	.align 32
	.type	B, @object
	.size	B, 36
B:
	.zero	36
	.globl	n
	.align 32
	.type	n, @object
	.size	n, 36
n:
	.zero	36
	.local	_ZStL8__ioinit
	.comm	_ZStL8__ioinit,1,1
	.section	.rodata.cst4,"aM",@progbits,4
	.align 4
.LC5:
	.long	1232348160
	.hidden	__dso_handle
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
