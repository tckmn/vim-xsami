" vim-xsami - automatic X-SAMPA to IPA translation
" Copyright (C) 2018  KeyboardFire <andy@keyboardfire.com>

" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.

" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.

" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <http://www.gnu.org/licenses/>.

let g:xsami_trigger = get(g:, 'xsami_trigger', '<C-l>')

" >>> d = dict(zip(xsIn, ipaOut)); d.update((x, d.get(x[:-1], x[:-1])+x[-1]) for x in map(lambda x: x[:-1], xsIn) if x and x not in xsIn); d[''] = ''; print('{'+','.join("'{}':'{}'".format(k.replace("'", "''"),d[k]) for k in d)+'}')
let s:data = {'_R_F':'᷈','J\_<':'ʄ','_H_T':'᷄','G\_<':'ʛ','_B_L':'᷅','|\|\':'ǁ','r\`':'ɻ','<R>':'↗','g_<':'ɠ','<F>':'↘','d_<':'ɗ','b_<':'ɓ','_?\':'ˤ','z\':'ʑ','z`':'ʐ','X\':'ħ','x\':'ɧ','_x':'̽','_X':'̆','_w':'ʷ','v\':'ʋ','_v':'̬','U\':'ᵿ','t`':'ʈ','_t':'̤','_T':'̋','s\':'ɕ','s`':'ʂ','r\':'ɹ','r`':'ɽ','_r':'̝','R\':'ʀ','_R':'̌','_q':'̙','p\':'ɸ','_o':'̞','O\':'ʘ','_O':'̹','n`':'ɳ','_n':'ⁿ','N\':'ɴ','_N':'̼','_m':'̻','M\':'ɰ','_M':'̄','l\':'ɺ','l`':'ɭ','_l':'ˡ','L\':'ʟ','_L':'̀','_k':'̰','K\':'ɮ','j\':'ʝ','_j':'ʲ','J\':'ɟ','I\':'ᵻ','h\':'ɦ','_h':'ʰ','H\':'ʜ','_H':'́','G\':'ɢ','_G':'ˠ','_F':'̂','_e':'̴','d`':'ɖ','_d':'̪','_c':'̜','B\':'ʙ','_B':'̏','_a':'̺','_A':'̘','3\':'ɞ','_0':'̥','@\':'ɘ','?\':'ʕ','!\':'ǃ',':\':'ˑ','-\':'‿','_+':'̟','_\':'̂','_}':'̚','_"':'̈','_/':'̌','_-':'̠','_>':'ʼ','_=':'̩','_~':'̃','_^':'̯','|\':'ǀ','||':'‖','>\':'ʡ','=\':'ǂ','<\':'ʢ','Z':'ʒ','z':'z','y':'y','Y':'ʏ','X':'χ','x':'x','w':'w','W':'ʍ','v':'v','V':'ʌ','u':'u','U':'ʊ','T':'θ','t':'t','s':'s','S':'ʃ','r':'r','R':'ʁ','q':'q','Q':'ɒ','p':'p','P':'ʋ','O':'ɔ','o':'o','N':'ŋ','n':'n','m':'m','M':'ɯ','l':'l','L':'ʎ','k':'k','K':'ɬ','j':'j','J':'ɲ','i':'i','I':'ɪ','h':'h','H':'ɥ','g':'ɡ','G':'ɣ','f':'f','F':'ɱ','E':'ɛ','e':'e','@':'ə','D':'ð','d':'d','C':'ç','c':'c','B':'β','b':'b','{':'æ','a':'a','A':'ɑ','9':'œ','8':'ɵ','7':'ɤ','6':'ɐ','5':'ɫ','4':'ɾ','3':'ɜ','2':'ø','1':'ɨ','%':'ˌ','&':'ɶ','}':'ʉ','"':'ˈ','''':'ʲ','.':'.','?':'ʔ','!':'ꜜ',':':'ː','|':'|','=':'̩','~':'̃','^':'ꜛ','`':'˞','_R_':'̌_','J\_':'ɟ_','_H_':'́_','G\_':'ɢ_','_B_':'̏_','|\|':'ǀ|','<R':'<R','g_':'ɡ_','<F':'<F','d_':'d_','b_':'b_','_?':'_?','_':'_','-':'-','>':'>','<':'<','':''}
let s:enabled = 0
let s:buf = ''

function! <SID>xsami()
    let s:enabled = !s:enabled
    return ''
endfunction

let s:pause = 0
function! <SID>inserthook()
    if !s:enabled | return | endif

    " if the keys are part of an IPA result, pass them through
    " this is terminated with an asterisk (*), which isn't in IPA
    if s:pause
        if v:char ==# '*'
            let s:pause = 0
            let &l:delcombine = s:delcombine
            let v:char = ''
        endif
        return
    endif

    if has_key(s:data, s:buf.v:char)
        " this XSAMPA sequence is valid IPA, so insert it
        let s:pause = 1
        let s:delcombine = &l:delcombine
        setl delcombine
        call feedkeys(repeat("\<bs>", strchars(s:data[s:buf])))
        let s:buf .= v:char
        call feedkeys(s:data[s:buf] . '*')
        let v:char = ''
    elseif len(s:buf)
        " finalize the previous sequence and start a new one
        let s:buf = ''
        call <SID>inserthook()
    endif
endfunction

function! <SID>reset()
    let s:enabled = 0
    let s:buf = ''
endfunction

augroup xsami
    autocmd!
    autocmd InsertCharPre * call <SID>inserthook()
    autocmd InsertLeave * call <SID>reset()
augroup END

imap <script> <expr> <Plug>xsami <SID>xsami()
if !hasmapto('<Plug>xsami')
    execute 'imap <unique> ' . g:xsami_trigger . ' <Plug>xsami'
endif
