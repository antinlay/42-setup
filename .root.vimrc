" Vim 8.2+: portable editing defaults, C/42 tabs, VS Code-like shortcuts.
set nocompatible
set encoding=utf-8
filetype plugin indent on
syntax enable
let mapleader = " "

" Interface and completion.
set background=dark
" Modern terminal RGB colors; keep a 256-color fallback for older terminals.
if has('termguicolors') && ($COLORTERM =~# 'truecolor\|24bit' || &term =~# 'xterm\|screen\|tmux\|kitty\|alacritty')
  set termguicolors
endif
colorscheme xcode_dark
set number
set cursorline
set cursorlineopt=number
set signcolumn=auto
set laststatus=2
set showcmd ruler showmatch
set mouse=a
set scrolloff=5 sidescrolloff=5
set nowrap
set splitbelow splitright
set wildmenu
set wildmode=longest:full,full
set wildignore+=*/.git/*,*/node_modules/*,*.o,*.a,*.swp
set completeopt=menuone,noinsert,noselect
set shortmess+=c
set updatetime=300
set timeoutlen=500
set ttimeoutlen=50
set listchars=tab:>-,trail:·,extends:>,precedes:<,nbsp:+
set nolist
set statusline=%f\ %h%m%r%=%{&filetype}\ [%{&expandtab?'spaces':'tabs'}:%{&tabstop}]\ %l:%c\ %p%%

" Search and editing.
set incsearch hlsearch ignorecase smartcase
set backspace=indent,eol,start
set autoindent
set tabstop=4 shiftwidth=4 softtabstop=4 expandtab
set history=1000
set hidden
set confirm
set nrformats-=octal
set formatoptions-=t
set foldmethod=manual

" Keep swap recovery and persistent undo in private Vim directories.
for s:dir in ['undo', 'swap', 'backup']
  call mkdir(expand('~/.vim/' . s:dir), 'p', 0700)
endfor
unlet s:dir
set undofile
set undodir=~/.vim/undo//
set directory=~/.vim/swap//
set backupdir=~/.vim/backup//
set backup
set backupcopy=auto

augroup personal_editing
  autocmd!
  " .h may be detected as C or C++; both need the same tab stops.
  autocmd FileType c,cpp setlocal tabstop=4 shiftwidth=4 softtabstop=0 noexpandtab colorcolumn=81
  autocmd FileType make setlocal tabstop=4 shiftwidth=4 softtabstop=0 noexpandtab
  autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
  autocmd FileType json,javascript,typescript,html,css,yaml setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
  autocmd FileType * setlocal formatoptions-=o formatoptions-=t
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line('$') && &filetype !~# 'commit' | execute 'normal! g`"' | endif
augroup END

" Familiar shortcuts; standard Vim motions remain available.
nnoremap <silent> <C-s> :update<CR>
inoremap <silent> <C-s> <C-o>:update<CR>
xnoremap <silent> <C-s> <Esc>:update<CR>
nnoremap <silent> <C-b> :Lexplore<CR>
nnoremap <silent> <leader>e :Lexplore<CR>
nnoremap <silent> <leader><space> :nohlsearch<CR>
nnoremap <silent> <leader>l :set list!<CR>
nnoremap <silent> <leader>w :set wrap!<CR>
nnoremap <silent> <leader>bn :bnext<CR>
nnoremap <silent> <leader>bp :bprevious<CR>
nnoremap <silent> <leader>q :copen<CR>
nnoremap <silent> [q :cprevious<CR>
nnoremap <silent> ]q :cnext<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
xnoremap < <gv
xnoremap > >gv
nnoremap j gj
nnoremap k gk
inoremap <C-Space> <C-n>

" Built-in project file picker: :Files, then type a path and use Tab.
set path+=**
set wildignore+=*/.venv/*,*/build/*,*/dist/*
command! -nargs=* -complete=file Files execute 'find ' . <q-args>
" Ctrl-P opens the command with completion ready.
nnoremap <C-p> :Files<Space>
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_winsize = 25
let g:netrw_browse_split = 4

" :Search text searches from Vim's current directory and opens quickfix.
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --
  set grepformat=%f:%l:%c:%m
  function! s:Search(text) abort
    silent execute 'grep! ' . shellescape(a:text) . ' .'
    cwindow
    redraw!
  endfunction
  command! -nargs=+ Search call <SID>Search(<q-args>)
  nnoremap <leader>f :Search<Space>
endif

" Clipboard: native support when available; otherwise X11 helpers.
if has('clipboard')
  set clipboard^=unnamedplus
  xnoremap <leader>y "+y
  nnoremap <leader>p "+p
elseif executable('xclip') && !empty($DISPLAY)
  function! s:CopySelection() abort
    let l:saved = getreg('z', 1, 1)
    let l:type = getregtype('z')
    normal! gv"zy
    call system('xclip -selection clipboard -in', getreg('z'))
    call setreg('z', l:saved, l:type)
  endfunction
  xnoremap <silent> <leader>y :<C-u>call <SID>CopySelection()<CR>
  nnoremap <silent> <leader>p :read !xclip -selection clipboard -out<CR>
endif

" F1 inserts a 42 header if the plugin is installed.
function! s:Header() abort
  if exists(':Stdheader') == 2
    Stdheader
  else
    echo '42 header plugin is not installed (:Stdheader unavailable).'
  endif
endfunction
nnoremap <silent> <F1> :call <SID>Header()<CR>
inoremap <silent> <F1> <C-o>:call <SID>Header()<CR>

" ===== BEGIN USER C00-C11 FUNCTIONS =====
" Each code line is a Vim comment. Assignment entry points are included.
"
" ===== C00/ex00/ft_putchar.c =====
" #include <unistd.h>
"
" void	ft_putchar(char c)
" {
" 	write(1, &c, 1);
" }
"
" ===== C00/ex01/ft_print_alphabet.c =====
" #include <unistd.h>
"
" void	ft_print_alphabet(void)
" {
" 	char	c;
"
" 	c = 'a';
" 	while (c <= 'z')
" 	{
" 		write (1, &c, 1);
" 		c++;
" 	}
" }
"
" ===== C00/ex02/ft_print_reverse_alphabet.c =====
" #include <unistd.h>
"
" void	ft_print_reverse_alphabet(void)
" {
" 	char	c;
"
" 	c = 'z';
" 	while (c >= 'a')
" 	{
" 		write (1, &c, 1);
" 		c--;
" 	}
" }
"
" ===== C00/ex03/ft_print_numbers.c =====
" #include <unistd.h>
"
" void	ft_print_numbers(void)
" {
" 	char	c;
"
" 	c = '0';
" 	while (c <= '9')
" 	{
" 		write (1, &c, 1);
" 		c++;
" 	}
" }
"
" ===== C00/ex04/ft_is_negative.c =====
" #include <unistd.h>
"
" void	ft_is_negative(int n)
" {
" 	char	neg;
" 	char	p;
"
" 	neg = 'N';
" 	p = 'P';
" 	if (n < 0)
" 	{
" 		write(1, &neg, 1);
" 	}
" 	else
" 	{
" 		write(1, &p, 1);
" 	}
" }
"
" ===== C00/ex05/ft_print_comb.c =====
" #include <unistd.h>
"
" void	ft_print_comb(void)
" {
" 	char	digits[3];
"
" 	digits[0] = '0';
" 	digits[1] = '1';
" 	digits[2] = '2';
" 	while (digits[0] <= '7')
" 	{
" 		digits[1] = digits[0] + 1;
" 		while (digits[1] <= '8')
" 		{
" 			digits[2] = digits[1] + 1;
" 			while (digits[2] <= '9')
" 			{
" 				write(1, &digits, 3);
" 				if (digits[0] != '7' || digits[1] != '8' || digits[2] != '9')
" 					write(1, ", ", 2);
" 				digits[2]++;
" 			}
" 			digits[1]++;
" 		}
" 		digits[0]++;
" 	}
" }
"
" ===== C00/ex06/ft_print_comb2.c =====
" #include <unistd.h>
"
" void	ft_print_two_digits(int number)
" {
" 	char	digits[2];
"
" 	digits[0] = '0' + number / 10;
" 	digits[1] = '0' + number % 10;
" 	write(1, digits, 2);
" }
"
" void	ft_print_comb2(void)
" {
" 	int	first;
" 	int	second;
"
" 	first = 0;
" 	second = 0;
" 	while (first <= 99)
" 	{
" 		second = first + 1;
" 		while (second <= 99)
" 		{
" 			ft_print_two_digits(first);
" 			write(1, " ", 1);
" 			ft_print_two_digits(second);
" 			if (first != 98 || second != 99)
" 				write(1, ", ", 2);
" 			second++;
" 		}
" 		first++;
" 	}
" }
"
" ===== C00/ex07/ft_putnbr.c =====
" #include <unistd.h>
"
" void	ft_write_long(long number)
" {
" 	char	c;
"
" 	if (number >= 10)
" 		ft_write_long(number / 10);
" 	c = '0' + number % 10;
" 	write(1, &c, 1);
" }
"
" void	ft_putnbr(int nb)
" {
" 	long	number;
"
" 	number = nb;
" 	if (number < 0)
" 	{
" 		write(1, "-", 1);
" 		number = -number;
" 	}
" 	ft_write_long(number);
" }
"
" ===== C00/ex08/ft_print_combn.c =====
" #include <unistd.h>
"
" void	ft_init_digits(char *digits, int n)
" {
" 	int	i;
"
" 	i = 0;
" 	while (i < n)
" 	{
" 		digits[i] = '0' + i;
" 		i++;
" 	}
" }
"
" void	ft_print_combn(int n)
" {
" 	char	digits[9];
" 	int		i;
"
" 	i = 0;
" 	ft_init_digits(digits, n);
" 	while (1)
" 	{
" 		write(1, digits, n);
" 		i = n - 1;
" 		while (i >= 0 && digits[i] == '0' + 10 - n + i)
" 		{
" 			i--;
" 		}
" 		if (i < 0)
" 			break ;
" 		digits[i]++;
" 		i++;
" 		while (i < n)
" 		{
" 			digits[i] = digits[i - 1] + 1;
" 			i++;
" 		}
" 		write(1, ", ", 2);
" 	}
" }
"
" ===== C01/ex00/ft_ft.c =====
" void	ft_ft(int *nbr)
" {
" 	*nbr = 42;
" }
"
" ===== C01/ex01/ft_ultimate_ft.c =====
" void	ft_ultimate_ft(int *********nbr)
" {
" 	*********nbr = 42;
" }
"
" ===== C01/ex02/ft_swap.c =====
" void	ft_swap(int *a, int *b)
" {
" 	int	temp;
"
" 	temp = *a;
" 	*a = *b;
" 	*b = temp;
" }
"
" ===== C01/ex03/ft_div_mod.c =====
" void	ft_div_mod(int a, int b, int *div, int *mod)
" {
" 	*div = a / b;
" 	*mod = a % b;
" }
"
" ===== C01/ex04/ft_ultimate_div_mod.c =====
" void	ft_ultimate_div_mod(int *a, int *b)
" {
" 	int	dev;
" 	int	mod;
"
" 	dev = *a / *b;
" 	mod = *a % *b;
" 	*a = dev;
" 	*b = mod;
" }
"
" ===== C01/ex05/ft_putstr.c =====
" #include <unistd.h>
"
" void	ft_putstr(char *str)
" {
" 	while (*str)
" 	{
" 		write(1, str++, 1);
" 	}
" }
"
" ===== C01/ex06/ft_strlen.c =====
" int	ft_strlen(char *str)
" {
" 	int	i;
"
" 	i = 0;
" 	while (*str)
" 	{
" 		i++;
" 		str++;
" 	}
" 	return (i);
" }
"
" ===== C01/ex07/ft_rev_int_tab.c =====
" void	ft_rev_int_tab(int *tab, int size)
" {
" 	int	left;
" 	int	right;
" 	int	temp;
"
" 	left = 0;
" 	right = size - 1;
" 	while (left < right)
" 	{
" 		temp = tab[left];
" 		tab[left] = tab[right];
" 		tab[right] = temp;
" 		left++;
" 		right--;
" 	}
" }
"
" ===== C01/ex08/ft_sort_int_tab.c =====
" void	ft_sort_int_tab(int *tab, int size)
" {
" 	int	i;
" 	int	j;
" 	int	temp;
"
" 	i = 0;
" 	while (i < size - 1)
" 	{
" 		j = 0;
" 		while (j < size - 1 - i)
" 		{
" 			if (tab[j] > tab[j + 1])
" 			{
" 				temp = tab[j];
" 				tab[j] = tab[j + 1];
" 				tab[j + 1] = temp;
" 			}
" 			j++;
" 		}
" 		i++;
" 	}
" }
"
" ===== C02/ex00/ft_strcpy.c =====
" char	*ft_strcpy(char *dest, char *src)
" {
" 	int	i;
"
" 	i = 0;
" 	while (src[i] != '\0')
" 	{
" 		dest[i] = src[i];
" 		i++;
" 	}
" 	dest[i] = src[i];
" 	return (&dest[0]);
" }
"
" ===== C02/ex01/ft_strncpy.c =====
" char	*ft_strncpy(char *dest, char *src, unsigned int n)
" {
" 	unsigned int	i;
"
" 	i = 0;
" 	while (i < n && src[i] != '\0')
" 	{
" 		dest[i] = src[i];
" 		i++;
" 	}
" 	while (i < n)
" 		dest[i++] = '\0';
" 	return (dest);
" }
"
" ===== C02/ex02/ft_str_is_alpha.c =====
" int	ft_str_is_alpha(char *str)
" {
" 	while (*str)
" 	{
" 		if ((*str >= 'a' && *str <= 'z') || (*str >= 'A' && *str <= 'Z'))
" 			str++;
" 		else
" 			return (0);
" 	}
" 	return (1);
" }
"
" ===== C02/ex03/ft_str_is_numeric.c =====
" int	ft_str_is_numeric(char *str)
" {
" 	while (*str)
" 	{
" 		if (*str >= '0' && *str <= '9')
" 			str++;
" 		else
" 			return (0);
" 	}
" 	return (1);
" }
"
" ===== C02/ex04/ft_str_is_lowercase.c =====
" int	ft_str_is_lowercase(char *str)
" {
" 	while (*str)
" 	{
" 		if (*str < 'a' || *str > 'z')
" 			return (0);
" 		str++;
" 	}
" 	return (1);
" }
"
" ===== C02/ex05/ft_str_is_uppercase.c =====
" int	ft_str_is_uppercase(char *str)
" {
" 	while (*str)
" 	{
" 		if (*str < 'A' || *str > 'Z')
" 			return (0);
" 		str++;
" 	}
" 	return (1);
" }
"
" ===== C02/ex06/ft_str_is_printable.c =====
" int	ft_str_is_printable(char *str)
" {
" 	while (*str)
" 	{
" 		if (*str < ' ' || *str > '~')
" 			return (0);
" 		str++;
" 	}
" 	return (1);
" }
"
" ===== C02/ex07/ft_strupcase.c =====
" char	*ft_strupcase(char *str)
" {
" 	char	*start_str;
"
" 	start_str = str;
" 	while (*str)
" 	{
" 		if (*str >= 'a' && *str <= 'z')
" 			*str = *str - ('a' - 'A');
" 		str++;
" 	}
" 	return (start_str);
" }
"
" ===== C02/ex08/ft_strlowcase.c =====
" char	*ft_strlowcase(char *str)
" {
" 	char	*start_str;
"
" 	start_str = str;
" 	while (*str)
" 	{
" 		if (*str >= 'A' && *str <= 'Z')
" 			*str = *str + ('a' - 'A');
" 		str++;
" 	}
" 	return (start_str);
" }
"
" ===== C02/ex09/ft_strcapitalize.c =====
" int	ft_char_is_alpha(char str)
" {
" 	if ((str >= 'a' && str <= 'z') || (str >= 'A' && str <= 'Z'))
" 		return (1);
" 	else
" 		return (0);
" }
"
" int	ft_char_is_numeric(char str)
" {
" 	if (str >= '0' && str <= '9')
" 		return (1);
" 	else
" 		return (0);
" }
"
" char	ft_charlowcase(char str)
" {
" 	if (str >= 'A' && str <= 'Z')
" 		str = str + ('a' - 'A');
" 	return (str);
" }
"
" char	ft_charuppercase(char str)
" {
" 	if (str >= 'a' && str <= 'z')
" 		str = str - ('a' - 'A');
" 	return (str);
" }
"
" char	*ft_strcapitalize(char *str)
" {
" 	int		new_word;
" 	char	*start_str;
"
" 	new_word = 1;
" 	start_str = str;
" 	while (*str)
" 	{
" 		if (!ft_char_is_numeric(*str) && !ft_char_is_alpha(*str))
" 			new_word = 1;
" 		else
" 		{
" 			if (new_word)
" 				*str = ft_charuppercase(*str);
" 			else
" 				*str = ft_charlowcase(*str);
" 			new_word = 0;
" 		}
" 		str++;
" 	}
" 	return (start_str);
" }
"
" ===== C02/ex10/ft_strlcpy.c =====
" unsigned int	ft_strlcpy(char *dest, char *src, unsigned int size)
" {
" 	unsigned int	i;
" 	unsigned int	n;
"
" 	i = 0;
" 	n = 0;
" 	while (*(src + i) != '\0')
" 		i++;
" 	if (size > 0)
" 	{
" 		while (n < size - 1 && *src != '\0')
" 		{
" 			*dest = *src;
" 			n++;
" 			dest++;
" 			src++;
" 		}
" 		*dest = '\0';
" 	}
" 	return (i);
" }
"
" ===== C02/ex11/ft_putstr_non_printable.c =====
" #include <unistd.h>
"
" int	ft_char_is_printable(char str)
" {
" 	if (str < ' ' || str > '~')
" 		return (0);
" 	return (1);
" }
"
" void	ft_putstr_non_printable(char *str)
" {
" 	unsigned char	c;
" 	char			*hex;
"
" 	hex = "0123456789abcdef";
" 	while (*str)
" 	{
" 		if (!ft_char_is_printable(*str))
" 		{
" 			c = (unsigned char)*str;
" 			write(1, "\\", 1);
" 			write(1, &hex[c / 16], 1);
" 			write(1, &hex[c % 16], 1);
" 		}
" 		else
" 			write(1, str, 1);
" 		str++;
" 	}
" }
"
" ===== C02/ex12/ft_print_memory.c =====
" #include <stdint.h>
" #include <unistd.h>
"
" void	ft_str_write_printable(unsigned char str)
" {
" 	if (str < ' ' || str > '~')
" 		write(1, ".", 1);
" 	else
" 		write(1, &str, 1);
" }
"
" unsigned int	ft_print_hex_byte(unsigned char *byte, unsigned int i,
" 		unsigned int offset, unsigned int size)
" {
" 	char	*hex;
"
" 	hex = "0123456789abcdef";
" 	while (i < 16 && offset + i < size)
" 	{
" 		write(1, &hex[*byte / 16], 1);
" 		write(1, &hex[*byte % 16], 1);
" 		i++;
" 		byte++;
" 		if (i % 2 == 0)
" 			write(1, " ", 1);
" 	}
" 	return (i);
" }
"
" void	ft_print_address_hex(uintptr_t address, int digits)
" {
" 	char	*hex;
"
" 	hex = "0123456789abcdef";
" 	if (digits == 0)
" 		return ;
" 	ft_print_address_hex(address / 16, digits - 1);
" 	write(1, &hex[address % 16], 1);
" }
"
" void	ft_print_spaces(int i)
" {
" 	while (i < 16)
" 	{
" 		write(1, "  ", 2);
" 		i++;
" 		if (i % 2 == 0)
" 			write(1, " ", 1);
" 	}
" }
"
" void	*ft_print_memory(void *addr, unsigned int size)
" {
" 	unsigned char	*ptr;
" 	unsigned int	i;
" 	unsigned int	offset;
"
" 	ptr = (unsigned char *)addr;
" 	i = 0;
" 	offset = 0;
" 	while (offset < size)
" 	{
" 		ft_print_address_hex((uintptr_t)(ptr + offset),
" 			(int)(sizeof(uintptr_t) * 2));
" 		write(1, ": ", 2);
" 		i = 0;
" 		i = ft_print_hex_byte(&ptr[offset + i], i, offset, size);
" 		ft_print_spaces(i);
" 		i = 0;
" 		while (i < 16 && offset + i < size)
" 		{
" 			ft_str_write_printable(ptr[offset + i]);
" 			i++;
" 		}
" 		offset += i;
" 		write(1, "\n", 1);
" 	}
" 	return (addr);
" }
"
" ===== C03/ex00/ft_strcmp.c =====
" int	ft_strcmp(char *s1, char *s2)
" {
" 	while (*s1 || *s2)
" 	{
" 		if (*s1 != *s2)
" 			return ((unsigned char) *s1 - (unsigned char) *s2);
" 		s1++;
" 		s2++;
" 	}
" 	return (0);
" }
"
" ===== C03/ex01/ft_strncmp.c =====
" int	ft_strncmp(char *s1, char *s2, unsigned int n)
" {
" 	unsigned int	i;
"
" 	i = 0;
" 	if (n == i)
" 		return (0);
" 	while (i < n && (s1[i] || s2[i]))
" 	{
" 		if (s1[i] != s2[i])
" 			return ((unsigned char) s1[i] - (unsigned char) s2[i]);
" 		i++;
" 	}
" 	return (0);
" }
"
" ===== C03/ex02/ft_strcat.c =====
" char	*ft_strcat(char *dest, char *src)
" {
" 	unsigned int	i;
" 	unsigned int	j;
"
" 	i = 0;
" 	j = 0;
" 	while (dest[i])
" 		i++;
" 	while (src[j])
" 	{
" 		dest[i] = src[j];
" 		j++;
" 		i++;
" 	}
" 	dest[i] = src[j];
" 	return (dest);
" }
"
" ===== C03/ex03/ft_strncat.c =====
" char	*ft_strncat(char *dest, char *src, unsigned int nb)
" {
" 	unsigned int	i;
" 	unsigned int	j;
"
" 	i = 0;
" 	j = 0;
" 	while (dest[i])
" 		i++;
" 	while (j < nb && src[j])
" 	{
" 		dest[i] = src[j];
" 		j++;
" 		i++;
" 	}
" 	dest[i] = '\0';
" 	return (dest);
" }
"
" ===== C03/ex04/ft_strstr.c =====
" char	*ft_strstr(char *str, char *to_find)
" {
" 	int	i;
" 	int	j;
"
" 	i = 0;
" 	j = 0;
" 	if (!*to_find)
" 		return (str);
" 	while (str[i])
" 	{
" 		j = 0;
" 		while (to_find[j] && to_find[j] == str[i + j])
" 		{
" 			j++;
" 		}
" 		if (!to_find[j])
" 			return (&str[i]);
" 		i++;
" 	}
" 	return (0);
" }
"
" ===== C03/ex05/ft_strlcat.c =====
" unsigned int	ft_strlcat(char *dest, char *src, unsigned int size)
" {
" 	unsigned int	i;
" 	unsigned int	j;
" 	unsigned int	k;
"
" 	i = 0;
" 	j = 0;
" 	k = 0;
" 	while (i < size && dest[i])
" 		i++;
" 	while (src[j])
" 		j++;
" 	if (i == size)
" 		return (size + j);
" 	while (src[k] && i < size - 1)
" 	{
" 		dest[i] = src[k];
" 		k++;
" 		i++;
" 	}
" 	dest[i] = '\0';
" 	return (i - k + j);
" }
"
" ===== C04/ex00/ft_strlen.c =====
" int	ft_strlen(char *str)
" {
" 	int	i;
"
" 	i = 0;
" 	while (str[i])
" 		i++;
" 	return (i);
" }
"
" ===== C04/ex01/ft_putstr.c =====
" #include <unistd.h>
"
" void	ft_putstr(char *str)
" {
" 	while (*str)
" 	{
" 		write(1, str, 1);
" 		str++;
" 	}
" }
"
" ===== C04/ex02/ft_putnbr.c =====
" #include <unistd.h>
"
" void	ft_putnbr(int nb)
" {
" 	long	n;
" 	char	c;
"
" 	n = nb;
" 	if (nb < 0)
" 	{
" 		write(1, "-", 1);
" 		n = -n;
" 	}
" 	c = n % 10 + '0';
" 	if (n >= 10)
" 		ft_putnbr(n / 10);
" 	write(1, &c, 1);
" }
"
" ===== C04/ex03/ft_atoi.c =====
" char	*ft_skip_space(char *str)
" {
" 	while (*str == ' ' || (*str >= 9 && *str <= 13))
" 		str++;
" 	return (str);
" }
"
" char	*ft_skip_sign(char *str)
" {
" 	while (*str == '-' || *str == '+')
" 		str++;
" 	return (str);
" }
"
" int	ft_sign_number(char *str)
" {
" 	char	*s;
" 	int		sign;
" 	int		i;
"
" 	s = ft_skip_space(str);
" 	sign = 1;
" 	i = 0;
" 	while (s[i] == '+' || s[i] == '-')
" 	{
" 		if (s[i] == '-')
" 			sign *= -1;
" 		i++;
" 	}
" 	return (sign);
" }
"
" int	ft_atoi(char *str)
" {
" 	int		sign;
" 	int		res;
" 	char	*s;
"
" 	sign = ft_sign_number(str);
" 	res = 0;
" 	s = ft_skip_space(str);
" 	s = ft_skip_sign(s);
" 	while (*s >= '0' && *s <= '9')
" 	{
" 		res = res * 10 + (*s - '0');
" 		s++;
" 	}
" 	res *= sign;
" 	return (res);
" }
"
" ===== C04/ex04/ft_putnbr_base.c =====
" #include <unistd.h>
"
" int	ft_original_len(char *base)
" {
" 	int	i;
" 	int	j;
"
" 	i = 0;
" 	while (base[i])
" 	{
" 		if (base[i] == '-' || base[i] == '+')
" 			return (0);
" 		j = i + 1;
" 		while (base[j])
" 		{
" 			if (base[i] == base[j])
" 				return (0);
" 			j++;
" 		}
" 		i++;
" 	}
" 	if (i < 2)
" 		return (0);
" 	return (i);
" }
"
" void	ft_putnbr_base(int nbr, char *base)
" {
" 	long	n;
" 	char	c;
" 	int		len;
"
" 	n = nbr;
" 	len = ft_original_len(base);
" 	if (!len)
" 		return ;
" 	if (nbr < 0)
" 	{
" 		write(1, "-", 1);
" 		n = -n;
" 	}
" 	c = base[n % len];
" 	if (n >= len)
" 		ft_putnbr_base(n / len, base);
" 	write(1, &c, 1);
" }
"
" ===== C04/ex05/ft_atoi_base.c =====
" int	ft_original_len(char *base)
" {
" 	int	i;
" 	int	j;
"
" 	i = 0;
" 	while (base[i])
" 	{
" 		if (base[i] == '-' || base[i] == '+' || base[i] == ' '
" 			|| (base[i] >= 9 && base[i] <= 13))
" 			return (0);
" 		j = i + 1;
" 		while (base[j])
" 		{
" 			if (base[i] == base[j])
" 				return (0);
" 			j++;
" 		}
" 		i++;
" 	}
" 	if (i < 2)
" 		return (0);
" 	return (i);
" }
"
" char	*ft_skip_chars(char *str, int space)
" {
" 	if (space)
" 	{
" 		while (*str == ' ' || (*str >= 9 && *str <= 13))
" 			str++;
" 	}
" 	else
" 	{
" 		while (*str == '-' || *str == '+')
" 			str++;
" 	}
" 	return (str);
" }
"
" int	ft_sign_number(char *str)
" {
" 	char	*s;
" 	int		sign;
" 	int		i;
"
" 	s = ft_skip_chars(str, 1);
" 	sign = 1;
" 	i = 0;
" 	while (s[i] == '+' || s[i] == '-')
" 	{
" 		if (s[i] == '-')
" 			sign *= -1;
" 		i++;
" 	}
" 	return (sign);
" }
"
" int	ft_digit_index(char c, char *base)
" {
" 	int	i;
"
" 	i = 0;
" 	while (base[i])
" 	{
" 		if (base[i] == c)
" 			return (i);
" 		i++;
" 	}
" 	return (-1);
" }
"
" int	ft_atoi_base(char *str, char *base)
" {
" 	int		len;
" 	int		sign;
" 	int		res;
" 	int		digit;
" 	char	*s;
"
" 	len = ft_original_len(base);
" 	if (!len)
" 		return (0);
" 	sign = ft_sign_number(str);
" 	res = 0;
" 	s = ft_skip_chars(str, 1);
" 	s = ft_skip_chars(s, 0);
" 	while (*s)
" 	{
" 		digit = ft_digit_index(*s, base);
" 		if (digit == -1)
" 			break ;
" 		res = res * len + digit;
" 		s++;
" 	}
" 	return (res * sign);
" }
"
" ===== C05/ex00/ft_iterative_factorial.c =====
" int	ft_iterative_factorial(int nb)
" {
" 	int	i;
" 	int	res;
"
" 	i = 1;
" 	res = 1;
" 	if (nb < 0)
" 		return (0);
" 	while (i <= nb)
" 	{
" 		res *= i;
" 		i++;
" 	}
" 	return (res);
" }
"
" ===== C05/ex01/ft_recursive_factorial.c =====
" int	ft_recursive_factorial(int nb)
" {
" 	if (nb < 0)
" 		return (0);
" 	else if (nb == 0)
" 		return (1);
" 	else
" 		return (nb * ft_recursive_factorial(nb - 1));
" }
"
" ===== C05/ex02/ft_iterative_power.c =====
" int	ft_iterative_power(int nb, int power)
" {
" 	int	res;
" 	int	i;
"
" 	res = 1;
" 	i = 1;
" 	if (power < 0)
" 		return (0);
" 	while (i <= power)
" 	{
" 		res = res * nb;
" 		i++;
" 	}
" 	return (res);
" }
"
" ===== C05/ex03/ft_recursive_power.c =====
" int	ft_recursive_power(int nb, int power)
" {
" 	if (power < 0)
" 		return (0);
" 	if (power == 0)
" 		return (1);
" 	return (nb * ft_recursive_power(nb, power - 1));
" }
"
" ===== C05/ex04/ft_fibonacci.c =====
" int	ft_fibonacci(int index)
" {
" 	if (index < 0)
" 		return (-1);
" 	if (index == 0)
" 		return (0);
" 	if (index == 1)
" 		return (1);
" 	return (ft_fibonacci(index - 1) + ft_fibonacci(index - 2));
" }
"
" ===== C05/ex05/ft_sqrt.c =====
" int	ft_sqrt(int nb)
" {
" 	int	i;
"
" 	i = 1;
" 	if (nb <= 0)
" 		return (0);
" 	while (i <= nb / i)
" 	{
" 		if (i * i == nb)
" 			return (i);
" 		i++;
" 	}
" 	return (0);
" }
"
" ===== C05/ex06/ft_is_prime.c =====
" int	ft_is_prime(int nb)
" {
" 	int	i;
"
" 	i = 2;
" 	if (nb <= 1)
" 		return (0);
" 	while (i <= nb / i)
" 	{
" 		if (nb % i == 0)
" 			return (0);
" 		i++;
" 	}
" 	return (1);
" }
"
" ===== C05/ex07/ft_find_next_prime.c =====
" int	ft_is_prime(int nb)
" {
" 	int	i;
"
" 	i = 2;
" 	if (nb <= 1)
" 		return (0);
" 	while (i <= nb / i)
" 	{
" 		if (nb % i == 0)
" 			return (0);
" 		i++;
" 	}
" 	return (1);
" }
"
" int	ft_find_next_prime(int nb)
" {
" 	int	i;
"
" 	i = nb;
" 	if (nb < 2)
" 		return (2);
" 	while (!ft_is_prime(i))
" 		i++;
" 	return (i);
" }
"
" ===== C05/ex08/ft_ten_queens_puzzle.c =====
" #include <unistd.h>
"
" int	ft_is_safe(int queens[10], int col, int row)
" {
" 	int	i;
"
" 	i = 0;
" 	while (i < col)
" 	{
" 		if (queens[i] == row)
" 			return (0);
" 		if (row - queens[i] == col - i || queens[i] - row == col - i)
" 			return (0);
" 		i++;
" 	}
" 	return (1);
" }
"
" void	print_queens(int queens[10])
" {
" 	int		col;
" 	char	c;
"
" 	col = 0;
" 	while (col < 10)
" 	{
" 		c = queens[col] + '0';
" 		write(1, &c, 1);
" 		col++;
" 	}
" 	write(1, "\n", 1);
" }
"
" int	solve(int queens[10], int col)
" {
" 	int	count;
" 	int	row;
"
" 	row = 0;
" 	count = 0;
" 	if (col == 10)
" 	{
" 		print_queens(queens);
" 		count++;
" 		return (1);
" 	}
" 	while (row < 10)
" 	{
" 		if (ft_is_safe(queens, col, row))
" 		{
" 			queens[col] = row;
" 			count += solve(queens, col + 1);
" 		}
" 		row++;
" 	}
" 	return (count);
" }
"
" int	ft_ten_queens_puzzle(void)
" {
" 	int	queens[10];
"
" 	return (solve(queens, 0));
" }
"
" ===== C06/ex00/ft_print_program_name.c =====
" #include <unistd.h>
"
" void	print_str(char *str)
" {
" 	while (*str)
" 	{
" 		write(1, str, 1);
" 		str++;
" 	}
" 	write(1, "\n", 1);
" }
"
" int	main(int argc, char **argv)
" {
" 	if (argc > 0)
" 		print_str(argv[0]);
" }
"
" ===== C06/ex01/ft_print_params.c =====
" #include <unistd.h>
"
" void	print_str(char *str)
" {
" 	while (*str)
" 	{
" 		write(1, str, 1);
" 		str++;
" 	}
" 	write(1, "\n", 1);
" }
"
" int	main(int argc, char **argv)
" {
" 	int	i;
"
" 	i = 1;
" 	if (argc > 0)
" 	{
" 		while (i < argc)
" 		{
" 			print_str(argv[i]);
" 			i++;
" 		}
" 	}
" }
"
" ===== C06/ex02/ft_rev_params.c =====
" #include <unistd.h>
"
" void	print_str(char *str)
" {
" 	while (*str)
" 	{
" 		write(1, str, 1);
" 		str++;
" 	}
" 	write(1, "\n", 1);
" }
"
" int	main(int argc, char **argv)
" {
" 	int	i;
"
" 	i = argc - 1;
" 	if (argc > 0)
" 	{
" 		while (i > 0)
" 		{
" 			print_str(argv[i]);
" 			i--;
" 		}
" 	}
" }
"
" ===== C06/ex03/ft_sort_params.c =====
" #include <unistd.h>
"
" void	print_str(char *str)
" {
" 	while (*str)
" 	{
" 		write(1, str, 1);
" 		str++;
" 	}
" 	write(1, "\n", 1);
" }
"
" int	ft_strcmp(char *s1, char *s2)
" {
" 	while (*s1 || *s2)
" 	{
" 		if (*s1 != *s2)
" 			return ((unsigned char) *s1 - (unsigned char) *s2);
" 		s1++;
" 		s2++;
" 	}
" 	return (0);
" }
"
" void	ft_sort_params(int argc, char **argv)
" {
" 	char	*tmp;
" 	int		i;
" 	int		pass;
"
" 	pass = 0;
" 	while (pass < argc - 2)
" 	{
" 		i = 1;
" 		while (i < argc - 1 - pass)
" 		{
" 			if (ft_strcmp(argv[i], argv[i + 1]) > 0)
" 			{
" 				tmp = argv[i];
" 				argv[i] = argv[i + 1];
" 				argv[i + 1] = tmp;
" 			}
" 			i++;
" 		}
" 		pass++;
" 	}
" }
"
" int	main(int argc, char **argv)
" {
" 	int	i;
"
" 	i = 1;
" 	if (argc > 0)
" 	{
" 		ft_sort_params(argc, argv);
" 		while (i < argc)
" 		{
" 			print_str(argv[i]);
" 			i++;
" 		}
" 	}
" }
"
" ===== C07/ex00/ft_strdup.c =====
" #include <stdlib.h>
"
" int	ft_strlen(char *str)
" {
" 	int	i;
"
" 	i = 0;
" 	while (*str)
" 	{
" 		i++;
" 		str++;
" 	}
" 	return (i);
" }
"
" char	*ft_strdup(char *src)
" {
" 	char	*copy;
" 	int		i;
"
" 	i = 0;
" 	copy = malloc(ft_strlen(src) + 1);
" 	if (copy == NULL)
" 		return (NULL);
" 	while (src[i])
" 	{
" 		copy[i] = src[i];
" 		i++;
" 	}
" 	copy[i] = src[i];
" 	return (copy);
" }
"
" ===== C07/ex01/ft_range.c =====
" #include <stdlib.h>
"
" int	*ft_range(int min, int max)
" {
" 	int	*range;
" 	int	i;
"
" 	if (min >= max)
" 		return (NULL);
" 	range = malloc((max - min) * sizeof(int));
" 	if (!range)
" 		return (NULL);
" 	i = 0;
" 	while (i < max - min)
" 	{
" 		range[i] = min + i;
" 		i++;
" 	}
" 	return (range);
" }
"
" ===== C07/ex02/ft_ultimate_range.c =====
" #include <stdlib.h>
"
" int	ft_ultimate_range(int **range, int min, int max)
" {
" 	int	i;
" 	int	size;
"
" 	i = 0;
" 	if (min >= max)
" 	{
" 		*range = NULL;
" 		return (0);
" 	}
" 	size = max - min;
" 	*range = malloc(size * sizeof(int));
" 	if (!*range)
" 		return (-1);
" 	while (i < size)
" 	{
" 		(*range)[i] = min + i;
" 		i++;
" 	}
" 	return (i);
" }
"
" ===== C07/ex03/ft_strjoin.c =====
" #include <stdlib.h>
"
" int	ft_strlen(char *str)
" {
" 	int	i;
"
" 	i = 0;
" 	while (*str)
" 	{
" 		i++;
" 		str++;
" 	}
" 	return (i);
" }
"
" int	ft_total_len(int size, char **strs, char *sep)
" {
" 	int	i;
" 	int	total;
"
" 	i = 0;
" 	total = 0;
" 	while (i < size)
" 	{
" 		total += ft_strlen(strs[i]);
" 		if (i < size - 1)
" 			total += ft_strlen(sep);
" 		i++;
" 	}
" 	return (total);
" }
"
" char	*ft_return_eof(void)
" {
" 	char	*res;
"
" 	res = malloc(1);
" 	if (!res)
" 		return (NULL);
" 	res[0] = '\0';
" 	return (res);
" }
"
" void	ft_copy_part(char *res, char *src, int *k)
" {
" 	int	j;
"
" 	j = 0;
" 	while (src[j])
" 	{
" 		res[*k] = src[j];
" 		j++;
" 		(*k)++;
" 	}
" }
"
" char	*ft_strjoin(int size, char **strs, char *sep)
" {
" 	char	*res;
" 	int		k;
" 	int		i;
"
" 	if (!size)
" 		return (ft_return_eof());
" 	res = malloc(ft_total_len(size, strs, sep) * sizeof(char) + 1);
" 	if (!res)
" 		return (NULL);
" 	k = 0;
" 	i = 0;
" 	while (i < size)
" 	{
" 		ft_copy_part(res, strs[i], &k);
" 		if (i < size - 1)
" 		{
" 			ft_copy_part(res, sep, &k);
" 		}
" 		i++;
" 	}
" 	res[k] = '\0';
" 	return (res);
" }
"
" ===== C07/ex04/ft_convert_base.c =====
" #include <stdlib.h>
"
" int	ft_digits_count(int number, int base_len)
" {
" 	int	digits;
" 	int	n;
"
" 	digits = 1;
" 	n = number / base_len;
" 	while (n != 0)
" 	{
" 		n /= base_len;
" 		digits++;
" 	}
" 	return (digits);
" }
"
" int	ft_check_base(char *base)
" {
" 	int	i;
" 	int	j;
"
" 	i = 0;
" 	if (ft_strlen(base) < 2)
" 		return (0);
" 	while (base[i])
" 	{
" 		if (base[i] == '+' || base[i] == '-' || base[i] == ' ' || (base[i] >= 9
" 				&& base[i] <= 13))
" 			return (0);
" 		j = i + 1;
" 		while (base[j])
" 		{
" 			if (base[i] == base[j])
" 				return (0);
" 			j++;
" 		}
" 		i++;
" 	}
" 	return (1);
" }
"
" char	*ft_itoa_base(int number, char *base_to)
" {
" 	char	*res;
" 	int		base_len;
" 	int		size;
" 	int		n;
" 	int		i;
"
" 	base_len = ft_strlen(base_to);
" 	size = ft_digits_count(number, base_len) + (number < 0) + 1;
" 	res = malloc(size);
" 	if (!res)
" 		return (NULL);
" 	res[size - 1] = '\0';
" 	n = number;
" 	if (n > 0)
" 		n = -n;
" 	i = size - 2;
" 	while (i >= (number < 0))
" 	{
" 		res[i] = base_to[-(n % base_len)];
" 		n /= base_len;
" 		i--;
" 	}
" 	if (number < 0)
" 		res[i] = '-';
" 	return (res);
" }
"
" char	*ft_convert_base(char *nbr, char *base_from, char *base_to)
" {
" 	int	number;
"
" 	if (!ft_check_base(base_from) || !ft_check_base(base_to))
" 		return (NULL);
" 	number = ft_atoi_base(nbr, base_from);
" 	return (ft_itoa_base(number, base_to));
" }
"
" ===== C07/ex04/ft_convert_base2.c =====
" #include <stdlib.h>
"
" int	ft_strlen(char *str)
" {
" 	int	i;
"
" 	i = 0;
" 	while (*str)
" 	{
" 		i++;
" 		str++;
" 	}
" 	return (i);
" }
"
" int	ft_skip_prefix(char *nbr, int *sign)
" {
" 	int	i;
"
" 	i = 0;
" 	while (nbr[i] == ' ' || nbr[i] == '\t' || nbr[i] == '\n' || nbr[i] == '\v'
" 		|| nbr[i] == '\f' || nbr[i] == '\r')
" 		i++;
" 	while (nbr[i] == '+' || nbr[i] == '-')
" 	{
" 		if (nbr[i] == '-')
" 			*sign = -*sign;
" 		i++;
" 	}
" 	return (i);
" }
"
" int	ft_digit_value(char c, char *base)
" {
" 	int	i;
"
" 	i = 0;
" 	while (base[i])
" 	{
" 		if (c == base[i])
" 			return (i);
" 		i++;
" 	}
" 	return (-1);
" }
"
" int	ft_atoi_base(char *nbr, char *base)
" {
" 	int	i;
" 	int	sign;
" 	int	result;
" 	int	len;
" 	int	digit;
"
" 	sign = 1;
" 	i = ft_skip_prefix(nbr, &sign);
" 	result = 0;
" 	len = ft_strlen(base);
" 	while (nbr[i])
" 	{
" 		digit = ft_digit_value(nbr[i], base);
" 		if (digit == -1)
" 			break ;
" 		result = result * len - digit;
" 		i++;
" 	}
" 	if (sign < 0)
" 		return (result);
" 	return (-result);
" }
"
" ===== C07/ex05/ft_split.c =====
" #include <stdlib.h>
"
" int	ft_is_sep(char c, char *charset)
" {
" 	int	i;
"
" 	i = 0;
" 	while (charset[i])
" 	{
" 		if (charset[i] == c)
" 			return (1);
" 		i++;
" 	}
" 	return (0);
" }
"
" int	ft_count_words(char *str, char *charset)
" {
" 	int	i;
" 	int	count;
"
" 	i = 0;
" 	count = 0;
" 	while (str[i])
" 	{
" 		while (str[i] && ft_is_sep(str[i], charset))
" 			i++;
" 		if (!str[i])
" 			return (count);
" 		count++;
" 		while (str[i] && !ft_is_sep(str[i], charset))
" 			i++;
" 	}
" 	return (count);
" }
"
" char	*ft_copy_word(char *start, int len)
" {
" 	char	*word;
" 	int		i;
"
" 	word = malloc(len + 1);
" 	if (!word)
" 		return (NULL);
" 	i = 0;
" 	while (i < len)
" 	{
" 		word[i] = start[i];
" 		i++;
" 	}
" 	word[i] = '\0';
" 	return (word);
" }
"
" int	ft_fill_words(char **res, char *str, char *charset)
" {
" 	int		i;
" 	int		j;
" 	int		start;
"
" 	i = 0;
" 	j = 0;
" 	while (str[i])
" 	{
" 		while (str[i] && ft_is_sep(str[i], charset))
" 			i++;
" 		if (!str[i])
" 			break ;
" 		start = i;
" 		while (str[i] && !ft_is_sep(str[i], charset))
" 			i++;
" 		res[j] = ft_copy_word(str + start, i - start);
" 		if (!res[j])
" 			return (0);
" 		j++;
" 	}
" 	res[j] = NULL;
" 	return (1);
" }
"
" char	**ft_split(char *str, char *charset)
" {
" 	char	**res;
"
" 	res = malloc((ft_count_words(str, charset) + 1) * sizeof(char *));
" 	if (!res)
" 		return (NULL);
" 	if (!ft_fill_words(res, str, charset))
" 		return (NULL);
" 	return (res);
" }
"
" ===== C08/ex04/ft_strs_to_tab.c =====
" #include <stdlib.h>
" #include "ft_stock_str.h"
"
" int	ft_strlen(char *str)
" {
" 	int	i;
"
" 	i = 0;
" 	while (str[i])
" 		i++;
" 	return (i);
" }
"
" char	*ft_strdup(char *src)
" {
" 	char	*copy;
" 	int		i;
"
" 	i = 0;
" 	copy = malloc(ft_strlen(src) + 1);
" 	if (copy == NULL)
" 		return (NULL);
" 	while (src[i])
" 	{
" 		copy[i] = src[i];
" 		i++;
" 	}
" 	copy[i] = src[i];
" 	return (copy);
" }
"
" void	ft_free_tab(t_stock_str *tab, int count)
" {
" 	int	i;
"
" 	i = 0;
" 	while (i < count)
" 	{
" 		free(tab[i].copy);
" 		i++;
" 	}
" 	free(tab);
" }
"
" struct s_stock_str	*ft_strs_to_tab(int ac, char **av)
" {
" 	int			i;
" 	t_stock_str	*tab;
"
" 	tab = malloc(sizeof(t_stock_str) * (ac + 1));
" 	if (!tab)
" 		return (NULL);
" 	i = 0;
" 	while (i < ac)
" 	{
" 		tab[i].size = ft_strlen(av[i]);
" 		tab[i].str = av[i];
" 		tab[i].copy = ft_strdup(av[i]);
" 		if (!tab[i].copy)
" 		{
" 			ft_free_tab(tab, i);
" 			return (NULL);
" 		}
" 		i++;
" 	}
" 	tab[ac].str = 0;
" 	return (tab);
" }
"
" ===== C08/ex05/ft_show_tab.c =====
" #include "ft_stock_str.h"
" #include <unistd.h>
"
" void	ft_putstr(char *str)
" {
" 	int	i;
"
" 	i = 0;
" 	while (str[i])
" 	{
" 		write(1, &str[i], 1);
" 		i++;
" 	}
" 	write(1, "\n", 1);
" }
"
" void	ft_putnbr(int n)
" {
" 	char	c;
"
" 	if (n >= 10)
" 		ft_putnbr(n / 10);
" 	c = n % 10 + '0';
" 	write(1, &c, 1);
" }
"
" void	ft_show_tab(struct s_stock_str *par)
" {
" 	int	i;
"
" 	i = 0;
" 	while (par[i].str != 0)
" 	{
" 		ft_putstr(par[i].str);
" 		ft_putnbr(par[i].size);
" 		write(1, "\n", 1);
" 		ft_putstr(par[i].copy);
" 		i++;
" 	}
" }
"
" ===== C09/ex00/ft_putchar.c =====
" #include <unistd.h>
"
" void	ft_putchar(char c)
" {
" 	write(1, &c, 1);
" }
"
" ===== C09/ex00/ft_putstr.c =====
" #include <unistd.h>
"
" void	ft_putstr(char *str)
" {
" 	while (*str)
" 	{
" 		write(1, str, 1);
" 		str++;
" 	}
" }
"
" ===== C09/ex00/ft_strcmp.c =====
" int	ft_strcmp(char *s1, char *s2)
" {
" 	while (*s1 || *s2)
" 	{
" 		if (*s1 != *s2)
" 			return ((unsigned char) *s1 - (unsigned char) *s2);
" 		s1++;
" 		s2++;
" 	}
" 	return (0);
" }
"
" ===== C09/ex00/ft_strlen.c =====
" int	ft_strlen(char *str)
" {
" 	int	i;
"
" 	i = 0;
" 	while (str[i])
" 		i++;
" 	return (i);
" }
"
" ===== C09/ex00/ft_swap.c =====
" void	ft_swap(int *a, int *b)
" {
" 	int	temp;
"
" 	temp = *a;
" 	*a = *b;
" 	*b = temp;
" }
"
" ===== C09/ex01/srcs/ft_putchar.c =====
" #include <unistd.h>
"
" void	ft_putchar(char c)
" {
" 	write(1, &c, 1);
" }
"
" ===== C09/ex01/srcs/ft_putstr.c =====
" #include <unistd.h>
"
" void	ft_putstr(char *str)
" {
" 	while (*str)
" 	{
" 		write(1, str, 1);
" 		str++;
" 	}
" }
"
" ===== C09/ex01/srcs/ft_strcmp.c =====
" int	ft_strcmp(char *s1, char *s2)
" {
" 	while (*s1 || *s2)
" 	{
" 		if (*s1 != *s2)
" 			return ((unsigned char) *s1 - (unsigned char) *s2);
" 		s1++;
" 		s2++;
" 	}
" 	return (0);
" }
"
" ===== C09/ex01/srcs/ft_strlen.c =====
" int	ft_strlen(char *str)
" {
" 	int	i;
"
" 	i = 0;
" 	while (str[i])
" 		i++;
" 	return (i);
" }
"
" ===== C09/ex01/srcs/ft_swap.c =====
" void	ft_swap(int *a, int *b)
" {
" 	int	temp;
"
" 	temp = *a;
" 	*a = *b;
" 	*b = temp;
" }
"
" ===== C09/ex02/ft_split.c =====
" #include <stdlib.h>
"
" int	ft_is_sep(char c, char *charset)
" {
" 	int	i;
"
" 	i = 0;
" 	while (charset[i])
" 	{
" 		if (charset[i] == c)
" 			return (1);
" 		i++;
" 	}
" 	return (0);
" }
"
" int	ft_count_words(char *str, char *charset)
" {
" 	int	i;
" 	int	count;
"
" 	i = 0;
" 	count = 0;
" 	while (str[i])
" 	{
" 		while (str[i] && ft_is_sep(str[i], charset))
" 			i++;
" 		if (!str[i])
" 			return (count);
" 		count++;
" 		while (str[i] && !ft_is_sep(str[i], charset))
" 			i++;
" 	}
" 	return (count);
" }
"
" char	*ft_copy_word(char *start, int len)
" {
" 	char	*word;
" 	int		i;
"
" 	word = malloc(len + 1);
" 	if (!word)
" 		return (NULL);
" 	i = 0;
" 	while (i < len)
" 	{
" 		word[i] = start[i];
" 		i++;
" 	}
" 	word[i] = '\0';
" 	return (word);
" }
"
" int	ft_fill_words(char **res, char *str, char *charset)
" {
" 	int		i;
" 	int		j;
" 	int		start;
"
" 	i = 0;
" 	j = 0;
" 	while (str[i])
" 	{
" 		while (str[i] && ft_is_sep(str[i], charset))
" 			i++;
" 		if (!str[i])
" 			break ;
" 		start = i;
" 		while (str[i] && !ft_is_sep(str[i], charset))
" 			i++;
" 		res[j] = ft_copy_word(str + start, i - start);
" 		if (!res[j])
" 			return (0);
" 		j++;
" 	}
" 	res[j] = NULL;
" 	return (1);
" }
"
" char	**ft_split(char *str, char *charset)
" {
" 	char	**res;
"
" 	res = malloc((ft_count_words(str, charset) + 1) * sizeof(char *));
" 	if (!res)
" 		return (NULL);
" 	if (!ft_fill_words(res, str, charset))
" 		return (NULL);
" 	return (res);
" }
"
" ===== C11/ex00/ft_foreach.c =====
" void	ft_foreach(int *tab, int length, void (*f)(int))
" {
" 	int	i;
"
" 	i = 0;
" 	while (i < length)
" 	{
" 		f(tab[i]);
" 		i++;
" 	}
" }
"
" ===== C11/ex01/ft_map.c =====
" #include <stdlib.h>
"
" int	*ft_map(int *tab, int length, int (*f)(int))
" {
" 	int	i;
" 	int	*res;
"
" 	i = 0;
" 	res = malloc(length * sizeof(int));
" 	if (!res)
" 		return (NULL);
" 	while (i < length)
" 	{
" 		res[i] = f(tab[i]);
" 		i++;
" 	}
" 	return (res);
" }
"
" ===== C11/ex02/ft_any.c =====
" #include <stddef.h>
"
" int	ft_any(char **tab, int (*f)(char*))
" {
" 	int	i;
"
" 	i = 0;
" 	while (tab[i] != NULL)
" 	{
" 		if (f(tab[i]) != 0)
" 			return (1);
" 		i++;
" 	}
" 	return (0);
" }
"
" ===== C11/ex03/ft_count_if.c =====
" int	ft_count_if(char **tab, int length, int (*f)(char*))
" {
" 	int	i;
" 	int	count;
"
" 	i = 0;
" 	count = 0;
" 	while (i < length)
" 	{
" 		if (f(tab[i]) != 0)
" 			count++;
" 		i++;
" 	}
" 	return (count);
" }
"
" ===== C11/ex04/ft_is_sort.c =====
" int	ft_is_sort(int *tab, int length, int (*f)(int, int))
" {
" 	int	i;
" 	int	direction;
" 	int	fres;
"
" 	i = 0;
" 	direction = 0;
" 	if (length <= 1)
" 		return (1);
" 	while (i + 1 < length)
" 	{
" 		fres = f(tab[i], tab[i + 1]);
" 		if ((direction == -1 && fres < 0) || (direction == 1 && fres > 0))
" 			return (0);
" 		if (fres < 0)
" 			direction = 1;
" 		else if (fres > 0)
" 			direction = -1;
" 		i++;
" 	}
" 	return (1);
" }
"
" ===== C11/ex05/do_op.c =====
" #include "do_op.h"
"
" t_op	ft_get_op(char *str)
" {
" 	if (!str[0] || str[1] != '\0')
" 		return (OP_INV);
" 	if (str[0] == '+')
" 		return (OP_ADD);
" 	else if (str[0] == '-')
" 		return (OP_SUB);
" 	else if (str[0] == '/')
" 		return (OP_DIV);
" 	else if (str[0] == '*')
" 		return (OP_MUL);
" 	else if (str[0] == '%')
" 		return (OP_MOD);
" 	return (OP_INV);
" }
"
" int	ft_check_error(t_op op, int b)
" {
" 	if ((op == OP_DIV || op == OP_MOD) && b == 0)
" 	{
" 		if (op == OP_DIV)
" 			write(1, "Stop : division by zero\n", 24);
" 		else if (op == OP_MOD)
" 			write(1, "Stop : modulo by zero\n", 22);
" 		return (1);
" 	}
" 	return (0);
" }
"
" int	ft_execute(t_op op, int a, int b)
" {
" 	int		(*operations[5])(int, int);
"
" 	operations[OP_ADD] = ft_add;
" 	operations[OP_SUB] = ft_sub;
" 	operations[OP_MUL] = ft_mult;
" 	operations[OP_DIV] = ft_div;
" 	operations[OP_MOD] = ft_mod;
" 	return (operations[op](a, b));
" }
"
" int	main(int argc, char **argv)
" {
" 	t_op	op;
" 	int		a;
" 	int		b;
"
" 	if (argc == 4)
" 	{
" 		op = ft_get_op(argv[2]);
" 		if (op == OP_INV)
" 		{
" 			write(1, "0\n", 2);
" 			return (1);
" 		}
" 		a = ft_atoi(argv[1]);
" 		b = ft_atoi(argv[3]);
" 		if (ft_check_error(op, b))
" 			return (1);
" 		ft_putnbr(ft_execute(op, a, b));
" 		write(1, "\n", 1);
" 	}
" 	return (0);
" }
"
" ===== C11/ex05/ft_atoi.c =====
" char	*ft_skip_space(char *str)
" {
" 	while (*str == ' ' || (*str >= 9 && *str <= 13))
" 		str++;
" 	return (str);
" }
"
" char	*ft_skip_sign(char *str)
" {
" 	while (*str == '-' || *str == '+')
" 		str++;
" 	return (str);
" }
"
" int	ft_sign_number(char *str)
" {
" 	char	*s;
" 	int		sign;
" 	int		i;
"
" 	s = ft_skip_space(str);
" 	sign = 1;
" 	i = 0;
" 	while (s[i] == '+' || s[i] == '-')
" 	{
" 		if (s[i] == '-')
" 			sign *= -1;
" 		i++;
" 	}
" 	return (sign);
" }
"
" int	ft_atoi(char *str)
" {
" 	int		sign;
" 	long	res;
" 	char	*s;
"
" 	sign = ft_sign_number(str);
" 	res = 0;
" 	s = ft_skip_space(str);
" 	s = ft_skip_sign(s);
" 	while (*s >= '0' && *s <= '9')
" 	{
" 		res = res * 10 + (*s - '0');
" 		s++;
" 	}
" 	res *= sign;
" 	return (res);
" }
"
" ===== C11/ex05/ft_ops.c =====
" #include "do_op.h"
"
" int	ft_add(int a, int b)
" {
" 	return (a + b);
" }
"
" int	ft_sub(int a, int b)
" {
" 	return (a - b);
" }
"
" int	ft_div(int a, int b)
" {
" 	return (a / b);
" }
"
" int	ft_mult(int a, int b)
" {
" 	return (a * b);
" }
"
" int	ft_mod(int a, int b)
" {
" 	return (a % b);
" }
"
" ===== C11/ex05/ft_putnbr.c =====
" #include <unistd.h>
"
" void	ft_putnbr(int nb)
" {
" 	long	n;
" 	char	c;
"
" 	n = nb;
" 	if (nb < 0)
" 	{
" 		write(1, "-", 1);
" 		n = -n;
" 	}
" 	c = n % 10 + '0';
" 	if (n >= 10)
" 		ft_putnbr(n / 10);
" 	write(1, &c, 1);
" }
"
" ===== C11/ex06/ft_sort_string_tab.c =====
" int	ft_strcmp(char *s1, char *s2)
" {
" 	while (*s1 || *s2)
" 	{
" 		if (*s1 != *s2)
" 			return ((unsigned char) *s1 - (unsigned char) *s2);
" 		s1++;
" 		s2++;
" 	}
" 	return (0);
" }
"
" void	ft_sort_string_tab(char **tab)
" {
" 	int		i;
" 	int		swapped;
" 	char	*str;
"
" 	i = 0;
" 	swapped = 1;
" 	while (swapped)
" 	{
" 		i = 0;
" 		swapped = 0;
" 		while (tab[i] && tab[i + 1])
" 		{
" 			if (ft_strcmp(tab[i], tab[i + 1]) > 0)
" 			{
" 				str = *(tab + i);
" 				*(tab + i) = *(tab + i + 1);
" 				*(tab + i + 1) = str;
" 				swapped = 1;
" 			}
" 			i++;
" 		}
" 	}
" }
"
" ===== C11/ex07/ft_advanced_sort_string_tab.c =====
" void	ft_advanced_sort_string_tab(char **tab,
" 			int (*cmp)(char *, char *))
" {
" 	int		i;
" 	int		swapped;
" 	char	*str;
"
" 	i = 0;
" 	swapped = 1;
" 	while (swapped)
" 	{
" 		i = 0;
" 		swapped = 0;
" 		while (tab[i] && tab[i + 1])
" 		{
" 			if (cmp(tab[i], tab[i + 1]) > 0)
" 			{
" 				str = *(tab + i);
" 				*(tab + i) = *(tab + i + 1);
" 				*(tab + i + 1) = str;
" 				swapped = 1;
" 			}
" 			i++;
" 		}
" 	}
" }
" ===== END USER C00-C11 FUNCTIONS =====
