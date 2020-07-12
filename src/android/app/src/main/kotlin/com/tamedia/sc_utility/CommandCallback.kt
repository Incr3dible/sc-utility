package com.tamedia.sc_utility

interface CommandCallback {
    open fun onCommandResultAvailable(cr: String?)
}