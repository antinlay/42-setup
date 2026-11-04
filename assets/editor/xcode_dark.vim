" Xcode-inspired dark palette, with truecolor and 256-color fallbacks.
set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "xcode_dark"
highlight Normal term=NONE cterm=NONE gui=NONE guifg=#DFDFE0 guibg=NONE ctermfg=253 ctermbg=NONE
highlight Comment term=NONE cterm=NONE gui=NONE guifg=#7F8C98 guibg=NONE ctermfg=102 ctermbg=NONE
highlight Constant term=NONE cterm=NONE gui=NONE guifg=#D0BF69 guibg=NONE ctermfg=179 ctermbg=NONE
highlight String term=NONE cterm=NONE gui=NONE guifg=#FC6A5D guibg=NONE ctermfg=203 ctermbg=NONE
highlight Character term=NONE cterm=NONE gui=NONE guifg=#FC6A5D guibg=NONE ctermfg=203 ctermbg=NONE
highlight Number term=NONE cterm=NONE gui=NONE guifg=#D0BF69 guibg=NONE ctermfg=179 ctermbg=NONE
highlight Boolean term=NONE cterm=NONE gui=NONE guifg=#FC5FA3 guibg=NONE ctermfg=205 ctermbg=NONE
highlight Statement term=NONE cterm=NONE gui=NONE guifg=#FC5FA3 guibg=NONE ctermfg=205 ctermbg=NONE
highlight Keyword term=NONE cterm=NONE gui=NONE guifg=#FC5FA3 guibg=NONE ctermfg=205 ctermbg=NONE
highlight Type term=NONE cterm=NONE gui=NONE guifg=#FC5FA3 guibg=NONE ctermfg=205 ctermbg=NONE
highlight StorageClass term=NONE cterm=NONE gui=NONE guifg=#FC5FA3 guibg=NONE ctermfg=205 ctermbg=NONE
highlight Structure term=NONE cterm=NONE gui=NONE guifg=#FC5FA3 guibg=NONE ctermfg=205 ctermbg=NONE
highlight Typedef term=NONE cterm=NONE gui=NONE guifg=#FC5FA3 guibg=NONE ctermfg=205 ctermbg=NONE
highlight PreProc term=NONE cterm=NONE gui=NONE guifg=#FD8F3F guibg=NONE ctermfg=209 ctermbg=NONE
highlight Include term=NONE cterm=NONE gui=NONE guifg=#FD8F3F guibg=NONE ctermfg=209 ctermbg=NONE
highlight Define term=NONE cterm=NONE gui=NONE guifg=#FD8F3F guibg=NONE ctermfg=209 ctermbg=NONE
highlight Identifier guifg=#DFDFE0 guibg=NONE gui=NONE ctermfg=253 ctermbg=NONE cterm=NONE
highlight Function term=NONE cterm=NONE gui=NONE guifg=#67B7A4 guibg=NONE ctermfg=73 ctermbg=NONE
highlight Operator guifg=#DFDFE0 guibg=NONE gui=NONE ctermfg=253 ctermbg=NONE cterm=NONE
highlight Special guifg=#D0BF69 guibg=NONE gui=NONE ctermfg=179 ctermbg=NONE cterm=NONE
highlight Delimiter guifg=#DFDFE0 guibg=NONE gui=NONE ctermfg=253 ctermbg=NONE cterm=NONE
highlight LineNr term=NONE cterm=NONE gui=NONE guifg=#777984 guibg=NONE ctermfg=243 ctermbg=NONE
highlight CursorLineNr term=NONE cterm=NONE gui=NONE guifg=#DFDFE0 guibg=NONE ctermfg=253 ctermbg=NONE
highlight CursorLine term=NONE cterm=NONE gui=NONE guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE
highlight ColorColumn term=NONE cterm=NONE gui=NONE guifg=#565862 guibg=NONE ctermfg=240 ctermbg=NONE
highlight SignColumn term=NONE cterm=NONE gui=NONE guifg=#565862 guibg=NONE ctermfg=240 ctermbg=NONE
highlight VertSplit term=NONE cterm=NONE gui=NONE guifg=#565862 guibg=NONE ctermfg=240 ctermbg=NONE
highlight StatusLine term=bold cterm=bold gui=bold guifg=#DFDFE0 guibg=NONE ctermfg=253 ctermbg=NONE
highlight StatusLineNC term=NONE cterm=NONE gui=NONE guifg=#777984 guibg=NONE ctermfg=243 ctermbg=NONE
highlight Visual term=NONE cterm=NONE gui=NONE guifg=NONE guibg=#454F68 ctermfg=NONE ctermbg=60
highlight Search guifg=#292A30 guibg=#D0BF69 gui=NONE ctermfg=236 ctermbg=179 cterm=NONE
highlight IncSearch guifg=#292A30 guibg=#FD8F3F gui=NONE ctermfg=236 ctermbg=209 cterm=NONE
highlight MatchParen term=underline cterm=underline gui=underline guifg=#5DD8FF guibg=NONE ctermfg=81 ctermbg=NONE
highlight Pmenu guifg=#DFDFE0 guibg=#363740 gui=NONE ctermfg=253 ctermbg=237 cterm=NONE
highlight PmenuSel guifg=#FFFFFF guibg=#536579 gui=NONE ctermfg=231 ctermbg=60 cterm=NONE
highlight PmenuSbar guifg=NONE guibg=#41434E gui=NONE ctermfg=NONE ctermbg=238 cterm=NONE
highlight PmenuThumb guifg=NONE guibg=#777984 gui=NONE ctermfg=NONE ctermbg=243 cterm=NONE
highlight NonText term=NONE cterm=NONE gui=NONE guifg=#565862 guibg=NONE ctermfg=240 ctermbg=NONE
highlight SpecialKey term=NONE cterm=NONE gui=NONE guifg=#565862 guibg=NONE ctermfg=240 ctermbg=NONE
highlight Directory guifg=#5DD8FF guibg=NONE gui=NONE ctermfg=81 ctermbg=NONE cterm=NONE
highlight Error guifg=#FFFFFF guibg=#A43A3A gui=NONE ctermfg=231 ctermbg=124 cterm=NONE
highlight ErrorMsg guifg=#FC6A5D guibg=NONE gui=NONE ctermfg=203 ctermbg=NONE cterm=NONE
highlight WarningMsg guifg=#D0BF69 guibg=NONE gui=NONE ctermfg=179 ctermbg=NONE cterm=NONE
highlight Todo guifg=#D0BF69 guibg=#363740 gui=NONE ctermfg=179 ctermbg=237 cterm=NONE
highlight DiffAdd guifg=NONE guibg=#30453B gui=NONE ctermfg=NONE ctermbg=22 cterm=NONE
highlight DiffDelete guifg=#FC6A5D guibg=#503338 gui=NONE ctermfg=203 ctermbg=52 cterm=NONE
highlight DiffChange guifg=NONE guibg=#354151 gui=NONE ctermfg=NONE ctermbg=24 cterm=NONE
highlight DiffText guifg=NONE guibg=#495B74 gui=NONE ctermfg=NONE ctermbg=60 cterm=NONE
highlight Folded guifg=#9699A3 guibg=#32333B gui=NONE ctermfg=246 ctermbg=237 cterm=NONE
highlight FoldColumn term=NONE cterm=NONE gui=NONE guifg=#565862 guibg=NONE ctermfg=240 ctermbg=NONE
highlight WildMenu guifg=#FFFFFF guibg=#536579 gui=NONE ctermfg=231 ctermbg=60 cterm=NONE
highlight NormalNC term=NONE cterm=NONE gui=NONE guifg=#565862 guibg=NONE ctermfg=240 ctermbg=NONE
highlight EndOfBuffer term=NONE cterm=NONE gui=NONE guifg=#565862 guibg=NONE ctermfg=240 ctermbg=NONE
highlight PreCondit term=NONE cterm=NONE gui=NONE guifg=#FD8F3F guibg=NONE ctermfg=209 ctermbg=NONE
highlight Macro term=NONE cterm=NONE gui=NONE guifg=#FD8F3F guibg=NONE ctermfg=209 ctermbg=NONE
highlight Float term=NONE cterm=NONE gui=NONE guifg=#D0BF69 guibg=NONE ctermfg=179 ctermbg=NONE
