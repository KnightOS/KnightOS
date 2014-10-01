showlist:
    libkpm(getPackageList)
    ; TODO
    libkpm(freePackageList)

    pcall(clearBuffer)
    kld(hl, todo)
    ld de, 0
    pcall(drawStr)
    pcall(fastCopy)
    pcall(flushKeys)
    pcall(waitKey)
    ret

todo:
    .db "TODO", 0
