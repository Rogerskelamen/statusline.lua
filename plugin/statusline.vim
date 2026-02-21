   "_____  ______    ___   ______   __  __   _____    __     ____    _   __    ______
  "/ ___/ /_  __/   /   | /_  __/  / / / /  / ___/   / /    /  _/   / | / /   / ____/
  "\__ \   / /     / /| |  / /    / / / /   \__ \   / /     / /    /  |/ /   / __/
 "___/ /  / /     / ___ | / /    / /_/ /   ___/ /  / /___ _/ /    / /|  /   / /___
"/____/  /_/     /_/  |_|/_/     \____/   /____/  /_____//___/   /_/ |_/   /_____/

function! Scrollbar() abort
    let width = 9
    let perc = (line('.') - 1.0) / (max([line('$'), 2]) - 1.0)
    let before = float2nr(round(perc * (width - 3)))
    let after = width - 3 - before
    return '[' . repeat(' ',  before) . '=' . repeat(' ', after) . ']'
endfunction

